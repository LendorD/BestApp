package app

import (
	"context"
	"log/slog"

	"gamementor/internal/clients/opendota"
	"gamementor/internal/config"
	httpdelivery "gamementor/internal/delivery/http"
	legacyhandler "gamementor/internal/delivery/http/handler"
	aicoachapp "gamementor/internal/modules/ai_coach/application"
	aicoachhttp "gamementor/internal/modules/ai_coach/delivery/http"
	aicoachdisabled "gamementor/internal/modules/ai_coach/infrastructure/ai_client/disabled"
	aicoachmemoryrepo "gamementor/internal/modules/ai_coach/infrastructure/repository/memory"
	analyticsapp "gamementor/internal/modules/analytics/application"
	analyticshttp "gamementor/internal/modules/analytics/delivery/http"
	dotaapp "gamementor/internal/modules/dota/application"
	dotaopendota "gamementor/internal/modules/dota/infrastructure/provider/opendota"
	identityapp "gamementor/internal/modules/identity/application"
	identityhttp "gamementor/internal/modules/identity/delivery/http"
	jobsapp "gamementor/internal/modules/jobs/application"
	jobshttp "gamementor/internal/modules/jobs/delivery/http"
	jobsdomain "gamementor/internal/modules/jobs/domain"
	jobsmemoryrepo "gamementor/internal/modules/jobs/infrastructure/repository/memory"
	platformcache "gamementor/internal/platform/cache"
	pgrepo "gamementor/internal/repository/postgres"
	"gamementor/internal/usecase"

	"github.com/jackc/pgx/v5/pgxpool"
)

type Modules struct {
	CS2Handler       *legacyhandler.CS2Handler
	UserHandler      *legacyhandler.UserHandler
	AnalyticsHandler *analyticshttp.Handler
	AICoachHandler   *aicoachhttp.Handler
	IdentityHandler  *identityhttp.Handler
	JobsHandler      *jobshttp.Handler
	JobsService      *jobsapp.Service
}

func NewModules(cfg *config.Config, pool *pgxpool.Pool, cacheStore platformcache.Cache, log *slog.Logger) *Modules {
	cs2Repo := pgrepo.NewCS2Repository(pool)
	userRepo := pgrepo.NewUserRepository(pool)

	openDotaClient := opendota.NewClient(cfg.OpenDotaBaseURL, cfg.OpenDotaTimeout)

	cs2UC := usecase.NewCS2Usecase(cs2Repo)
	userUC := usecase.NewUserUsecase(userRepo)

	dotaProvider := dotaopendota.New(openDotaClient)
	dotaService := dotaapp.NewService(dotaProvider, dotaProvider, cacheStore)
	analyticsService := analyticsapp.NewService(dotaService, cacheStore)
	identityService := identityapp.NewService()
	aiCoachService := aicoachapp.NewService(
		analyticsService,
		aicoachdisabled.New(cfg.AIProvider, cfg.AIAPIKey, cfg.AIModel),
		aicoachmemoryrepo.New(),
		cacheStore,
	)

	var jobsService *jobsapp.Service
	var jobsHandler *jobshttp.Handler
	if cfg.JobsEnabled {
		jobsService = jobsapp.NewService(jobsmemoryrepo.New(), log)
		registerJobHandlers(jobsService, dotaService, analyticsService, aiCoachService)
		jobsHandler = jobshttp.NewHandler(jobsService)
	} else {
		log.Info("jobs module disabled by config")
	}

	return &Modules{
		CS2Handler:       legacyhandler.NewCS2Handler(cs2UC),
		UserHandler:      legacyhandler.NewUserHandler(userUC),
		AnalyticsHandler: analyticshttp.NewHandler(analyticsService),
		AICoachHandler:   aicoachhttp.NewHandler(aiCoachService),
		IdentityHandler:  identityhttp.NewHandler(identityService),
		JobsHandler:      jobsHandler,
		JobsService:      jobsService,
	}
}

func (m *Modules) RouterHandlers() httpdelivery.RouterHandlers {
	return httpdelivery.RouterHandlers{
		CS2:       m.CS2Handler,
		User:      m.UserHandler,
		Analytics: m.AnalyticsHandler,
		AICoach:   m.AICoachHandler,
		Identity:  m.IdentityHandler,
		Jobs:      m.JobsHandler,
	}
}

func registerJobHandlers(
	jobs *jobsapp.Service,
	dota *dotaapp.Service,
	analytics *analyticsapp.Service,
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
		snapshot, err := analytics.RefreshDotaSnapshot(ctx, steamID)
		if err != nil {
			return nil, err
		}
		return map[string]any{"steam_id": steamID, "snapshot": snapshot.Normalized}, nil
	})
	jobs.Register(jobsdomain.JobTypeGenerateAICoachReport, func(ctx context.Context, payload jobsdomain.JobPayload) (map[string]any, error) {
		steamID := payload.String("steam_id")
		report, err := aiCoach.ReviewDotaPlayer(ctx, steamID)
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
