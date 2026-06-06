package application

import (
	"context"
	"time"

	usersapp "gamementor/internal/modules/users/application"
	usersdomain "gamementor/internal/modules/users/domain"
)

// Service coordinates registration/login on top of the users aggregate and
// issues JWT tokens for authenticated sessions.
type Service struct {
	users  *usersapp.Service
	tokens *TokenManager
}

// AuthResult is returned to the client after register/login.
type AuthResult struct {
	User      *usersdomain.User `json:"user"`
	Token     string            `json:"token"`
	ExpiresAt time.Time         `json:"expires_at"`
}

func NewService(users *usersapp.Service, tokens *TokenManager) *Service {
	return &Service{users: users, tokens: tokens}
}

func (s *Service) Register(ctx context.Context, input usersdomain.RegisterUserInput) (*AuthResult, error) {
	res, err := s.users.Register(ctx, input)
	if err != nil {
		return nil, err
	}
	return s.issue(res.User)
}

func (s *Service) Login(ctx context.Context, input usersdomain.LoginUserInput) (*AuthResult, error) {
	res, err := s.users.Login(ctx, input)
	if err != nil {
		return nil, err
	}
	return s.issue(res.User)
}

// Me returns the current user by id (used by GET /auth/me).
func (s *Service) Me(ctx context.Context, userID int64) (*usersdomain.User, error) {
	return s.users.GetProfile(ctx, userID)
}

// Tokens exposes the token manager for the auth middleware.
func (s *Service) Tokens() *TokenManager { return s.tokens }

func (s *Service) issue(user *usersdomain.User) (*AuthResult, error) {
	token, exp, err := s.tokens.Generate(user.ID, user.Username, user.Email)
	if err != nil {
		return nil, err
	}
	return &AuthResult{User: user, Token: token, ExpiresAt: exp}, nil
}
