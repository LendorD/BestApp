package http

import (
	stdhttp "net/http"
	"strconv"

	"gamementor/internal/delivery/http/middleware"
	"gamementor/internal/delivery/http/response"
	"gamementor/internal/domain"
	usersapp "gamementor/internal/modules/users/application"
	usersdomain "gamementor/internal/modules/users/domain"

	"github.com/gin-gonic/gin"
)

type Handler struct {
	service *usersapp.Service
}

func NewHandler(service *usersapp.Service) *Handler {
	return &Handler{service: service}
}

func RegisterRoutes(group *gin.RouterGroup, handler *Handler, authRequired gin.HandlerFunc) {
	users := group.Group("/users")
	// "me" routes operate on the authenticated user (id taken from the JWT).
	if authRequired != nil {
		me := users.Group("/me")
		me.Use(authRequired)
		me.GET("/profile", handler.GetMyProfile)
		me.PUT("/profile", handler.UpdateMyProfile)
	}
	users.GET("/:id/profile", handler.GetProfile)
	users.PUT("/:id/profile", handler.UpdateProfile)
}

func (h *Handler) GetMyProfile(c *gin.Context) {
	userID, ok := middleware.CurrentUserID(c)
	if !ok {
		response.Error(c, domain.Unauthorized("not authenticated"))
		return
	}
	user, err := h.service.GetProfile(c.Request.Context(), userID)
	if err != nil {
		response.Error(c, err)
		return
	}
	response.OK(c, user)
}

func (h *Handler) UpdateMyProfile(c *gin.Context) {
	userID, ok := middleware.CurrentUserID(c)
	if !ok {
		response.Error(c, domain.Unauthorized("not authenticated"))
		return
	}
	var input usersdomain.UpdateUserProfileInput
	if err := c.ShouldBindJSON(&input); err != nil {
		response.BadRequest(c, "invalid json body")
		return
	}
	user, err := h.service.UpdateProfile(c.Request.Context(), userID, input)
	if err != nil {
		response.Error(c, err)
		return
	}
	response.OK(c, user)
}

func (h *Handler) GetProfile(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}
	user, err := h.service.GetProfile(c.Request.Context(), id)
	if err != nil {
		response.Error(c, err)
		return
	}
	response.OK(c, user)
}

func (h *Handler) UpdateProfile(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}
	var input usersdomain.UpdateUserProfileInput
	if err := c.ShouldBindJSON(&input); err != nil {
		response.BadRequest(c, "invalid json body")
		return
	}
	user, err := h.service.UpdateProfile(c.Request.Context(), id, input)
	if err != nil {
		response.Error(c, err)
		return
	}
	response.OK(c, user)
}

func parseID(c *gin.Context) (int64, bool) {
	id, err := strconv.ParseInt(c.Param("id"), 10, 64)
	if err != nil || id <= 0 {
		c.JSON(stdhttp.StatusBadRequest, response.Body{
			Success: false,
			Error:   &response.ErrorBody{Code: "bad_request", Message: "id must be positive integer"},
		})
		return 0, false
	}
	return id, true
}
