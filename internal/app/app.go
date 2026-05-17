package app

import (
	"context"
	"errors"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"gamementor/internal/clients/opendota"
	"gamementor/internal/config"
	httpdelivery "gamementor/internal/delivery/http"
	"gamementor/internal/delivery/http/handler"
	"gamementor/internal/logger"
	"gamementor/internal/platform/postgres"
	pgrepo "gamementor/internal/repository/postgres"
	"gamementor/internal/usecase"
)

func Run() error {
	cfg, err := config.Load()
	if err != nil {
		return err
	}

	log := logger.New(cfg.AppEnv)
	slog.SetDefault(log)

	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	pool, err := postgres.NewPool(ctx, cfg.DatabaseURL)
	if err != nil {
		return err
	}
	defer pool.Close()

	cs2Repo := pgrepo.NewCS2Repository(pool)
	dotaRepo := pgrepo.NewDotaRepository(pool)
	userRepo := pgrepo.NewUserRepository(pool)

	openDotaClient := opendota.NewClient(cfg.OpenDotaBaseURL, cfg.OpenDotaTimeout)

	cs2UC := usecase.NewCS2Usecase(cs2Repo)
	dotaUC := usecase.NewDotaUsecase(openDotaClient, dotaRepo)
	userUC := usecase.NewUserUsecase(userRepo)

	cs2Handler := handler.NewCS2Handler(cs2UC)
	dotaHandler := handler.NewDotaHandler(dotaUC)
	userHandler := handler.NewUserHandler(userUC)

	router := httpdelivery.NewRouter(log, cs2Handler, dotaHandler, userHandler)
	server := &http.Server{
		Addr:              cfg.HTTPAddr,
		Handler:           router,
		ReadHeaderTimeout: cfg.ReadHeaderTimeout,
	}

	errCh := make(chan error, 1)
	go func() {
		log.Info("http server started", "addr", cfg.HTTPAddr)
		errCh <- server.ListenAndServe()
	}()

	select {
	case <-ctx.Done():
		shutdownCtx, cancel := context.WithTimeout(context.Background(), cfg.ShutdownTimeout)
		defer cancel()
		log.Info("http server shutting down")
		if err := server.Shutdown(shutdownCtx); err != nil {
			return err
		}
		return nil
	case err := <-errCh:
		if errors.Is(err, http.ErrServerClosed) {
			return nil
		}
		time.Sleep(100 * time.Millisecond)
		return err
	}
}
