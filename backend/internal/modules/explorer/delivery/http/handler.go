package http

import (
	"encoding/json"
	"strconv"

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
	// Raw OpenDota passthrough for the API-test page (choose stats responsibly).
	group.GET("/dota/raw/:steam_id/:resource", handler.Raw)
}

func (h *Handler) Raw(c *gin.Context) {
	limit, _ := strconv.Atoi(c.Query("limit"))
	raw, err := h.service.Raw(c.Request.Context(), c.Param("steam_id"), c.Param("resource"), limit)
	if err != nil {
		response.Error(c, err)
		return
	}
	response.OK(c, json.RawMessage(raw))
}

func (h *Handler) Explore(c *gin.Context) {
	result, err := h.service.Explore(c.Request.Context(), c.Param("steam_id"))
	if err != nil {
		response.Error(c, err)
		return
	}
	response.OK(c, result)
}
