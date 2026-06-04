package stratz

import (
	"context"

	dotadomain "gamementor/internal/modules/dota/domain"
)

type Provider struct {
	apiKey string
}

func New(apiKey string) *Provider {
	return &Provider{apiKey: apiKey}
}

func (p *Provider) GetPlayerProfile(ctx context.Context, steamID string) (*dotadomain.PlayerProfile, error) {
	_ = ctx
	_ = steamID
	return nil, dotadomain.ProviderDisabled("stratz")
}

func (p *Provider) GetRecentMatches(ctx context.Context, steamID string, limit int) ([]dotadomain.MatchSummary, error) {
	_ = ctx
	_ = steamID
	_ = limit
	return nil, dotadomain.ProviderDisabled("stratz")
}

func (p *Provider) GetHeroStats(ctx context.Context, steamID string) ([]dotadomain.HeroStats, error) {
	_ = ctx
	_ = steamID
	return nil, dotadomain.ProviderDisabled("stratz")
}

func (p *Provider) GetMatchDetails(ctx context.Context, matchID string) (*dotadomain.MatchDetails, error) {
	_ = ctx
	_ = matchID
	return nil, dotadomain.ProviderDisabled("stratz")
}
