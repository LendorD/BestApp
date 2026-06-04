package http

import "github.com/gin-gonic/gin"

func RegisterRoutes(group *gin.RouterGroup, handler *Handler) {
	jobs := group.Group("/jobs")
	jobs.POST("", handler.CreateJob)
	jobs.GET("/:job_id", handler.GetJob)
}
