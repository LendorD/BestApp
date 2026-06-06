package domain

import (
	"context"
	"time"
)

type User struct {
	ID            int64      `json:"id"`
	Email         string     `json:"email"`
	Username      string     `json:"username"`
	DisplayName   string     `json:"display_name"`
	AvatarURL     string     `json:"avatar_url"`
	Bio           string     `json:"bio"`
	FavoriteGame  string     `json:"favorite_game"`
	DotaAccountID *int64     `json:"dota_account_id,omitempty"`
	CreatedAt     time.Time  `json:"created_at"`
	UpdatedAt     time.Time  `json:"updated_at"`
	LastLoginAt   *time.Time `json:"last_login_at,omitempty"`
}

type RegisterUserInput struct {
	Email       string `json:"email"`
	Username    string `json:"username"`
	Password    string `json:"password"`
	DisplayName string `json:"display_name"`
}

type LoginUserInput struct {
	Identity string `json:"identity"`
	Password string `json:"password"`
}

type UpdateUserProfileInput struct {
	DisplayName   string `json:"display_name"`
	AvatarURL     string `json:"avatar_url"`
	Bio           string `json:"bio"`
	FavoriteGame  string `json:"favorite_game"`
	DotaAccountID *int64 `json:"dota_account_id"`
}

type AuthResponse struct {
	User *User `json:"user"`
}

// UserRepository is the persistence port for users (shared by auth module).
type UserRepository interface {
	CreateUser(ctx context.Context, input RegisterUserInput, passwordHash string) (*User, error)
	GetUserByID(ctx context.Context, id int64) (*User, error)
	GetUserByIdentity(ctx context.Context, identity string) (*User, string, error)
	UpdateProfile(ctx context.Context, id int64, input UpdateUserProfileInput) (*User, error)
}
