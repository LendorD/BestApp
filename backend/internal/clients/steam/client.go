// Package steam is a tiny client for the Steam Web API (vanity URL resolution).
package steam

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strings"
	"time"
)

type Client struct {
	apiKey     string
	baseURL    string
	httpClient *http.Client
}

func NewClient(apiKey string, timeout time.Duration) *Client {
	if timeout <= 0 {
		timeout = 10 * time.Second
	}
	return &Client{
		apiKey:     strings.TrimSpace(apiKey),
		baseURL:    "https://api.steampowered.com",
		httpClient: &http.Client{Timeout: timeout},
	}
}

// Enabled reports whether a Steam API key is configured.
func (c *Client) Enabled() bool { return c.apiKey != "" }

type vanityResponse struct {
	Response struct {
		SteamID string `json:"steamid"`
		Success int    `json:"success"`
		Message string `json:"message"`
	} `json:"response"`
}

// ResolveVanity turns a Steam custom URL name (the part after /id/) into a SteamID64.
func (c *Client) ResolveVanity(ctx context.Context, vanity string) (string, error) {
	if !c.Enabled() {
		return "", fmt.Errorf("steam api key is not configured")
	}
	vanity = strings.TrimSpace(vanity)
	if vanity == "" {
		return "", fmt.Errorf("vanity name is empty")
	}

	q := url.Values{}
	q.Set("key", c.apiKey)
	q.Set("vanityurl", vanity)
	endpoint := c.baseURL + "/ISteamUser/ResolveVanityURL/v1/?" + q.Encode()

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, endpoint, nil)
	if err != nil {
		return "", fmt.Errorf("build steam request: %w", err)
	}
	resp, err := c.httpClient.Do(req)
	if err != nil {
		return "", fmt.Errorf("steam request failed: %w", err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(io.LimitReader(resp.Body, 1<<20))
	if err != nil {
		return "", fmt.Errorf("read steam response: %w", err)
	}
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return "", fmt.Errorf("steam returned status %d", resp.StatusCode)
	}

	var parsed vanityResponse
	if err := json.Unmarshal(body, &parsed); err != nil {
		return "", fmt.Errorf("decode steam response: %w", err)
	}
	if parsed.Response.Success != 1 || parsed.Response.SteamID == "" {
		return "", fmt.Errorf("steam vanity not found")
	}
	return parsed.Response.SteamID, nil
}
