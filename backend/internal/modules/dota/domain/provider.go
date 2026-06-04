package domain

import "context"

type PlayerStatsProvider interface {
	GetPlayerProfile(ctx context.Context, steamID string) (*PlayerProfile, error)
	GetRecentMatches(ctx context.Context, steamID string, limit int) ([]MatchSummary, error)
	GetHeroStats(ctx context.Context, steamID string) ([]HeroStats, error)
}

type MatchDetailsProvider interface {
	GetMatchDetails(ctx context.Context, matchID string) (*MatchDetails, error)
}
