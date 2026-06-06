package application

import (
	"context"
	"fmt"

	statisticsapp "gamementor/internal/modules/statistics/application"
)

// LabDashboard returns the full Dota analytics dashboard for a player.
// The dota service delegates all statistics work to the statistics service.
func (s *Service) LabDashboard(ctx context.Context, steamID, period, role string) (*statisticsapp.DotaLabDashboard, error) {
	if s.stats == nil {
		return nil, fmt.Errorf("statistics service is not configured")
	}
	return s.stats.BuildDotaLabDashboard(ctx, steamID, statisticsapp.DotaLabQuery{Period: period, Role: role})
}

// RefreshLab recomputes and re-caches the Dota analytics dashboard.
func (s *Service) RefreshLab(ctx context.Context, steamID, period, role string) (*statisticsapp.DotaLabDashboard, error) {
	if s.stats == nil {
		return nil, fmt.Errorf("statistics service is not configured")
	}
	return s.stats.RefreshDotaLabDashboard(ctx, steamID, statisticsapp.DotaLabQuery{Period: period, Role: role})
}
