package postgres

import (
	"context"
	"errors"
	"fmt"

	"gamementor/internal/domain"
	usersdomain "gamementor/internal/modules/users/domain"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"
)

type Repository struct {
	pool *pgxpool.Pool
}

func NewRepository(pool *pgxpool.Pool) *Repository {
	return &Repository{pool: pool}
}

func (r *Repository) CreateUser(ctx context.Context, input usersdomain.RegisterUserInput, passwordHash string) (*usersdomain.User, error) {
	row := r.pool.QueryRow(ctx, `
		INSERT INTO tbl_users (email, username, password_hash, display_name, updated_at)
		VALUES ($1, $2, $3, $4, now())
		RETURNING id, email, username, display_name, avatar_url, bio, favorite_game,
		          dota_account_id, created_at, updated_at, last_login_at
	`, input.Email, input.Username, passwordHash, input.DisplayName)

	user, err := scanUser(row)
	if err != nil {
		if isUniqueViolation(err) {
			return nil, domain.ValidationError("email or username already exists")
		}
		return nil, fmt.Errorf("create user: %w", err)
	}
	return user, nil
}

func (r *Repository) GetUserByID(ctx context.Context, id int64) (*usersdomain.User, error) {
	row := r.pool.QueryRow(ctx, `
		SELECT id, email, username, display_name, avatar_url, bio, favorite_game,
		       dota_account_id, created_at, updated_at, last_login_at
		FROM tbl_users WHERE id = $1
	`, id)

	user, err := scanUser(row)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, domain.NotFound("user not found")
		}
		return nil, fmt.Errorf("get user: %w", err)
	}
	return user, nil
}

func (r *Repository) GetUserByIdentity(ctx context.Context, identity string) (*usersdomain.User, string, error) {
	row := r.pool.QueryRow(ctx, `
		SELECT id, email, username, display_name, avatar_url, bio, favorite_game,
		       dota_account_id, created_at, updated_at, last_login_at, password_hash
		FROM tbl_users
		WHERE lower(email) = lower($1) OR lower(username) = lower($1)
	`, identity)

	user, passwordHash, err := scanUserWithPassword(row)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, "", domain.NotFound("user not found")
		}
		return nil, "", fmt.Errorf("get user by identity: %w", err)
	}
	return user, passwordHash, nil
}

func (r *Repository) UpdateProfile(ctx context.Context, id int64, input usersdomain.UpdateUserProfileInput) (*usersdomain.User, error) {
	row := r.pool.QueryRow(ctx, `
		UPDATE tbl_users
		SET display_name = $2, avatar_url = $3, bio = $4, favorite_game = $5,
		    dota_account_id = $6, updated_at = now()
		WHERE id = $1
		RETURNING id, email, username, display_name, avatar_url, bio, favorite_game,
		          dota_account_id, created_at, updated_at, last_login_at
	`, id, input.DisplayName, input.AvatarURL, input.Bio, input.FavoriteGame, input.DotaAccountID)

	user, err := scanUser(row)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, domain.NotFound("user not found")
		}
		return nil, fmt.Errorf("update user profile: %w", err)
	}
	return user, nil
}

type scanner interface {
	Scan(dest ...any) error
}

func scanUser(row scanner) (*usersdomain.User, error) {
	user, _, err := scanUserFields(row, false)
	return user, err
}

func scanUserWithPassword(row scanner) (*usersdomain.User, string, error) {
	return scanUserFields(row, true)
}

func scanUserFields(row scanner, withPassword bool) (*usersdomain.User, string, error) {
	var user usersdomain.User
	var dotaAccountID pgtype.Int8
	var lastLoginAt pgtype.Timestamptz
	var passwordHash string

	dest := []any{
		&user.ID, &user.Email, &user.Username, &user.DisplayName, &user.AvatarURL,
		&user.Bio, &user.FavoriteGame, &dotaAccountID, &user.CreatedAt, &user.UpdatedAt, &lastLoginAt,
	}
	if withPassword {
		dest = append(dest, &passwordHash)
	}
	if err := row.Scan(dest...); err != nil {
		return nil, "", err
	}
	if dotaAccountID.Valid {
		value := dotaAccountID.Int64
		user.DotaAccountID = &value
	}
	if lastLoginAt.Valid {
		value := lastLoginAt.Time
		user.LastLoginAt = &value
	}
	return &user, passwordHash, nil
}

func isUniqueViolation(err error) bool {
	var pgErr *pgconn.PgError
	return errors.As(err, &pgErr) && pgErr.Code == "23505"
}
