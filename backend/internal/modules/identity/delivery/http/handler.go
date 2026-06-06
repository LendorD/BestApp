package http

import (
	"gamementor/internal/delivery/http/response"
	identityapp "gamementor/internal/modules/identity/application"

	"github.com/gin-gonic/gin"
)

type Handler struct {
	service *identityapp.Service
}

func NewHandler(service *identityapp.Service) *Handler {
	return &Handler{service: service}
}

func (h *Handler) ResolveDotaAccount(c *gin.Context) {
	var input identityapp.ResolveDotaAccountInput
	if err := c.ShouldBindJSON(&input); err != nil {
		response.BadRequest(c, "invalid json body")
		return
	}

	result, err := h.service.ResolveDotaAccountAuto(c.Request.Context(), input.Input)
	if err != nil {
		response.Error(c, err)
		return
	}
	response.OK(c, result)
}
