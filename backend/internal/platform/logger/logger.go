package logger

import (
	"log/slog"

	legacylogger "gamementor/internal/logger"
)

func New(appEnv string) *slog.Logger {
	return legacylogger.New(appEnv)
}
