package memory

import (
	"context"
	"errors"
	"testing"
	"time"

	"gamementor/internal/platform/cache"
)

func TestMemoryCacheSetGetDelete(t *testing.T) {
	ctx := context.Background()
	c := New()

	input := map[string]any{"value": "ok"}
	if err := c.Set(ctx, "k", input, time.Minute); err != nil {
		t.Fatalf("set: %v", err)
	}

	var out map[string]string
	if err := c.Get(ctx, "k", &out); err != nil {
		t.Fatalf("get: %v", err)
	}
	if out["value"] != "ok" {
		t.Fatalf("unexpected value: %q", out["value"])
	}

	if err := c.Delete(ctx, "k"); err != nil {
		t.Fatalf("delete: %v", err)
	}
	if err := c.Get(ctx, "k", &out); !errors.Is(err, cache.ErrMiss) {
		t.Fatalf("expected cache miss, got %v", err)
	}
}

func TestMemoryCacheTTL(t *testing.T) {
	ctx := context.Background()
	c := New()
	now := time.Date(2026, 6, 4, 10, 0, 0, 0, time.UTC)
	c.now = func() time.Time { return now }

	if err := c.Set(ctx, "k", "value", time.Second); err != nil {
		t.Fatalf("set: %v", err)
	}

	now = now.Add(2 * time.Second)
	var out string
	if err := c.Get(ctx, "k", &out); !errors.Is(err, cache.ErrMiss) {
		t.Fatalf("expected cache miss, got %v", err)
	}
}
