package application

import (
	"testing"
	"time"

	dotadomain "gamementor/internal/modules/dota/domain"
)

func TestCalculateDotaSnapshot(t *testing.T) {
	now := time.Date(2026, 6, 4, 12, 0, 0, 0, time.UTC)
	matches := []dotadomain.MatchSummary{
		{HeroID: 1, Won: true, Kills: 10, Deaths: 2, Assists: 8, GoldPerMin: 620, XPPerMin: 710, HeroDamage: 22000, TowerDamage: 1800, StartTime: now.AddDate(0, 0, -1)},
		{HeroID: 1, Won: false, Kills: 6, Deaths: 6, Assists: 9, GoldPerMin: 480, XPPerMin: 560, HeroDamage: 15000, TowerDamage: 300, StartTime: now.AddDate(0, 0, -2)},
		{HeroID: 8, Won: true, Kills: 14, Deaths: 3, Assists: 12, GoldPerMin: 700, XPPerMin: 820, HeroDamage: 31000, TowerDamage: 4000, StartTime: now.AddDate(0, 0, -20)},
	}

	snapshot := CalculateDotaSnapshot("123", matches, now)
	if snapshot.Winrate != 66.67 {
		t.Fatalf("unexpected winrate: %.2f", snapshot.Winrate)
	}
	if snapshot.Winrate7Days != 50 {
		t.Fatalf("unexpected 7 day winrate: %.2f", snapshot.Winrate7Days)
	}
	if snapshot.AverageKDA != 5.36 {
		t.Fatalf("unexpected kda: %.2f", snapshot.AverageKDA)
	}
	if len(snapshot.TopHeroes) != 2 {
		t.Fatalf("expected top heroes, got %d", len(snapshot.TopHeroes))
	}
	if snapshot.FarmingScore <= 0 || snapshot.ImpactScore <= 0 {
		t.Fatalf("expected positive scores: farming=%d impact=%d", snapshot.FarmingScore, snapshot.ImpactScore)
	}
	if snapshot.Normalized["steam_id"] != "123" {
		t.Fatalf("snapshot not normalized")
	}
}

func TestHeroStatsForPeriodSortAndFilters(t *testing.T) {
	now := time.Date(2026, 6, 4, 12, 0, 0, 0, time.UTC)
	from := now.AddDate(0, 0, -7)
	matches := []dotadomain.MatchSummary{
		{HeroID: 1, Won: true, Kills: 8, Deaths: 2, Assists: 6, StartTime: now.AddDate(0, 0, -1)},
		{HeroID: 1, Won: true, Kills: 8, Deaths: 4, Assists: 4, StartTime: now.AddDate(0, 0, -2)},
		{HeroID: 2, Won: false, Kills: 2, Deaths: 8, Assists: 4, StartTime: now.AddDate(0, 0, -3)},
		{HeroID: 3, Won: true, Kills: 20, Deaths: 0, Assists: 1, StartTime: now.AddDate(0, 0, -30)},
	}

	heroes := HeroStatsForPeriod(matches, HeroStatsQuery{
		From:       &from,
		MinMatches: 2,
		SortBy:     "winrate",
	})
	if len(heroes) != 1 {
		t.Fatalf("expected one hero after min match filter, got %d", len(heroes))
	}
	if heroes[0].HeroID != 1 || heroes[0].Winrate != 100 {
		t.Fatalf("unexpected hero stats: %+v", heroes[0])
	}
}
