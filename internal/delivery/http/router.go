package httpdelivery

import (
	"log/slog"
	"net/http"

	"gamementor/internal/delivery/http/handler"
	"gamementor/internal/delivery/http/middleware"

	"github.com/gin-gonic/gin"
)

func NewRouter(log *slog.Logger, cs2Handler *handler.CS2Handler, dotaHandler *handler.DotaHandler) *gin.Engine {
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

	cs2 := api.Group("/cs2")
	cs2.GET("/maps", cs2Handler.ListMaps)
	cs2.POST("/grenades", cs2Handler.CreateGrenade)
	cs2.GET("/grenades", cs2Handler.ListGrenades)
	cs2.GET("/grenades/:id", cs2Handler.GetGrenade)
	cs2.PUT("/grenades/:id", cs2Handler.UpdateGrenade)
	cs2.DELETE("/grenades/:id", cs2Handler.DeleteGrenade)

	dota := api.Group("/dota")
	dota.GET("/players/:account_id", dotaHandler.GetPlayer)
	dota.GET("/players/:account_id/matches", dotaHandler.GetMatches)
	dota.GET("/players/:account_id/summary", dotaHandler.GetSummary)

	return router
}
