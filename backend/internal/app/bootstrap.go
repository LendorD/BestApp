package app

import (
	"context"
	"fmt"
	"log/slog"

	"gamementor/internal/config"
	platformcache "gamementor/internal/platform/cache"
	"gamementor/internal/platform/cache/memory"
	rediscache "gamementor/internal/platform/cache/redis"
	"gamementor/internal/platform/postgres"

	"github.com/jackc/pgx/v5/pgxpool"
)

type BootstrapResult struct {
	Pool    *pgxpool.Pool
	Cache   platformcache.Cache
	Modules *Modules
}

func Bootstrap(ctx context.Context, cfg *config.Config, log *slog.Logger) (*BootstrapResult, error) {
	pool, err := postgres.NewPool(ctx, cfg.DatabaseURL)
	if err != nil {
		return nil, err
	}

	cacheStore, err := buildCache(cfg, log)
	if err != nil {
		pool.Close()
		return nil, err
	}

	modules := NewModules(cfg, pool, cacheStore, log)
	return &BootstrapResult{
		Pool:    pool,
		Cache:   cacheStore,
		Modules: modules,
	}, nil
}

func (b *BootstrapResult) Close() {
	if b == nil || b.Pool == nil {
		return
	}
	b.Pool.Close()
}

func buildCache(cfg *config.Config, log *slog.Logger) (platformcache.Cache, error) {
	if !cfg.CacheEnabled {
		log.Info("cache disabled by config")
		return nil, nil
	}
	if cfg.RedisURL == "" {
		log.Info("redis url is empty; using memory cache")
		return memory.New(), nil
	}

	cacheStore, err := rediscache.New(cfg.RedisURL)
	if err != nil {
		return nil, fmt.Errorf("create redis cache: %w", err)
	}
	log.Info("redis cache enabled")
	return cacheStore, nil
}
