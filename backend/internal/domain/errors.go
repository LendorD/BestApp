package domain

import (
	"errors"
	"fmt"
)

var (
	ErrNotFound     = errors.New("not found")
	ErrValidation   = errors.New("validation error")
	ErrUnauthorized = errors.New("unauthorized")
	ErrExternal     = errors.New("external service error")
)

func NotFound(message string) error {
	return fmt.Errorf("%w: %s", ErrNotFound, message)
}

func ValidationError(message string) error {
	return fmt.Errorf("%w: %s", ErrValidation, message)
}

func Unauthorized(message string) error {
	return fmt.Errorf("%w: %s", ErrUnauthorized, message)
}

func ExternalError(message string) error {
	return fmt.Errorf("%w: %s", ErrExternal, message)
}
