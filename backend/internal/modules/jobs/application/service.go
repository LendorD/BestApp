package application

import (
	"context"
	"errors"
	"log/slog"
	"sync"
	"time"

	"github.com/google/uuid"

	jobsdomain "gamementor/internal/modules/jobs/domain"
)

type HandlerFunc func(ctx context.Context, payload jobsdomain.JobPayload) (map[string]any, error)

type Service struct {
	repo     jobsdomain.Repository
	logger   *slog.Logger
	handlers map[jobsdomain.JobType]HandlerFunc
	now      func() time.Time
	mu       sync.RWMutex
}

func NewService(repo jobsdomain.Repository, logger *slog.Logger) *Service {
	return &Service{
		repo:     repo,
		logger:   logger,
		handlers: make(map[jobsdomain.JobType]HandlerFunc),
		now:      time.Now,
	}
}

func (s *Service) Register(jobType jobsdomain.JobType, handler HandlerFunc) {
	s.mu.Lock()
	s.handlers[jobType] = handler
	s.mu.Unlock()
}

func (s *Service) CreateJob(ctx context.Context, input CreateJobInput) (*jobsdomain.Job, error) {
	if input.Type == "" {
		return nil, jobsdomain.InvalidJob("type is required")
	}
	if input.Payload == nil {
		input.Payload = jobsdomain.JobPayload{}
	}

	now := s.now().UTC()
	job := &jobsdomain.Job{
		ID:        uuid.NewString(),
		Type:      input.Type,
		Status:    jobsdomain.JobStatusPending,
		Payload:   input.Payload,
		CreatedAt: now,
		UpdatedAt: now,
	}
	if err := s.repo.Save(ctx, job); err != nil {
		return nil, err
	}

	go s.runJob(context.Background(), job.ID)
	return job, nil
}

func (s *Service) GetJob(ctx context.Context, id string) (*jobsdomain.Job, error) {
	if id == "" {
		return nil, jobsdomain.InvalidJob("job_id is required")
	}
	return s.repo.GetByID(ctx, id)
}

func (s *Service) runJob(ctx context.Context, id string) {
	job, err := s.repo.GetByID(ctx, id)
	if err != nil {
		s.logger.Error("job load failed", "job_id", id, "error", err)
		return
	}

	now := s.now().UTC()
	job.Status = jobsdomain.JobStatusRunning
	job.StartedAt = &now
	job.UpdatedAt = now
	if err := s.repo.Update(ctx, job); err != nil {
		s.logger.Error("job running update failed", "job_id", id, "error", err)
		return
	}

	s.mu.RLock()
	handler := s.handlers[job.Type]
	s.mu.RUnlock()

	var result map[string]any
	if handler == nil {
		err = jobsdomain.InvalidJob("unsupported job type")
	} else {
		result, err = handler(ctx, job.Payload)
	}

	finished := s.now().UTC()
	job.UpdatedAt = finished
	job.CompletedAt = &finished
	if err != nil {
		job.Status = jobsdomain.JobStatusFailed
		job.Error = err.Error()
	} else {
		job.Status = jobsdomain.JobStatusCompleted
		job.Result = result
	}
	if updateErr := s.repo.Update(ctx, job); updateErr != nil && !errors.Is(updateErr, context.Canceled) {
		s.logger.Error("job finish update failed", "job_id", id, "error", updateErr)
	}
}
