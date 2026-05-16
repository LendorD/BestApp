package handler

import (
	"strconv"

	"gamementor/internal/delivery/http/response"
	"gamementor/internal/usecase"

	"github.com/gin-gonic/gin"
)

type DotaHandler struct {
	usecase *usecase.DotaUsecase
}

func NewDotaHandler(usecase *usecase.DotaUsecase) *DotaHandler {
	return &DotaHandler{usecase: usecase}
}

func (h *DotaHandler) GetPlayer(c *gin.Context) {
	accountID, ok := parseAccountID(c)
	if !ok {
		return
	}

	player, err := h.usecase.GetPlayer(c.Request.Context(), accountID)
	if err != nil {
		response.Error(c, err)
		return
	}
	response.OK(c, player)
}

func (h *DotaHandler) GetMatches(c *gin.Context) {
	accountID, ok := parseAccountID(c)
	if !ok {
		return
	}

	matches, err := h.usecase.GetRecentMatches(c.Request.Context(), accountID)
	if err != nil {
		response.Error(c, err)
		return
	}
	response.OK(c, matches)
}

func (h *DotaHandler) GetSummary(c *gin.Context) {
	accountID, ok := parseAccountID(c)
	if !ok {
		return
	}

	summary, err := h.usecase.GetSummary(c.Request.Context(), accountID)
	if err != nil {
		response.Error(c, err)
		return
	}
	response.OK(c, summary)
}

func parseAccountID(c *gin.Context) (int64, bool) {
	accountID, err := strconv.ParseInt(c.Param("account_id"), 10, 64)
	if err != nil || accountID <= 0 {
		response.BadRequest(c, "account_id must be positive integer")
		return 0, false
	}
	return accountID, true
}
