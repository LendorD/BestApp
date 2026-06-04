package application

import (
	"context"
	"fmt"
	"strings"
	"time"

	dotadomain "gamementor/internal/modules/dota/domain"
	platformcache "gamementor/internal/platform/cache"
)

type Service struct {
	statsProvider dotadomain.PlayerStatsProvider
	matchProvider dotadomain.MatchDetailsProvider
	cache         platformcache.Cache
}

func NewService(statsProvider dotadomain.PlayerStatsProvider, matchProvider dotadomain.MatchDetailsProvider, cacheStore ...platformcache.Cache) *Service {
	service := &Service{statsProvider: statsProvider, matchProvider: matchProvider}
	if len(cacheStore) > 0 {
		service.cache = cacheStore[0]
	}
	return service
}

func (s *Service) GetPlayerProfile(ctx context.Context, steamID string) (*dotadomain.PlayerProfile, error) {
	steamID = strings.TrimSpace(steamID)
	if steamID == "" {
		return nil, dotadomain.InvalidSteamID(steamID)
	}
	key := fmt.Sprintf("dota:profile:%s", steamID)
	var cached dotadomain.PlayerProfile
	if s.cacheHit(ctx, key, &cached) {
		return &cached, nil
	}

	profile, err := s.statsProvider.GetPlayerProfile(ctx, steamID)
	if err != nil {
		return nil, err
	}
	s.cacheSet(ctx, key, profile, 24*time.Hour)
	return profile, nil
}

func (s *Service) GetRecentMatches(ctx context.Context, steamID string, limit int) ([]dotadomain.MatchSummary, error) {
	steamID = strings.TrimSpace(steamID)
	if steamID == "" {
		return nil, dotadomain.InvalidSteamID(steamID)
	}
	if limit <= 0 {
		limit = 50
	}
	if limit > 100 {
		limit = 100
	}
	key := fmt.Sprintf("dota:matches:%s:%d", steamID, limit)
	var cached []dotadomain.MatchSummary
	if s.cacheHit(ctx, key, &cached) {
		return cached, nil
	}

	matches, err := s.statsProvider.GetRecentMatches(ctx, steamID, limit)
	if err != nil {
		return nil, err
	}
	s.cacheSet(ctx, key, matches, 30*time.Minute)
	return matches, nil
}

func (s *Service) GetHeroStats(ctx context.Context, steamID string, filter HeroStatsFilter) ([]dotadomain.HeroStats, error) {
	steamID = strings.TrimSpace(steamID)
	if steamID == "" {
		return nil, dotadomain.InvalidSteamID(steamID)
	}
	key := fmt.Sprintf("dota:heroes:%s", steamID)
	var cached []dotadomain.HeroStats
	if s.cacheHit(ctx, key, &cached) {
		if filter.Limit > 0 && len(cached) > filter.Limit {
			return cached[:filter.Limit], nil
		}
		return cached, nil
	}

	heroes, err := s.statsProvider.GetHeroStats(ctx, steamID)
	if err != nil {
		return nil, err
	}
	s.cacheSet(ctx, key, heroes, 30*time.Minute)
	if filter.Limit > 0 && len(heroes) > filter.Limit {
		heroes = heroes[:filter.Limit]
	}
	return heroes, nil
}

func (s *Service) GetMatchDetails(ctx context.Context, matchID string) (*dotadomain.MatchDetails, error) {
	matchID = strings.TrimSpace(matchID)
	if matchID == "" {
		return nil, dotadomain.InvalidSteamID(matchID)
	}
	key := fmt.Sprintf("dota:match-details:%s", matchID)
	var cached dotadomain.MatchDetails
	if s.cacheHit(ctx, key, &cached) {
		return &cached, nil
	}

	details, err := s.matchProvider.GetMatchDetails(ctx, matchID)
	if err != nil {
		return nil, err
	}
	s.cacheSet(ctx, key, details, 7*24*time.Hour)
	return details, nil
}

func (s *Service) cacheHit(ctx context.Context, key string, dest any) bool {
	if s.cache == nil {
		return false
	}
	err := s.cache.Get(ctx, key, dest)
	return err == nil
}

func (s *Service) cacheSet(ctx context.Context, key string, value any, ttl time.Duration) {
	if s.cache == nil {
		return
	}
	_ = s.cache.Set(ctx, key, value, ttl)
}
