package http

import (
	"gamementor/internal/delivery/http/response"
	explorerapp "gamementor/internal/modules/explorer/application"

	"github.com/gin-gonic/gin"
)

type Handler struct {
	service *explorerapp.Service
}

func NewHandler(service *explorerapp.Service) *Handler {
	return &Handler{service: service}
}

func RegisterRoutes(group *gin.RouterGroup, handler *Handler) {
	group.GET("/dota/explorer/:steam_id", handler.Explore)
}

func (h *Handler) Explore(c *gin.Context) {
	result, err := h.service.Explore(c.Request.Context(), c.Param("steam_id"))
	if err != nil {
		response.Error(c, err)
		return
	}
	response.OK(c, result)
}
