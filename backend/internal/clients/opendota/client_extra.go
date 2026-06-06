package opendota

import (
	"context"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strings"

	"gamementor/internal/domain"
)

// GetWinLoss returns the player's win/loss counts as raw JSON.
func (c *Client) GetWinLoss(ctx context.Context, accountID int64) ([]byte, error) {
	return c.get(ctx, fmt.Sprintf("/api/players/%d/wl", accountID))
}

// GetTotals returns aggregate per-metric totals/averages as raw JSON.
func (c *Client) GetTotals(ctx context.Context, accountID int64) ([]byte, error) {
	return c.get(ctx, fmt.Sprintf("/api/players/%d/totals", accountID))
}

// GetHeroesAgg returns aggregated per-hero performance as raw JSON.
func (c *Client) GetHeroesAgg(ctx context.Context, accountID int64) ([]byte, error) {
	return c.get(ctx, fmt.Sprintf("/api/players/%d/heroes", accountID))
}

// GetPeers returns frequently-played-with players as raw JSON.
func (c *Client) GetPeers(ctx context.Context, accountID int64) ([]byte, error) {
	return c.get(ctx, fmt.Sprintf("/api/players/%d/peers", accountID))
}

// GetCounts returns counts grouped by game mode, lane role, etc. as raw JSON.
func (c *Client) GetCounts(ctx context.Context, accountID int64) ([]byte, error) {
	return c.get(ctx, fmt.Sprintf("/api/players/%d/counts", accountID))
}

// GetMatch returns full (possibly parsed) match data as raw JSON.
func (c *Client) GetMatch(ctx context.Context, matchID int64) ([]byte, error) {
	return c.get(ctx, fmt.Sprintf("/api/matches/%d", matchID))
}

// RequestParse asks OpenDota to parse a replay (turns a "demo" into structured
// data: teamfights, objectives, item/ability timings). Returns the job JSON.
func (c *Client) RequestParse(ctx context.Context, matchID int64) ([]byte, error) {
	return c.post(ctx, fmt.Sprintf("/api/request/%d", matchID))
}

// matchProjections are the per-match fields we ask OpenDota to include.
var matchProjections = []string{
	"kills", "deaths", "assists", "gold_per_min", "xp_per_min", "last_hits",
	"denies", "hero_damage", "tower_damage", "hero_healing", "duration",
	"start_time", "obs_placed", "sen_placed", "camps_stacked", "lane_role",
	"hero_id", "player_slot", "radiant_win",
}

// GetMatchesProjected returns up to `limit` recent matches with rich per-match
// fields. When days > 0 it restricts to that many days back. Raw JSON.
func (c *Client) GetMatchesProjected(ctx context.Context, accountID int64, days, limit int) ([]byte, error) {
	if limit <= 0 {
		limit = 20
	}
	q := url.Values{}
	q.Set("limit", fmt.Sprintf("%d", limit))
	if days > 0 {
		q.Set("date", fmt.Sprintf("%d", days))
	}
	for _, p := range matchProjections {
		q.Add("project", p)
	}
	return c.get(ctx, fmt.Sprintf("/api/players/%d/matches?%s", accountID, encodeProjects(q)))
}

// GetBenchmarks returns percentile distributions for a hero. Raw JSON.
func (c *Client) GetBenchmarks(ctx context.Context, heroID int) ([]byte, error) {
	return c.get(ctx, fmt.Sprintf("/api/benchmarks?hero_id=%d", heroID))
}

// encodeProjects keeps repeated project= params (url.Values.Encode also works,
// but we keep ordering stable and avoid escaping the simple values).
func encodeProjects(q url.Values) string {
	parts := make([]string, 0, len(q))
	for k, vs := range q {
		for _, v := range vs {
			parts = append(parts, k+"="+v)
		}
	}
	return strings.Join(parts, "&")
}

func (c *Client) post(ctx context.Context, path string) ([]byte, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, c.baseURL+path, nil)
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
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return nil, domain.ExternalError(fmt.Sprintf("opendota returned status %d", resp.StatusCode))
	}
	return body, nil
}
