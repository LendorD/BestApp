package middleware

import (
	"net/http"
	"os"
	"strings"

	"github.com/gin-gonic/gin"
)

// CORS allows cross-origin requests. By default (no env set) it reflects any
// Origin — convenient for local development. In production set
// CORS_ALLOWED_ORIGINS to a comma-separated whitelist, e.g.
//
//	CORS_ALLOWED_ORIGINS=https://gamementor.gg,https://www.gamementor.gg
//
// and only those origins will be allowed.
func CORS() gin.HandlerFunc {
	allowed := map[string]bool{}
	for _, o := range strings.Split(os.Getenv("CORS_ALLOWED_ORIGINS"), ",") {
		if o = strings.TrimSpace(strings.TrimSuffix(o, "/")); o != "" {
			allowed[strings.ToLower(o)] = true
		}
	}
	restrict := len(allowed) > 0

	return func(c *gin.Context) {
		origin := c.GetHeader("Origin")
		if origin != "" {
			if !restrict || allowed[strings.ToLower(strings.TrimSuffix(origin, "/"))] {
				c.Header("Access-Control-Allow-Origin", origin)
				c.Header("Vary", "Origin")
			}
		}
		c.Header("Access-Control-Allow-Methods", "GET,POST,PUT,DELETE,OPTIONS")
		c.Header("Access-Control-Allow-Headers", "Authorization,Content-Type,X-Request-ID")
		c.Header("Access-Control-Expose-Headers", "X-Request-ID")

		if c.Request.Method == http.MethodOptions {
			c.AbortWithStatus(http.StatusNoContent)
			return
		}

		c.Next()
	}
}
