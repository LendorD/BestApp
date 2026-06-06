package http

import (
	"gamementor/internal/domain"
	"gamementor/internal/delivery/http/middleware"
	"gamementor/internal/delivery/http/response"
	authapp "gamementor/internal/modules/auth/application"
	usersdomain "gamementor/internal/modules/users/domain"

	"github.com/gin-gonic/gin"
)

// Handler serves authentication endpoints (register/login/me). It delegates to
// the auth application service, which issues JWT tokens.
type Handler struct {
	auth *authapp.Service
}

func NewHandler(auth *authapp.Service) *Handler {
	return &Handler{auth: auth}
}

// RegisterRoutes wires public auth routes plus the protected /auth/me route.
func RegisterRoutes(group *gin.RouterGroup, handler *Handler, authRequired gin.HandlerFunc) {
	auth := group.Group("/auth")
	auth.POST("/register", handler.Register)
	auth.POST("/login", handler.Login)
	if authRequired != nil {
		auth.GET("/me", authRequired, handler.Me)
	}
}

func (h *Handler) Register(c *gin.Context) {
	var input usersdomain.RegisterUserInput
	if err := c.ShouldBindJSON(&input); err != nil {
		response.BadRequest(c, "invalid json body")
		return
	}
	result, err := h.auth.Register(c.Request.Context(), input)
	if err != nil {
		response.Error(c, err)
		return
	}
	response.Created(c, result)
}

func (h *Handler) Login(c *gin.Context) {
	var input usersdomain.LoginUserInput
	if err := c.ShouldBindJSON(&input); err != nil {
		response.BadRequest(c, "invalid json body")
		return
	}
	result, err := h.auth.Login(c.Request.Context(), input)
	if err != nil {
		response.Error(c, err)
		return
	}
	response.OK(c, result)
}

func (h *Handler) Me(c *gin.Context) {
	userID, ok := middleware.CurrentUserID(c)
	if !ok {
		response.Error(c, domain.Unauthorized("not authenticated"))
		return
	}
	user, err := h.auth.Me(c.Request.Context(), userID)
	if err != nil {
		response.Error(c, err)
		return
	}
	response.OK(c, user)
}
