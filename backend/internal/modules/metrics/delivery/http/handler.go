package http

import (
	"strconv"

	"gamementor/internal/delivery/http/response"
	metricsapp "gamementor/internal/modules/metrics/application"

	"github.com/gin-gonic/gin"
)

type Handler struct {
	service *metricsapp.Service
}

func NewHandler(service *metricsapp.Service) *Handler {
	return &Handler{service: service}
}

func RegisterRoutes(group *gin.RouterGroup, handler *Handler) {
	// GET /dota/metrics/:steam_id?days=30&limit=50
	group.GET("/dota/metrics/:steam_id", handler.Metrics)
}

func (h *Handler) Metrics(c *gin.Context) {
	days, _ := strconv.Atoi(c.Query("days"))
	limit, _ := strconv.Atoi(c.Query("limit"))
	report, err := h.service.Build(c.Request.Context(), c.Param("steam_id"), days, limit)
	if err != nil {
		response.Error(c, err)
		return
	}
	response.OK(c, report)
}
