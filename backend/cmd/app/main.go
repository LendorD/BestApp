package main

import (
	"context"
	"errors"
	"log/slog"
	"net/http"
	"os"

	"gamementor/internal/app"
)

func main() {
	if err := app.Run(); err != nil {
		if errors.Is(err, http.ErrServerClosed) || errors.Is(err, context.Canceled) {
			return
		}
		slog.Error("application stopped with error", "error", err)
		os.Exit(1)
	}
}
