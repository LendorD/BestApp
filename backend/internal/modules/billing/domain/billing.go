// Package domain holds the billing aggregate: plans and subscriptions. Billing
// is intentionally provider-agnostic; a real payment provider (e.g. Stripe) can
// be plugged in later behind the application service without touching domain.
package domain

import (
	"context"
	"time"

	"gamementor/internal/domain"
)

// PlanID enumerates the available subscription tiers.
type PlanID string

const (
	PlanFree PlanID = "free"
	PlanPro  PlanID = "pro"
	PlanTeam PlanID = "team"
)

// Plan is a purchasable tier shown on the pricing page.
type Plan struct {
	ID           PlanID   `json:"id"`
	Name         string   `json:"name"`
	PriceMonthly int      `json:"price_monthly"` // in USD, 0 == free
	Currency     string   `json:"currency"`
	Tagline      string   `json:"tagline"`
	Features     []string `json:"features"`
	Highlight    bool     `json:"highlight"`
}

// SubscriptionStatus values.
const (
	StatusActive   = "active"
	StatusCanceled = "canceled"
	StatusPastDue  = "past_due"
)

// Subscription is the current billing state of a user.
type Subscription struct {
	UserID           int64      `json:"user_id"`
	Plan             PlanID     `json:"plan"`
	Status           string     `json:"status"`
	CurrentPeriodEnd *time.Time `json:"current_period_end,omitempty"`
	UpdatedAt        time.Time  `json:"updated_at"`
}

// Catalog is the canonical, in-code list of plans.
func Catalog() []Plan {
	return []Plan{
		{
			ID: PlanFree, Name: "Free", PriceMonthly: 0, Currency: "USD",
			Tagline: "Базовый разбор для старта",
			Features: []string{
				"Поиск любого профиля",
				"Обзорный дашборд",
				"Последние 20 матчей",
				"Базовые метрики",
			},
		},
		{
			ID: PlanPro, Name: "Pro", PriceMonthly: 9, Currency: "USD",
			Tagline: "Полный AI-коуч и разбор реплеев",
			Highlight: true,
			Features: []string{
				"Всё из Free",
				"AI-коуч по профилю и матчам",
				"Разбор реплеев в текст",
				"Сравнение с про-игроками",
				"Анализ героев и слабых сторон",
				"История без ограничений",
			},
		},
		{
			ID: PlanTeam, Name: "Team", PriceMonthly: 29, Currency: "USD",
			Tagline: "Для команд и тренеров",
			Features: []string{
				"Всё из Pro",
				"До 5 аккаунтов",
				"Командная аналитика",
				"Экспорт отчётов",
				"Приоритетная поддержка",
			},
		},
	}
}

// PlanByID returns a plan from the catalog.
func PlanByID(id PlanID) (Plan, bool) {
	for _, p := range Catalog() {
		if p.ID == id {
			return p, true
		}
	}
	return Plan{}, false
}

// ValidPlan reports whether id is a known plan.
func ValidPlan(id PlanID) bool {
	_, ok := PlanByID(id)
	return ok
}

// InvalidInput is a convenience validation error for the billing module.
func InvalidInput(message string) error {
	return domain.ValidationError(message)
}

// Repository is the persistence port for subscriptions.
type Repository interface {
	Get(ctx context.Context, userID int64) (*Subscription, error)
	Upsert(ctx context.Context, sub *Subscription) (*Subscription, error)
}
