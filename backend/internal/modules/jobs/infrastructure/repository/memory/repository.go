package memory

import (
	"context"
	"sync"

	jobsdomain "gamementor/internal/modules/jobs/domain"
)

type Repository struct {
	mu   sync.RWMutex
	jobs map[string]*jobsdomain.Job
}

func New() *Repository {
	return &Repository{jobs: make(map[string]*jobsdomain.Job)}
}

func (r *Repository) Save(ctx context.Context, job *jobsdomain.Job) error {
	if err := ctx.Err(); err != nil {
		return err
	}
	r.mu.Lock()
	r.jobs[job.ID] = clone(job)
	r.mu.Unlock()
	return nil
}

func (r *Repository) GetByID(ctx context.Context, id string) (*jobsdomain.Job, error) {
	if err := ctx.Err(); err != nil {
		return nil, err
	}
	r.mu.RLock()
	job := r.jobs[id]
	r.mu.RUnlock()
	if job == nil {
		return nil, jobsdomain.ErrJobNotFound
	}
	return clone(job), nil
}

func (r *Repository) Update(ctx context.Context, job *jobsdomain.Job) error {
	if err := ctx.Err(); err != nil {
		return err
	}
	r.mu.Lock()
	if r.jobs[job.ID] == nil {
		r.mu.Unlock()
		return jobsdomain.ErrJobNotFound
	}
	r.jobs[job.ID] = clone(job)
	r.mu.Unlock()
	return nil
}

func clone(job *jobsdomain.Job) *jobsdomain.Job {
	if job == nil {
		return nil
	}
	cp := *job
	cp.Payload = cloneMap(job.Payload)
	cp.Result = cloneMap(job.Result)
	return &cp
}

func cloneMap(src map[string]any) map[string]any {
	if src == nil {
		return nil
	}
	dst := make(map[string]any, len(src))
	for key, value := range src {
		dst[key] = value
	}
	return dst
}
