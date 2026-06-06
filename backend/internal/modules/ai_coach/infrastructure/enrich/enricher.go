// Package enrich gathers extra Dota 2 context (OpenDota aggregates, parsed
// match summaries, optional Stratz data) and renders it as compact text that
// can be appended to the AI Coach prompt.
package enrich

import (
	"context"
	"encoding/json"
	"fmt"
	"strconv"
	"strings"
	"time"

	"gamementor/internal/clients/opendota"
)

// Enricher wraps the low-level OpenDota client plus optional Stratz access.
type Enricher struct {
	od        *opendota.Client
	stratzKey string
	stratz    *stratzClient
}

func New(od *opendota.Client, stratzKey string, timeout time.Duration) *Enricher {
	e := &Enricher{od: od, stratzKey: strings.TrimSpace(stratzKey)}
	if e.stratzKey != "" {
		e.stratz = newStratzClient(e.stratzKey, timeout)
	}
	return e
}

// PlayerContext returns a compact, human-readable block of extra player data.
// It is best-effort: missing sources are simply skipped.
func (e *Enricher) PlayerContext(ctx context.Context, steamID string) string {
	if e == nil || e.od == nil {
		return ""
	}
	accountID, err := strconv.ParseInt(strings.TrimSpace(steamID), 10, 64)
	if err != nil || accountID <= 0 {
		return ""
	}

	var b strings.Builder
	b.WriteString("ADDITIONAL OPENDOTA DATA\n")

	if raw, err := e.od.GetWinLoss(ctx, accountID); err == nil {
		var wl struct {
			Win  int `json:"win"`
			Lose int `json:"lose"`
		}
		if json.Unmarshal(raw, &wl) == nil && (wl.Win+wl.Lose) > 0 {
			wr := float64(wl.Win) / float64(wl.Win+wl.Lose) * 100
			fmt.Fprintf(&b, "- Win/Loss: %d-%d (%.1f%% winrate over %d games)\n", wl.Win, wl.Lose, wr, wl.Win+wl.Lose)
		}
	}

	if raw, err := e.od.GetTotals(ctx, accountID); err == nil {
		var totals []struct {
			Field string  `json:"field"`
			N     int     `json:"n"`
			Sum   float64 `json:"sum"`
		}
		if json.Unmarshal(raw, &totals) == nil {
			wanted := map[string]string{
				"kills": "Kills", "deaths": "Deaths", "assists": "Assists",
				"gold_per_min": "GPM", "xp_per_min": "XPM", "last_hits": "LastHits",
				"hero_damage": "HeroDamage", "tower_damage": "TowerDamage",
				"hero_healing": "HeroHealing", "stuns": "Stuns",
			}
			parts := []string{}
			for _, t := range totals {
				label, ok := wanted[t.Field]
				if !ok || t.N == 0 {
					continue
				}
				parts = append(parts, fmt.Sprintf("%s avg %.1f", label, t.Sum/float64(t.N)))
			}
			if len(parts) > 0 {
				b.WriteString("- Career averages: " + strings.Join(parts, ", ") + "\n")
			}
		}
	}

	if raw, err := e.od.GetHeroesAgg(ctx, accountID); err == nil {
		var heroes []struct {
			HeroID     int   `json:"hero_id"`
			Games      int   `json:"games"`
			Win        int   `json:"win"`
			LastPlayed int64 `json:"last_played"`
		}
		if json.Unmarshal(raw, &heroes) == nil && len(heroes) > 0 {
			limit := 5
			if len(heroes) < limit {
				limit = len(heroes)
			}
			parts := []string{}
			for _, h := range heroes[:limit] {
				if h.Games == 0 {
					continue
				}
				wr := float64(h.Win) / float64(h.Games) * 100
				parts = append(parts, fmt.Sprintf("hero %d (%d games, %.0f%% WR)", h.HeroID, h.Games, wr))
			}
			if len(parts) > 0 {
				b.WriteString("- Most played heroes: " + strings.Join(parts, "; ") + "\n")
			}
		}
	}

	if raw, err := e.od.GetCounts(ctx, accountID); err == nil {
		var counts struct {
			LaneRole map[string]struct {
				Games int `json:"games"`
				Win   int `json:"win"`
			} `json:"lane_role"`
		}
		if json.Unmarshal(raw, &counts) == nil && len(counts.LaneRole) > 0 {
			laneNames := map[string]string{"1": "Safelane", "2": "Mid", "3": "Offlane", "4": "Jungle"}
			parts := []string{}
			for k, v := range counts.LaneRole {
				if v.Games == 0 {
					continue
				}
				name := laneNames[k]
				if name == "" {
					name = "Lane " + k
				}
				parts = append(parts, fmt.Sprintf("%s %d games", name, v.Games))
			}
			if len(parts) > 0 {
				b.WriteString("- Lane distribution: " + strings.Join(parts, ", ") + "\n")
			}
		}
	}

	if e.stratz != nil {
		if s := e.stratz.playerSummary(ctx, accountID); s != "" {
			b.WriteString(s)
		}
	}

	out := b.String()
	if strings.Count(out, "\n") <= 1 {
		return "" // nothing useful gathered
	}
	return out
}

// MatchContext requests a parse of the replay (best effort) and renders a
// compact text summary of the match for the LLM.
func (e *Enricher) MatchContext(ctx context.Context, matchID string) (string, error) {
	if e == nil || e.od == nil {
		return "", fmt.Errorf("enricher not configured")
	}
	id, err := strconv.ParseInt(strings.TrimSpace(matchID), 10, 64)
	if err != nil || id <= 0 {
		return "", fmt.Errorf("invalid match id")
	}

	// Ask OpenDota to parse the replay. Best effort: parsing is async and may
	// already be done; we do not block on completion.
	_, _ = e.od.RequestParse(ctx, id)

	raw, err := e.od.GetMatch(ctx, id)
	if err != nil {
		return "", err
	}

	var m matchPayload
	if err := json.Unmarshal(raw, &m); err != nil {
		return "", fmt.Errorf("decode match: %w", err)
	}

	var b strings.Builder
	winner := "Dire"
	if m.RadiantWin {
		winner = "Radiant"
	}
	fmt.Fprintf(&b, "MATCH %d SUMMARY\n", id)
	fmt.Fprintf(&b, "- Result: %s win | Score %d-%d | Duration %d:%02d\n",
		winner, m.RadiantScore, m.DireScore, m.Duration/60, m.Duration%60)
	if m.Version == nil {
		b.WriteString("- Replay not fully parsed yet (basic stats only; ask user to retry in ~1 min for teamfight/objective detail)\n")
	} else {
		fmt.Fprintf(&b, "- Parsed replay: %d teamfights recorded\n", len(m.Teamfights))
	}

	b.WriteString("- Players (hero / K-D-A / GPM / XPM / LH / heroDmg):\n")
	for _, p := range m.Players {
		side := "Dire"
		if p.IsRadiant {
			side = "Radiant"
		}
		lane := laneRoleName(p.LaneRole)
		fmt.Fprintf(&b, "  [%s%s] hero %d: %d-%d-%d, %d GPM, %d XPM, %d LH, %d HD\n",
			side, lane, p.HeroID, p.Kills, p.Deaths, p.Assists, p.GoldPerMin, p.XPPerMin, p.LastHits, p.HeroDamage)
	}

	if len(m.Objectives) > 0 {
		towers := 0
		roshan := 0
		for _, o := range m.Objectives {
			switch o.Type {
			case "building_kill", "CHAT_MESSAGE_TOWER_KILL":
				towers++
			case "CHAT_MESSAGE_ROSHAN_KILL":
				roshan++
			}
		}
		fmt.Fprintf(&b, "- Objectives: ~%d building events, %d Roshan kills\n", towers, roshan)
	}

	return b.String(), nil
}

func laneRoleName(role int) string {
	switch role {
	case 1:
		return " safelane"
	case 2:
		return " mid"
	case 3:
		return " offlane"
	case 4:
		return " jungle"
	default:
		return ""
	}
}

type matchPayload struct {
	RadiantWin   bool              `json:"radiant_win"`
	Duration     int               `json:"duration"`
	RadiantScore int               `json:"radiant_score"`
	DireScore    int               `json:"dire_score"`
	Version      *int              `json:"version"`
	Players      []matchPlayer     `json:"players"`
	Teamfights   []json.RawMessage `json:"teamfights"`
	Objectives   []matchObjective  `json:"objectives"`
}

type matchPlayer struct {
	HeroID     int  `json:"hero_id"`
	IsRadiant  bool `json:"isRadiant"`
	LaneRole   int  `json:"lane_role"`
	Kills      int  `json:"kills"`
	Deaths     int  `json:"deaths"`
	Assists    int  `json:"assists"`
	GoldPerMin int  `json:"gold_per_min"`
	XPPerMin   int  `json:"xp_per_min"`
	LastHits   int  `json:"last_hits"`
	HeroDamage int  `json:"hero_damage"`
}

type matchObjective struct {
	Type string `json:"type"`
}
