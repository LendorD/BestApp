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
	RedisURL          string
	OpenDotaBaseURL   string
	OpenDotaAPIKey    string
	StratzAPIKey      string
	SteamAPIKey       string
	AIProvider        string
	AIAPIKey          string
	AIModel           string
	CacheEnabled      bool
	JobsEnabled       bool
	OpenDotaTimeout   time.Duration
	ReadHeaderTimeout time.Duration
	ShutdownTimeout   time.Duration
}

func Load() (*Config, error) {
	cfg := &Config{
		AppEnv:          getEnv("APP_ENV", "local"),
		HTTPAddr:        getEnv("HTTP_ADDR", ":8080"),
		DatabaseURL:     getEnv("DATABASE_URL", ""),
		RedisURL:        getEnv("REDIS_URL", ""),
		OpenDotaBaseURL: getEnv("OPENDOTA_BASE_URL", "https://api.opendota.com"),
		OpenDotaAPIKey:  getEnv("OPENDOTA_API_KEY", ""),
		StratzAPIKey:    getEnv("STRATZ_API_KEY", ""),
		SteamAPIKey:     getEnv("STEAM_API_KEY", ""),
		AIProvider:      getEnv("AI_PROVIDER", ""),
		AIAPIKey:        getEnv("AI_API_KEY", ""),
		AIModel:         getEnv("AI_MODEL", ""),
		CacheEnabled:    parseBoolEnv("CACHE_ENABLED", true),
		JobsEnabled:     parseBoolEnv("JOBS_ENABLED", true),
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

func parseBoolEnv(key string, fallback bool) bool {
	raw := os.Getenv(key)
	if raw == "" {
		return fallback
	}
	switch raw {
	case "1", "true", "TRUE", "yes", "YES", "on", "ON":
		return true
	case "0", "false", "FALSE", "no", "NO", "off", "OFF":
		return false
	default:
		return fallback
	}
}
