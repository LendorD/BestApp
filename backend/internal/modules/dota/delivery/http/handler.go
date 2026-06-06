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

// ---- player endpoints: data via dota usecase -> provider ----

func (h *Handler) GetPlayerProfile(c *gin.Context) {
	profile, err := h.service.GetPlayerProfile(c.Request.Context(), c.Param("steam_id"))
	if err != nil {
		writeError(c, err)
		return
	}
	response.OK(c, profile)
}

func (h *Handler) GetRecentMatches(c *gin.Context) {
	matches, err := h.service.GetRecentMatches(c.Request.Context(), c.Param("steam_id"), parseLimit(c, 50))
	if err != nil {
		writeError(c, err)
		return
	}
	response.OK(c, matches)
}

func (h *Handler) GetHeroStats(c *gin.Context) {
	heroes, err := h.service.GetHeroStats(c.Request.Context(), c.Param("steam_id"), dotaapp.HeroStatsFilter{Limit: parseLimit(c, 0)})
	if err != nil {
		writeError(c, err)
		return
	}
	response.OK(c, heroes)
}

// ---- lab / analytics endpoints: data via dota usecase -> statistics service ----

func (h *Handler) GetLabDashboard(c *gin.Context) {
	period, role := labQuery(c)
	dashboard, err := h.service.LabDashboard(c.Request.Context(), c.Param("steam_id"), period, role)
	if err != nil {
		writeError(c, err)
		return
	}
	response.OK(c, dashboard)
}

func (h *Handler) GetLabProComparison(c *gin.Context) {
	period, role := labQuery(c)
	dashboard, err := h.service.LabDashboard(c.Request.Context(), c.Param("steam_id"), period, role)
	if err != nil {
		writeError(c, err)
		return
	}
	response.OK(c, dashboard.ProComparison)
}

func (h *Handler) GetLabHeroes(c *gin.Context) {
	period, role := labQuery(c)
	dashboard, err := h.service.LabDashboard(c.Request.Context(), c.Param("steam_id"), period, role)
	if err != nil {
		writeError(c, err)
		return
	}
	response.OK(c, dashboard.HeroPerformance)
}

func (h *Handler) GetLabForm(c *gin.Context) {
	period, role := labQuery(c)
	dashboard, err := h.service.LabDashboard(c.Request.Context(), c.Param("steam_id"), period, role)
	if err != nil {
		writeError(c, err)
		return
	}
	response.OK(c, dashboard.FormTimeline)
}

func (h *Handler) GetLabWeaknesses(c *gin.Context) {
	period, role := labQuery(c)
	dashboard, err := h.service.LabDashboard(c.Request.Context(), c.Param("steam_id"), period, role)
	if err != nil {
		writeError(c, err)
		return
	}
	response.OK(c, dashboard.Weaknesses)
}

func (h *Handler) GetLabAICoachPreview(c *gin.Context) {
	period, role := labQuery(c)
	dashboard, err := h.service.LabDashboard(c.Request.Context(), c.Param("steam_id"), period, role)
	if err != nil {
		writeError(c, err)
		return
	}
	response.OK(c, dashboard.AICoach)
}

func (h *Handler) RefreshLab(c *gin.Context) {
	period, role := labQuery(c)
	dashboard, err := h.service.RefreshLab(c.Request.Context(), c.Param("steam_id"), period, role)
	if err != nil {
		writeError(c, err)
		return
	}
	response.OK(c, dashboard)
}

func labQuery(c *gin.Context) (string, string) {
	return c.DefaultQuery("period", "30d"), c.DefaultQuery("role", "all")
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
			Error:   &response.ErrorBody{Code: "provider_disabled", Message: err.Error()},
		})
	default:
		response.Error(c, domain.ExternalError(err.Error()))
	}
}
