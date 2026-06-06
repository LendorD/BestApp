// Package application implements the unified windowed statistics service.
// It is the single source of truth for player metrics: it pulls a window of
// recent matches from OpenDota, computes ~20 metrics, turns the core ones into
// bracket percentiles via OpenDota benchmarks, derives sub-scores and an
// overall GameMentor Score, and attaches Stratz IMP when available.
package application

import (
	"context"
	"encoding/json"
	"math"
	"sort"
	"strconv"
	"strings"

	"gamementor/internal/clients/opendota"
	"gamementor/internal/clients/stratz"
	"gamementor/internal/domain"
)

type Service struct {
	od     *opendota.Client
	stratz *stratz.Client
}

func NewService(od *opendota.Client, st *stratz.Client) *Service {
	return &Service{od: od, stratz: st}
}

// --- output shapes ---

type Metric struct {
	Key        string   `json:"key"`
	Label      string   `json:"label"`
	Value      float64  `json:"value"`
	Unit       string   `json:"unit"`
	Group      string   `json:"group"`
	Percentile *float64 `json:"percentile,omitempty"` // 0..100, vs hero/bracket benchmark
}

type Scores struct {
	Farm       int `json:"farm"`
	Fighting   int `json:"fighting"`
	Objectives int `json:"objectives"`
	Vision     int `json:"vision"`
	Stability  int `json:"stability"`
	Overall    int `json:"overall"`
}

type Report struct {
	AccountID     int64    `json:"account_id"`
	Games         int      `json:"games"`
	WindowDays    int      `json:"window_days"`
	AvgDuration   int      `json:"avg_duration_seconds"`
	WinratePct    float64  `json:"winrate_pct"`
	Metrics       []Metric `json:"metrics"`
	Scores        Scores   `json:"scores"`
	AvgIMP        *float64 `json:"avg_imp,omitempty"`
	BenchmarkHero int      `json:"benchmark_hero,omitempty"`
	Notes         []string `json:"notes,omitempty"`
}

// projected match shape (matches GetMatchesProjected projections)
type pmatch struct {
	MatchID     int64 `json:"match_id"`
	PlayerSlot  int   `json:"player_slot"`
	RadiantWin  bool  `json:"radiant_win"`
	Duration    int   `json:"duration"`
	HeroID      int   `json:"hero_id"`
	Kills       int   `json:"kills"`
	Deaths      int   `json:"deaths"`
	Assists     int   `json:"assists"`
	GoldPerMin  int   `json:"gold_per_min"`
	XPPerMin    int   `json:"xp_per_min"`
	LastHits    int   `json:"last_hits"`
	Denies      int   `json:"denies"`
	HeroDamage  int   `json:"hero_damage"`
	TowerDamage int   `json:"tower_damage"`
	HeroHealing int   `json:"hero_healing"`
	ObsPlaced   int   `json:"obs_placed"`
	SenPlaced   int   `json:"sen_placed"`
	CampsStack  int   `json:"camps_stacked"`
}

// Build computes the report for the given window. days<=0 means "no date limit"
// (use limit only); limit caps the number of matches considered.
func (s *Service) Build(ctx context.Context, steamID string, days, limit int) (*Report, error) {
	accountID, err := strconv.ParseInt(strings.TrimSpace(steamID), 10, 64)
	if err != nil || accountID <= 0 {
		return nil, domain.ValidationError("steam_id must be a numeric account id")
	}
	if limit <= 0 || limit > 200 {
		limit = 50
	}

	raw, err := s.od.GetMatchesProjected(ctx, accountID, days, limit)
	if err != nil {
		return nil, err
	}
	var matches []pmatch
	if err := json.Unmarshal(raw, &matches); err != nil {
		return nil, domain.ExternalError("decode matches: " + err.Error())
	}

	report := &Report{AccountID: accountID, WindowDays: days, Games: len(matches)}
	if len(matches) == 0 {
		report.Notes = append(report.Notes, "no matches in window")
		return report, nil
	}

	var (
		wins                                                              int
		sumK, sumD, sumA                                                  float64
		sumDur                                                            float64
		sumGPM, sumXPM, sumDenies, sumTower, sumWards, sumStacks          float64
		sumCSmin, sumHeroDmgMin, sumHealMin                               float64
		heroCount                                                         = map[int]int{}
	)

	for _, m := range matches {
		isRadiant := m.PlayerSlot < 128
		if (isRadiant && m.RadiantWin) || (!isRadiant && !m.RadiantWin) {
			wins++
		}
		mins := float64(m.Duration) / 60
		if mins <= 0 {
			mins = 1
		}
		sumDur += float64(m.Duration)
		sumK += float64(m.Kills)
		sumD += float64(m.Deaths)
		sumA += float64(m.Assists)
		sumGPM += float64(m.GoldPerMin)
		sumXPM += float64(m.XPPerMin)
		sumDenies += float64(m.Denies)
		sumTower += float64(m.TowerDamage)
		sumWards += float64(m.ObsPlaced + m.SenPlaced)
		sumStacks += float64(m.CampsStack)
		sumCSmin += float64(m.LastHits) / mins
		sumHeroDmgMin += float64(m.HeroDamage) / mins
		sumHealMin += float64(m.HeroHealing) / mins
		heroCount[m.HeroID]++
	}

	n := float64(len(matches))
	report.AvgDuration = int(sumDur / n)
	report.WinratePct = round1(float64(wins) / n * 100)
	kda := (sumK + sumA) / math.Max(sumD, 1)

	avgGPM := sumGPM / n
	avgXPM := sumXPM / n
	avgCSmin := sumCSmin / n
	avgHeroDmgMin := sumHeroDmgMin / n
	avgHealMin := sumHealMin / n

	// Benchmarks for the most-played hero in the window → percentiles.
	benchHero := topKey(heroCount)
	report.BenchmarkHero = benchHero
	bench := s.benchmarks(ctx, benchHero)

	pct := func(key string, value float64) *float64 {
		if bench == nil {
			return nil
		}
		if p, ok := bench.percentile(key, value); ok {
			return &p
		}
		return nil
	}

	report.Metrics = []Metric{
		{Key: "winrate", Label: "Винрейт", Value: report.WinratePct, Unit: "%", Group: "Итог"},
		{Key: "kda", Label: "KDA", Value: round2(kda), Unit: "", Group: "Бой"},
		{Key: "gpm", Label: "GPM", Value: round1(avgGPM), Unit: "", Group: "Фарм", Percentile: pct("gold_per_min", avgGPM)},
		{Key: "xpm", Label: "XPM", Value: round1(avgXPM), Unit: "", Group: "Фарм", Percentile: pct("xp_per_min", avgXPM)},
		{Key: "cs_min", Label: "CS/мин", Value: round1(avgCSmin), Unit: "", Group: "Фарм", Percentile: pct("last_hits_per_min", avgCSmin)},
		{Key: "denies", Label: "Денаи/игра", Value: round1(sumDenies / n), Unit: "", Group: "Фарм"},
		{Key: "kills", Label: "Убийства/игра", Value: round1(sumK / n), Unit: "", Group: "Бой"},
		{Key: "deaths", Label: "Смерти/игра", Value: round1(sumD / n), Unit: "", Group: "Бой"},
		{Key: "assists", Label: "Помощи/игра", Value: round1(sumA / n), Unit: "", Group: "Бой"},
		{Key: "hero_dmg_min", Label: "Урон/мин", Value: round1(avgHeroDmgMin), Unit: "", Group: "Бой", Percentile: pct("hero_damage_per_min", avgHeroDmgMin)},
		{Key: "tower_dmg", Label: "Урон по башням/игра", Value: round1(sumTower / n), Unit: "", Group: "Объекты", Percentile: pct("tower_damage", sumTower/n)},
		{Key: "heal_min", Label: "Хил/мин", Value: round1(avgHealMin), Unit: "", Group: "Поддержка", Percentile: pct("hero_healing_per_min", avgHealMin)},
		{Key: "wards", Label: "Варды/игра", Value: round1(sumWards / n), Unit: "", Group: "Вижн"},
		{Key: "stacks", Label: "Стаки/игра", Value: round1(sumStacks / n), Unit: "", Group: "Вижн"},
		{Key: "duration", Label: "Ср. матч (мин)", Value: round1(sumDur / n / 60), Unit: "мин", Group: "Темп"},
	}

	// Stratz IMP (optional).
	if s.stratz != nil && s.stratz.Enabled() {
		if card, err := s.stratz.ExplorePlayer(ctx, accountID); err == nil && card != nil && card.AvgIMP != nil {
			report.AvgIMP = card.AvgIMP
		}
	}

	report.Scores = s.scores(report, kda)
	return report, nil
}

// scores converts metrics/percentiles into 0..100 sub-scores. Where a benchmark
// percentile exists we use it; otherwise we fall back to simple normalization.
func (s *Service) scores(r *Report, kda float64) Scores {
	get := func(key string) *float64 {
		for i := range r.Metrics {
			if r.Metrics[i].Key == key {
				return r.Metrics[i].Percentile
			}
		}
		return nil
	}
	avgP := func(keys ...string) float64 {
		var sum, cnt float64
		for _, k := range keys {
			if p := get(k); p != nil {
				sum += *p
				cnt++
			}
		}
		if cnt == 0 {
			return 50
		}
		return sum / cnt
	}

	farm := avgP("gpm", "xpm", "cs_min")
	objectives := avgP("tower_dmg")

	// Fighting: blend hero-damage percentile with a KDA curve (KDA 4 ~ 75).
	dmgP := 50.0
	if p := get("hero_dmg_min"); p != nil {
		dmgP = *p
	}
	kdaScore := clamp(kda/6*100, 0, 100)
	fighting := (dmgP + kdaScore) / 2

	// Vision: scale wards/stacks (rough, no public benchmark).
	wards := metricValue(r, "wards")
	stacks := metricValue(r, "stacks")
	vision := clamp(wards/10*70+stacks/4*30, 0, 100)

	// Stability: fewer deaths + winrate.
	deaths := metricValue(r, "deaths")
	deathScore := clamp(100-deaths*8, 0, 100)
	stability := clamp(deathScore*0.5+r.WinratePct*0.5, 0, 100)

	overall := (farm*0.3 + fighting*0.3 + objectives*0.15 + stability*0.15 + vision*0.1)
	return Scores{
		Farm:       int(math.Round(farm)),
		Fighting:   int(math.Round(fighting)),
		Objectives: int(math.Round(objectives)),
		Vision:     int(math.Round(vision)),
		Stability:  int(math.Round(stability)),
		Overall:    int(math.Round(overall)),
	}
}

// ReviewContext renders a compact text block of the player's recent-form
// metrics (with percentiles, sub-scores and IMP) for the AI Coach prompt.
// Best-effort: returns "" if nothing useful could be gathered.
func (s *Service) ReviewContext(ctx context.Context, steamID string) string {
	report, err := s.Build(ctx, steamID, 0, 50)
	if err != nil || report == nil || report.Games == 0 {
		return ""
	}
	var b strings.Builder
	b.WriteString("WINDOWED METRICS (last ")
	b.WriteString(strconv.Itoa(report.Games))
	b.WriteString(" games)\n")
	for _, m := range report.Metrics {
		b.WriteString("- ")
		b.WriteString(m.Label)
		b.WriteString(": ")
		b.WriteString(strconv.FormatFloat(m.Value, 'f', -1, 64))
		if m.Unit != "" {
			b.WriteString(m.Unit)
		}
		if m.Percentile != nil {
			b.WriteString(" (")
			b.WriteString(strconv.FormatFloat(*m.Percentile, 'f', 0, 64))
			b.WriteString("th percentile vs hero bracket)")
		}
		b.WriteString("\n")
	}
	sc := report.Scores
	b.WriteString("- Sub-scores (0-100): Farm ")
	b.WriteString(strconv.Itoa(sc.Farm))
	b.WriteString(", Fighting ")
	b.WriteString(strconv.Itoa(sc.Fighting))
	b.WriteString(", Objectives ")
	b.WriteString(strconv.Itoa(sc.Objectives))
	b.WriteString(", Vision ")
	b.WriteString(strconv.Itoa(sc.Vision))
	b.WriteString(", Stability ")
	b.WriteString(strconv.Itoa(sc.Stability))
	b.WriteString(", Overall ")
	b.WriteString(strconv.Itoa(sc.Overall))
	b.WriteString("\n")
	if report.AvgIMP != nil {
		b.WriteString("- Stratz average IMP (impact on win, -100..+100): ")
		b.WriteString(strconv.FormatFloat(*report.AvgIMP, 'f', 1, 64))
		b.WriteString("\n")
	}
	return b.String()
}

// --- benchmarks ---

type benchData struct {
	result map[string][]struct {
		Percentile float64 `json:"percentile"`
		Value      float64 `json:"value"`
	}
}

func (s *Service) benchmarks(ctx context.Context, heroID int) *benchData {
	if heroID <= 0 {
		return nil
	}
	raw, err := s.od.GetBenchmarks(ctx, heroID)
	if err != nil {
		return nil
	}
	var parsed struct {
		Result map[string][]struct {
			Percentile float64 `json:"percentile"`
			Value      float64 `json:"value"`
		} `json:"result"`
	}
	if json.Unmarshal(raw, &parsed) != nil || len(parsed.Result) == 0 {
		return nil
	}
	return &benchData{result: parsed.Result}
}

// percentile maps a raw value to its percentile (0..100) for the metric key.
func (b *benchData) percentile(key string, value float64) (float64, bool) {
	buckets, ok := b.result[key]
	if !ok || len(buckets) == 0 {
		return 0, false
	}
	sort.Slice(buckets, func(i, j int) bool { return buckets[i].Percentile < buckets[j].Percentile })
	p := buckets[0].Percentile * 100
	for _, bucket := range buckets {
		if value >= bucket.Value {
			p = bucket.Percentile * 100
		} else {
			break
		}
	}
	return round1(p), true
}

// --- helpers ---

func metricValue(r *Report, key string) float64 {
	for i := range r.Metrics {
		if r.Metrics[i].Key == key {
			return r.Metrics[i].Value
		}
	}
	return 0
}

func topKey(m map[int]int) int {
	best, bestN := 0, -1
	for k, v := range m {
		if v > bestN {
			best, bestN = k, v
		}
	}
	return best
}

func clamp(v, lo, hi float64) float64 {
	if v < lo {
		return lo
	}
	if v > hi {
		return hi
	}
	return v
}

func round1(v float64) float64 { return math.Round(v*10) / 10 }
func round2(v float64) float64 { return math.Round(v*100) / 100 }
