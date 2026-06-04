package memory

import (
	"context"
	"encoding/json"
	"sync"
	"time"

	"gamementor/internal/platform/cache"
)

type Cache struct {
	mu    sync.RWMutex
	items map[string]item
	now   func() time.Time
}

type item struct {
	payload   []byte
	expiresAt time.Time
}

func New() *Cache {
	return &Cache{
		items: make(map[string]item),
		now:   time.Now,
	}
}

func (c *Cache) Get(ctx context.Context, key string, dest any) error {
	if err := ctx.Err(); err != nil {
		return err
	}

	c.mu.RLock()
	entry, ok := c.items[key]
	c.mu.RUnlock()
	if !ok {
		return cache.ErrMiss
	}
	if !entry.expiresAt.IsZero() && c.now().After(entry.expiresAt) {
		_ = c.Delete(ctx, key)
		return cache.ErrMiss
	}
	return json.Unmarshal(entry.payload, dest)
}

func (c *Cache) Set(ctx context.Context, key string, value any, ttl time.Duration) error {
	if err := ctx.Err(); err != nil {
		return err
	}

	payload, err := json.Marshal(value)
	if err != nil {
		return err
	}

	var expiresAt time.Time
	if ttl > 0 {
		expiresAt = c.now().Add(ttl)
	}

	c.mu.Lock()
	c.items[key] = item{payload: payload, expiresAt: expiresAt}
	c.mu.Unlock()
	return nil
}

func (c *Cache) Delete(ctx context.Context, key string) error {
	if err := ctx.Err(); err != nil {
		return err
	}

	c.mu.Lock()
	delete(c.items, key)
	c.mu.Unlock()
	return nil
}
