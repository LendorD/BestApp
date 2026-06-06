// Package stratz is a small, exported GraphQL client for the Stratz API.
// It is best-effort: any error is returned so the caller (e.g. the data
// explorer) can surface it, but it never panics.
package stratz

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"
)

const endpoint = "https://api.stratz.com/graphql"

type Client struct {
	token      string
	httpClient *http.Client
}

func NewClient(token string, timeout time.Duration) *Client {
	if timeout <= 0 {
		timeout = 15 * time.Second
	}
	return &Client{token: strings.TrimSpace(token), httpClient: &http.Client{Timeout: timeout}}
}

// Enabled reports whether a token is configured.
func (c *Client) Enabled() bool { return c != nil && c.token != "" }

// MatchIMP is a single recent match with Stratz' Individual Match Performance.
type MatchIMP struct {
	MatchID  int64 `json:"match_id"`
	Win      bool  `json:"win"`
	Duration int   `json:"duration_seconds"`
	HeroID   int   `json:"hero_id"`
	IMP      int   `json:"imp"`
	Kills    int   `json:"kills"`
	Deaths   int   `json:"deaths"`
	Assists  int   `json:"assists"`
	Networth int   `json:"networth"`
}

// PlayerCard is the structured explorer view of a Stratz player.
type PlayerCard struct {
	Name          string     `json:"name"`
	Avatar        string     `json:"avatar"`
	MatchCount    int        `json:"match_count"`
	WinCount      int        `json:"win_count"`
	WinratePct    float64    `json:"winrate_pct"`
	BehaviorScore int        `json:"behavior_score"`
	AvgIMP        *float64   `json:"avg_imp,omitempty"`
	RecentMatches []MatchIMP `json:"recent_matches"`
	Note          string     `json:"note,omitempty"`
}

// ExplorePlayer fetches a rich player card. It first tries an extended query
// (with recent matches + IMP); if Stratz rejects any field it falls back to a
// minimal known-good query so the caller still gets the basics.
func (c *Client) ExplorePlayer(ctx context.Context, accountID int64) (*PlayerCard, error) {
	if !c.Enabled() {
		return nil, fmt.Errorf("stratz token not configured")
	}

	extended := `query($id: Long!){
      player(steamAccountId: $id){
        steamAccount { name avatar }
        matchCount
        winCount
        behaviorScore
        matches(request: { take: 12 }){
          id
          didRadiantWin
          durationSeconds
          players(steamAccountId: $id){
            heroId
            imp
            isVictory
            kills
            deaths
            assists
            networth
          }
        }
      }
    }`

	card, gqlErr, transportErr := c.queryExtended(ctx, extended, accountID)
	if transportErr != nil {
		return nil, transportErr
	}
	if gqlErr == "" && card != nil {
		return card, nil
	}

	// Fallback: minimal query that is known to work everywhere.
	minimal := `query($id: Long!){ player(steamAccountId: $id){ matchCount winCount steamAccount { name avatar } } }`
	mcard, mErr, tErr := c.queryMinimal(ctx, minimal, accountID)
	if tErr != nil {
		return nil, tErr
	}
	if mcard == nil {
		if mErr != "" {
			return nil, fmt.Errorf("stratz: %s", mErr)
		}
		return nil, fmt.Errorf("stratz: no data")
	}
	if gqlErr != "" {
		mcard.Note = "Расширенные поля недоступны: " + gqlErr
	}
	return mcard, nil
}

func (c *Client) queryExtended(ctx context.Context, query string, accountID int64) (*PlayerCard, string, error) {
	raw, err := c.do(ctx, query, accountID)
	if err != nil {
		return nil, "", err
	}
	var parsed struct {
		Data struct {
			Player *struct {
				MatchCount    int `json:"matchCount"`
				WinCount      int `json:"winCount"`
				BehaviorScore int `json:"behaviorScore"`
				SteamAccount  struct {
					Name   string `json:"name"`
					Avatar string `json:"avatar"`
				} `json:"steamAccount"`
				Matches []struct {
					ID              int64 `json:"id"`
					DidRadiantWin   bool  `json:"didRadiantWin"`
					DurationSeconds int   `json:"durationSeconds"`
					Players         []struct {
						HeroID    int  `json:"heroId"`
						IMP       int  `json:"imp"`
						IsVictory bool `json:"isVictory"`
						Kills     int  `json:"kills"`
						Deaths    int  `json:"deaths"`
						Assists   int  `json:"assists"`
						Networth  int  `json:"networth"`
					} `json:"players"`
				} `json:"matches"`
			} `json:"player"`
		} `json:"data"`
		Errors []struct {
			Message string `json:"message"`
		} `json:"errors"`
	}
	if err := json.Unmarshal(raw, &parsed); err != nil {
		return nil, "decode error", nil
	}
	if len(parsed.Errors) > 0 {
		return nil, parsed.Errors[0].Message, nil
	}
	p := parsed.Data.Player
	if p == nil {
		return nil, "player not found", nil
	}

	card := &PlayerCard{
		Name:          p.SteamAccount.Name,
		Avatar:        p.SteamAccount.Avatar,
		MatchCount:    p.MatchCount,
		WinCount:      p.WinCount,
		BehaviorScore: p.BehaviorScore,
	}
	if p.MatchCount > 0 {
		card.WinratePct = float64(p.WinCount) / float64(p.MatchCount) * 100
	}

	var impSum, impN float64
	for _, m := range p.Matches {
		if len(m.Players) == 0 {
			continue
		}
		pl := m.Players[0]
		card.RecentMatches = append(card.RecentMatches, MatchIMP{
			MatchID:  m.ID,
			Win:      pl.IsVictory,
			Duration: m.DurationSeconds,
			HeroID:   pl.HeroID,
			IMP:      pl.IMP,
			Kills:    pl.Kills,
			Deaths:   pl.Deaths,
			Assists:  pl.Assists,
			Networth: pl.Networth,
		})
		impSum += float64(pl.IMP)
		impN++
	}
	if impN > 0 {
		avg := impSum / impN
		card.AvgIMP = &avg
	}
	return card, "", nil
}

func (c *Client) queryMinimal(ctx context.Context, query string, accountID int64) (*PlayerCard, string, error) {
	raw, err := c.do(ctx, query, accountID)
	if err != nil {
		return nil, "", err
	}
	var parsed struct {
		Data struct {
			Player *struct {
				MatchCount   int `json:"matchCount"`
				WinCount     int `json:"winCount"`
				SteamAccount struct {
					Name   string `json:"name"`
					Avatar string `json:"avatar"`
				} `json:"steamAccount"`
			} `json:"player"`
		} `json:"data"`
		Errors []struct {
			Message string `json:"message"`
		} `json:"errors"`
	}
	if err := json.Unmarshal(raw, &parsed); err != nil {
		return nil, "decode error", nil
	}
	if len(parsed.Errors) > 0 {
		return nil, parsed.Errors[0].Message, nil
	}
	p := parsed.Data.Player
	if p == nil {
		return nil, "player not found", nil
	}
	card := &PlayerCard{
		Name:       p.SteamAccount.Name,
		Avatar:     p.SteamAccount.Avatar,
		MatchCount: p.MatchCount,
		WinCount:   p.WinCount,
	}
	if p.MatchCount > 0 {
		card.WinratePct = float64(p.WinCount) / float64(p.MatchCount) * 100
	}
	return card, "", nil
}

func (c *Client) do(ctx context.Context, query string, accountID int64) ([]byte, error) {
	body, err := json.Marshal(map[string]any{
		"query":     query,
		"variables": map[string]any{"id": accountID},
	})
	if err != nil {
		return nil, err
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, endpoint, bytes.NewReader(body))
	if err != nil {
		return nil, err
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+c.token)
	// Stratz requires this exact User-Agent for API-token access.
	req.Header.Set("User-Agent", "STRATZ_API")

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("stratz request failed: %w", err)
	}
	defer resp.Body.Close()
	raw, err := io.ReadAll(io.LimitReader(resp.Body, 2<<20))
	if err != nil {
		return nil, err
	}
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return nil, fmt.Errorf("stratz returned status %d", resp.StatusCode)
	}
	return raw, nil
}
