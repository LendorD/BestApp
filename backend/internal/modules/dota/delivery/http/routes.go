package http

import "github.com/gin-gonic/gin"

func RegisterRoutes(group *gin.RouterGroup, handler *Handler) {
	dota := group.Group("/dota")
	dota.GET("/player/:steam_id/profile", handler.GetPlayerProfile)
	dota.GET("/player/:steam_id/matches", handler.GetRecentMatches)
	dota.GET("/player/:steam_id/heroes", handler.GetHeroStats)
}
