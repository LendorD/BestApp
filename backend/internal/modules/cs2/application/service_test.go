package application

import (
	"context"
	"testing"

	cs2domain "gamementor/internal/modules/cs2/domain"
)

type fakeCS2Repo struct{}

func (f *fakeCS2Repo) ListMaps(ctx context.Context) ([]cs2domain.CS2Map, error) { return nil, nil }
func (f *fakeCS2Repo) CreateGrenade(ctx context.Context, in cs2domain.CreateCS2GrenadeInput) (*cs2domain.CS2Grenade, error) {
	return &cs2domain.CS2Grenade{Map: in.Map, Side: in.Side, Type: in.Type, Title: in.Title}, nil
}
func (f *fakeCS2Repo) ListGrenades(ctx context.Context, filter cs2domain.CS2GrenadeFilter) ([]cs2domain.CS2Grenade, error) {
	return nil, nil
}
func (f *fakeCS2Repo) GetGrenade(ctx context.Context, id int64) (*cs2domain.CS2Grenade, error) {
	return nil, nil
}
func (f *fakeCS2Repo) UpdateGrenade(ctx context.Context, id int64, in cs2domain.UpdateCS2GrenadeInput) (*cs2domain.CS2Grenade, error) {
	return nil, nil
}
func (f *fakeCS2Repo) DeleteGrenade(ctx context.Context, id int64) error { return nil }

func TestCreateGrenadeRejectsEmptyInput(t *testing.T) {
	s := NewService(&fakeCS2Repo{})
	if _, err := s.CreateGrenade(context.Background(), cs2domain.CreateCS2GrenadeInput{}); err == nil {
		t.Fatal("expected validation error for empty grenade input")
	}
}

func TestCreateGrenadeNormalizesInput(t *testing.T) {
	s := NewService(&fakeCS2Repo{})
	g, err := s.CreateGrenade(context.Background(), cs2domain.CreateCS2GrenadeInput{
		Map: " Mirage ", Side: "t", Type: "Smoke", Title: " A site ",
		FromPosition: "T spawn", ToPosition: "A", Difficulty: "Easy",
	})
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if g.Map != "mirage" {
		t.Errorf("map not lowercased: %q", g.Map)
	}
	if g.Side != cs2domain.CS2SideT {
		t.Errorf("side not normalized: %q", g.Side)
	}
}

func TestListGrenadesRejectsBadSide(t *testing.T) {
	s := NewService(&fakeCS2Repo{})
	if _, err := s.ListGrenades(context.Background(), cs2domain.CS2GrenadeFilter{Side: "X"}); err == nil {
		t.Fatal("expected validation error for invalid side")
	}
}
