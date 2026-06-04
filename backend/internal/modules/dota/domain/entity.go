package domain

import (
	"encoding/json"
	"time"
)

type PlayerProfile struct {
	SteamID     string          `json:"steam_id"`
	AccountID   int64           `json:"account_id"`
	PersonaName string          `json:"persona_name"`
	AvatarFull  string          `json:"avatar_full"`
	ProfileURL  string          `json:"profile_url"`
	RankTier    *int            `json:"rank_tier,omitempty"`
	RawJSON     json.RawMessage `json:"-"`
	FetchedAt   time.Time       `json:"fetched_at,omitempty"`
}

type MatchSummary struct {
	MatchID         string          `json:"match_id"`
	AccountID       int64           `json:"account_id"`
	PlayerSlot      int             `json:"player_slot"`
	RadiantWin      bool            `json:"radiant_win"`
	Won             bool            `json:"won"`
	HeroID          int             `json:"hero_id"`
	Kills           int             `json:"kills"`
	Deaths          int             `json:"deaths"`
	Assists         int             `json:"assists"`
	GoldPerMin      int             `json:"gold_per_min"`
	XPPerMin        int             `json:"xp_per_min"`
	LastHits        int             `json:"last_hits"`
	HeroDamage      int             `json:"hero_damage"`
	TowerDamage     int             `json:"tower_damage"`
	HeroHealing     int             `json:"hero_healing"`
	AverageRank     *int            `json:"average_rank,omitempty"`
	PartySize       *int            `json:"party_size,omitempty"`
	GameMode        int             `json:"game_mode"`
	DurationSeconds int             `json:"duration_seconds"`
	StartTime       time.Time       `json:"start_time"`
	RawJSON         json.RawMessage `json:"-"`
}

type HeroStats struct {
	HeroID  int     `json:"hero_id"`
	Matches int     `json:"matches"`
	Wins    int     `json:"wins"`
	Losses  int     `json:"losses"`
	Winrate float64 `json:"winrate"`
	KDA     float64 `json:"kda"`
}

type MatchDetails struct {
	MatchID string          `json:"match_id"`
	RawJSON json.RawMessage `json:"raw_json,omitempty"`
}
