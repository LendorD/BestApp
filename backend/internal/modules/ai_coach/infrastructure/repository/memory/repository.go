package memory

import (
	"context"
	"sync"

	coachdomain "gamementor/internal/modules/ai_coach/domain"
)

type Repository struct {
	mu     sync.RWMutex
	byID   map[string]*coachdomain.CoachReport
	latest map[string]string
}

func New() *Repository {
	return &Repository{
		byID:   make(map[string]*coachdomain.CoachReport),
		latest: make(map[string]string),
	}
}

func (r *Repository) Save(ctx context.Context, report *coachdomain.CoachReport) error {
	if err := ctx.Err(); err != nil {
		return err
	}

	r.mu.Lock()
	r.byID[report.ID] = clone(report)
	r.latest[report.SteamID] = report.ID
	r.mu.Unlock()
	return nil
}

func (r *Repository) LatestBySteamID(ctx context.Context, steamID string) (*coachdomain.CoachReport, error) {
	if err := ctx.Err(); err != nil {
		return nil, err
	}

	r.mu.RLock()
	id, ok := r.latest[steamID]
	report := r.byID[id]
	r.mu.RUnlock()
	if !ok || report == nil {
		return nil, coachdomain.ErrReportNotFound
	}
	return clone(report), nil
}

func (r *Repository) GetByID(ctx context.Context, id string) (*coachdomain.CoachReport, error) {
	if err := ctx.Err(); err != nil {
		return nil, err
	}

	r.mu.RLock()
	report := r.byID[id]
	r.mu.RUnlock()
	if report == nil {
		return nil, coachdomain.ErrReportNotFound
	}
	return clone(report), nil
}

func clone(report *coachdomain.CoachReport) *coachdomain.CoachReport {
	if report == nil {
		return nil
	}
	cp := *report
	cp.Strengths = append([]string(nil), report.Strengths...)
	cp.Weaknesses = append([]string(nil), report.Weaknesses...)
	cp.MainMistakes = append([]string(nil), report.MainMistakes...)
	cp.Recommendations = append([]string(nil), report.Recommendations...)
	cp.TrainingPlan = append([]string(nil), report.TrainingPlan...)
	cp.HeroesToFocus = append([]string(nil), report.HeroesToFocus...)
	cp.HeroesToAvoid = append([]string(nil), report.HeroesToAvoid...)
	cp.NextSteps = append([]string(nil), report.NextSteps...)
	return &cp
}
