package domain

import (
	"encoding/json"
	"time"
)

type DotaPlayer struct {
	AccountID   int64           `json:"account_id"`
	PersonaName string          `json:"persona_name"`
	AvatarFull  string          `json:"avatar_full"`
	ProfileURL  string          `json:"profile_url"`
	RankTier    *int            `json:"rank_tier,omitempty"`
	Raw         json.RawMessage `json:"-"`
	CreatedAt   time.Time       `json:"created_at,omitempty"`
	UpdatedAt   time.Time       `json:"updated_at,omitempty"`
}

type DotaPlayerMatch struct {
	MatchID         int64           `json:"match_id"`
	AccountID       int64           `json:"account_id"`
	PlayerSlot      int             `json:"player_slot"`
	RadiantWin      bool            `json:"radiant_win"`
	Won             bool            `json:"won"`
	HeroID          int             `json:"hero_id"`
	Kills           int             `json:"kills"`
	Deaths          int             `json:"deaths"`
	Assists         int             `json:"assists"`
	DurationSeconds int             `json:"duration_seconds"`
	StartTime       time.Time       `json:"start_time"`
	Raw             json.RawMessage `json:"-"`
	CreatedAt       time.Time       `json:"created_at,omitempty"`
	UpdatedAt       time.Time       `json:"updated_at,omitempty"`
}

type DotaHeroSummary struct {
	HeroID  int     `json:"hero_id"`
	Matches int     `json:"matches"`
	Wins    int     `json:"wins"`
	Winrate float64 `json:"winrate"`
}

type DotaSummary struct {
	AccountID   int64             `json:"account_id"`
	Matches     int               `json:"matches"`
	Wins        int               `json:"wins"`
	Losses      int               `json:"losses"`
	Winrate     float64           `json:"winrate"`
	AvgKills    float64           `json:"average_kills"`
	AvgDeaths   float64           `json:"average_deaths"`
	AvgAssists  float64           `json:"average_assists"`
	KDA         float64           `json:"kda"`
	TopHeroes   []DotaHeroSummary `json:"top_heroes"`
	SnapshotID  int64             `json:"snapshot_id,omitempty"`
	Snapshotted time.Time         `json:"snapshotted_at,omitempty"`
}

type DotaPlayerSnapshot struct {
	ID         int64             `json:"id"`
	AccountID  int64             `json:"account_id"`
	Matches    int               `json:"matches"`
	Wins       int               `json:"wins"`
	Losses     int               `json:"losses"`
	Winrate    float64           `json:"winrate"`
	AvgKills   float64           `json:"average_kills"`
	AvgDeaths  float64           `json:"average_deaths"`
	AvgAssists float64           `json:"average_assists"`
	KDA        float64           `json:"kda"`
	TopHeroes  []DotaHeroSummary `json:"top_heroes"`
	CreatedAt  time.Time         `json:"created_at"`
}
