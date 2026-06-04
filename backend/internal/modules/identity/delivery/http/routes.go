package http

import "github.com/gin-gonic/gin"

func RegisterRoutes(group *gin.RouterGroup, handler *Handler) {
	identity := group.Group("/identity")
	identity.POST("/dota/resolve", handler.ResolveDotaAccount)
}
