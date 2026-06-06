package application

import (
	"context"
	"strings"

	"gamementor/internal/domain"
	cs2domain "gamementor/internal/modules/cs2/domain"
)

type Service struct {
	repo cs2domain.CS2Repository
}

func NewService(repo cs2domain.CS2Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) ListMaps(ctx context.Context) ([]cs2domain.CS2Map, error) {
	return s.repo.ListMaps(ctx)
}

func (s *Service) CreateGrenade(ctx context.Context, input cs2domain.CreateCS2GrenadeInput) (*cs2domain.CS2Grenade, error) {
	normalized, err := normalizeGrenadeInput(input)
	if err != nil {
		return nil, err
	}
	return s.repo.CreateGrenade(ctx, normalized)
}

func (s *Service) ListGrenades(ctx context.Context, filter cs2domain.CS2GrenadeFilter) ([]cs2domain.CS2Grenade, error) {
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

	return s.repo.ListGrenades(ctx, filter)
}

func (s *Service) GetGrenade(ctx context.Context, id int64) (*cs2domain.CS2Grenade, error) {
	if id <= 0 {
		return nil, domain.ValidationError("id must be positive")
	}
	return s.repo.GetGrenade(ctx, id)
}

func (s *Service) UpdateGrenade(ctx context.Context, id int64, input cs2domain.UpdateCS2GrenadeInput) (*cs2domain.CS2Grenade, error) {
	if id <= 0 {
		return nil, domain.ValidationError("id must be positive")
	}
	normalized, err := normalizeGrenadeInput(input)
	if err != nil {
		return nil, err
	}
	return s.repo.UpdateGrenade(ctx, id, normalized)
}

func (s *Service) DeleteGrenade(ctx context.Context, id int64) error {
	if id <= 0 {
		return domain.ValidationError("id must be positive")
	}
	return s.repo.DeleteGrenade(ctx, id)
}

func normalizeGrenadeInput(input cs2domain.CreateCS2GrenadeInput) (cs2domain.CreateCS2GrenadeInput, error) {
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
	return side == cs2domain.CS2SideT || side == cs2domain.CS2SideCT
}

func validGrenadeType(value string) bool {
	switch value {
	case cs2domain.CS2GrenadeTypeSmoke, cs2domain.CS2GrenadeTypeFlash, cs2domain.CS2GrenadeTypeMolotov, cs2domain.CS2GrenadeTypeHE:
		return true
	default:
		return false
	}
}

func validDifficulty(value string) bool {
	switch value {
	case cs2domain.DifficultyEasy, cs2domain.DifficultyMedium, cs2domain.DifficultyHard:
		return true
	default:
		return false
	}
}
