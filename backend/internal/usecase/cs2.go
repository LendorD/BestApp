package usecase

import (
	"context"
	"strings"

	"gamementor/internal/domain"
)

type CS2Repository interface {
	ListMaps(ctx context.Context) ([]domain.CS2Map, error)
	CreateGrenade(ctx context.Context, input domain.CreateCS2GrenadeInput) (*domain.CS2Grenade, error)
	ListGrenades(ctx context.Context, filter domain.CS2GrenadeFilter) ([]domain.CS2Grenade, error)
	GetGrenade(ctx context.Context, id int64) (*domain.CS2Grenade, error)
	UpdateGrenade(ctx context.Context, id int64, input domain.UpdateCS2GrenadeInput) (*domain.CS2Grenade, error)
	DeleteGrenade(ctx context.Context, id int64) error
}

type CS2Usecase struct {
	repo CS2Repository
}

func NewCS2Usecase(repo CS2Repository) *CS2Usecase {
	return &CS2Usecase{repo: repo}
}

func (u *CS2Usecase) ListMaps(ctx context.Context) ([]domain.CS2Map, error) {
	return u.repo.ListMaps(ctx)
}

func (u *CS2Usecase) CreateGrenade(ctx context.Context, input domain.CreateCS2GrenadeInput) (*domain.CS2Grenade, error) {
	normalized, err := normalizeGrenadeInput(input)
	if err != nil {
		return nil, err
	}
	return u.repo.CreateGrenade(ctx, normalized)
}

func (u *CS2Usecase) ListGrenades(ctx context.Context, filter domain.CS2GrenadeFilter) ([]domain.CS2Grenade, error) {
	filter.Map = strings.ToLower(strings.TrimSpace(filter.Map))
	filter.Side = strings.ToUpper(strings.TrimSpace(filter.Side))
	filter.Type = strings.ToLower(strings.TrimSpace(filter.Type))
	filter.Difficulty = strings.ToLower(strings.TrimSpace(filter.Difficulty))

	if filter.Side != "" && !validSide(filter.Side) {
		return nil, domain.ValidationError("side must be T or CT")
	}
	if filter.Type != "" && !validGrenadeType(filter.Type) {
		return nil, domain.ValidationError("type must be smoke, flash, molotov or he")
	}
	if filter.Difficulty != "" && !validDifficulty(filter.Difficulty) {
		return nil, domain.ValidationError("difficulty must be easy, medium or hard")
	}
	if filter.Limit <= 0 {
		filter.Limit = 50
	}
	if filter.Limit > 100 {
		filter.Limit = 100
	}
	if filter.Offset < 0 {
		filter.Offset = 0
	}

	return u.repo.ListGrenades(ctx, filter)
}

func (u *CS2Usecase) GetGrenade(ctx context.Context, id int64) (*domain.CS2Grenade, error) {
	if id <= 0 {
		return nil, domain.ValidationError("id must be positive")
	}
	return u.repo.GetGrenade(ctx, id)
}

func (u *CS2Usecase) UpdateGrenade(ctx context.Context, id int64, input domain.UpdateCS2GrenadeInput) (*domain.CS2Grenade, error) {
	if id <= 0 {
		return nil, domain.ValidationError("id must be positive")
	}
	normalized, err := normalizeGrenadeInput(input)
	if err != nil {
		return nil, err
	}
	return u.repo.UpdateGrenade(ctx, id, normalized)
}

func (u *CS2Usecase) DeleteGrenade(ctx context.Context, id int64) error {
	if id <= 0 {
		return domain.ValidationError("id must be positive")
	}
	return u.repo.DeleteGrenade(ctx, id)
}

func normalizeGrenadeInput(input domain.CreateCS2GrenadeInput) (domain.CreateCS2GrenadeInput, error) {
	input.Map = strings.ToLower(strings.TrimSpace(input.Map))
	input.Side = strings.ToUpper(strings.TrimSpace(input.Side))
	input.Type = strings.ToLower(strings.TrimSpace(input.Type))
	input.Title = strings.TrimSpace(input.Title)
	input.Description = strings.TrimSpace(input.Description)
	input.FromPosition = strings.TrimSpace(input.FromPosition)
	input.ToPosition = strings.TrimSpace(input.ToPosition)
	input.Difficulty = strings.ToLower(strings.TrimSpace(input.Difficulty))
	input.ImageURL = strings.TrimSpace(input.ImageURL)
	input.VideoURL = strings.TrimSpace(input.VideoURL)
	input.Tags = normalizeTags(input.Tags)

	if input.Map == "" {
		return input, domain.ValidationError("map is required")
	}
	if !validSide(input.Side) {
		return input, domain.ValidationError("side must be T or CT")
	}
	if !validGrenadeType(input.Type) {
		return input, domain.ValidationError("type must be smoke, flash, molotov or he")
	}
	if input.Title == "" {
		return input, domain.ValidationError("title is required")
	}
	if input.FromPosition == "" {
		return input, domain.ValidationError("from_position is required")
	}
	if input.ToPosition == "" {
		return input, domain.ValidationError("to_position is required")
	}
	if !validDifficulty(input.Difficulty) {
		return input, domain.ValidationError("difficulty must be easy, medium or hard")
	}

	return input, nil
}

func normalizeTags(tags []string) []string {
	result := make([]string, 0, len(tags))
	seen := make(map[string]struct{}, len(tags))
	for _, tag := range tags {
		clean := strings.ToLower(strings.TrimSpace(tag))
		if clean == "" {
			continue
		}
		if _, ok := seen[clean]; ok {
			continue
		}
		seen[clean] = struct{}{}
		result = append(result, clean)
	}
	return result
}

func validSide(side string) bool {
	return side == domain.CS2SideT || side == domain.CS2SideCT
}

func validGrenadeType(value string) bool {
	switch value {
	case domain.CS2GrenadeTypeSmoke, domain.CS2GrenadeTypeFlash, domain.CS2GrenadeTypeMolotov, domain.CS2GrenadeTypeHE:
		return true
	default:
		return false
	}
}

func validDifficulty(value string) bool {
	switch value {
	case domain.DifficultyEasy, domain.DifficultyMedium, domain.DifficultyHard:
		return true
	default:
		return false
	}
}
