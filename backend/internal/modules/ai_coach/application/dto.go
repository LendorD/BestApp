package application

import (
	"context"

	coachdomain "gamementor/internal/modules/ai_coach/domain"
)

type AIRequest struct {
	SteamID string
	Model   string
	Prompt  string
}

type AIClient interface {
	GenerateCoachReport(ctx context.Context, request AIRequest) (*coachdomain.ReportContent, error)
}
