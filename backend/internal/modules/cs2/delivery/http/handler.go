package http

import (
	stdhttp "net/http"
	"strconv"

	"gamementor/internal/delivery/http/response"
	cs2app "gamementor/internal/modules/cs2/application"
	cs2domain "gamementor/internal/modules/cs2/domain"

	"github.com/gin-gonic/gin"
)

type Handler struct {
	service *cs2app.Service
}

func NewHandler(service *cs2app.Service) *Handler {
	return &Handler{service: service}
}

func RegisterRoutes(group *gin.RouterGroup, handler *Handler) {
	cs2 := group.Group("/cs2")
	cs2.GET("/maps", handler.ListMaps)
	cs2.POST("/grenades", handler.CreateGrenade)
	cs2.GET("/grenades", handler.ListGrenades)
	cs2.GET("/grenades/:id", handler.GetGrenade)
	cs2.PUT("/grenades/:id", handler.UpdateGrenade)
	cs2.DELETE("/grenades/:id", handler.DeleteGrenade)
}

func (h *Handler) ListMaps(c *gin.Context) {
	maps, err := h.service.ListMaps(c.Request.Context())
	if err != nil {
		response.Error(c, err)
		return
	}
	response.OK(c, maps)
}

func (h *Handler) CreateGrenade(c *gin.Context) {
	var input cs2domain.CreateCS2GrenadeInput
	if err := c.ShouldBindJSON(&input); err != nil {
		response.BadRequest(c, "invalid json body")
		return
	}
	grenade, err := h.service.CreateGrenade(c.Request.Context(), input)
	if err != nil {
		response.Error(c, err)
		return
	}
	response.Created(c, grenade)
}

func (h *Handler) ListGrenades(c *gin.Context) {
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
	grenades, err := h.service.ListGrenades(c.Request.Context(), cs2domain.CS2GrenadeFilter{
		Map: c.Query("map"), Side: c.Query("side"), Type: c.Query("type"),
		Difficulty: c.Query("difficulty"), Limit: limit, Offset: offset,
	})
	if err != nil {
		response.Error(c, err)
		return
	}
	response.OK(c, grenades)
}

func (h *Handler) GetGrenade(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}
	grenade, err := h.service.GetGrenade(c.Request.Context(), id)
	if err != nil {
		response.Error(c, err)
		return
	}
	response.OK(c, grenade)
}

func (h *Handler) UpdateGrenade(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}
	var input cs2domain.UpdateCS2GrenadeInput
	if err := c.ShouldBindJSON(&input); err != nil {
		response.BadRequest(c, "invalid json body")
		return
	}
	grenade, err := h.service.UpdateGrenade(c.Request.Context(), id, input)
	if err != nil {
		response.Error(c, err)
		return
	}
	response.OK(c, grenade)
}

func (h *Handler) DeleteGrenade(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}
	if err := h.service.DeleteGrenade(c.Request.Context(), id); err != nil {
		response.Error(c, err)
		return
	}
	response.NoContent(c)
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

func parseOptionalInt(c *gin.Context, key string, fallback int) (int, error) {
	raw := c.Query(key)
	if raw == "" {
		return fallback, nil
	}
	return strconv.Atoi(raw)
}
