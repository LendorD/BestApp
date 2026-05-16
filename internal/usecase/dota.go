package usecase

import (
	"context"
	"sort"

	"gamementor/internal/domain"
)

type OpenDotaClient interface {
	GetPlayer(ctx context.Context, accountID int64) (*domain.DotaPlayer, error)
	GetRecentMatches(ctx context.Context, accountID int64) ([]domain.DotaPlayerMatch, error)
}

type DotaRepository interface {
	UpsertPlayer(ctx context.Context, player *domain.DotaPlayer) (*domain.DotaPlayer, error)
	UpsertMatches(ctx context.Context, accountID int64, matches []domain.DotaPlayerMatch) error
	SaveSnapshot(ctx context.Context, snapshot *domain.DotaPlayerSnapshot) (*domain.DotaPlayerSnapshot, error)
}

type DotaUsecase struct {
	client OpenDotaClient
	repo   DotaRepository
}

func NewDotaUsecase(client OpenDotaClient, repo DotaRepository) *DotaUsecase {
	return &DotaUsecase{client: client, repo: repo}
}

func (u *DotaUsecase) GetPlayer(ctx context.Context, accountID int64) (*domain.DotaPlayer, error) {
	if accountID <= 0 {
		return nil, domain.ValidationError("account_id must be positive")
	}

	player, err := u.client.GetPlayer(ctx, accountID)
	if err != nil {
		return nil, err
	}
	return u.repo.UpsertPlayer(ctx, player)
}

func (u *DotaUsecase) GetRecentMatches(ctx context.Context, accountID int64) ([]domain.DotaPlayerMatch, error) {
	if accountID <= 0 {
		return nil, domain.ValidationError("account_id must be positive")
	}

	matches, err := u.client.GetRecentMatches(ctx, accountID)
	if err != nil {
		return nil, err
	}
	if err := u.repo.UpsertMatches(ctx, accountID, matches); err != nil {
		return nil, err
	}
	return matches, nil
}

func (u *DotaUsecase) GetSummary(ctx context.Context, accountID int64) (*domain.DotaSummary, error) {
	matches, err := u.GetRecentMatches(ctx, accountID)
	if err != nil {
		return nil, err
	}

	summary := calculateSummary(accountID, matches)
	snapshot := &domain.DotaPlayerSnapshot{
		AccountID:  summary.AccountID,
		Matches:    summary.Matches,
		Wins:       summary.Wins,
		Losses:     summary.Losses,
		Winrate:    summary.Winrate,
		AvgKills:   summary.AvgKills,
		AvgDeaths:  summary.AvgDeaths,
		AvgAssists: summary.AvgAssists,
		KDA:        summary.KDA,
		TopHeroes:  summary.TopHeroes,
	}

	saved, err := u.repo.SaveSnapshot(ctx, snapshot)
	if err != nil {
		return nil, err
	}
	summary.SnapshotID = saved.ID
	summary.Snapshotted = saved.CreatedAt
	return summary, nil
}

func calculateSummary(accountID int64, matches []domain.DotaPlayerMatch) *domain.DotaSummary {
	summary := &domain.DotaSummary{
		AccountID: accountID,
		Matches:   len(matches),
		TopHeroes: make([]domain.DotaHeroSummary, 0),
	}
	if len(matches) == 0 {
		return summary
	}

	var kills, deaths, assists int
	heroStats := make(map[int]*domain.DotaHeroSummary)

	for _, match := range matches {
		kills += match.Kills
		deaths += match.Deaths
		assists += match.Assists
		if match.Won {
			summary.Wins++
		}

		stat, ok := heroStats[match.HeroID]
		if !ok {
			stat = &domain.DotaHeroSummary{HeroID: match.HeroID}
			heroStats[match.HeroID] = stat
		}
		stat.Matches++
		if match.Won {
			stat.Wins++
		}
	}

	summary.Losses = summary.Matches - summary.Wins
	summary.Winrate = percent(summary.Wins, summary.Matches)
	summary.AvgKills = average(kills, summary.Matches)
	summary.AvgDeaths = average(deaths, summary.Matches)
	summary.AvgAssists = average(assists, summary.Matches)
	if deaths == 0 {
		summary.KDA = float64(kills + assists)
	} else {
		summary.KDA = round2(float64(kills+assists) / float64(deaths))
	}

	for _, stat := range heroStats {
		stat.Winrate = percent(stat.Wins, stat.Matches)
		summary.TopHeroes = append(summary.TopHeroes, *stat)
	}
	sort.Slice(summary.TopHeroes, func(i, j int) bool {
		if summary.TopHeroes[i].Matches == summary.TopHeroes[j].Matches {
			return summary.TopHeroes[i].HeroID < summary.TopHeroes[j].HeroID
		}
		return summary.TopHeroes[i].Matches > summary.TopHeroes[j].Matches
	})
	if len(summary.TopHeroes) > 5 {
		summary.TopHeroes = summary.TopHeroes[:5]
	}

	return summary
}

func average(total, count int) float64 {
	if count == 0 {
		return 0
	}
	return round2(float64(total) / float64(count))
}

func percent(value, total int) float64 {
	if total == 0 {
		return 0
	}
	return round2(float64(value) / float64(total) * 100)
}

func round2(value float64) float64 {
	return float64(int(value*100+0.5)) / 100
}
