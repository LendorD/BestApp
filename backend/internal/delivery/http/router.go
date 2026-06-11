package httpdelivery

import (
	"log/slog"
	"net/http"

	"gamementor/internal/delivery/http/middleware"
	aicoachhttp "gamementor/internal/modules/ai_coach/delivery/http"
	authhttp "gamementor/internal/modules/auth/delivery/http"
	billinghttp "gamementor/internal/modules/billing/delivery/http"
	cs2http "gamementor/internal/modules/cs2/delivery/http"
	dotahttp "gamementor/internal/modules/dota/delivery/http"
	explorerhttp "gamementor/internal/modules/explorer/delivery/http"
	metricshttp "gamementor/internal/modules/metrics/delivery/http"
	identityhttp "gamementor/internal/modules/identity/delivery/http"
	jobshttp "gamementor/internal/modules/jobs/delivery/http"
	usershttp "gamementor/internal/modules/users/delivery/http"

	"github.com/gin-gonic/gin"
)

// RouterHandlers carries every module's HTTP handler. The router only wires
// modules; it contains no business logic.
type RouterHandlers struct {
	CS2            *cs2http.Handler
	Users          *usershttp.Handler
	Auth           *authhttp.Handler
	Billing        *billinghttp.Handler
	Dota           *dotahttp.Handler
	Explorer       *explorerhttp.Handler
	Metrics        *metricshttp.Handler
	AICoach        *aicoachhttp.Handler
	Identity       *identityhttp.Handler
	Jobs           *jobshttp.Handler
	AuthMiddleware gin.HandlerFunc
	ProMiddleware  gin.HandlerFunc
}

func NewRouter(log *slog.Logger, handlers RouterHandlers) *gin.Engine {
	gin.SetMode(gin.ReleaseMode)

	router := gin.New()
	router.Use(gin.Recovery())
	router.Use(middleware.CORS())
	router.Use(middleware.RequestID())
	router.Use(middleware.Logger(log))

	router.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"success": true, "data": gin.H{"status": "ok"}})
	})
	router.GET("/swagger", func(c *gin.Context) { c.File("./docs/swagger.html") })
	router.GET("/swagger/openapi.yaml", func(c *gin.Context) { c.File("./docs/openapi.yaml") })

	// Per-IP rate limit: protects OpenDota free-tier quotas and AI tokens.
	// Sustained ~2 req/s with a burst of 20 covers normal dashboard loads.
	api := router.Group("/api/v1", middleware.RateLimit(2, 20))
	api.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"success": true, "data": gin.H{"status": "ok"}})
	})

	if handlers.Auth != nil {
		authhttp.RegisterRoutes(api, handlers.Auth, handlers.AuthMiddleware)
	}
	if handlers.Users != nil {
		usershttp.RegisterRoutes(api, handlers.Users, handlers.AuthMiddleware)
	}
	if handlers.Billing != nil {
		billinghttp.RegisterRoutes(api, handlers.Billing, handlers.AuthMiddleware)
	}
	if handlers.CS2 != nil {
		cs2http.RegisterRoutes(api, handlers.CS2)
	}
	if handlers.Dota != nil {
		dotahttp.RegisterRoutes(api, handlers.Dota)
	}
	if handlers.Explorer != nil {
		explorerhttp.RegisterRoutes(api, handlers.Explorer)
	}
	if handlers.Metrics != nil {
		metricshttp.RegisterRoutes(api, handlers.Metrics)
	}
	if handlers.AICoach != nil {
		aicoachhttp.RegisterRoutes(api, handlers.AICoach, handlers.AuthMiddleware, handlers.ProMiddleware)
	}
	if handlers.Identity != nil {
		identityhttp.RegisterRoutes(api, handlers.Identity)
	}
	if handlers.Jobs != nil {
		jobshttp.RegisterRoutes(api, handlers.Jobs)
	}

	return router
}
