package domain

import "time"

type JobType string
type JobStatus string
type JobPayload map[string]any

const (
	JobTypeRefreshPlayerStats     JobType = "refresh_player_stats"
	JobTypeBuildAnalyticsSnapshot JobType = "build_analytics_snapshot"
	JobTypeGenerateAICoachReport  JobType = "generate_ai_coach_report"
	JobTypeUpdateHeroMeta         JobType = "update_hero_meta"
)

const (
	JobStatusPending   JobStatus = "pending"
	JobStatusRunning   JobStatus = "running"
	JobStatusCompleted JobStatus = "completed"
	JobStatusFailed    JobStatus = "failed"
)

type Job struct {
	ID          string         `json:"id"`
	Type        JobType        `json:"type"`
	Status      JobStatus      `json:"status"`
	Payload     JobPayload     `json:"payload"`
	Result      map[string]any `json:"result,omitempty"`
	Error       string         `json:"error,omitempty"`
	CreatedAt   time.Time      `json:"created_at"`
	UpdatedAt   time.Time      `json:"updated_at"`
	StartedAt   *time.Time     `json:"started_at,omitempty"`
	CompletedAt *time.Time     `json:"completed_at,omitempty"`
}

func (p JobPayload) String(key string) string {
	if p == nil {
		return ""
	}
	value, ok := p[key]
	if !ok || value == nil {
		return ""
	}
	switch typed := value.(type) {
	case string:
		return typed
	default:
		return ""
	}
}
