// Package application implements the "data explorer": it gathers everything we
// can currently pull from OpenDota and Stratz for one account and returns it as
// structured JSON so the frontend can show what data is available.
package application

import (
	"context"
	"encoding/json"
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

// ExploreResult is the full explorer payload.
type ExploreResult struct {
	AccountID int64        `json:"account_id"`
	OpenDota  OpenDotaData `json:"opendota"`
	Stratz    StratzData   `json:"stratz"`
}

type OpenDotaData struct {
	Profile       *Profile        `json:"profile,omitempty"`
	WinLoss       *WinLoss        `json:"win_loss,omitempty"`
	Averages      []KV            `json:"averages,omitempty"`
	TopHeroes     []HeroAgg       `json:"top_heroes,omitempty"`
	Lanes         []KV            `json:"lanes,omitempty"`
	RecentMatches []ExplorerMatch `json:"recent_matches,omitempty"`
	Notes         []string        `json:"notes,omitempty"`
}

type StratzData struct {
	Enabled bool               `json:"enabled"`
	Player  *stratz.PlayerCard `json:"player,omitempty"`
	Error   string             `json:"error,omitempty"`
}

type Profile struct {
	Name       string `json:"name"`
	Avatar     string `json:"avatar"`
	ProfileURL string `json:"profile_url"`
	RankTier   *int   `json:"rank_tier,omitempty"`
}

type WinLoss struct {
	Win        int     `json:"win"`
	Lose       int     `json:"lose"`
	WinratePct float64 `json:"winrate_pct"`
}

type KV struct {
	Label string  `json:"label"`
	Value float64 `json:"value"`
}

type HeroAgg struct {
	HeroID     int     `json:"hero_id"`
	Games      int     `json:"games"`
	Win        int     `json:"win"`
	WinratePct float64 `json:"winrate_pct"`
}

type ExplorerMatch struct {
	MatchID  int64 `json:"match_id"`
	HeroID   int   `json:"hero_id"`
	Won      bool  `json:"won"`
	Kills    int   `json:"kills"`
	Deaths   int   `json:"deaths"`
	Assists  int   `json:"assists"`
	GPM      int   `json:"gpm"`
	XPM      int   `json:"xpm"`
	Duration int   `json:"duration_seconds"`
}

// Explore returns everything available for the given account id.
func (s *Service) Explore(ctx context.Context, steamID string) (*ExploreResult, error) {
	accountID, err := strconv.ParseInt(strings.TrimSpace(steamID), 10, 64)
	if err != nil || accountID <= 0 {
		return nil, domain.ValidationError("steam_id must be a numeric account id")
	}

	result := &ExploreResult{AccountID: accountID}
	result.OpenDota = s.openDota(ctx, accountID)
	result.Stratz = s.stratzData(ctx, accountID)
	return result, nil
}

func (s *Service) openDota(ctx context.Context, accountID int64) OpenDotaData {
	out := OpenDotaData{}

	if player, err := s.od.GetPlayer(ctx, accountID); err == nil && player != nil {
		out.Profile = &Profile{
			Name:       player.PersonaName,
			Avatar:     player.AvatarFull,
			ProfileURL: player.ProfileURL,
			RankTier:   player.RankTier,
		}
	} else if err != nil {
		out.Notes = append(out.Notes, "profile: "+err.Error())
	}

	if raw, err := s.od.GetWinLoss(ctx, accountID); err == nil {
		var wl struct {
			Win  int `json:"win"`
			Lose int `json:"lose"`
		}
		if json.Unmarshal(raw, &wl) == nil && (wl.Win+wl.Lose) > 0 {
			w := &WinLoss{Win: wl.Win, Lose: wl.Lose}
			w.WinratePct = float64(wl.Win) / float64(wl.Win+wl.Lose) * 100
			out.WinLoss = w
		}
	}

	if raw, err := s.od.GetTotals(ctx, accountID); err == nil {
		var totals []struct {
			Field string  `json:"field"`
			N     int     `json:"n"`
			Sum   float64 `json:"sum"`
		}
		if json.Unmarshal(raw, &totals) == nil {
			labels := map[string]string{
				"kills": "Убийства", "deaths": "Смерти", "assists": "Помощи",
				"gold_per_min": "GPM", "xp_per_min": "XPM", "last_hits": "Ластхиты",
				"hero_damage": "Урон по героям", "tower_damage": "Урон по башням",
				"hero_healing": "Хил", "stuns": "Станы (сек)",
			}
			for _, t := range totals {
				label, ok := labels[t.Field]
				if !ok || t.N == 0 {
					continue
				}
				out.Averages = append(out.Averages, KV{Label: label, Value: round1(t.Sum / float64(t.N))})
			}
		}
	}

	if raw, err := s.od.GetHeroesAgg(ctx, accountID); err == nil {
		// hero_id may arrive as a JSON string ("1") or number (1); flexInt
		// accepts both so we never get bogus hero_id 0 entries.
		var heroes []struct {
			HeroID flexInt `json:"hero_id"`
			Games  int     `json:"games"`
			Win    int     `json:"win"`
		}
		_ = json.Unmarshal(raw, &heroes)
		for _, hh := range heroes {
			h := struct {
				HeroID int
				Games  int
				Win    int
			}{HeroID: int(hh.HeroID), Games: hh.Games, Win: hh.Win}
			if h.Games == 0 {
				continue
			}
			out.TopHeroes = append(out.TopHeroes, HeroAgg{
				HeroID: h.HeroID, Games: h.Games, Win: h.Win,
				WinratePct: round1(float64(h.Win) / float64(h.Games) * 100),
			})
		}
		sort.Slice(out.TopHeroes, func(i, j int) bool { return out.TopHeroes[i].Games > out.TopHeroes[j].Games })
		if len(out.TopHeroes) > 12 {
			out.TopHeroes = out.TopHeroes[:12]
		}
	}

	if raw, err := s.od.GetCounts(ctx, accountID); err == nil {
		var counts struct {
			LaneRole map[string]struct {
				Games int `json:"games"`
				Win   int `json:"win"`
			} `json:"lane_role"`
		}
		if json.Unmarshal(raw, &counts) == nil {
			names := map[string]string{"1": "Лёгкая (safelane)", "2": "Мид", "3": "Сложная (offlane)", "4": "Лес"}
			for k, v := range counts.LaneRole {
				if v.Games == 0 {
					continue
				}
				name := names[k]
				if name == "" {
					name = "Лайн " + k
				}
				out.Lanes = append(out.Lanes, KV{Label: name, Value: float64(v.Games)})
			}
			sort.Slice(out.Lanes, func(i, j int) bool { return out.Lanes[i].Value > out.Lanes[j].Value })
		}
	}

	if matches, err := s.od.GetRecentMatches(ctx, accountID); err == nil {
		limit := 20
		if len(matches) < limit {
			limit = len(matches)
		}
		for _, m := range matches[:limit] {
			out.RecentMatches = append(out.RecentMatches, ExplorerMatch{
				MatchID:  m.MatchID,
				HeroID:   m.HeroID,
				Won:      m.Won,
				Kills:    m.Kills,
				Deaths:   m.Deaths,
				Assists:  m.Assists,
				GPM:      m.GoldPerMin,
				XPM:      m.XPPerMin,
				Duration: m.DurationSeconds,
			})
		}
	}

	return out
}

func (s *Service) stratzData(ctx context.Context, accountID int64) StratzData {
	if s.stratz == nil || !s.stratz.Enabled() {
		return StratzData{Enabled: false}
	}
	card, err := s.stratz.ExplorePlayer(ctx, accountID)
	if err != nil {
		return StratzData{Enabled: true, Error: err.Error()}
	}
	return StratzData{Enabled: true, Player: card}
}

func round1(v float64) float64 {
	return float64(int(v*10+0.5)) / 10
}

// flexInt decodes a JSON value that may be a number or a quoted string.
type flexInt int

func (f *flexInt) UnmarshalJSON(b []byte) error {
	s := strings.Trim(strings.TrimSpace(string(b)), "\"")
	if s == "" || s == "null" {
		*f = 0
		return nil
	}
	n, err := strconv.Atoi(s)
	if err != nil {
		*f = 0
		return nil // tolerate unexpected shapes
	}
	*f = flexInt(n)
	return nil
}
