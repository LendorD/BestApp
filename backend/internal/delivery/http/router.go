package httpdelivery

import (
	"log/slog"
	"net/http"

	"gamementor/internal/delivery/http/handler"
	"gamementor/internal/delivery/http/middleware"
	aicoachhttp "gamementor/internal/modules/ai_coach/delivery/http"
	analyticshttp "gamementor/internal/modules/analytics/delivery/http"
	identityhttp "gamementor/internal/modules/identity/delivery/http"
	jobshttp "gamementor/internal/modules/jobs/delivery/http"

	"github.com/gin-gonic/gin"
)

type RouterHandlers struct {
	CS2       *handler.CS2Handler
	User      *handler.UserHandler
	Analytics *analyticshttp.Handler
	AICoach   *aicoachhttp.Handler
	Identity  *identityhttp.Handler
	Jobs      *jobshttp.Handler
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

	router.GET("/swagger", func(c *gin.Context) {
		c.File("./docs/swagger.html")
	})
	router.GET("/swagger/openapi.yaml", func(c *gin.Context) {
		c.File("./docs/openapi.yaml")
	})

	api := router.Group("/api/v1")
	api.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"success": true, "data": gin.H{"status": "ok"}})
	})

	auth := api.Group("/auth")
	auth.POST("/register", handlers.User.Register)
	auth.POST("/login", handlers.User.Login)

	users := api.Group("/users")
	users.GET("/:id/profile", handlers.User.GetProfile)
	users.PUT("/:id/profile", handlers.User.UpdateProfile)

	cs2 := api.Group("/cs2")
	cs2.GET("/maps", handlers.CS2.ListMaps)
	cs2.POST("/grenades", handlers.CS2.CreateGrenade)
	cs2.GET("/grenades", handlers.CS2.ListGrenades)
	cs2.GET("/grenades/:id", handlers.CS2.GetGrenade)
	cs2.PUT("/grenades/:id", handlers.CS2.UpdateGrenade)
	cs2.DELETE("/grenades/:id", handlers.CS2.DeleteGrenade)

	if handlers.Analytics != nil {
		analyticshttp.RegisterRoutes(api, handlers.Analytics)
	}
	if handlers.AICoach != nil {
		aicoachhttp.RegisterRoutes(api, handlers.AICoach)
	}
	if handlers.Identity != nil {
		identityhttp.RegisterRoutes(api, handlers.Identity)
	}
	if handlers.Jobs != nil {
		jobshttp.RegisterRoutes(api, handlers.Jobs)
	}

	return router
}
