package domain

import (
	"time"

	dotadomain "gamementor/internal/modules/dota/domain"
)

type DotaSnapshot struct {
	SteamID        string                    `json:"steam_id"`
	Matches        int                       `json:"matches"`
	Wins           int                       `json:"wins"`
	Losses         int                       `json:"losses"`
	Winrate        float64                   `json:"winrate"`
	Winrate7Days   float64                   `json:"winrate_7_days"`
	Winrate30Days  float64                   `json:"winrate_30_days"`
	Winrate90Days  float64                   `json:"winrate_90_days"`
	AverageKDA     float64                   `json:"average_kda"`
	AverageGPM     float64                   `json:"average_gpm"`
	AverageXPM     float64                   `json:"average_xpm"`
	ImpactScore    int                       `json:"impact_score"`
	StabilityScore int                       `json:"stability_score"`
	FarmingScore   int                       `json:"farming_score"`
	FightingScore  int                       `json:"fighting_score"`
	ObjectiveScore int                       `json:"objective_score"`
	TopHeroes      []HeroPeriodStats         `json:"top_heroes"`
	WorstHeroes    []HeroPeriodStats         `json:"worst_heroes"`
	Normalized     map[string]any            `json:"normalized"`
	SourceMatches  []dotadomain.MatchSummary `json:"-"`
	CreatedAt      time.Time                 `json:"created_at"`
}

type HeroPeriodStats struct {
	HeroID     int     `json:"hero_id"`
	Matches    int     `json:"matches"`
	Wins       int     `json:"wins"`
	Losses     int     `json:"losses"`
	Winrate    float64 `json:"winrate"`
	AverageKDA float64 `json:"average_kda"`
	Games      int     `json:"games"`
}
