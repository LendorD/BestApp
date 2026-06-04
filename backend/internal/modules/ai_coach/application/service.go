package application

import (
	"context"
	"errors"
	"fmt"
	"strings"
	"time"

	"github.com/google/uuid"

	coachdomain "gamementor/internal/modules/ai_coach/domain"
	analyticsdomain "gamementor/internal/modules/analytics/domain"
	platformcache "gamementor/internal/platform/cache"
)

type AnalyticsProvider interface {
	BuildDotaSnapshot(ctx context.Context, steamID string) (*analyticsdomain.DotaSnapshot, error)
}

type Service struct {
	analytics AnalyticsProvider
	aiClient  AIClient
	repo      coachdomain.Repository
	cache     platformcache.Cache
	now       func() time.Time
}

func NewService(analytics AnalyticsProvider, aiClient AIClient, repo coachdomain.Repository, cacheStore ...platformcache.Cache) *Service {
	service := &Service{
		analytics: analytics,
		aiClient:  aiClient,
		repo:      repo,
		now:       time.Now,
	}
	if len(cacheStore) > 0 {
		service.cache = cacheStore[0]
	}
	return service
}

func (s *Service) ReviewDotaPlayer(ctx context.Context, steamID string) (*coachdomain.CoachReport, error) {
	steamID = strings.TrimSpace(steamID)
	if steamID == "" {
		return nil, coachdomain.InvalidInput("steam_id is required")
	}

	snapshot, err := s.analytics.BuildDotaSnapshot(ctx, steamID)
	if err != nil {
		return nil, err
	}
	prompt, err := BuildDotaReviewPrompt(snapshot)
	if err != nil {
		return nil, err
	}

	content, err := s.aiClient.GenerateCoachReport(ctx, AIRequest{
		SteamID: steamID,
		Prompt:  prompt,
	})
	if err != nil {
		return nil, err
	}

	report := &coachdomain.CoachReport{
		ID:              uuid.NewString(),
		SteamID:         steamID,
		Summary:         content.Summary,
		Strengths:       content.Strengths,
		Weaknesses:      content.Weaknesses,
		MainMistakes:    content.MainMistakes,
		Recommendations: content.Recommendations,
		TrainingPlan:    content.TrainingPlan,
		HeroesToFocus:   content.HeroesToFocus,
		HeroesToAvoid:   content.HeroesToAvoid,
		NextSteps:       content.NextSteps,
		Snapshot:        snapshot,
		Prompt:          prompt,
		CreatedAt:       s.now().UTC(),
	}
	if err := s.repo.Save(ctx, report); err != nil {
		return nil, fmt.Errorf("save ai coach report: %w", err)
	}
	s.cacheReport(ctx, report)
	return report, nil
}

func (s *Service) LatestDotaReport(ctx context.Context, steamID string) (*coachdomain.CoachReport, error) {
	steamID = strings.TrimSpace(steamID)
	if steamID == "" {
		return nil, coachdomain.InvalidInput("steam_id is required")
	}

	key := "ai-coach:dota:latest:" + steamID
	var cached coachdomain.CoachReport
	if s.cache != nil && s.cache.Get(ctx, key, &cached) == nil {
		return &cached, nil
	}
	report, err := s.repo.LatestBySteamID(ctx, steamID)
	if err != nil {
		return nil, err
	}
	s.cacheReport(ctx, report)
	return report, nil
}

func (s *Service) GetReport(ctx context.Context, reportID string) (*coachdomain.CoachReport, error) {
	reportID = strings.TrimSpace(reportID)
	if reportID == "" {
		return nil, coachdomain.InvalidInput("report_id is required")
	}

	key := "ai-coach:report:" + reportID
	var cached coachdomain.CoachReport
	if s.cache != nil && s.cache.Get(ctx, key, &cached) == nil {
		return &cached, nil
	}
	report, err := s.repo.GetByID(ctx, reportID)
	if err != nil {
		return nil, err
	}
	s.cacheReport(ctx, report)
	return report, nil
}

func (s *Service) cacheReport(ctx context.Context, report *coachdomain.CoachReport) {
	if s.cache == nil || report == nil {
		return
	}
	_ = s.cache.Set(ctx, "ai-coach:report:"+report.ID, report, 0)
	_ = s.cache.Set(ctx, "ai-coach:dota:latest:"+report.SteamID, report, 0)
}

func IsProviderDisabled(err error) bool {
	return errors.Is(err, coachdomain.ErrProviderDisabled)
}
