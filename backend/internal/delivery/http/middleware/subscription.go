package middleware

import (
	"context"
	"net/http"

	"github.com/gin-gonic/gin"
)

// SubscriptionChecker reports whether a user has an active paid plan.
// Implemented by the billing application service; kept as a local port so the
// middleware does not import the billing module.
type SubscriptionChecker interface {
	HasActivePaidPlan(ctx context.Context, userID int64) (bool, error)
}

// ProRequired rejects requests from users without an active paid plan.
// Must run after AuthRequired (needs the user id in the context).
func ProRequired(checker SubscriptionChecker) gin.HandlerFunc {
	return func(c *gin.Context) {
		userID, ok := CurrentUserID(c)
		if !ok {
			abortUnauthorized(c, "missing bearer token")
			return
		}
		paid, err := checker.HasActivePaidPlan(c.Request.Context(), userID)
		if err != nil {
			c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{
				"success": false,
				"error":   gin.H{"code": "billing_unavailable", "message": "could not verify subscription"},
			})
			return
		}
		if !paid {
			c.AbortWithStatusJSON(http.StatusForbidden, gin.H{
				"success": false,
				"error":   gin.H{"code": "pro_required", "message": "Эта функция доступна по подписке Pro"},
			})
			return
		}
		c.Next()
	}
}
