package watcher

import (
	"context"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/fsnotify/fsnotify"
)

type FileWatcher struct {
	path   string
	logger *slog.Logger

	offset  int64
	partial string
}

func NewFileWatcher(path string, logger *slog.Logger) (*FileWatcher, error) {
	absolutePath, err := filepath.Abs(path)
	if err != nil {
		return nil, fmt.Errorf("resolve console log path: %w", err)
	}
	if logger == nil {
		logger = slog.Default()
	}
	return &FileWatcher{
		path:   filepath.Clean(absolutePath),
		logger: logger,
	}, nil
}

func (w *FileWatcher) Lines(ctx context.Context) (<-chan string, <-chan error) {
	lines := make(chan string)
	errs := make(chan error, 8)

	go func() {
		defer close(lines)
		defer close(errs)

		if err := w.run(ctx, lines, errs); err != nil && !errors.Is(err, context.Canceled) {
			errs <- err
		}
	}()

	return lines, errs
}

func (w *FileWatcher) run(ctx context.Context, lines chan<- string, errs chan<- error) error {
	dir := filepath.Dir(w.path)
	if err := os.MkdirAll(dir, 0o755); err != nil {
		return fmt.Errorf("ensure console log directory: %w", err)
	}

	if stat, err := os.Stat(w.path); err == nil {
		w.offset = stat.Size()
		w.logger.Info("Console log connected", "path", w.path, "offset", w.offset)
	} else if errors.Is(err, os.ErrNotExist) {
		w.logger.Info("Console log does not exist yet, waiting for file", "path", w.path)
	} else {
		return fmt.Errorf("stat console log: %w", err)
	}

	fileWatcher, err := fsnotify.NewWatcher()
	if err != nil {
		return fmt.Errorf("create fsnotify watcher: %w", err)
	}
	defer fileWatcher.Close()

	if err := fileWatcher.Add(dir); err != nil {
		return fmt.Errorf("watch console log directory: %w", err)
	}

	ticker := time.NewTicker(time.Second)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			return ctx.Err()
		case event, ok := <-fileWatcher.Events:
			if !ok {
				return nil
			}
			if !samePath(event.Name, w.path) {
				continue
			}
			if event.Has(fsnotify.Remove) || event.Has(fsnotify.Rename) {
				w.offset = 0
				w.partial = ""
				w.logger.Info("Console log was rotated or removed, waiting for new file", "path", w.path)
				continue
			}
			if event.Has(fsnotify.Write) || event.Has(fsnotify.Create) {
				if err := w.readNewLines(lines); err != nil {
					sendError(ctx, errs, err)
				}
			}
		case err, ok := <-fileWatcher.Errors:
			if !ok {
				return nil
			}
			sendError(ctx, errs, fmt.Errorf("fsnotify error: %w", err))
		case <-ticker.C:
			if err := w.readNewLines(lines); err != nil {
				sendError(ctx, errs, err)
			}
		}
	}
}

func (w *FileWatcher) readNewLines(lines chan<- string) error {
	file, err := os.Open(w.path)
	if err != nil {
		if errors.Is(err, os.ErrNotExist) {
			return nil
		}
		return fmt.Errorf("open console log: %w", err)
	}
	defer file.Close()

	stat, err := file.Stat()
	if err != nil {
		return fmt.Errorf("stat console log: %w", err)
	}
	if stat.Size() < w.offset {
		w.logger.Info("Console log was truncated, resetting tail offset", "path", w.path)
		w.offset = 0
		w.partial = ""
	}

	if _, err := file.Seek(w.offset, io.SeekStart); err != nil {
		return fmt.Errorf("seek console log: %w", err)
	}
	data, err := io.ReadAll(file)
	if err != nil {
		return fmt.Errorf("read console log tail: %w", err)
	}
	if len(data) == 0 {
		return nil
	}

	w.offset += int64(len(data))
	text := w.partial + string(data)
	text = strings.ReplaceAll(text, "\r\n", "\n")
	text = strings.ReplaceAll(text, "\r", "\n")

	parts := strings.Split(text, "\n")
	w.partial = parts[len(parts)-1]
	for _, line := range parts[:len(parts)-1] {
		if strings.TrimSpace(line) == "" {
			continue
		}
		lines <- line
	}

	return nil
}

func sendError(ctx context.Context, errs chan<- error, err error) {
	select {
	case errs <- err:
	case <-ctx.Done():
	default:
	}
}

func samePath(left, right string) bool {
	left = filepath.Clean(left)
	right = filepath.Clean(right)
	if left == right {
		return true
	}
	return strings.EqualFold(left, right)
}
