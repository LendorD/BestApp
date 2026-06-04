package handler

import (
	"net/http"
	"strconv"

	"gamementor/internal/delivery/http/response"
	"gamementor/internal/domain"
	"gamementor/internal/usecase"

	"github.com/gin-gonic/gin"
)

type CS2Handler struct {
	usecase *usecase.CS2Usecase
}

func NewCS2Handler(usecase *usecase.CS2Usecase) *CS2Handler {
	return &CS2Handler{usecase: usecase}
}

func (h *CS2Handler) ListMaps(c *gin.Context) {
	maps, err := h.usecase.ListMaps(c.Request.Context())
	if err != nil {
		response.Error(c, err)
		return
	}
	response.OK(c, maps)
}

func (h *CS2Handler) CreateGrenade(c *gin.Context) {
	var input domain.CreateCS2GrenadeInput
	if err := c.ShouldBindJSON(&input); err != nil {
		response.BadRequest(c, "invalid json body")
		return
	}

	grenade, err := h.usecase.CreateGrenade(c.Request.Context(), input)
	if err != nil {
		response.Error(c, err)
		return
	}
	response.Created(c, grenade)
}

func (h *CS2Handler) ListGrenades(c *gin.Context) {
	limit, err := parseOptionalInt(c, "limit", 50)
	if err != nil {
		response.BadRequest(c, "limit must be an integer")
		return
	}
	offset, err := parseOptionalInt(c, "offset", 0)
	if err != nil {
		response.BadRequest(c, "offset must be an integer")
		return
	}

	grenades, err := h.usecase.ListGrenades(c.Request.Context(), domain.CS2GrenadeFilter{
		Map:        c.Query("map"),
		Side:       c.Query("side"),
		Type:       c.Query("type"),
		Difficulty: c.Query("difficulty"),
		Limit:      limit,
		Offset:     offset,
	})
	if err != nil {
		response.Error(c, err)
		return
	}
	response.OK(c, grenades)
}

func (h *CS2Handler) GetGrenade(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}

	grenade, err := h.usecase.GetGrenade(c.Request.Context(), id)
	if err != nil {
		response.Error(c, err)
		return
	}
	response.OK(c, grenade)
}

func (h *CS2Handler) UpdateGrenade(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}

	var input domain.UpdateCS2GrenadeInput
	if err := c.ShouldBindJSON(&input); err != nil {
		response.BadRequest(c, "invalid json body")
		return
	}

	grenade, err := h.usecase.UpdateGrenade(c.Request.Context(), id, input)
	if err != nil {
		response.Error(c, err)
		return
	}
	response.OK(c, grenade)
}

func (h *CS2Handler) DeleteGrenade(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}

	if err := h.usecase.DeleteGrenade(c.Request.Context(), id); err != nil {
		response.Error(c, err)
		return
	}
	response.NoContent(c)
}

func parseID(c *gin.Context) (int64, bool) {
	id, err := strconv.ParseInt(c.Param("id"), 10, 64)
	if err != nil || id <= 0 {
		c.JSON(http.StatusBadRequest, response.Body{
			Success: false,
			Error: &response.ErrorBody{
				Code:    "bad_request",
				Message: "id must be positive integer",
			},
		})
		return 0, false
	}
	return id, true
}

func parseOptionalInt(c *gin.Context, key string, fallback int) (int, error) {
	raw := c.Query(key)
	if raw == "" {
		return fallback, nil
	}
	return strconv.Atoi(raw)
}
