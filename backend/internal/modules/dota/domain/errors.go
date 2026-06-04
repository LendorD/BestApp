package domain

import (
	"errors"
	"fmt"
)

var (
	ErrProviderDisabled = errors.New("provider disabled or api key is missing")
	ErrInvalidSteamID   = errors.New("invalid steam id")
)

func ProviderDisabled(provider string) error {
	return fmt.Errorf("%w: %s", ErrProviderDisabled, provider)
}

func InvalidSteamID(value string) error {
	return fmt.Errorf("%w: %s", ErrInvalidSteamID, value)
}
