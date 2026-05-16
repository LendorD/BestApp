package response

import (
	"errors"
	"net/http"
	"strings"

	"gamementor/internal/domain"

	"github.com/gin-gonic/gin"
)

type Body struct {
	Success bool       `json:"success"`
	Data    any        `json:"data,omitempty"`
	Error   *ErrorBody `json:"error,omitempty"`
}

type ErrorBody struct {
	Code    string `json:"code"`
	Message string `json:"message"`
}

func OK(c *gin.Context, data any) {
	c.JSON(http.StatusOK, Body{Success: true, Data: data})
}

func Created(c *gin.Context, data any) {
	c.JSON(http.StatusCreated, Body{Success: true, Data: data})
}

func NoContent(c *gin.Context) {
	c.JSON(http.StatusOK, Body{Success: true, Data: gin.H{"deleted": true}})
}

func Error(c *gin.Context, err error) {
	status, code, message := classify(err)
	c.JSON(status, Body{
		Success: false,
		Error: &ErrorBody{
			Code:    code,
			Message: message,
		},
	})
}

func BadRequest(c *gin.Context, message string) {
	c.JSON(http.StatusBadRequest, Body{
		Success: false,
		Error: &ErrorBody{
			Code:    "bad_request",
			Message: message,
		},
	})
}

func classify(err error) (int, string, string) {
	message := cleanMessage(err)
	switch {
	case errors.Is(err, domain.ErrValidation):
		return http.StatusBadRequest, "validation_error", message
	case errors.Is(err, domain.ErrNotFound):
		return http.StatusNotFound, "not_found", message
	case errors.Is(err, domain.ErrExternal):
		return http.StatusBadGateway, "external_service_error", message
	default:
		return http.StatusInternalServerError, "internal_error", "internal server error"
	}
}

func cleanMessage(err error) string {
	if err == nil {
		return ""
	}
	message := err.Error()
	prefixes := []string{
		domain.ErrValidation.Error() + ": ",
		domain.ErrNotFound.Error() + ": ",
		domain.ErrExternal.Error() + ": ",
	}
	for _, prefix := range prefixes {
		message = strings.TrimPrefix(message, prefix)
	}
	return message
}
