package domain

import (
	"time"

	analyticsdomain "gamementor/internal/modules/statistics/domain"
)

type CoachReport struct {
	ID              string                        `json:"id"`
	SteamID         string                        `json:"steam_id"`
	Summary         string                        `json:"summary"`
	Strengths       []string                      `json:"strengths"`
	Weaknesses      []string                      `json:"weaknesses"`
	MainMistakes    []string                      `json:"main_mistakes"`
	Recommendations []string                      `json:"recommendations"`
	TrainingPlan    []string                      `json:"training_plan"`
	HeroesToFocus   []string                      `json:"heroes_to_focus"`
	HeroesToAvoid   []string                      `json:"heroes_to_avoid"`
	NextSteps       []string                      `json:"next_steps"`
	Snapshot        *analyticsdomain.DotaSnapshot `json:"snapshot,omitempty"`
	Prompt          string                        `json:"-"`
	CreatedAt       time.Time                     `json:"created_at"`
}

type ReportContent struct {
	Summary         string   `json:"summary"`
	Strengths       []string `json:"strengths"`
	Weaknesses      []string `json:"weaknesses"`
	MainMistakes    []string `json:"main_mistakes"`
	Recommendations []string `json:"recommendations"`
	TrainingPlan    []string `json:"training_plan"`
	HeroesToFocus   []string `json:"heroes_to_focus"`
	HeroesToAvoid   []string `json:"heroes_to_avoid"`
	NextSteps       []string `json:"next_steps"`
}
