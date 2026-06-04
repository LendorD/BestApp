package usecase

import (
	"context"
	"errors"
	"net/mail"
	"strings"
	"unicode/utf8"

	"gamementor/internal/domain"

	"golang.org/x/crypto/bcrypt"
)

type UserRepository interface {
	CreateUser(ctx context.Context, input domain.RegisterUserInput, passwordHash string) (*domain.User, error)
	GetUserByID(ctx context.Context, id int64) (*domain.User, error)
	GetUserByIdentity(ctx context.Context, identity string) (*domain.User, string, error)
	UpdateProfile(ctx context.Context, id int64, input domain.UpdateUserProfileInput) (*domain.User, error)
}

type UserUsecase struct {
	repo UserRepository
}

func NewUserUsecase(repo UserRepository) *UserUsecase {
	return &UserUsecase{repo: repo}
}

func (u *UserUsecase) Register(ctx context.Context, input domain.RegisterUserInput) (*domain.AuthResponse, error) {
	normalized, err := normalizeRegisterInput(input)
	if err != nil {
		return nil, err
	}

	hash, err := bcrypt.GenerateFromPassword([]byte(normalized.Password), bcrypt.DefaultCost)
	if err != nil {
		return nil, err
	}

	user, err := u.repo.CreateUser(ctx, normalized, string(hash))
	if err != nil {
		return nil, err
	}
	return &domain.AuthResponse{User: user}, nil
}

func (u *UserUsecase) Login(ctx context.Context, input domain.LoginUserInput) (*domain.AuthResponse, error) {
	identity := strings.ToLower(strings.TrimSpace(input.Identity))
	password := strings.TrimSpace(input.Password)
	if identity == "" {
		return nil, domain.ValidationError("email or username is required")
	}
	if password == "" {
		return nil, domain.ValidationError("password is required")
	}

	user, passwordHash, err := u.repo.GetUserByIdentity(ctx, identity)
	if err != nil {
		if errors.Is(err, domain.ErrNotFound) {
			return nil, domain.Unauthorized("invalid email or password")
		}
		return nil, err
	}
	if err := bcrypt.CompareHashAndPassword([]byte(passwordHash), []byte(password)); err != nil {
		return nil, domain.Unauthorized("invalid email or password")
	}
	return &domain.AuthResponse{User: user}, nil
}

func (u *UserUsecase) GetProfile(ctx context.Context, id int64) (*domain.User, error) {
	if id <= 0 {
		return nil, domain.ValidationError("user id must be positive")
	}
	return u.repo.GetUserByID(ctx, id)
}

func (u *UserUsecase) UpdateProfile(ctx context.Context, id int64, input domain.UpdateUserProfileInput) (*domain.User, error) {
	if id <= 0 {
		return nil, domain.ValidationError("user id must be positive")
	}

	input.DisplayName = strings.TrimSpace(input.DisplayName)
	input.AvatarURL = strings.TrimSpace(input.AvatarURL)
	input.Bio = strings.TrimSpace(input.Bio)
	input.FavoriteGame = strings.TrimSpace(input.FavoriteGame)

	if input.DisplayName == "" {
		return nil, domain.ValidationError("display_name is required")
	}
	if utf8.RuneCountInString(input.DisplayName) > 80 {
		return nil, domain.ValidationError("display_name is too long")
	}
	if utf8.RuneCountInString(input.Bio) > 500 {
		return nil, domain.ValidationError("bio is too long")
	}
	if input.DotaAccountID != nil && *input.DotaAccountID <= 0 {
		return nil, domain.ValidationError("dota_account_id must be positive")
	}

	return u.repo.UpdateProfile(ctx, id, input)
}

func normalizeRegisterInput(input domain.RegisterUserInput) (domain.RegisterUserInput, error) {
	input.Email = strings.ToLower(strings.TrimSpace(input.Email))
	input.Username = strings.ToLower(strings.TrimSpace(input.Username))
	input.Password = strings.TrimSpace(input.Password)
	input.DisplayName = strings.TrimSpace(input.DisplayName)

	if input.Email == "" {
		return input, domain.ValidationError("email is required")
	}
	if _, err := mail.ParseAddress(input.Email); err != nil {
		return input, domain.ValidationError("email is invalid")
	}
	if input.Username == "" {
		return input, domain.ValidationError("username is required")
	}
	if utf8.RuneCountInString(input.Username) < 3 {
		return input, domain.ValidationError("username must be at least 3 characters")
	}
	if utf8.RuneCountInString(input.Username) > 40 {
		return input, domain.ValidationError("username is too long")
	}
	if utf8.RuneCountInString(input.Password) < 6 {
		return input, domain.ValidationError("password must be at least 6 characters")
	}
	if input.DisplayName == "" {
		input.DisplayName = input.Username
	}
	return input, nil
}
