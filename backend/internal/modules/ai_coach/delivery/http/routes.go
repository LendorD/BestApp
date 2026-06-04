package http

import "github.com/gin-gonic/gin"

func RegisterRoutes(group *gin.RouterGroup, handler *Handler) {
	coach := group.Group("/ai-coach/dota")
	coach.POST("/player/:steam_id/review", handler.ReviewDotaPlayer)
	coach.GET("/player/:steam_id/latest", handler.LatestDotaReport)
	coach.GET("/reports/:report_id", handler.GetReport)
}
