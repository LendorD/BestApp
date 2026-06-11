package http

import "github.com/gin-gonic/gin"

// RegisterRoutes mounts the AI coach endpoints.
// Token-burning POST endpoints (review generation) are gated: auth is always
// required, and the pro (subscription) middleware is applied when provided.
// Read-only GETs stay public so cached reports render without a session.
func RegisterRoutes(group *gin.RouterGroup, handler *Handler, auth gin.HandlerFunc, pro gin.HandlerFunc) {
	coach := group.Group("/ai-coach/dota")
	coach.GET("/player/:steam_id/latest", handler.LatestDotaReport)
	coach.GET("/reports/:report_id", handler.GetReport)

	gated := []gin.HandlerFunc{}
	if auth != nil {
		gated = append(gated, auth)
	}
	if pro != nil {
		gated = append(gated, pro)
	}
	coach.POST("/player/:steam_id/review", append(gated, handler.ReviewDotaPlayer)...)
	coach.POST("/match/:match_id/review", append(gated, handler.ReviewDotaMatch)...)
}
