package queue

import "context"

type Queue interface {
	Publish(ctx context.Context, topic string, payload any) error
	Subscribe(ctx context.Context, topic string, handler func(context.Context, any) error) error
}
