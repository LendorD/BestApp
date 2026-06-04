package redis

import (
	"context"
	"encoding/json"
	"errors"
	"time"

	"gamementor/internal/platform/cache"

	"github.com/redis/go-redis/v9"
)

type Cache struct {
	client *redis.Client
}

func New(url string) (*Cache, error) {
	if url == "" {
		return nil, errors.New("redis url is required")
	}
	opts, err := redis.ParseURL(url)
	if err != nil {
		return nil, err
	}
	return &Cache{client: redis.NewClient(opts)}, nil
}

func (c *Cache) Get(ctx context.Context, key string, dest any) error {
	payload, err := c.client.Get(ctx, key).Bytes()
	if errors.Is(err, redis.Nil) {
		return cache.ErrMiss
	}
	if err != nil {
		return err
	}
	return json.Unmarshal(payload, dest)
}

func (c *Cache) Set(ctx context.Context, key string, value any, ttl time.Duration) error {
	payload, err := json.Marshal(value)
	if err != nil {
		return err
	}
	return c.client.Set(ctx, key, payload, ttl).Err()
}

func (c *Cache) Delete(ctx context.Context, key string) error {
	return c.client.Del(ctx, key).Err()
}
