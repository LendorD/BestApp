package database

import (
	"context"

	"gamementor/internal/platform/postgres"

	"github.com/jackc/pgx/v5/pgxpool"
)

func NewPostgresPool(ctx context.Context, databaseURL string) (*pgxpool.Pool, error) {
	return postgres.NewPool(ctx, databaseURL)
}
