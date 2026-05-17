package handler

import (
	"gamementor/internal/delivery/http/response"
	"gamementor/internal/domain"
	"gamementor/internal/usecase"

	"github.com/gin-gonic/gin"
)

type UserHandler struct {
	usecase *usecase.UserUsecase
}

func NewUserHandler(usecase *usecase.UserUsecase) *UserHandler {
	return &UserHandler{usecase: usecase}
}

func (h *UserHandler) Register(c *gin.Context) {
	var input domain.RegisterUserInput
	if err := c.ShouldBindJSON(&input); err != nil {
		response.BadRequest(c, "invalid json body")
		return
	}

	auth, err := h.usecase.Register(c.Request.Context(), input)
	if err != nil {
		response.Error(c, err)
		return
	}
	response.Created(c, auth)
}

func (h *UserHandler) Login(c *gin.Context) {
	var input domain.LoginUserInput
	if err := c.ShouldBindJSON(&input); err != nil {
		response.BadRequest(c, "invalid json body")
		return
	}

	auth, err := h.usecase.Login(c.Request.Context(), input)
	if err != nil {
		response.Error(c, err)
		return
	}
	response.OK(c, auth)
}

func (h *UserHandler) GetProfile(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}

	user, err := h.usecase.GetProfile(c.Request.Context(), id)
	if err != nil {
		response.Error(c, err)
		return
	}
	response.OK(c, user)
}

func (h *UserHandler) UpdateProfile(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}

	var input domain.UpdateUserProfileInput
	if err := c.ShouldBindJSON(&input); err != nil {
		response.BadRequest(c, "invalid json body")
		return
	}

	user, err := h.usecase.UpdateProfile(c.Request.Context(), id, input)
	if err != nil {
		response.Error(c, err)
		return
	}
	response.OK(c, user)
}
