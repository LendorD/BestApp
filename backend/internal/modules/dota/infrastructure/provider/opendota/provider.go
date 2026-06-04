package opendota

import (
	"context"
	"strconv"
	"time"

	legacydomain "gamementor/internal/domain"
	dotadomain "gamementor/internal/modules/dota/domain"
)

type LegacyClient interface {
	GetPlayer(ctx context.Context, accountID int64) (*legacydomain.DotaPlayer, error)
	GetRecentMatches(ctx context.Context, accountID int64) ([]legacydomain.DotaPlayerMatch, error)
}

type Provider struct {
	client LegacyClient
	now    func() time.Time
}

func New(client LegacyClient) *Provider {
	return &Provider{client: client, now: time.Now}
}

func (p *Provider) GetPlayerProfile(ctx context.Context, steamID string) (*dotadomain.PlayerProfile, error) {
	accountID, err := parseAccountID(steamID)
	if err != nil {
		return nil, err
	}
	player, err := p.client.GetPlayer(ctx, accountID)
	if err != nil {
		return nil, err
	}
	return &dotadomain.PlayerProfile{
		SteamID:     steamID,
		AccountID:   player.AccountID,
		PersonaName: player.PersonaName,
		AvatarFull:  player.AvatarFull,
		ProfileURL:  player.ProfileURL,
		RankTier:    player.RankTier,
		RawJSON:     player.Raw,
		FetchedAt:   p.now().UTC(),
	}, nil
}

func (p *Provider) GetRecentMatches(ctx context.Context, steamID string, limit int) ([]dotadomain.MatchSummary, error) {
	accountID, err := parseAccountID(steamID)
	if err != nil {
		return nil, err
	}
	matches, err := p.client.GetRecentMatches(ctx, accountID)
	if err != nil {
		return nil, err
	}
	if limit <= 0 || limit > len(matches) {
		limit = len(matches)
	}

	out := make([]dotadomain.MatchSummary, 0, limit)
	for _, match := range matches[:limit] {
		out = append(out, fromLegacyMatch(match))
	}
	return out, nil
}

func (p *Provider) GetHeroStats(ctx context.Context, steamID string) ([]dotadomain.HeroStats, error) {
	matches, err := p.GetRecentMatches(ctx, steamID, 100)
	if err != nil {
		return nil, err
	}
	return buildHeroStats(matches), nil
}

func (p *Provider) GetMatchDetails(ctx context.Context, matchID string) (*dotadomain.MatchDetails, error) {
	_ = ctx
	if _, err := strconv.ParseInt(matchID, 10, 64); err != nil {
		return nil, dotadomain.InvalidSteamID(matchID)
	}
	return nil, dotadomain.ProviderDisabled("opendota match details")
}

func parseAccountID(steamID string) (int64, error) {
	accountID, err := strconv.ParseInt(steamID, 10, 64)
	if err != nil || accountID <= 0 {
		return 0, dotadomain.InvalidSteamID(steamID)
	}
	return accountID, nil
}

func fromLegacyMatch(match legacydomain.DotaPlayerMatch) dotadomain.MatchSummary {
	return dotadomain.MatchSummary{
		MatchID:         strconv.FormatInt(match.MatchID, 10),
		AccountID:       match.AccountID,
		PlayerSlot:      match.PlayerSlot,
		RadiantWin:      match.RadiantWin,
		Won:             match.Won,
		HeroID:          match.HeroID,
		Kills:           match.Kills,
		Deaths:          match.Deaths,
		Assists:         match.Assists,
		GoldPerMin:      match.GoldPerMin,
		XPPerMin:        match.XPPerMin,
		LastHits:        match.LastHits,
		HeroDamage:      match.HeroDamage,
		TowerDamage:     match.TowerDamage,
		HeroHealing:     match.HeroHealing,
		AverageRank:     match.AverageRank,
		PartySize:       match.PartySize,
		GameMode:        match.GameMode,
		DurationSeconds: match.DurationSeconds,
		StartTime:       match.StartTime,
		RawJSON:         match.Raw,
	}
}

func buildHeroStats(matches []dotadomain.MatchSummary) []dotadomain.HeroStats {
	type agg struct {
		matches int
		wins    int
		kills   int
		deaths  int
		assists int
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
	}

	out := make([]dotadomain.HeroStats, 0, len(byHero))
	for heroID, stat := range byHero {
		out = append(out, dotadomain.HeroStats{
			HeroID:  heroID,
			Matches: stat.matches,
			Wins:    stat.wins,
			Losses:  stat.matches - stat.wins,
			Winrate: percent(stat.wins, stat.matches),
			KDA:     kda(stat.kills, stat.deaths, stat.assists),
		})
	}
	return out
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
