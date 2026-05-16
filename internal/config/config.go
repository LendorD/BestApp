package config

import (
	"fmt"
	"os"
	"time"
)

type Config struct {
	AppEnv            string
	HTTPAddr          string
	DatabaseURL       string
	OpenDotaBaseURL   string
	OpenDotaTimeout   time.Duration
	ReadHeaderTimeout time.Duration
	ShutdownTimeout   time.Duration
}

func Load() (*Config, error) {
	cfg := &Config{
		AppEnv:          getEnv("APP_ENV", "local"),
		HTTPAddr:        getEnv("HTTP_ADDR", ":8080"),
		DatabaseURL:     getEnv("DATABASE_URL", ""),
		OpenDotaBaseURL: getEnv("OPENDOTA_BASE_URL", "https://api.opendota.com"),
	}

	if cfg.DatabaseURL == "" {
		return nil, fmt.Errorf("DATABASE_URL is required")
	}

	var err error
	cfg.OpenDotaTimeout, err = parseDurationEnv("OPENDOTA_TIMEOUT", 10*time.Second)
	if err != nil {
		return nil, err
	}
	cfg.ReadHeaderTimeout, err = parseDurationEnv("HTTP_READ_HEADER_TIMEOUT", 5*time.Second)
	if err != nil {
		return nil, err
	}
	cfg.ShutdownTimeout, err = parseDurationEnv("HTTP_SHUTDOWN_TIMEOUT", 10*time.Second)
	if err != nil {
		return nil, err
	}

	return cfg, nil
}

func getEnv(key, fallback string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return fallback
}

func parseDurationEnv(key string, fallback time.Duration) (time.Duration, error) {
	raw := os.Getenv(key)
	if raw == "" {
		return fallback, nil
	}
	value, err := time.ParseDuration(raw)
	if err != nil {
		return 0, fmt.Errorf("invalid %s duration: %w", key, err)
	}
	return value, nil
}
