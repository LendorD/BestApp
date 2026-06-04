package http

import "github.com/gin-gonic/gin"

func RegisterRoutes(group *gin.RouterGroup, handler *Handler) {
	lab := group.Group("/dota/lab/players/:steam_id")
	lab.GET("/dashboard", handler.GetDotaLabDashboard)
	lab.GET("/pro-comparison", handler.GetDotaLabProComparison)
	lab.GET("/heroes", handler.GetDotaLabHeroes)
	lab.GET("/form", handler.GetDotaLabForm)
	lab.GET("/weaknesses", handler.GetDotaLabWeaknesses)
	lab.GET("/ai-coach-preview", handler.GetDotaLabAICoachPreview)
	lab.POST("/refresh", handler.RefreshDotaLabDashboard)
}
