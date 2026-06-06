// Package openai implements aicoachapp.AIClient against any OpenAI-compatible
// chat completions endpoint (OpenRouter, OpenAI, Ollama, Together, etc.).
package openai

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"

	"gamementor/internal/domain"
	aicoachapp "gamementor/internal/modules/ai_coach/application"
	coachdomain "gamementor/internal/modules/ai_coach/domain"
)

const systemPrompt = "You are GameMentor AI Coach, an expert Dota 2 analyst. " +
	"You always answer with a single strict JSON object and nothing else. " +
	"Write the human-readable text fields in Russian."

// Client talks to an OpenAI-compatible /chat/completions endpoint.
type Client struct {
	provider   string
	apiKey     string
	model      string
	baseURL    string
	httpClient *http.Client
}

// New builds a client. baseURL may be empty: it is then derived from provider.
func New(provider, apiKey, model, baseURL string, timeout time.Duration) *Client {
	if timeout <= 0 {
		timeout = 60 * time.Second
	}
	if baseURL == "" {
		switch strings.ToLower(provider) {
		case "openrouter":
			baseURL = "https://openrouter.ai/api/v1"
		case "openai":
			baseURL = "https://api.openai.com/v1"
		case "ollama":
			baseURL = "http://localhost:11434/v1"
		}
	}
	return &Client{
		provider:   provider,
		apiKey:     apiKey,
		model:      model,
		baseURL:    strings.TrimRight(baseURL, "/"),
		httpClient: &http.Client{Timeout: timeout},
	}
}

// Enabled reports whether the client is configured enough to make calls.
func (c *Client) Enabled() bool {
	// Ollama can run without an API key; everything else needs one.
	keyOK := c.apiKey != "" || strings.ToLower(c.provider) == "ollama"
	return keyOK && c.model != "" && c.baseURL != ""
}

type chatMessage struct {
	Role    string `json:"role"`
	Content string `json:"content"`
}

type chatRequest struct {
	Model          string         `json:"model"`
	Messages       []chatMessage  `json:"messages"`
	Temperature    float64        `json:"temperature"`
	ResponseFormat map[string]any `json:"response_format,omitempty"`
}

type chatResponse struct {
	Choices []struct {
		Message struct {
			Content string `json:"content"`
		} `json:"message"`
	} `json:"choices"`
	Error *struct {
		Message string `json:"message"`
	} `json:"error,omitempty"`
}

// GenerateCoachReport implements aicoachapp.AIClient.
func (c *Client) GenerateCoachReport(ctx context.Context, request aicoachapp.AIRequest) (*coachdomain.ReportContent, error) {
	if !c.Enabled() {
		return nil, coachdomain.ProviderDisabled(c.provider)
	}

	model := c.model
	if request.Model != "" {
		model = request.Model
	}

	// NOTE: we intentionally do NOT set response_format/json_object — many free
	// OpenRouter models don't support JSON mode and reject the request. The
	// system prompt asks for strict JSON and extractJSON() pulls it from text.
	body := chatRequest{
		Model: model,
		Messages: []chatMessage{
			{Role: "system", Content: systemPrompt},
			{Role: "user", Content: request.Prompt},
		},
		Temperature: 0.4,
	}
	raw, err := json.Marshal(body)
	if err != nil {
		return nil, fmt.Errorf("marshal ai request: %w", err)
	}

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, c.baseURL+"/chat/completions", bytes.NewReader(raw))
	if err != nil {
		return nil, fmt.Errorf("build ai request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")
	if c.apiKey != "" {
		req.Header.Set("Authorization", "Bearer "+c.apiKey)
	}
	// OpenRouter recommends these headers; harmless elsewhere.
	req.Header.Set("HTTP-Referer", "https://gamementor.app")
	req.Header.Set("X-Title", "GameMentor AI Coach")

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return nil, domain.ExternalError("AI request failed: " + err.Error())
	}
	defer resp.Body.Close()

	payload, err := io.ReadAll(io.LimitReader(resp.Body, 8<<20))
	if err != nil {
		return nil, domain.ExternalError("read AI response: " + err.Error())
	}
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return nil, domain.ExternalError(fmt.Sprintf("AI provider status %d (model %s): %s", resp.StatusCode, model, truncate(string(payload), 400)))
	}

	var parsed chatResponse
	if err := json.Unmarshal(payload, &parsed); err != nil {
		return nil, domain.ExternalError("decode AI response: " + err.Error())
	}
	if parsed.Error != nil && parsed.Error.Message != "" {
		return nil, domain.ExternalError("AI provider error: " + parsed.Error.Message)
	}
	if len(parsed.Choices) == 0 {
		return nil, domain.ExternalError("AI provider returned no choices (model " + model + ")")
	}

	content := extractJSON(parsed.Choices[0].Message.Content)
	var report coachdomain.ReportContent
	if err := json.Unmarshal([]byte(content), &report); err != nil {
		return nil, domain.ExternalError("AI output is not valid JSON: " + truncate(content, 200))
	}
	return &report, nil
}

// extractJSON strips markdown code fences and grabs the outermost JSON object.
func extractJSON(s string) string {
	s = strings.TrimSpace(s)
	s = strings.TrimPrefix(s, "```json")
	s = strings.TrimPrefix(s, "```")
	s = strings.TrimSuffix(s, "```")
	s = strings.TrimSpace(s)
	start := strings.Index(s, "{")
	end := strings.LastIndex(s, "}")
	if start >= 0 && end > start {
		return s[start : end+1]
	}
	return s
}

func truncate(s string, n int) string {
	if len(s) <= n {
		return s
	}
	return s[:n] + "..."
}
