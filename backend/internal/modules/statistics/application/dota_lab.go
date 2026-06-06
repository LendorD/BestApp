package application

import (
	"context"
	"sort"
	"strings"
	"time"

	dotadomain "gamementor/internal/modules/dota/domain"
)

const (
	periodAll = "all"
	period7d  = "7d"
	period30d = "30d"
	period90d = "90d"

	roleAll      = "all"
	roleCarry    = "carry"
	roleMid      = "mid"
	roleOfflane  = "offlane"
	roleSupport4 = "support4"
	roleSupport5 = "support5"
)

func (s *Service) BuildDotaLabDashboard(ctx context.Context, steamID string, query DotaLabQuery) (*DotaLabDashboard, error) {
	period := normalizePeriod(query.Period)
	role := normalizeRole(query.Role)
	cacheKey := "analytics:dota:lab:" + steamID + ":" + period + ":" + role
	var cached DotaLabDashboard
	if s.cache != nil && s.cache.Get(ctx, cacheKey, &cached) == nil {
		return &cached, nil
	}

	profile, err := s.dota.GetPlayerProfile(ctx, steamID)
	if err != nil {
		return nil, err
	}
	matches, err := s.dota.GetRecentMatches(ctx, steamID, 100)
	if err != nil {
		return nil, err
	}

	dashboard := buildDotaLabDashboard(profile, matches, period, role, s.now().UTC())
	if s.cache != nil {
		_ = s.cache.Set(ctx, cacheKey, dashboard, 10*time.Minute)
	}
	return dashboard, nil
}

func (s *Service) RefreshDotaLabDashboard(ctx context.Context, steamID string, query DotaLabQuery) (*DotaLabDashboard, error) {
	period := normalizePeriod(query.Period)
	role := normalizeRole(query.Role)
	cacheKey := "analytics:dota:lab:" + steamID + ":" + period + ":" + role
	if s.cache != nil {
		_ = s.cache.Delete(ctx, cacheKey)
	}
	return s.BuildDotaLabDashboard(ctx, steamID, DotaLabQuery{Period: period, Role: role})
}

func buildDotaLabDashboard(profile *dotadomain.PlayerProfile, source []dotadomain.MatchSummary, period string, role string, now time.Time) *DotaLabDashboard {
	matches := filterDotaLabMatches(source, period, role, now)
	stats := calculateLabStats(matches)
	heroes := calculateHeroPerformance(matches)
	bestHeroes := takeHeroPerformance(heroes, 5)
	problemHeroes := problemHeroPerformance(heroes, 5)
	performance := calculatePerformanceScore(stats)
	weaknesses := buildWeaknesses(stats)
	mainProblem := buildMainProblem(stats)

	dashboard := &DotaLabDashboard{
		SteamID: profile.SteamID,
		Period:  period,
		Role:    role,
		Player: DotaLabPlayer{
			SteamID:      profile.SteamID,
			AccountID:    profile.AccountID,
			PersonaName:  profile.PersonaName,
			AvatarFull:   profile.AvatarFull,
			ProfileURL:   profile.ProfileURL,
			RankTier:     profile.RankTier,
			RankLabel:    rankLabel(profile.RankTier),
			Matches:      stats.Matches,
			Winrate:      stats.Winrate,
			FavoriteRole: favoriteRole(source),
			CurrentForm:  currentForm(performance.Total, stats.WinrateTrend),
		},
		Summary: DotaLabSummary{
			Matches:                stats.Matches,
			Wins:                   stats.Wins,
			Losses:                 stats.Losses,
			Winrate:                stats.Winrate,
			AverageKills:           stats.AverageKills,
			AverageDeaths:          stats.AverageDeaths,
			AverageAssists:         stats.AverageAssists,
			AverageKDA:             stats.AverageKDA,
			AverageGPM:             stats.AverageGPM,
			AverageXPM:             stats.AverageXPM,
			AverageLastHits:        stats.AverageLastHits,
			AverageHeroDamage:      stats.AverageHeroDamage,
			AverageTowerDamage:     stats.AverageTowerDamage,
			AverageHeroHealing:     stats.AverageHeroHealing,
			AverageDurationMinutes: stats.AverageDurationMinutes,
		},
		Performance:   performance,
		ProComparison: buildProComparison(stats),
		HeroPerformance: HeroPerformanceSection{
			Best:    bestHeroes,
			Problem: problemHeroes,
		},
		FormTimeline: buildFormTimeline(matches),
		Weaknesses:   weaknesses,
		AICoach: AICoachPreview{
			Title:                "AI Coach",
			MainProblem:          mainProblem,
			EstimatedWinrateLoss: "6-8%",
			ReportPreview: ReportPreview{
				StrengthsCount:       strengthsCount(performance),
				MistakesCount:        len(weaknesses),
				RecommendationsCount: recommendationsCount(stats),
				TrainingPlansCount:   1,
			},
			PrimaryAction: "Провести AI-анализ",
		},
		TrainingPlan: buildTrainingPlan(bestHeroes, role),
		Matches:      labMatches(matches),
		GeneratedAt:  now,
	}
	return dashboard
}

type labStats struct {
	Matches                int
	Wins                   int
	Losses                 int
	Winrate                float64
	AverageKills           float64
	AverageDeaths          float64
	AverageAssists         float64
	AverageKDA             float64
	AverageGPM             float64
	AverageXPM             float64
	AverageLastHits        float64
	AverageHeroDamage      float64
	AverageTowerDamage     float64
	AverageHeroHealing     float64
	AverageDurationMinutes float64
	WinrateTrend           string
	KDATrend               string
}

func calculateLabStats(matches []dotadomain.MatchSummary) labStats {
	stats := labStats{Matches: len(matches)}
	if len(matches) == 0 {
		stats.WinrateTrend = "stable"
		stats.KDATrend = "stable"
		return stats
	}

	var kills, deaths, assists, gpm, xpm, lastHits, heroDamage, towerDamage, heroHealing, duration int
	for _, match := range matches {
		if match.Won {
			stats.Wins++
		}
		kills += match.Kills
		deaths += match.Deaths
		assists += match.Assists
		gpm += match.GoldPerMin
		xpm += match.XPPerMin
		lastHits += match.LastHits
		heroDamage += match.HeroDamage
		towerDamage += match.TowerDamage
		heroHealing += match.HeroHealing
		duration += match.DurationSeconds
	}

	stats.Losses = stats.Matches - stats.Wins
	stats.Winrate = percent(stats.Wins, stats.Matches)
	stats.AverageKills = average(kills, stats.Matches)
	stats.AverageDeaths = average(deaths, stats.Matches)
	stats.AverageAssists = average(assists, stats.Matches)
	stats.AverageKDA = kda(kills, deaths, assists)
	stats.AverageGPM = average(gpm, stats.Matches)
	stats.AverageXPM = average(xpm, stats.Matches)
	stats.AverageLastHits = average(lastHits, stats.Matches)
	stats.AverageHeroDamage = average(heroDamage, stats.Matches)
	stats.AverageTowerDamage = average(towerDamage, stats.Matches)
	stats.AverageHeroHealing = average(heroHealing, stats.Matches)
	stats.AverageDurationMinutes = round2(float64(duration) / float64(stats.Matches) / 60)
	stats.WinrateTrend, stats.KDATrend = calculateTrends(matches)
	return stats
}

func calculatePerformanceScore(stats labStats) PerformanceScore {
	farm := scoreClamp(normalized(stats.AverageGPM, 320, 760)*56 + normalized(stats.AverageXPM, 380, 860)*34 + normalized(stats.AverageLastHits, 70, 320)*10)
	fights := scoreClamp(normalized(stats.AverageKDA, 1, 6.5)*48 + normalized(stats.AverageKills, 2, 13)*24 + normalized(stats.AverageHeroDamage, 7000, 36000)*28)
	objectives := scoreClamp(normalized(stats.AverageTowerDamage, 250, 5000)*78 + normalized(stats.Winrate, 35, 70)*22)
	stability := scoreClamp(normalized(stats.Winrate, 35, 70)*58 + normalized(9-stats.AverageDeaths, 1, 8)*42)
	teamplay := scoreClamp(normalized(stats.AverageAssists, 5, 22)*62 + normalized(stats.AverageHeroHealing, 0, 4200)*18 + normalized(stats.AverageKDA, 1, 6.5)*20)
	total := scoreClamp(float64(farm)*0.22 + float64(fights)*0.22 + float64(objectives)*0.18 + float64(stability)*0.22 + float64(teamplay)*0.16)

	return PerformanceScore{
		Total: total,
		Breakdown: []PerformancePart{
			{Key: "farm", Label: "Фарм", Score: farm},
			{Key: "fights", Label: "Драки", Score: fights},
			{Key: "objectives", Label: "Объекты", Score: objectives},
			{Key: "stability", Label: "Стабильность", Score: stability},
			{Key: "teamplay", Label: "Командная игра", Score: teamplay},
		},
	}
}

func buildProComparison(stats labStats) ProComparison {
	metrics := []ComparisonMetric{
		{Key: "gpm", Label: "GPM", MinValue: 300, MaxValue: 820},
		{Key: "xpm", Label: "XPM", MinValue: 350, MaxValue: 920},
		{Key: "kda", Label: "KDA", MinValue: 1, MaxValue: 7, Decimals: 1},
		{Key: "winrate", Label: "Winrate", MinValue: 35, MaxValue: 75, Suffix: "%"},
		{Key: "hero_damage", Label: "Hero Damage", MinValue: 7000, MaxValue: 42000},
		{Key: "tower_damage", Label: "Tower Damage", MinValue: 250, MaxValue: 6000},
		{Key: "last_hits", Label: "Last Hits", MinValue: 50, MaxValue: 360},
		{Key: "net_worth", Label: "Net Worth", MinValue: 9000, MaxValue: 33000},
	}
	rawSeries := []rawComparisonSeries{
		{
			ID: "player", Name: "Твой профиль", Color: "#2ECF84",
			Values: map[string]float64{
				"gpm": stats.AverageGPM, "xpm": stats.AverageXPM, "kda": stats.AverageKDA,
				"winrate": stats.Winrate, "hero_damage": stats.AverageHeroDamage,
				"tower_damage": stats.AverageTowerDamage, "last_hits": stats.AverageLastHits,
				"net_worth": stats.AverageGPM * stats.AverageDurationMinutes,
			},
		},
		{ID: "yatoro", Name: "Yatoro", Color: "#D6B84A", Values: map[string]float64{"gpm": 735, "xpm": 820, "kda": 5.4, "winrate": 63, "hero_damage": 31500, "tower_damage": 4100, "last_hits": 320, "net_worth": 29500}},
		{ID: "nisha", Name: "Nisha", Color: "#66D9EF", Values: map[string]float64{"gpm": 690, "xpm": 850, "kda": 5.8, "winrate": 61, "hero_damage": 34000, "tower_damage": 2600, "last_hits": 285, "net_worth": 28200}},
		{ID: "save", Name: "Save", Color: "#FF4D61", Values: map[string]float64{"gpm": 430, "xpm": 590, "kda": 4.6, "winrate": 62, "hero_damage": 17000, "tower_damage": 950, "last_hits": 75, "net_worth": 16800}},
		{ID: "collapse", Name: "Collapse", Color: "#9B7BFF", Values: map[string]float64{"gpm": 560, "xpm": 705, "kda": 4.8, "winrate": 60, "hero_damage": 26000, "tower_damage": 2200, "last_hits": 210, "net_worth": 23800}},
		{ID: "mira", Name: "Mira", Color: "#FF8A3D", Values: map[string]float64{"gpm": 395, "xpm": 565, "kda": 4.2, "winrate": 59, "hero_damage": 15500, "tower_damage": 800, "last_hits": 62, "net_worth": 15100}},
		{ID: "pure", Name: "Pure", Color: "#B8D660", Values: map[string]float64{"gpm": 710, "xpm": 810, "kda": 5.2, "winrate": 60, "hero_damage": 30500, "tower_damage": 3900, "last_hits": 310, "net_worth": 28900}},
		{ID: "malr1ne", Name: "Malr1ne", Color: "#FF6BAA", Values: map[string]float64{"gpm": 675, "xpm": 855, "kda": 5.1, "winrate": 60, "hero_damage": 36000, "tower_damage": 2100, "last_hits": 270, "net_worth": 27400}},
	}

	out := ProComparison{Metrics: metrics, Series: make([]ComparisonSeries, 0, len(rawSeries))}
	for _, series := range rawSeries {
		values := make(map[string]MetricValue, len(metrics))
		for _, metric := range metrics {
			raw := series.Values[metric.Key]
			values[metric.Key] = MetricValue{
				Raw:        round2(raw),
				Normalized: round2(normalized(raw, metric.MinValue, metric.MaxValue) * 100),
			}
		}
		out.Series = append(out.Series, ComparisonSeries{
			ID:     series.ID,
			Name:   series.Name,
			Color:  series.Color,
			Values: values,
		})
	}
	return out
}

type rawComparisonSeries struct {
	ID     string
	Name   string
	Color  string
	Values map[string]float64
}

func filterDotaLabMatches(source []dotadomain.MatchSummary, period string, role string, now time.Time) []dotadomain.MatchSummary {
	sorted := append([]dotadomain.MatchSummary(nil), source...)
	sort.Slice(sorted, func(i, j int) bool {
		return sorted[i].StartTime.After(sorted[j].StartTime)
	})

	var cutoff *time.Time
	var fallbackLimit int
	switch period {
	case period7d:
		value := now.AddDate(0, 0, -7)
		cutoff = &value
		fallbackLimit = 7
	case period30d:
		value := now.AddDate(0, 0, -30)
		cutoff = &value
		fallbackLimit = 30
	case period90d:
		value := now.AddDate(0, 0, -90)
		cutoff = &value
		fallbackLimit = 50
	}

	filtered := make([]dotadomain.MatchSummary, 0, len(sorted))
	for _, match := range sorted {
		if cutoff != nil && match.StartTime.Before(*cutoff) {
			continue
		}
		if role != roleAll && roleForMatch(match) != role {
			continue
		}
		filtered = append(filtered, match)
	}
	if len(filtered) == 0 && cutoff != nil && role == roleAll && len(sorted) > 0 {
		limit := fallbackLimit
		if limit <= 0 || limit > len(sorted) {
			limit = len(sorted)
		}
		return sorted[:limit]
	}
	return filtered
}

func calculateHeroPerformance(matches []dotadomain.MatchSummary) []HeroPerformance {
	type agg struct {
		matches int
		wins    int
		kills   int
		deaths  int
		assists int
		gpm     int
	}
	byHero := map[int]*agg{}
	for _, match := range matches {
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
		stat.gpm += match.GoldPerMin
	}

	heroes := make([]HeroPerformance, 0, len(byHero))
	for heroID, stat := range byHero {
		heroes = append(heroes, HeroPerformance{
			HeroID:     heroID,
			Role:       roleForHero(heroID),
			Matches:    stat.matches,
			Wins:       stat.wins,
			Losses:     stat.matches - stat.wins,
			Winrate:    percent(stat.wins, stat.matches),
			AverageKDA: kda(stat.kills, stat.deaths, stat.assists),
			AverageGPM: average(stat.gpm, stat.matches),
		})
	}
	sort.Slice(heroes, func(i, j int) bool {
		left := heroes[i].Winrate*0.58 + heroes[i].AverageKDA*8 + float64(heroes[i].Matches)*2
		right := heroes[j].Winrate*0.58 + heroes[j].AverageKDA*8 + float64(heroes[j].Matches)*2
		return left > right
	})
	return heroes
}

func problemHeroPerformance(heroes []HeroPerformance, limit int) []HeroPerformance {
	problems := make([]HeroPerformance, 0, len(heroes))
	for _, hero := range heroes {
		if hero.Matches >= 2 && hero.Winrate < 50 {
			problems = append(problems, hero)
		}
	}
	sort.Slice(problems, func(i, j int) bool {
		if problems[i].Winrate == problems[j].Winrate {
			return problems[i].Matches > problems[j].Matches
		}
		return problems[i].Winrate < problems[j].Winrate
	})
	return takeHeroPerformance(problems, limit)
}

func takeHeroPerformance(heroes []HeroPerformance, limit int) []HeroPerformance {
	if len(heroes) <= limit {
		return heroes
	}
	return heroes[:limit]
}

func buildFormTimeline(matches []dotadomain.MatchSummary) FormTimeline {
	limit := 50
	if len(matches) < limit {
		limit = len(matches)
	}
	sample := append([]dotadomain.MatchSummary(nil), matches[:limit]...)
	for i, j := 0, len(sample)-1; i < j; i, j = i+1, j-1 {
		sample[i], sample[j] = sample[j], sample[i]
	}

	points := make([]FormPoint, 0, len(sample))
	var peak *FormPoint
	var low *FormPoint
	for i, match := range sample {
		point := FormPoint{
			Index:     i,
			MatchID:   match.MatchID,
			HeroID:    match.HeroID,
			Won:       match.Won,
			Score:     matchFormScore(match),
			KDA:       kda(match.Kills, match.Deaths, match.Assists),
			StartTime: match.StartTime,
		}
		points = append(points, point)
		if peak == nil || point.Score > peak.Score {
			copy := point
			peak = &copy
		}
		if low == nil || point.Score < low.Score {
			copy := point
			low = &copy
		}
	}
	return FormTimeline{Matches: points, Peak: peak, Low: low}
}

func buildWeaknesses(stats labStats) []Weakness {
	items := make([]Weakness, 0, 5)
	if stats.AverageTowerDamage < 1000 {
		items = append(items, Weakness{Key: "objective_pressure", Title: "Низкий урон по строениям", Severity: "high", Message: "Преимущество после выигранных драк не конвертируется в вышки, Рошана и контроль карты."})
	}
	if stats.AverageGPM < 470 {
		items = append(items, Weakness{Key: "low_gpm", Title: "GPM ниже комфортного", Severity: "medium", Message: "После линии теряется темп фарма, из-за чего ключевые предметы приходят позже."})
	}
	if stats.AverageDeaths > 6.5 {
		items = append(items, Weakness{Key: "deaths", Title: "Слишком много смертей", Severity: "high", Message: "Часть ресурсов уходит в восстановление позиции вместо давления по карте."})
	}
	if stats.AverageAssists < 9 && stats.AverageKills < 7 {
		items = append(items, Weakness{Key: "kill_participation", Title: "Мало участия в убийствах", Severity: "medium", Message: "Игрок недостаточно часто участвует в ключевых драках и разменах."})
	}
	if stats.AverageKDA < 2.4 {
		items = append(items, Weakness{Key: "low_kda", Title: "KDA проседает", Severity: "medium", Message: "Нужно сократить рискованные выходы без обзора и телепортов союзников."})
	}
	if stats.Winrate < 50 {
		items = append(items, Weakness{Key: "winrate", Title: "Винрейт ниже 50%", Severity: "high", Message: "Пул героев и план первых 10 минут требуют стабилизации."})
	}
	if len(items) == 0 {
		items = append(items, Weakness{Key: "timings", Title: "Работа с таймингами", Severity: "low", Message: "Критичных слабых мест не видно: следующий рост даст точная игра вокруг объектов."})
	}
	return items
}

func buildMainProblem(stats labStats) string {
	switch {
	case stats.AverageTowerDamage < 1000:
		return "низкая реализация преимущества после выигранных драк"
	case stats.AverageDeaths > 6.5:
		return "слишком много смертей в середине игры"
	case stats.AverageGPM < 470:
		return "просадка экономики после стадии линий"
	case stats.Winrate < 50:
		return "нестабильный пул героев и слабый стартовый план"
	default:
		return "сильные тайминги недостаточно быстро превращаются в объекты"
	}
}

func buildTrainingPlan(bestHeroes []HeroPerformance, role string) TrainingPlan {
	heroFocus := "основном герое"
	if len(bestHeroes) > 0 {
		heroFocus = "герое #" + itoa(bestHeroes[0].HeroID)
	}
	return TrainingPlan{
		Week: 1,
		Items: []TrainingPlanItem{
			{Day: "Понедельник", Title: "2 игры на " + heroFocus, Focus: "стабилизировать пул"},
			{Day: "Вторник", Title: "Разбор одного проигранного реплея", Focus: "найти повторяющиеся ошибки"},
			{Day: "Среда", Title: "Тренировка первых 10 минут", Focus: "лейнинг и стартовый план"},
			{Day: "Четверг", Title: "3 рейтинговые игры на роли " + role, Focus: "закрепить решения"},
			{Day: "Пятница", Title: "Проверка объектов после выигранных драк", Focus: "конверсия преимущества"},
		},
	}
}

func labMatches(matches []dotadomain.MatchSummary) []DotaLabMatch {
	limit := 20
	if len(matches) < limit {
		limit = len(matches)
	}
	out := make([]DotaLabMatch, 0, limit)
	for _, match := range matches[:limit] {
		out = append(out, DotaLabMatch{
			MatchID:         match.MatchID,
			Won:             match.Won,
			HeroID:          match.HeroID,
			Role:            roleForMatch(match),
			Kills:           match.Kills,
			Deaths:          match.Deaths,
			Assists:         match.Assists,
			GoldPerMin:      match.GoldPerMin,
			XPPerMin:        match.XPPerMin,
			LastHits:        match.LastHits,
			HeroDamage:      match.HeroDamage,
			TowerDamage:     match.TowerDamage,
			DurationSeconds: match.DurationSeconds,
			StartTime:       match.StartTime,
		})
	}
	return out
}

func calculateTrends(matches []dotadomain.MatchSummary) (string, string) {
	if len(matches) < 6 {
		return "stable", "stable"
	}
	half := len(matches) / 2
	recent := matches[:half]
	previous := matches[half:]
	return trend(winrate(recent)-winrate(previous), 5, -5),
		trend(kdaForMatches(recent)-kdaForMatches(previous), 0.35, -0.35)
}

func winrate(matches []dotadomain.MatchSummary) float64 {
	if len(matches) == 0 {
		return 0
	}
	var wins int
	for _, match := range matches {
		if match.Won {
			wins++
		}
	}
	return percent(wins, len(matches))
}

func kdaForMatches(matches []dotadomain.MatchSummary) float64 {
	var kills, deaths, assists int
	for _, match := range matches {
		kills += match.Kills
		deaths += match.Deaths
		assists += match.Assists
	}
	return kda(kills, deaths, assists)
}

func trend(diff, positiveThreshold, negativeThreshold float64) string {
	if diff >= positiveThreshold {
		return "up"
	}
	if diff <= negativeThreshold {
		return "down"
	}
	return "stable"
}

func matchFormScore(match dotadomain.MatchSummary) float64 {
	result := -9.0
	if match.Won {
		result = 15
	}
	score := 46 + result + kda(match.Kills, match.Deaths, match.Assists)*7 + (float64(match.GoldPerMin)-420)/12
	return round2(clampFloat(score, 5, 96))
}

func favoriteRole(matches []dotadomain.MatchSummary) string {
	if len(matches) == 0 {
		return roleAll
	}
	counts := map[string]int{}
	for _, match := range matches {
		counts[roleForMatch(match)]++
	}
	var bestRole string
	var bestCount int
	for role, count := range counts {
		if count > bestCount {
			bestRole = role
			bestCount = count
		}
	}
	if bestRole == "" {
		return roleAll
	}
	return bestRole
}

func roleForMatch(match dotadomain.MatchSummary) string {
	role := roleForHero(match.HeroID)
	if role != roleAll {
		return role
	}
	switch {
	case match.GoldPerMin >= 560 || match.LastHits >= 230:
		return roleCarry
	case match.GoldPerMin >= 500:
		return roleMid
	case match.GoldPerMin >= 430:
		return roleOfflane
	case match.Assists >= 14:
		return roleSupport5
	default:
		return roleSupport4
	}
}

func roleForHero(heroID int) string {
	switch {
	case containsInt(carryHeroes, heroID):
		return roleCarry
	case containsInt(midHeroes, heroID):
		return roleMid
	case containsInt(offlaneHeroes, heroID):
		return roleOfflane
	case containsInt(support4Heroes, heroID):
		return roleSupport4
	case containsInt(support5Heroes, heroID):
		return roleSupport5
	default:
		return roleAll
	}
}

var (
	carryHeroes    = []int{1, 6, 8, 12, 35, 41, 44, 48, 54, 67, 70}
	midHeroes      = []int{10, 11, 13, 17, 22, 25, 34, 39, 46, 52, 74}
	offlaneHeroes  = []int{2, 16, 19, 29, 38, 49, 55, 60, 65, 69}
	support4Heroes = []int{7, 9, 20, 27, 51, 62, 64, 71, 72}
	support5Heroes = []int{3, 5, 26, 30, 31, 37, 50, 57, 58, 66, 68}
)

func containsInt(items []int, needle int) bool {
	for _, item := range items {
		if item == needle {
			return true
		}
	}
	return false
}

func currentForm(totalScore int, winrateTrend string) string {
	if winrateTrend == "down" || totalScore < 45 {
		return "просадка"
	}
	if totalScore >= 70 || winrateTrend == "up" {
		return "хорошая"
	}
	return "стабильная"
}

func strengthsCount(performance PerformanceScore) int {
	var count int
	for _, item := range performance.Breakdown {
		if item.Score >= 70 {
			count++
		}
	}
	if count == 0 && performance.Total >= 55 {
		return 2
	}
	return count
}

func recommendationsCount(stats labStats) int {
	count := 4
	if stats.Winrate < 50 {
		count++
	}
	if stats.AverageDeaths > 6.5 {
		count++
	}
	return clampInt(count, 3, 6)
}

func normalizePeriod(value string) string {
	switch strings.ToLower(strings.TrimSpace(value)) {
	case periodAll, "all_time", "all-time", "recent":
		return periodAll
	case period7d, "7", "week":
		return period7d
	case period90d, "90", "quarter":
		return period90d
	default:
		return period30d
	}
}

func normalizeRole(value string) string {
	switch strings.ToLower(strings.TrimSpace(value)) {
	case roleCarry, "pos1", "pos_1":
		return roleCarry
	case roleMid, "pos2", "pos_2":
		return roleMid
	case roleOfflane, "pos3", "pos_3":
		return roleOfflane
	case roleSupport4, "support_4", "pos4", "pos_4":
		return roleSupport4
	case roleSupport5, "support_5", "pos5", "pos_5":
		return roleSupport5
	default:
		return roleAll
	}
}

func normalized(value, min, max float64) float64 {
	if max <= min {
		return 0
	}
	return clampFloat((value-min)/(max-min), 0, 1)
}

func clampFloat(value, min, max float64) float64 {
	if value < min {
		return min
	}
	if value > max {
		return max
	}
	return value
}

func scoreClamp(value float64) int {
	return clampInt(int(value+0.5), 0, 100)
}

func rankLabel(rankTier *int) string {
	if rankTier == nil || *rankTier <= 0 {
		return "Ранг неизвестен"
	}
	if *rankTier >= 80 {
		return "Immortal"
	}
	medal := *rankTier / 10
	star := *rankTier % 10
	medalName := map[int]string{
		1: "Herald",
		2: "Guardian",
		3: "Crusader",
		4: "Archon",
		5: "Legend",
		6: "Ancient",
		7: "Divine",
	}[medal]
	if medalName == "" {
		medalName = "Неизвестно"
	}
	if star == 0 {
		return medalName
	}
	return medalName + " " + itoa(star)
}

func itoa(value int) string {
	if value == 0 {
		return "0"
	}
	const digits = "0123456789"
	var out []byte
	for value > 0 {
		out = append([]byte{digits[value%10]}, out...)
		value /= 10
	}
	return string(out)
}
