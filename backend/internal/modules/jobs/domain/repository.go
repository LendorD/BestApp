package domain

import "context"

type Repository interface {
	Save(ctx context.Context, job *Job) error
	GetByID(ctx context.Context, id string) (*Job, error)
	Update(ctx context.Context, job *Job) error
}
