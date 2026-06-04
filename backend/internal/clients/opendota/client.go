package opendota

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"

	"gamementor/internal/domain"
)

type Client struct {
	baseURL    string
	httpClient *http.Client
}

func NewClient(baseURL string, timeout time.Duration) *Client {
	if timeout <= 0 {
		timeout = 10 * time.Second
	}
	return &Client{
		baseURL: strings.TrimRight(baseURL, "/"),
		httpClient: &http.Client{
			Timeout: timeout,
		},
	}
}

func (c *Client) GetPlayer(ctx context.Context, accountID int64) (*domain.DotaPlayer, error) {
	body, err := c.get(ctx, fmt.Sprintf("/api/players/%d", accountID))
	if err != nil {
		return nil, err
	}

	var payload playerResponse
	if err := json.Unmarshal(body, &payload); err != nil {
		return nil, fmt.Errorf("decode opendota player: %w", err)
	}

	player := &domain.DotaPlayer{
		AccountID:   accountID,
		PersonaName: payload.Profile.PersonaName,
		AvatarFull:  payload.Profile.AvatarFull,
		ProfileURL:  payload.Profile.ProfileURL,
		RankTier:    payload.RankTier,
		Raw:         body,
	}
	if payload.Profile.AccountID != 0 {
		player.AccountID = payload.Profile.AccountID
	}

	return player, nil
}

func (c *Client) GetRecentMatches(ctx context.Context, accountID int64) ([]domain.DotaPlayerMatch, error) {
	body, err := c.get(ctx, fmt.Sprintf("/api/players/%d/recentMatches", accountID))
	if err != nil {
		return nil, err
	}

	var rawItems []json.RawMessage
	if err := json.Unmarshal(body, &rawItems); err != nil {
		return nil, fmt.Errorf("decode opendota recent matches: %w", err)
	}

	matches := make([]domain.DotaPlayerMatch, 0, len(rawItems))
	for _, raw := range rawItems {
		var payload recentMatchResponse
		if err := json.Unmarshal(raw, &payload); err != nil {
			return nil, fmt.Errorf("decode opendota recent match: %w", err)
		}

		isRadiant := payload.PlayerSlot < 128
		won := (isRadiant && payload.RadiantWin) || (!isRadiant && !payload.RadiantWin)
		matches = append(matches, domain.DotaPlayerMatch{
			MatchID:         payload.MatchID,
			AccountID:       accountID,
			PlayerSlot:      payload.PlayerSlot,
			RadiantWin:      payload.RadiantWin,
			Won:             won,
			HeroID:          payload.HeroID,
			Kills:           payload.Kills,
			Deaths:          payload.Deaths,
			Assists:         payload.Assists,
			GoldPerMin:      payload.GoldPerMin,
			XPPerMin:        payload.XPPerMin,
			LastHits:        payload.LastHits,
			HeroDamage:      payload.HeroDamage,
			TowerDamage:     payload.TowerDamage,
			HeroHealing:     payload.HeroHealing,
			AverageRank:     payload.AverageRank,
			PartySize:       payload.PartySize,
			GameMode:        payload.GameMode,
			DurationSeconds: payload.Duration,
			StartTime:       time.Unix(payload.StartTime, 0).UTC(),
			Raw:             raw,
		})
	}

	return matches, nil
}

func (c *Client) get(ctx context.Context, path string) ([]byte, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, c.baseURL+path, nil)
	if err != nil {
		return nil, fmt.Errorf("build opendota request: %w", err)
	}
	req.Header.Set("Accept", "application/json")
	req.Header.Set("User-Agent", "GameMentor/0.1")

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return nil, domain.ExternalError(fmt.Sprintf("opendota request failed: %v", err))
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(io.LimitReader(resp.Body, 4<<20))
	if err != nil {
		return nil, fmt.Errorf("read opendota response: %w", err)
	}
	if resp.StatusCode == http.StatusNotFound {
		return nil, domain.NotFound("opendota player not found")
	}
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return nil, domain.ExternalError(fmt.Sprintf("opendota returned status %d", resp.StatusCode))
	}

	return body, nil
}

type playerResponse struct {
	RankTier *int `json:"rank_tier"`
	Profile  struct {
		AccountID   int64  `json:"account_id"`
		PersonaName string `json:"personaname"`
		AvatarFull  string `json:"avatarfull"`
		ProfileURL  string `json:"profileurl"`
	} `json:"profile"`
}

type recentMatchResponse struct {
	MatchID     int64 `json:"match_id"`
	PlayerSlot  int   `json:"player_slot"`
	RadiantWin  bool  `json:"radiant_win"`
	Duration    int   `json:"duration"`
	HeroID      int   `json:"hero_id"`
	StartTime   int64 `json:"start_time"`
	Kills       int   `json:"kills"`
	Deaths      int   `json:"deaths"`
	Assists     int   `json:"assists"`
	GoldPerMin  int   `json:"gold_per_min"`
	XPPerMin    int   `json:"xp_per_min"`
	LastHits    int   `json:"last_hits"`
	HeroDamage  int   `json:"hero_damage"`
	TowerDamage int   `json:"tower_damage"`
	HeroHealing int   `json:"hero_healing"`
	AverageRank *int  `json:"average_rank"`
	PartySize   *int  `json:"party_size"`
	GameMode    int   `json:"game_mode"`
}
