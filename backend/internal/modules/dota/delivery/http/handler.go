package http

import (
	"errors"
	"net/http"
	"strconv"

	"gamementor/internal/delivery/http/response"
	"gamementor/internal/domain"
	dotaapp "gamementor/internal/modules/dota/application"
	dotadomain "gamementor/internal/modules/dota/domain"

	"github.com/gin-gonic/gin"
)

type Handler struct {
	service *dotaapp.Service
}

func NewHandler(service *dotaapp.Service) *Handler {
	return &Handler{service: service}
}

func (h *Handler) GetPlayerProfile(c *gin.Context) {
	profile, err := h.service.GetPlayerProfile(c.Request.Context(), c.Param("steam_id"))
	if err != nil {
		writeError(c, err)
		return
	}
	response.OK(c, profile)
}

func (h *Handler) GetRecentMatches(c *gin.Context) {
	limit := parseLimit(c, 50)
	matches, err := h.service.GetRecentMatches(c.Request.Context(), c.Param("steam_id"), limit)
	if err != nil {
		writeError(c, err)
		return
	}
	response.OK(c, matches)
}

func (h *Handler) GetHeroStats(c *gin.Context) {
	heroes, err := h.service.GetHeroStats(c.Request.Context(), c.Param("steam_id"), dotaapp.HeroStatsFilter{
		Limit: parseLimit(c, 0),
	})
	if err != nil {
		writeError(c, err)
		return
	}
	response.OK(c, heroes)
}

func parseLimit(c *gin.Context, fallback int) int {
	raw := c.Query("limit")
	if raw == "" {
		return fallback
	}
	limit, err := strconv.Atoi(raw)
	if err != nil || limit < 0 {
		return fallback
	}
	return limit
}

func writeError(c *gin.Context, err error) {
	switch {
	case errors.Is(err, dotadomain.ErrInvalidSteamID):
		response.BadRequest(c, err.Error())
	case errors.Is(err, dotadomain.ErrProviderDisabled):
		c.JSON(http.StatusBadGateway, response.Body{
			Success: false,
			Error: &response.ErrorBody{
				Code:    "provider_disabled",
				Message: err.Error(),
			},
		})
	default:
		response.Error(c, domain.ExternalError(err.Error()))
	}
}
