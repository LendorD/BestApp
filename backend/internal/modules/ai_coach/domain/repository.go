package domain

import "context"

type Repository interface {
	Save(ctx context.Context, report *CoachReport) error
	LatestBySteamID(ctx context.Context, steamID string) (*CoachReport, error)
	GetByID(ctx context.Context, id string) (*CoachReport, error)
}
