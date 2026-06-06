package postgres

import (
	"context"
	"errors"
	"fmt"

	billingdomain "gamementor/internal/modules/billing/domain"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"
)

type Repository struct {
	pool *pgxpool.Pool
}

func NewRepository(pool *pgxpool.Pool) *Repository {
	return &Repository{pool: pool}
}

func (r *Repository) Get(ctx context.Context, userID int64) (*billingdomain.Subscription, error) {
	row := r.pool.QueryRow(ctx, `
		SELECT user_id, plan, status, current_period_end, updated_at
		FROM tbl_subscriptions WHERE user_id = $1
	`, userID)

	sub, err := scanSubscription(row)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, fmt.Errorf("get subscription: %w", err)
	}
	return sub, nil
}

func (r *Repository) Upsert(ctx context.Context, sub *billingdomain.Subscription) (*billingdomain.Subscription, error) {
	row := r.pool.QueryRow(ctx, `
		INSERT INTO tbl_subscriptions (user_id, plan, status, current_period_end, updated_at)
		VALUES ($1, $2, $3, $4, now())
		ON CONFLICT (user_id) DO UPDATE
		SET plan = EXCLUDED.plan,
		    status = EXCLUDED.status,
		    current_period_end = EXCLUDED.current_period_end,
		    updated_at = now()
		RETURNING user_id, plan, status, current_period_end, updated_at
	`, sub.UserID, string(sub.Plan), sub.Status, sub.CurrentPeriodEnd)

	saved, err := scanSubscription(row)
	if err != nil {
		return nil, fmt.Errorf("upsert subscription: %w", err)
	}
	return saved, nil
}

type scanner interface {
	Scan(dest ...any) error
}

func scanSubscription(row scanner) (*billingdomain.Subscription, error) {
	var sub billingdomain.Subscription
	var plan string
	var periodEnd pgtype.Timestamptz

	if err := row.Scan(&sub.UserID, &plan, &sub.Status, &periodEnd, &sub.UpdatedAt); err != nil {
		return nil, err
	}
	sub.Plan = billingdomain.PlanID(plan)
	if periodEnd.Valid {
		value := periodEnd.Time
		sub.CurrentPeriodEnd = &value
	}
	return &sub, nil
}
