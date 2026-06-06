package enrich

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"
)

const stratzEndpoint = "https://api.stratz.com/graphql"

// stratzClient is a minimal best-effort GraphQL client for Stratz.
// Any error results in an empty enrichment string (never fatal).
type stratzClient struct {
	token      string
	httpClient *http.Client
}

func newStratzClient(token string, timeout time.Duration) *stratzClient {
	if timeout <= 0 {
		timeout = 15 * time.Second
	}
	return &stratzClient{token: token, httpClient: &http.Client{Timeout: timeout}}
}

func (s *stratzClient) playerSummary(ctx context.Context, accountID int64) string {
	if s == nil || s.token == "" {
		return ""
	}
	query := `query($id: Long!){ player(steamAccountId: $id){ matchCount winCount steamAccount { name } } }`
	body, err := json.Marshal(map[string]any{
		"query":     query,
		"variables": map[string]any{"id": accountID},
	})
	if err != nil {
		return ""
	}

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, stratzEndpoint, bytes.NewReader(body))
	if err != nil {
		return ""
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+s.token)
	// Stratz requires this exact User-Agent for API-token access.
	req.Header.Set("User-Agent", "STRATZ_API")

	resp, err := s.httpClient.Do(req)
	if err != nil {
		return ""
	}
	defer resp.Body.Close()
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return ""
	}
	raw, err := io.ReadAll(io.LimitReader(resp.Body, 1<<20))
	if err != nil {
		return ""
	}

	var parsed struct {
		Data struct {
			Player struct {
				MatchCount   int `json:"matchCount"`
				WinCount     int `json:"winCount"`
				SteamAccount struct {
					Name string `json:"name"`
				} `json:"steamAccount"`
			} `json:"player"`
		} `json:"data"`
		Errors []json.RawMessage `json:"errors"`
	}
	if json.Unmarshal(raw, &parsed) != nil || len(parsed.Errors) > 0 {
		return ""
	}
	p := parsed.Data.Player
	if p.MatchCount == 0 {
		return ""
	}
	wr := 0.0
	if p.MatchCount > 0 {
		wr = float64(p.WinCount) / float64(p.MatchCount) * 100
	}
	return fmt.Sprintf("- Stratz (%s): %d total matches, %.1f%% lifetime winrate\n", p.SteamAccount.Name, p.MatchCount, wr)
}
