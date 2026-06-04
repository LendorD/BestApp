package opendota

import (
	"encoding/json"
	"testing"
	"time"

	legacydomain "gamementor/internal/domain"
)

func TestFromLegacyMatchNormalizesOpenDotaMatch(t *testing.T) {
	averageRank := 54
	partySize := 2
	started := time.Date(2026, 6, 4, 12, 0, 0, 0, time.UTC)
	match := fromLegacyMatch(legacydomain.DotaPlayerMatch{
		MatchID:         42,
		AccountID:       123,
		PlayerSlot:      129,
		RadiantWin:      false,
		Won:             true,
		HeroID:          8,
		Kills:           11,
		Deaths:          3,
		Assists:         15,
		GoldPerMin:      640,
		XPPerMin:        720,
		LastHits:        260,
		HeroDamage:      24000,
		TowerDamage:     3500,
		HeroHealing:     100,
		AverageRank:     &averageRank,
		PartySize:       &partySize,
		GameMode:        22,
		DurationSeconds: 2400,
		StartTime:       started,
		Raw:             json.RawMessage(`{"match_id":42}`),
	})

	if match.MatchID != "42" || match.AccountID != 123 || match.HeroID != 8 {
		t.Fatalf("unexpected identity fields: %+v", match)
	}
	if !match.Won || match.RadiantWin {
		t.Fatalf("unexpected win fields: won=%v radiant_win=%v", match.Won, match.RadiantWin)
	}
	if match.GoldPerMin != 640 || match.XPPerMin != 720 || match.TowerDamage != 3500 {
		t.Fatalf("extra stats were not normalized: %+v", match)
	}
	if match.StartTime != started || string(match.RawJSON) != `{"match_id":42}` {
		t.Fatalf("raw or start time mismatch: %+v", match)
	}
}
