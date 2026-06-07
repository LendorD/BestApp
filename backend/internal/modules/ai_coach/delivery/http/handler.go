package http

import (
	"errors"
	stdhttp "net/http"

	"gamementor/internal/delivery/http/response"
	aicoachapp "gamementor/internal/modules/ai_coach/application"
	coachdomain "gamementor/internal/modules/ai_coach/domain"

	"github.com/gin-gonic/gin"
)

type Handler struct {
	service *aicoachapp.Service
}

func NewHandler(service *aicoachapp.Service) *Handler {
	return &Handler{service: service}
}

func (h *Handler) ReviewDotaPlayer(c *gin.Context) {
	// Optional body: { "focus": "..." } from the coach survey.
	var body struct {
		Focus string `json:"focus"`
	}
	_ = c.ShouldBindJSON(&body)
	report, err := h.service.ReviewDotaPlayer(c.Request.Context(), c.Param("steam_id"), body.Focus)
	if err != nil {
		writeError(c, err)
		return
	}
	response.OK(c, report)
}

func (h *Handler) ReviewDotaMatch(c *gin.Context) {
	report, err := h.service.ReviewDotaMatch(c.Request.Context(), c.Query("steam_id"), c.Param("match_id"))
	if err != nil {
		writeError(c, err)
		return
	}
	response.OK(c, report)
}

func (h *Handler) LatestDotaReport(c *gin.Context) {
	report, err := h.service.LatestDotaReport(c.Request.Context(), c.Param("steam_id"))
	if err != nil {
		writeError(c, err)
		return
	}
	response.OK(c, report)
}

func (h *Handler) GetReport(c *gin.Context) {
	report, err := h.service.GetReport(c.Request.Context(), c.Param("report_id"))
	if err != nil {
		writeError(c, err)
		return
	}
	response.OK(c, report)
}

func writeError(c *gin.Context, err error) {
	switch {
	case errors.Is(err, coachdomain.ErrInvalidCoachInput):
		response.BadRequest(c, err.Error())
	case errors.Is(err, coachdomain.ErrReportNotFound):
		c.JSON(stdhttp.StatusNotFound, response.Body{
			Success: false,
			Error:   &response.ErrorBody{Code: "not_found", Message: err.Error()},
		})
	case aicoachapp.IsProviderDisabled(err):
		c.JSON(stdhttp.StatusBadGateway, response.Body{
			Success: false,
			Error:   &response.ErrorBody{Code: "provider_disabled", Message: err.Error()},
		})
	default:
		response.Error(c, err)
	}
}
