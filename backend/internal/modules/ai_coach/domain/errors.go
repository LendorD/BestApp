package domain

import (
	"errors"
	"fmt"
)

var (
	ErrReportNotFound    = errors.New("ai coach report not found")
	ErrProviderDisabled  = errors.New("provider disabled or api key is missing")
	ErrInvalidCoachInput = errors.New("invalid ai coach input")
)

func ProviderDisabled(provider string) error {
	if provider == "" {
		provider = "ai"
	}
	return fmt.Errorf("%w: %s", ErrProviderDisabled, provider)
}

func InvalidInput(message string) error {
	return fmt.Errorf("%w: %s", ErrInvalidCoachInput, message)
}
