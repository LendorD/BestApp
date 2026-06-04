package application

import "time"

type HeroStatsQuery struct {
	From       *time.Time
	To         *time.Time
	MinMatches int
	SortBy     string
}

type DotaLabQuery struct {
	Period string
	Role   string
}

type DotaLabDashboard struct {
	SteamID         string                 `json:"steam_id"`
	Period          string                 `json:"period"`
	Role            string                 `json:"role"`
	Player          DotaLabPlayer          `json:"player"`
	Summary         DotaLabSummary         `json:"summary"`
	Performance     PerformanceScore       `json:"performance"`
	ProComparison   ProComparison          `json:"pro_comparison"`
	HeroPerformance HeroPerformanceSection `json:"hero_performance"`
	FormTimeline    FormTimeline           `json:"form_timeline"`
	Weaknesses      []Weakness             `json:"weaknesses"`
	AICoach         AICoachPreview         `json:"ai_coach"`
	TrainingPlan    TrainingPlan           `json:"training_plan"`
	Matches         []DotaLabMatch         `json:"matches"`
	GeneratedAt     time.Time              `json:"generated_at"`
}

type DotaLabPlayer struct {
	SteamID      string  `json:"steam_id"`
	AccountID    int64   `json:"account_id"`
	PersonaName  string  `json:"persona_name"`
	AvatarFull   string  `json:"avatar_full"`
	ProfileURL   string  `json:"profile_url"`
	RankTier     *int    `json:"rank_tier,omitempty"`
	RankLabel    string  `json:"rank_label"`
	Matches      int     `json:"matches"`
	Winrate      float64 `json:"winrate"`
	FavoriteRole string  `json:"favorite_role"`
	CurrentForm  string  `json:"current_form"`
}

type DotaLabSummary struct {
	Matches                int     `json:"matches"`
	Wins                   int     `json:"wins"`
	Losses                 int     `json:"losses"`
	Winrate                float64 `json:"winrate"`
	AverageKills           float64 `json:"average_kills"`
	AverageDeaths          float64 `json:"average_deaths"`
	AverageAssists         float64 `json:"average_assists"`
	AverageKDA             float64 `json:"average_kda"`
	AverageGPM             float64 `json:"average_gpm"`
	AverageXPM             float64 `json:"average_xpm"`
	AverageLastHits        float64 `json:"average_last_hits"`
	AverageHeroDamage      float64 `json:"average_hero_damage"`
	AverageTowerDamage     float64 `json:"average_tower_damage"`
	AverageHeroHealing     float64 `json:"average_hero_healing"`
	AverageDurationMinutes float64 `json:"average_duration_minutes"`
}

type PerformanceScore struct {
	Total     int               `json:"total"`
	Breakdown []PerformancePart `json:"breakdown"`
}

type PerformancePart struct {
	Key   string `json:"key"`
	Label string `json:"label"`
	Score int    `json:"score"`
}

type ProComparison struct {
	Metrics []ComparisonMetric `json:"metrics"`
	Series  []ComparisonSeries `json:"series"`
}

type ComparisonMetric struct {
	Key      string  `json:"key"`
	Label    string  `json:"label"`
	MinValue float64 `json:"min_value"`
	MaxValue float64 `json:"max_value"`
	Suffix   string  `json:"suffix,omitempty"`
	Decimals int     `json:"decimals"`
}

type ComparisonSeries struct {
	ID     string                 `json:"id"`
	Name   string                 `json:"name"`
	Color  string                 `json:"color"`
	Values map[string]MetricValue `json:"values"`
}

type MetricValue struct {
	Raw        float64 `json:"raw"`
	Normalized float64 `json:"normalized"`
}

type HeroPerformanceSection struct {
	Best    []HeroPerformance `json:"best"`
	Problem []HeroPerformance `json:"problem"`
}

type HeroPerformance struct {
	HeroID     int     `json:"hero_id"`
	Role       string  `json:"role"`
	Matches    int     `json:"matches"`
	Wins       int     `json:"wins"`
	Losses     int     `json:"losses"`
	Winrate    float64 `json:"winrate"`
	AverageKDA float64 `json:"average_kda"`
	AverageGPM float64 `json:"average_gpm"`
}

type FormTimeline struct {
	Matches []FormPoint `json:"matches"`
	Peak    *FormPoint  `json:"peak,omitempty"`
	Low     *FormPoint  `json:"low,omitempty"`
}

type FormPoint struct {
	Index     int       `json:"index"`
	MatchID   string    `json:"match_id"`
	HeroID    int       `json:"hero_id"`
	Won       bool      `json:"won"`
	Score     float64   `json:"score"`
	KDA       float64   `json:"kda"`
	StartTime time.Time `json:"start_time"`
}

type Weakness struct {
	Key      string `json:"key"`
	Title    string `json:"title"`
	Severity string `json:"severity"`
	Message  string `json:"message"`
}

type AICoachPreview struct {
	Title                string        `json:"title"`
	MainProblem          string        `json:"main_problem"`
	EstimatedWinrateLoss string        `json:"estimated_winrate_loss"`
	ReportPreview        ReportPreview `json:"report_preview"`
	PrimaryAction        string        `json:"primary_action"`
}

type ReportPreview struct {
	StrengthsCount       int `json:"strengths_count"`
	MistakesCount        int `json:"mistakes_count"`
	RecommendationsCount int `json:"recommendations_count"`
	TrainingPlansCount   int `json:"training_plans_count"`
}

type TrainingPlan struct {
	Week  int                `json:"week"`
	Items []TrainingPlanItem `json:"items"`
}

type TrainingPlanItem struct {
	Day   string `json:"day"`
	Title string `json:"title"`
	Focus string `json:"focus"`
}

type DotaLabMatch struct {
	MatchID         string    `json:"match_id"`
	Won             bool      `json:"won"`
	HeroID          int       `json:"hero_id"`
	Role            string    `json:"role"`
	Kills           int       `json:"kills"`
	Deaths          int       `json:"deaths"`
	Assists         int       `json:"assists"`
	GoldPerMin      int       `json:"gold_per_min"`
	XPPerMin        int       `json:"xp_per_min"`
	LastHits        int       `json:"last_hits"`
	HeroDamage      int       `json:"hero_damage"`
	TowerDamage     int       `json:"tower_damage"`
	DurationSeconds int       `json:"duration_seconds"`
	StartTime       time.Time `json:"start_time"`
}
