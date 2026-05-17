package main

import (
	"bufio"
	"context"
	"errors"
	"flag"
	"fmt"
	"log/slog"
	"os"
	"os/signal"
	"strings"
	"syscall"
	"time"

	"gamementor/internal/exporter"
	"gamementor/internal/parser"
	"gamementor/internal/recorder"
	"gamementor/internal/watcher"
)

type config struct {
	logPath     string
	mapName     string
	grenadeType string
	outputPath  string
	debounce    time.Duration
	fromStart   bool
	verbose     bool
	yes         bool
	defaultPath bool
}

func main() {
	if err := run(); err != nil {
		slog.Error("recorder stopped with error", "error", err)
		os.Exit(1)
	}
}

func run() error {
	cfg := parseFlags()
	log := slog.New(slog.NewTextHandler(os.Stdout, &slog.HandlerOptions{
		Level: slog.LevelInfo,
	}))
	slog.SetDefault(log)

	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	fileWatcher, err := watcher.NewFileWatcher(
		cfg.logPath,
		log,
		watcher.WithFromStart(cfg.fromStart),
	)
	if err != nil {
		return err
	}
	if cfg.defaultPath {
		log.Warn("No -log-path or CS2_CONSOLE_LOG provided; watching local console.log. Pass the real CS2 console.log path if nothing happens.", "path", fileWatcher.Path())
	}

	session := recorder.NewSession(cfg.mapName, cfg.grenadeType, cfg.debounce)
	lines, errs := fileWatcher.Lines(ctx)
	input := bufio.NewReader(os.Stdin)

	log.Info("Recording started", "map", cfg.mapName, "grenade_type", cfg.grenadeType, "log_path", fileWatcher.Path(), "from_start", cfg.fromStart)
	fmt.Println("Press F9 in CS2 at the throw position, then press F9 again at the landing position.")

	for {
		select {
		case <-ctx.Done():
			log.Info("Recording cancelled")
			return nil
		case err, ok := <-errs:
			if !ok {
				continue
			}
			return err
		case line, ok := <-lines:
			if !ok {
				return nil
			}
			if cfg.verbose {
				log.Info("Console line received", "line", line)
			}
			capture, matched, err := parser.ParseGetPosLine(line)
			if err != nil {
				log.Warn("Failed to parse getpos line", "error", err, "line", line)
				continue
			}
			if !matched {
				continue
			}

			stage, err := session.Capture(*capture)
			if errors.Is(err, recorder.ErrSessionComplete) {
				log.Info("Recording session is already complete, ignoring extra getpos line")
				continue
			}
			if err != nil {
				return err
			}

			switch stage {
			case recorder.StageDuplicate:
				log.Info("Duplicate getpos ignored")
			case recorder.StageThrowCaptured:
				log.Info(
					"Throw position captured",
					"x", capture.Position.X,
					"y", capture.Position.Y,
					"z", capture.Position.Z,
					"pitch", capture.View.Pitch,
					"yaw", capture.View.Yaw,
				)
			case recorder.StageLandingCaptured:
				log.Info(
					"Landing position captured",
					"x", capture.Position.X,
					"y", capture.Position.Y,
					"z", capture.Position.Z,
				)
				return exportIfConfirmed(input, session, cfg, log)
			}
		}
	}
}

func parseFlags() config {
	envLogPath := os.Getenv("CS2_CONSOLE_LOG")
	defaultLogPath := os.Getenv("CS2_CONSOLE_LOG")
	if defaultLogPath == "" {
		defaultLogPath = "console.log"
	}

	cfg := config{}
	flag.StringVar(&cfg.logPath, "log-path", defaultLogPath, "path to CS2 console.log")
	flag.StringVar(&cfg.mapName, "map", "de_mirage", "CS2 map name for exported JSON")
	flag.StringVar(&cfg.grenadeType, "type", "smoke", "grenade type: smoke, flash, molotov or he")
	flag.StringVar(&cfg.outputPath, "out", "grenade.json", "JSON export path")
	flag.DurationVar(&cfg.debounce, "debounce", 800*time.Millisecond, "duplicate getpos debounce window")
	flag.BoolVar(&cfg.fromStart, "from-start", false, "read existing console.log content from the beginning before tailing new lines")
	flag.BoolVar(&cfg.verbose, "verbose", false, "log every new console line seen by the recorder")
	flag.BoolVar(&cfg.yes, "yes", false, "export JSON without confirmation after two captures")
	flag.Parse()

	logPathFlagSet := false
	flag.Visit(func(f *flag.Flag) {
		if f.Name == "log-path" {
			logPathFlagSet = true
		}
	})
	cfg.defaultPath = envLogPath == "" && !logPathFlagSet

	return cfg
}

func exportIfConfirmed(input *bufio.Reader, session *recorder.Session, cfg config, log *slog.Logger) error {
	payload, err := session.ExportPayload()
	if err != nil {
		return err
	}

	if !cfg.yes && !promptExport(input, cfg.outputPath) {
		log.Info("JSON export skipped")
		return nil
	}

	if err := exporter.ExportJSON(cfg.outputPath, payload); err != nil {
		return err
	}
	log.Info("JSON exported", "path", cfg.outputPath)
	return nil
}

func promptExport(input *bufio.Reader, outputPath string) bool {
	fmt.Printf("\nTwo positions captured. Export JSON to %s? [Y/n]: ", outputPath)
	answer, err := input.ReadString('\n')
	if err != nil {
		return true
	}

	answer = strings.ToLower(strings.TrimSpace(answer))
	return answer == "" || answer == "y" || answer == "yes"
}
