package middleware

import (
	"net/http"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
)

// RateLimit is a small in-memory token-bucket limiter keyed by client IP.
// Good enough for a single instance; swap for Redis when scaling horizontally.
// rps is the sustained refill rate (tokens per second), burst is the bucket size.
func RateLimit(rps float64, burst float64) gin.HandlerFunc {
	type bucket struct {
		tokens float64
		last   time.Time
	}
	var (
		mu      sync.Mutex
		buckets = map[string]*bucket{}
	)

	// Periodically drop idle buckets so the map does not grow forever.
	go func() {
		for range time.Tick(5 * time.Minute) {
			mu.Lock()
			cutoff := time.Now().Add(-10 * time.Minute)
			for ip, b := range buckets {
				if b.last.Before(cutoff) {
					delete(buckets, ip)
				}
			}
			mu.Unlock()
		}
	}()

	return func(c *gin.Context) {
		ip := c.ClientIP()
		now := time.Now()

		mu.Lock()
		b, ok := buckets[ip]
		if !ok {
			b = &bucket{tokens: burst, last: now}
			buckets[ip] = b
		}
		// refill
		b.tokens += now.Sub(b.last).Seconds() * rps
		if b.tokens > burst {
			b.tokens = burst
		}
		b.last = now
		allowed := b.tokens >= 1
		if allowed {
			b.tokens--
		}
		mu.Unlock()

		if !allowed {
			c.Header("Retry-After", "5")
			c.AbortWithStatusJSON(http.StatusTooManyRequests, gin.H{
				"success": false,
				"error":   gin.H{"code": "rate_limited", "message": "Слишком много запросов — подожди несколько секунд"},
			})
			return
		}
		c.Next()
	}
}
