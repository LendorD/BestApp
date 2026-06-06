package middleware

import (
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
)

// ctxUserIDKey / ctxUsernameKey are the gin context keys for the authenticated
// user. Kept unexported; use CurrentUserID to read them.
const (
	ctxUserIDKey   = "auth_user_id"
	ctxUsernameKey = "auth_username"
)

// TokenClaims is the minimal shape the middleware needs from a parsed token.
type TokenClaims interface {
	GetUserID() int64
	GetUsername() string
}

// TokenParser verifies a raw bearer token and returns its claims.
type TokenParser interface {
	ParseClaims(token string) (TokenClaims, error)
}

// AuthRequired rejects requests without a valid bearer token. On success it
// stores the user id/username in the gin context.
func AuthRequired(parser TokenParser) gin.HandlerFunc {
	return func(c *gin.Context) {
		token, ok := bearerToken(c)
		if !ok {
			abortUnauthorized(c, "missing bearer token")
			return
		}
		claims, err := parser.ParseClaims(token)
		if err != nil {
			abortUnauthorized(c, "invalid or expired token")
			return
		}
		c.Set(ctxUserIDKey, claims.GetUserID())
		c.Set(ctxUsernameKey, claims.GetUsername())
		c.Next()
	}
}

// CurrentUserID returns the authenticated user id from the context.
func CurrentUserID(c *gin.Context) (int64, bool) {
	value, exists := c.Get(ctxUserIDKey)
	if !exists {
		return 0, false
	}
	id, ok := value.(int64)
	return id, ok && id > 0
}

func bearerToken(c *gin.Context) (string, bool) {
	header := strings.TrimSpace(c.GetHeader("Authorization"))
	if header == "" {
		return "", false
	}
	parts := strings.SplitN(header, " ", 2)
	if len(parts) == 2 && strings.EqualFold(parts[0], "Bearer") {
		return strings.TrimSpace(parts[1]), true
	}
	return header, true
}

func abortUnauthorized(c *gin.Context, message string) {
	c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
		"success": false,
		"error":   gin.H{"code": "unauthorized", "message": message},
	})
}
