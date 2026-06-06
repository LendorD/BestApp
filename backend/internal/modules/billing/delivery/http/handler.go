package http

import (
	"gamementor/internal/delivery/http/middleware"
	"gamementor/internal/delivery/http/response"
	"gamementor/internal/domain"
	billingapp "gamementor/internal/modules/billing/application"
	billingdomain "gamementor/internal/modules/billing/domain"

	"github.com/gin-gonic/gin"
)

type Handler struct {
	service *billingapp.Service
}

func NewHandler(service *billingapp.Service) *Handler {
	return &Handler{service: service}
}

// RegisterRoutes wires public plans plus protected subscription routes.
func RegisterRoutes(group *gin.RouterGroup, handler *Handler, authRequired gin.HandlerFunc) {
	billing := group.Group("/billing")
	billing.GET("/plans", handler.Plans)
	if authRequired != nil {
		secured := billing.Group("")
		secured.Use(authRequired)
		secured.GET("/subscription", handler.GetSubscription)
		secured.POST("/subscribe", handler.Subscribe)
		secured.POST("/cancel", handler.Cancel)
	}
}

func (h *Handler) Plans(c *gin.Context) {
	response.OK(c, gin.H{"plans": h.service.Plans()})
}

func (h *Handler) GetSubscription(c *gin.Context) {
	userID, ok := middleware.CurrentUserID(c)
	if !ok {
		response.Error(c, domain.Unauthorized("not authenticated"))
		return
	}
	sub, err := h.service.GetSubscription(c.Request.Context(), userID)
	if err != nil {
		response.Error(c, err)
		return
	}
	response.OK(c, sub)
}

func (h *Handler) Subscribe(c *gin.Context) {
	userID, ok := middleware.CurrentUserID(c)
	if !ok {
		response.Error(c, domain.Unauthorized("not authenticated"))
		return
	}
	var body struct {
		Plan string `json:"plan"`
	}
	if err := c.ShouldBindJSON(&body); err != nil {
		response.BadRequest(c, "invalid json body")
		return
	}
	sub, err := h.service.Subscribe(c.Request.Context(), userID, billingdomain.PlanID(body.Plan))
	if err != nil {
		response.Error(c, err)
		return
	}
	response.OK(c, sub)
}

func (h *Handler) Cancel(c *gin.Context) {
	userID, ok := middleware.CurrentUserID(c)
	if !ok {
		response.Error(c, domain.Unauthorized("not authenticated"))
		return
	}
	sub, err := h.service.Cancel(c.Request.Context(), userID)
	if err != nil {
		response.Error(c, err)
		return
	}
	response.OK(c, sub)
}
