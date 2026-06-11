package application

import (
	"context"
	"time"

	billingdomain "gamementor/internal/modules/billing/domain"
)

// Service implements mock billing: plans come from the in-code catalog, and a
// "subscribe" simply activates the chosen plan immediately. A real payment
// provider can be added later behind this same interface.
type Service struct {
	repo billingdomain.Repository
	now  func() time.Time
}

func NewService(repo billingdomain.Repository) *Service {
	return &Service{repo: repo, now: time.Now}
}

// Plans returns the public pricing catalog.
func (s *Service) Plans() []billingdomain.Plan {
	return billingdomain.Catalog()
}

// GetSubscription returns the user's subscription, defaulting to Free.
func (s *Service) GetSubscription(ctx context.Context, userID int64) (*billingdomain.Subscription, error) {
	if userID <= 0 {
		return nil, billingdomain.InvalidInput("user id is required")
	}
	sub, err := s.repo.Get(ctx, userID)
	if err != nil {
		return nil, err
	}
	if sub == nil {
		return &billingdomain.Subscription{
			UserID:    userID,
			Plan:      billingdomain.PlanFree,
			Status:    billingdomain.StatusActive,
			UpdatedAt: s.now().UTC(),
		}, nil
	}
	return sub, nil
}

// HasActivePaidPlan reports whether the user is on an active non-free plan.
// Used by the delivery layer to gate Pro features (AI coach, deep review).
func (s *Service) HasActivePaidPlan(ctx context.Context, userID int64) (bool, error) {
	sub, err := s.GetSubscription(ctx, userID)
	if err != nil {
		return false, err
	}
	if sub.Plan == billingdomain.PlanFree || sub.Status != billingdomain.StatusActive {
		return false, nil
	}
	if sub.CurrentPeriodEnd != nil && sub.CurrentPeriodEnd.Before(s.now().UTC()) {
		return false, nil
	}
	return true, nil
}

// Subscribe activates the given plan for the user (mock checkout).
func (s *Service) Subscribe(ctx context.Context, userID int64, plan billingdomain.PlanID) (*billingdomain.Subscription, error) {
	if userID <= 0 {
		return nil, billingdomain.InvalidInput("user id is required")
	}
	if !billingdomain.ValidPlan(plan) {
		return nil, billingdomain.InvalidInput("unknown plan")
	}

	now := s.now().UTC()
	sub := &billingdomain.Subscription{
		UserID:    userID,
		Plan:      plan,
		Status:    billingdomain.StatusActive,
		UpdatedAt: now,
	}
	if plan != billingdomain.PlanFree {
		end := now.AddDate(0, 1, 0)
		sub.CurrentPeriodEnd = &end
	}
	return s.repo.Upsert(ctx, sub)
}

// Cancel downgrades the user back to Free.
func (s *Service) Cancel(ctx context.Context, userID int64) (*billingdomain.Subscription, error) {
	if userID <= 0 {
		return nil, billingdomain.InvalidInput("user id is required")
	}
	sub := &billingdomain.Subscription{
		UserID:    userID,
		Plan:      billingdomain.PlanFree,
		Status:    billingdomain.StatusCanceled,
		UpdatedAt: s.now().UTC(),
	}
	return s.repo.Upsert(ctx, sub)
}
