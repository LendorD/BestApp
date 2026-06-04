package http

import (
	"errors"
	stdhttp "net/http"

	"gamementor/internal/delivery/http/response"
	jobsapp "gamementor/internal/modules/jobs/application"
	jobsdomain "gamementor/internal/modules/jobs/domain"

	"github.com/gin-gonic/gin"
)

type Handler struct {
	service *jobsapp.Service
}

func NewHandler(service *jobsapp.Service) *Handler {
	return &Handler{service: service}
}

func (h *Handler) CreateJob(c *gin.Context) {
	var input jobsapp.CreateJobInput
	if err := c.ShouldBindJSON(&input); err != nil {
		response.BadRequest(c, "invalid json body")
		return
	}

	job, err := h.service.CreateJob(c.Request.Context(), input)
	if err != nil {
		writeError(c, err)
		return
	}
	response.Created(c, job)
}

func (h *Handler) GetJob(c *gin.Context) {
	job, err := h.service.GetJob(c.Request.Context(), c.Param("job_id"))
	if err != nil {
		writeError(c, err)
		return
	}
	response.OK(c, job)
}

func writeError(c *gin.Context, err error) {
	switch {
	case errors.Is(err, jobsdomain.ErrInvalidJob):
		response.BadRequest(c, err.Error())
	case errors.Is(err, jobsdomain.ErrJobNotFound):
		c.JSON(stdhttp.StatusNotFound, response.Body{
			Success: false,
			Error:   &response.ErrorBody{Code: "not_found", Message: err.Error()},
		})
	default:
		response.Error(c, err)
	}
}
