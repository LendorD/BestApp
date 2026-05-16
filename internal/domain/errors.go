package domain

import (
	"errors"
	"fmt"
)

var (
	ErrNotFound   = errors.New("not found")
	ErrValidation = errors.New("validation error")
	ErrExternal   = errors.New("external service error")
)

func NotFound(message string) error {
	return fmt.Errorf("%w: %s", ErrNotFound, message)
}

func ValidationError(message string) error {
	return fmt.Errorf("%w: %s", ErrValidation, message)
}

func ExternalError(message string) error {
	return fmt.Errorf("%w: %s", ErrExternal, message)
}
