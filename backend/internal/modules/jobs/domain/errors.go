package domain

import (
	"errors"
	"fmt"
)

var (
	ErrJobNotFound = errors.New("job not found")
	ErrInvalidJob  = errors.New("invalid job")
)

func InvalidJob(message string) error {
	return fmt.Errorf("%w: %s", ErrInvalidJob, message)
}
