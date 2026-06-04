package application

import (
	"context"
	"sort"
	"time"

	analyticsdomain "gamementor/internal/modules/analytics/domain"
	dotadomain "gamementor/internal/modules/dota/domain"
	platformcache "gamementor/internal/platform/cache"
)

type DotaMatchReader interface {
	GetPlayerProfile(ctx context.Context, steamID string) (*dotadomain.PlayerProfile, error)
	GetRecentMatches(ctx context.Context, steamID string, limit int) ([]dotadomain.MatchSummary, error)
}

type Service struct {
	dota  DotaMatchReader
	now   func() time.Time
	cache platformcache.Cache
}

func NewService(dota DotaMatchReader, cacheStore ...platformcache.Cache) *Service {
	service := &Service{dota: dota, now: time.Now}
	if len(cacheStore) > 0 {
		service.cache = cacheStore[0]
	}
	return service
}

func (s *Service) BuildDotaSnapshot(ctx context.Context, steamID string) (*analyticsdomain.DotaSnapshot, error) {
	key := "analytics:dota:snapshot:" + steamID
	var cached analyticsdomain.DotaSnapshot
	if s.cache != nil && s.cache.Get(ctx, key, &cached) == nil {
		return &cached, nil
	}
	return s.calculateAndCache(ctx, steamID, key)
}

func (s *Service) RefreshDotaSnapshot(ctx context.Context, steamID string) (*analyticsdomain.DotaSnapshot, error) {
	key := "analytics:dota:snapshot:" + steamID
	if s.cache != nil {
		_ = s.cache.Delete(ctx, key)
	}
	return s.calculateAndCache(ctx, steamID, key)
}

func (s *Service) calculateAndCache(ctx context.Context, steamID string, cacheKey string) (*analyticsdomain.DotaSnapshot, error) {
	matches, err := s.dota.GetRecentMatches(ctx, steamID, 100)
	if err != nil {
		return nil, err
	}
	snapshot := CalculateDotaSnapshot(steamID, matches, s.now().UTC())
	if s.cache != nil {
		_ = s.cache.Set(ctx, cacheKey, snapshot, 15*time.Minute)
	}
	return snapshot, nil
}

func (s *Service) GetHeroStats(ctx context.Context, steamID string, query HeroStatsQuery) ([]analyticsdomain.HeroPeriodStats, error) {
	matches, err := s.dota.GetRecentMatches(ctx, steamID, 100)
	if err != nil {
		return nil, err
	}
	return HeroStatsForPeriod(matches, query), nil
}

func CalculateDotaSnapshot(steamID string, matches []dotadomain.MatchSummary, now time.Time) *analyticsdomain.DotaSnapshot {
	snapshot := &analyticsdomain.DotaSnapshot{
		SteamID:       steamID,
		Matches:       len(matches),
		TopHeroes:     []analyticsdomain.HeroPeriodStats{},
		WorstHeroes:   []analyticsdomain.HeroPeriodStats{},
		SourceMatches: matches,
		CreatedAt:     now,
	}
	if len(matches) == 0 {
		snapshot.Normalized = normalizedSnapshot(snapshot)
		return snapshot
	}

	var wins, kills, deaths, assists, gpm, xpm, towerDamage, heroDamage int
	for _, match := range matches {
		if match.Won {
			wins++
		}
		kills += match.Kills
		deaths += match.Deaths
		assists += match.Assists
		gpm += match.GoldPerMin
		xpm += match.XPPerMin
		towerDamage += match.TowerDamage
		heroDamage += match.HeroDamage
	}

	snapshot.Wins = wins
	snapshot.Losses = snapshot.Matches - wins
	snapshot.Winrate = percent(wins, snapshot.Matches)
	snapshot.Winrate7Days = winrateSince(matches, now.AddDate(0, 0, -7))
	snapshot.Winrate30Days = winrateSince(matches, now.AddDate(0, 0, -30))
	snapshot.Winrate90Days = winrateSince(matches, now.AddDate(0, 0, -90))
	snapshot.AverageKDA = kda(kills, deaths, assists)
	snapshot.AverageGPM = average(gpm, snapshot.Matches)
	snapshot.AverageXPM = average(xpm, snapshot.Matches)

	avgTowerDamage := average(towerDamage, snapshot.Matches)
	avgHeroDamage := average(heroDamage, snapshot.Matches)
	snapshot.FarmingScore = scoreRange(snapshot.AverageGPM, 320, 700)
	snapshot.FightingScore = scoreRange(avgHeroDamage, 6000, 30000)
	snapshot.ObjectiveScore = scoreRange(avgTowerDamage, 0, 4500)
	snapshot.StabilityScore = stabilityScore(matches)
	snapshot.ImpactScore = clampInt((snapshot.FarmingScore+snapshot.FightingScore+snapshot.ObjectiveScore+int(snapshot.Winrate))/4, 0, 100)

	heroes := HeroStatsForPeriod(matches, HeroStatsQuery{MinMatches: 1, SortBy: "games"})
	snapshot.TopHeroes = takeHeroes(heroes, 5)
	worst := append([]analyticsdomain.HeroPeriodStats(nil), heroes...)
	sort.Slice(worst, func(i, j int) bool {
		if worst[i].Winrate == worst[j].Winrate {
			return worst[i].Games > worst[j].Games
		}
		return worst[i].Winrate < worst[j].Winrate
	})
	snapshot.WorstHeroes = takeHeroes(worst, 5)
	snapshot.Normalized = normalizedSnapshot(snapshot)
	return snapshot
}

func HeroStatsForPeriod(matches []dotadomain.MatchSummary, query HeroStatsQuery) []analyticsdomain.HeroPeriodStats {
	type agg struct {
		matches int
		wins    int
		kills   int
		deaths  int
		assists int
	}
	byHero := map[int]*agg{}
	for _, match := range matches {
		if query.From != nil && match.StartTime.Before(*query.From) {
			continue
		}
		if query.To != nil && match.StartTime.After(*query.To) {
			continue
		}
		stat := byHero[match.HeroID]
		if stat == nil {
			stat = &agg{}
			byHero[match.HeroID] = stat
		}
		stat.matches++
		if match.Won {
			stat.wins++
		}
		stat.kills += match.Kills
		stat.deaths += match.Deaths
		stat.assists += match.Assists
	}

	result := make([]analyticsdomain.HeroPeriodStats, 0, len(byHero))
	for heroID, stat := range byHero {
		if query.MinMatches > 0 && stat.matches < query.MinMatches {
			continue
		}
		result = append(result, analyticsdomain.HeroPeriodStats{
			HeroID:     heroID,
			Matches:    stat.matches,
			Wins:       stat.wins,
			Losses:     stat.matches - stat.wins,
			Winrate:    percent(stat.wins, stat.matches),
			AverageKDA: kda(stat.kills, stat.deaths, stat.assists),
			Games:      stat.matches,
		})
	}

	sortBy := query.SortBy
	if sortBy == "" {
		sortBy = "games"
	}
	sort.Slice(result, func(i, j int) bool {
		switch sortBy {
		case "winrate":
			if result[i].Winrate == result[j].Winrate {
				return result[i].Games > result[j].Games
			}
			return result[i].Winrate > result[j].Winrate
		case "kda":
			if result[i].AverageKDA == result[j].AverageKDA {
				return result[i].Games > result[j].Games
			}
			return result[i].AverageKDA > result[j].AverageKDA
		default:
			if result[i].Games == result[j].Games {
				return result[i].Winrate > result[j].Winrate
			}
			return result[i].Games > result[j].Games
		}
	})
	return result
}

func normalizedSnapshot(snapshot *analyticsdomain.DotaSnapshot) map[string]any {
	return map[string]any{
		"steam_id":        snapshot.SteamID,
		"matches":         snapshot.Matches,
		"winrate":         snapshot.Winrate,
		"winrate_7_days":  snapshot.Winrate7Days,
		"winrate_30_days": snapshot.Winrate30Days,
		"winrate_90_days": snapshot.Winrate90Days,
		"average_kda":     snapshot.AverageKDA,
		"average_gpm":     snapshot.AverageGPM,
		"average_xpm":     snapshot.AverageXPM,
		"impact_score":    snapshot.ImpactScore,
		"stability_score": snapshot.StabilityScore,
		"farming_score":   snapshot.FarmingScore,
		"fighting_score":  snapshot.FightingScore,
		"objective_score": snapshot.ObjectiveScore,
		"top_heroes":      snapshot.TopHeroes,
		"worst_heroes":    snapshot.WorstHeroes,
	}
}

func winrateSince(matches []dotadomain.MatchSummary, cutoff time.Time) float64 {
	var total, wins int
	for _, match := range matches {
		if match.StartTime.Before(cutoff) {
			continue
		}
		total++
		if match.Won {
			wins++
		}
	}
	return percent(wins, total)
}

func stabilityScore(matches []dotadomain.MatchSummary) int {
	if len(matches) < 4 {
		return 50
	}
	var swings int
	for i := 1; i < len(matches); i++ {
		if matches[i].Won != matches[i-1].Won {
			swings++
		}
	}
	return clampInt(100-(swings*100)/(len(matches)-1), 0, 100)
}

func takeHeroes(heroes []analyticsdomain.HeroPeriodStats, limit int) []analyticsdomain.HeroPeriodStats {
	if len(heroes) <= limit {
		return heroes
	}
	return heroes[:limit]
}

func scoreRange(value, min, max float64) int {
	if max <= min {
		return 0
	}
	return clampInt(int((value-min)/(max-min)*100), 0, 100)
}

func clampInt(value, min, max int) int {
	if value < min {
		return min
	}
	if value > max {
		return max
	}
	return value
}

func average(total, count int) float64 {
	if count == 0 {
		return 0
	}
	return round2(float64(total) / float64(count))
}

func percent(value, total int) float64 {
	if total == 0 {
		return 0
	}
	return round2(float64(value) / float64(total) * 100)
}

func kda(kills, deaths, assists int) float64 {
	if deaths == 0 {
		return float64(kills + assists)
	}
	return round2(float64(kills+assists) / float64(deaths))
}

func round2(value float64) float64 {
	return float64(int(value*100+0.5)) / 100
}
