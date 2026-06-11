package app

import (
	"context"
	"log/slog"

	"gamementor/internal/clients/opendota"
	steamclient "gamementor/internal/clients/steam"
	stratzclient "gamementor/internal/clients/stratz"
	"gamementor/internal/config"
	httpdelivery "gamementor/internal/delivery/http"
	"gamementor/internal/delivery/http/middleware"
	aicoachapp "gamementor/internal/modules/ai_coach/application"
	aicoachhttp "gamementor/internal/modules/ai_coach/delivery/http"
	aicoachdisabled "gamementor/internal/modules/ai_coach/infrastructure/ai_client/disabled"
	aicoachopenai "gamementor/internal/modules/ai_coach/infrastructure/ai_client/openai"
	aicoachenrich "gamementor/internal/modules/ai_coach/infrastructure/enrich"
	aicoachmemoryrepo "gamementor/internal/modules/ai_coach/infrastructure/repository/memory"
	authapp "gamementor/internal/modules/auth/application"
	authhttp "gamementor/internal/modules/auth/delivery/http"
	billingapp "gamementor/internal/modules/billing/application"
	billinghttp "gamementor/internal/modules/billing/delivery/http"
	billingrepo "gamementor/internal/modules/billing/infrastructure/repository/postgres"
	cs2app "gamementor/internal/modules/cs2/application"
	cs2http "gamementor/internal/modules/cs2/delivery/http"
	cs2repo "gamementor/internal/modules/cs2/infrastructure/repository/postgres"
	explorerapp "gamementor/internal/modules/explorer/application"
	explorerhttp "gamementor/internal/modules/explorer/delivery/http"
	metricsapp "gamementor/internal/modules/metrics/application"
	metricshttp "gamementor/internal/modules/metrics/delivery/http"
	dotaapp "gamementor/internal/modules/dota/application"
	dotahttp "gamementor/internal/modules/dota/delivery/http"
	dotaopendota "gamementor/internal/modules/dota/infrastructure/provider/opendota"
	identityapp "gamementor/internal/modules/identity/application"
	identityhttp "gamementor/internal/modules/identity/delivery/http"
	jobsapp "gamementor/internal/modules/jobs/application"
	jobshttp "gamementor/internal/modules/jobs/delivery/http"
	jobsdomain "gamementor/internal/modules/jobs/domain"
	jobsmemoryrepo "gamementor/internal/modules/jobs/infrastructure/repository/memory"
	statisticsapp "gamementor/internal/modules/statistics/application"
	usersapp "gamementor/internal/modules/users/application"
	usershttp "gamementor/internal/modules/users/delivery/http"
	usersrepo "gamementor/internal/modules/users/infrastructure/repository/postgres"
	platformcache "gamementor/internal/platform/cache"

	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5/pgxpool"
)

type Modules struct {
	CS2Handler      *cs2http.Handler
	UsersHandler    *usershttp.Handler
	AuthHandler     *authhttp.Handler
	BillingHandler  *billinghttp.Handler
	DotaHandler     *dotahttp.Handler
	ExplorerHandler *explorerhttp.Handler
	MetricsHandler  *metricshttp.Handler
	AICoachHandler  *aicoachhttp.Handler
	IdentityHandler *identityhttp.Handler
	JobsHandler     *jobshttp.Handler
	JobsService     *jobsapp.Service
	AuthMiddleware  gin.HandlerFunc
	ProMiddleware   gin.HandlerFunc
}

// tokenParserAdapter lets the JWT TokenManager satisfy the delivery
// middleware.TokenParser port without the middleware importing the auth module.
type tokenParserAdapter struct {
	tm *authapp.TokenManager
}

func (a tokenParserAdapter) ParseClaims(token string) (middleware.TokenClaims, error) {
	claims, err := a.tm.Parse(token)
	if err != nil {
		return nil, err
	}
	return claims, nil
}

func NewModules(cfg *config.Config, pool *pgxpool.Pool, cacheStore platformcache.Cache, log *slog.Logger) *Modules {
	// --- repositories (infrastructure) ---
	cs2Repository := cs2repo.NewRepository(pool)
	userRepository := usersrepo.NewRepository(pool)
	billingRepository := billingrepo.NewRepository(pool)

	// --- external clients / providers ---
	openDotaClient := opendota.NewClient(cfg.OpenDotaBaseURL, cfg.OpenDotaTimeout)
	steamClient := steamclient.NewClient(cfg.SteamAPIKey, cfg.OpenDotaTimeout)
	stratzClient := stratzclient.NewClient(cfg.StratzAPIKey, cfg.AITimeout)
	dotaProvider := dotaopendota.New(openDotaClient)

	// --- application services ---
	cs2Service := cs2app.NewService(cs2Repository)
	usersService := usersapp.NewService(userRepository)
	tokenManager := authapp.NewTokenManager(cfg.JWTSecret, cfg.JWTTTL)
	authService := authapp.NewService(usersService, tokenManager)
	authMiddleware := middleware.AuthRequired(tokenParserAdapter{tm: tokenManager})
	billingService := billingapp.NewService(billingRepository)
	proMiddleware := middleware.ProRequired(billingService)
	dotaService := dotaapp.NewService(dotaProvider, dotaProvider, cacheStore)
	statisticsService := statisticsapp.NewService(dotaService, cacheStore)
	dotaService.SetStatistics(statisticsService)
	identityService := identityapp.NewService(steamClient)
	explorerService := explorerapp.NewService(openDotaClient, stratzClient)
	metricsService := metricsapp.NewService(openDotaClient, stratzClient)

	// Pick a real LLM client when configured, otherwise the disabled stub.
	var aiClient aicoachapp.AIClient
	if openaiClient := aicoachopenai.New(cfg.AIProvider, cfg.AIAPIKey, cfg.AIModel, cfg.AIBaseURL, cfg.AITimeout); openaiClient.Enabled() {
		aiClient = openaiClient
		log.Info("ai coach enabled", "provider", cfg.AIProvider, "model", cfg.AIModel)
	} else {
		aiClient = aicoachdisabled.New(cfg.AIProvider, cfg.AIAPIKey, cfg.AIModel)
		log.Info("ai coach disabled: set AI_PROVIDER, AI_API_KEY and AI_MODEL to enable")
	}

	enricher := aicoachenrich.New(openDotaClient, cfg.StratzAPIKey, cfg.AITimeout)
	aiCoachService := aicoachapp.NewService(statisticsService, aiClient, aicoachmemoryrepo.New(), cacheStore)
	aiCoachService.SetEnricher(enricher)
	aiCoachService.SetMetrics(metricsService)

	var jobsService *jobsapp.Service
	var jobsHandler *jobshttp.Handler
	if cfg.JobsEnabled {
		jobsService = jobsapp.NewService(jobsmemoryrepo.New(), log)
		registerJobHandlers(jobsService, dotaService, statisticsService, aiCoachService)
		jobsHandler = jobshttp.NewHandler(jobsService)
	} else {
		log.Info("jobs module disabled by config")
	}

	return &Modules{
		CS2Handler:      cs2http.NewHandler(cs2Service),
		UsersHandler:    usershttp.NewHandler(usersService),
		AuthHandler:     authhttp.NewHandler(authService),
		BillingHandler:  billinghttp.NewHandler(billingService),
		DotaHandler:     dotahttp.NewHandler(dotaService),
		ExplorerHandler: explorerhttp.NewHandler(explorerService),
		MetricsHandler:  metricshttp.NewHandler(metricsService),
		AICoachHandler:  aicoachhttp.NewHandler(aiCoachService),
		IdentityHandler: identityhttp.NewHandler(identityService),
		JobsHandler:     jobsHandler,
		JobsService:     jobsService,
		AuthMiddleware:  authMiddleware,
		ProMiddleware:   proMiddleware,
	}
}

func (m *Modules) RouterHandlers() httpdelivery.RouterHandlers {
	return httpdelivery.RouterHandlers{
		CS2:            m.CS2Handler,
		Users:          m.UsersHandler,
		Auth:           m.AuthHandler,
		Billing:        m.BillingHandler,
		Dota:           m.DotaHandler,
		Explorer:       m.ExplorerHandler,
		Metrics:        m.MetricsHandler,
		AICoach:        m.AICoachHandler,
		Identity:       m.IdentityHandler,
		Jobs:           m.JobsHandler,
		AuthMiddleware: m.AuthMiddleware,
		ProMiddleware:  m.ProMiddleware,
	}
}

func registerJobHandlers(
	jobs *jobsapp.Service,
	dota *dotaapp.Service,
	statistics *statisticsapp.Service,
	aiCoach *aicoachapp.Service,
) {
	jobs.Register(jobsdomain.JobTypeRefreshPlayerStats, func(ctx context.Context, payload jobsdomain.JobPayload) (map[string]any, error) {
		steamID := payload.String("steam_id")
		matches, err := dota.GetRecentMatches(ctx, steamID, 50)
		if err != nil {
			return nil, err
		}
		return map[string]any{"steam_id": steamID, "matches": len(matches)}, nil
	})
	jobs.Register(jobsdomain.JobTypeBuildAnalyticsSnapshot, func(ctx context.Context, payload jobsdomain.JobPayload) (map[string]any, error) {
		steamID := payload.String("steam_id")
		snapshot, err := statistics.RefreshDotaSnapshot(ctx, steamID)
		if err != nil {
			return nil, err
		}
		return map[string]any{"steam_id": steamID, "snapshot": snapshot.Normalized}, nil
	})
	jobs.Register(jobsdomain.JobTypeGenerateAICoachReport, func(ctx context.Context, payload jobsdomain.JobPayload) (map[string]any, error) {
		steamID := payload.String("steam_id")
		report, err := aiCoach.ReviewDotaPlayer(ctx, steamID, "")
		if err != nil {
			return nil, err
		}
		return map[string]any{"steam_id": steamID, "report_id": report.ID}, nil
	})
	jobs.Register(jobsdomain.JobTypeUpdateHeroMeta, func(ctx context.Context, payload jobsdomain.JobPayload) (map[string]any, error) {
		_ = ctx
		return map[string]any{
			"source": payload.String("source"),
			"status": "queued for future provider implementation",
		}, nil
	})
}
