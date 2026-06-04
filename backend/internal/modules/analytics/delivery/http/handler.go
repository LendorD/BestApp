package http

import (
	"errors"
	"net/http"
	"strconv"
	"time"

	"gamementor/internal/delivery/http/response"
	"gamementor/internal/domain"
	analyticsapp "gamementor/internal/modules/analytics/application"
	dotadomain "gamementor/internal/modules/dota/domain"

	"github.com/gin-gonic/gin"
)

type Handler struct {
	service *analyticsapp.Service
}

func NewHandler(service *analyticsapp.Service) *Handler {
	return &Handler{service: service}
}

func (h *Handler) GetDotaPlayerAnalytics(c *gin.Context) {
	snapshot, err := h.service.BuildDotaSnapshot(c.Request.Context(), c.Param("steam_id"))
	if err != nil {
		writeAnalyticsError(c, err)
		return
	}
	response.OK(c, snapshot)
}

func (h *Handler) GetDotaLabDashboard(c *gin.Context) {
	dashboard, err := h.service.BuildDotaLabDashboard(c.Request.Context(), c.Param("steam_id"), parseLabQuery(c))
	if err != nil {
		writeAnalyticsError(c, err)
		return
	}
	response.OK(c, dashboard)
}

func (h *Handler) GetDotaLabProComparison(c *gin.Context) {
	dashboard, err := h.service.BuildDotaLabDashboard(c.Request.Context(), c.Param("steam_id"), parseLabQuery(c))
	if err != nil {
		writeAnalyticsError(c, err)
		return
	}
	response.OK(c, dashboard.ProComparison)
}

func (h *Handler) GetDotaLabHeroes(c *gin.Context) {
	dashboard, err := h.service.BuildDotaLabDashboard(c.Request.Context(), c.Param("steam_id"), parseLabQuery(c))
	if err != nil {
		writeAnalyticsError(c, err)
		return
	}
	response.OK(c, dashboard.HeroPerformance)
}

func (h *Handler) GetDotaLabForm(c *gin.Context) {
	dashboard, err := h.service.BuildDotaLabDashboard(c.Request.Context(), c.Param("steam_id"), parseLabQuery(c))
	if err != nil {
		writeAnalyticsError(c, err)
		return
	}
	response.OK(c, dashboard.FormTimeline)
}

func (h *Handler) GetDotaLabWeaknesses(c *gin.Context) {
	dashboard, err := h.service.BuildDotaLabDashboard(c.Request.Context(), c.Param("steam_id"), parseLabQuery(c))
	if err != nil {
		writeAnalyticsError(c, err)
		return
	}
	response.OK(c, dashboard.Weaknesses)
}

func (h *Handler) GetDotaLabAICoachPreview(c *gin.Context) {
	dashboard, err := h.service.BuildDotaLabDashboard(c.Request.Context(), c.Param("steam_id"), parseLabQuery(c))
	if err != nil {
		writeAnalyticsError(c, err)
		return
	}
	response.OK(c, dashboard.AICoach)
}

func (h *Handler) RefreshDotaLabDashboard(c *gin.Context) {
	dashboard, err := h.service.RefreshDotaLabDashboard(c.Request.Context(), c.Param("steam_id"), parseLabQuery(c))
	if err != nil {
		writeAnalyticsError(c, err)
		return
	}
	response.OK(c, dashboard)
}

func (h *Handler) GetDotaHeroAnalytics(c *gin.Context) {
	query, ok := parseHeroQuery(c)
	if !ok {
		return
	}
	heroes, err := h.service.GetHeroStats(c.Request.Context(), c.Param("steam_id"), query)
	if err != nil {
		writeAnalyticsError(c, err)
		return
	}
	response.OK(c, heroes)
}

func (h *Handler) RefreshDotaPlayerAnalytics(c *gin.Context) {
	snapshot, err := h.service.RefreshDotaSnapshot(c.Request.Context(), c.Param("steam_id"))
	if err != nil {
		writeAnalyticsError(c, err)
		return
	}
	response.OK(c, snapshot)
}

func parseLabQuery(c *gin.Context) analyticsapp.DotaLabQuery {
	return analyticsapp.DotaLabQuery{
		Period: c.DefaultQuery("period", "30d"),
		Role:   c.DefaultQuery("role", "all"),
	}
}

func parseHeroQuery(c *gin.Context) (analyticsapp.HeroStatsQuery, bool) {
	var query analyticsapp.HeroStatsQuery
	if raw := c.Query("from"); raw != "" {
		value, err := time.Parse("2006-01-02", raw)
		if err != nil {
			response.BadRequest(c, "from must use YYYY-MM-DD")
			return query, false
		}
		query.From = &value
	}
	if raw := c.Query("to"); raw != "" {
		value, err := time.Parse("2006-01-02", raw)
		if err != nil {
			response.BadRequest(c, "to must use YYYY-MM-DD")
			return query, false
		}
		query.To = &value
	}
	if raw := c.Query("min_matches"); raw != "" {
		value, err := strconv.Atoi(raw)
		if err != nil || value < 0 {
			response.BadRequest(c, "min_matches must be positive integer")
			return query, false
		}
		query.MinMatches = value
	}
	query.SortBy = c.DefaultQuery("sort_by", "games")
	switch query.SortBy {
	case "games", "winrate", "kda":
	default:
		response.BadRequest(c, "sort_by must be winrate, kda or games")
		return query, false
	}
	return query, true
}

func writeAnalyticsError(c *gin.Context, err error) {
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
