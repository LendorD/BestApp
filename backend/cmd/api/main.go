package main

import (
	"context"
	"errors"
	"log/slog"
	"net/http"
	"os"

	"gamementor/internal/app"
)

// @title GameMentor API
// @version 0.1.0
// @description MVP backend for CS2 grenade training and Dota 2 player analytics.
// @BasePath /
func main() {
	if err := app.Run(); err != nil {
		if errors.Is(err, http.ErrServerClosed) || errors.Is(err, context.Canceled) {
			return
		}
		slog.Error("application stopped with error", "error", err)
		os.Exit(1)
	}
}
