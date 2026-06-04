package disabled

import (
	"context"

	aicoachapp "gamementor/internal/modules/ai_coach/application"
	coachdomain "gamementor/internal/modules/ai_coach/domain"
)

type Client struct {
	provider string
	apiKey   string
	model    string
}

func New(provider string, apiKey string, model string) *Client {
	return &Client{provider: provider, apiKey: apiKey, model: model}
}

func (c *Client) GenerateCoachReport(ctx context.Context, request aicoachapp.AIRequest) (*coachdomain.ReportContent, error) {
	if err := ctx.Err(); err != nil {
		return nil, err
	}
	_ = request
	if c.provider == "" || c.apiKey == "" || c.model == "" {
		return nil, coachdomain.ProviderDisabled(c.provider)
	}
	return nil, coachdomain.ProviderDisabled(c.provider)
}
