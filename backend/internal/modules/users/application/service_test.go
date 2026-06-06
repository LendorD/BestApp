package application

import (
	"context"
	"testing"

	usersdomain "gamementor/internal/modules/users/domain"
)

type fakeUserRepo struct{ created bool }

func (f *fakeUserRepo) CreateUser(ctx context.Context, in usersdomain.RegisterUserInput, hash string) (*usersdomain.User, error) {
	f.created = true
	return &usersdomain.User{ID: 1, Email: in.Email, Username: in.Username, DisplayName: in.DisplayName}, nil
}
func (f *fakeUserRepo) GetUserByID(ctx context.Context, id int64) (*usersdomain.User, error) {
	return &usersdomain.User{ID: id}, nil
}
func (f *fakeUserRepo) GetUserByIdentity(ctx context.Context, identity string) (*usersdomain.User, string, error) {
	return nil, "", nil
}
func (f *fakeUserRepo) UpdateProfile(ctx context.Context, id int64, in usersdomain.UpdateUserProfileInput) (*usersdomain.User, error) {
	return &usersdomain.User{ID: id, DisplayName: in.DisplayName}, nil
}

func TestRegisterRejectsInvalidEmail(t *testing.T) {
	s := NewService(&fakeUserRepo{})
	_, err := s.Register(context.Background(), usersdomain.RegisterUserInput{Email: "not-an-email", Username: "player", Password: "secret1"})
	if err == nil {
		t.Fatal("expected validation error for invalid email")
	}
}

func TestRegisterSucceeds(t *testing.T) {
	repo := &fakeUserRepo{}
	s := NewService(repo)
	res, err := s.Register(context.Background(), usersdomain.RegisterUserInput{Email: "a@b.com", Username: "player", Password: "secret1"})
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if !repo.created || res == nil || res.User == nil {
		t.Fatal("expected user to be created")
	}
}

func TestUpdateProfileRequiresDisplayName(t *testing.T) {
	s := NewService(&fakeUserRepo{})
	if _, err := s.UpdateProfile(context.Background(), 1, usersdomain.UpdateUserProfileInput{}); err == nil {
		t.Fatal("expected validation error for empty display_name")
	}
}
