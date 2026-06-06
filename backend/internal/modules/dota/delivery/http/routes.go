package http

import "github.com/gin-gonic/gin"

// RegisterRoutes mounts all Dota endpoints. Player data comes from the dota
// usecase; lab/analytics data is delegated by the usecase to the statistics service.
func RegisterRoutes(group *gin.RouterGroup, handler *Handler) {
	player := group.Group("/dota/player/:steam_id")
	player.GET("/profile", handler.GetPlayerProfile)
	player.GET("/matches", handler.GetRecentMatches)
	player.GET("/heroes", handler.GetHeroStats)

	lab := group.Group("/dota/lab/players/:steam_id")
	lab.GET("/dashboard", handler.GetLabDashboard)
	lab.GET("/pro-comparison", handler.GetLabProComparison)
	lab.GET("/heroes", handler.GetLabHeroes)
	lab.GET("/form", handler.GetLabForm)
	lab.GET("/weaknesses", handler.GetLabWeaknesses)
	lab.GET("/ai-coach-preview", handler.GetLabAICoachPreview)
	lab.POST("/refresh", handler.RefreshLab)
}
