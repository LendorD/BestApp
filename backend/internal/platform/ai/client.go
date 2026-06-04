package ai

import (
	"context"
	"errors"
)

var ErrDisabled = errors.New("provider disabled or api key is missing")

type Request struct {
	Model        string
	SystemPrompt string
	UserPrompt   string
}

type Response struct {
	Content string
}

type Client interface {
	Generate(ctx context.Context, request Request) (*Response, error)
}

type DisabledClient struct{}

func NewDisabledClient() *DisabledClient {
	return &DisabledClient{}
}

func (c *DisabledClient) Generate(ctx context.Context, request Request) (*Response, error) {
	if err := ctx.Err(); err != nil {
		return nil, err
	}
	_ = request
	return nil, ErrDisabled
}
