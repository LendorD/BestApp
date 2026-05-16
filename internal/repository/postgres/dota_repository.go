package postgres

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"gamementor/internal/domain"

	"github.com/jackc/pgx/v5/pgxpool"
)

type DotaRepository struct {
	pool *pgxpool.Pool
}

func NewDotaRepository(pool *pgxpool.Pool) *DotaRepository {
	return &DotaRepository{pool: pool}
}

func (r *DotaRepository) UpsertPlayer(ctx context.Context, player *domain.DotaPlayer) (*domain.DotaPlayer, error) {
	if len(player.Raw) == 0 {
		player.Raw = json.RawMessage(`{}`)
	}

	row := r.pool.QueryRow(ctx, `
		INSERT INTO tbl_dota_players (
			account_id, persona_name, avatar_full, profile_url, rank_tier, raw, updated_at
		)
		VALUES ($1, $2, $3, $4, $5, $6, now())
		ON CONFLICT (account_id) DO UPDATE
		SET persona_name = EXCLUDED.persona_name,
		    avatar_full = EXCLUDED.avatar_full,
		    profile_url = EXCLUDED.profile_url,
		    rank_tier = EXCLUDED.rank_tier,
		    raw = EXCLUDED.raw,
		    updated_at = now()
		RETURNING created_at, updated_at
	`, player.AccountID, player.PersonaName, player.AvatarFull, player.ProfileURL, player.RankTier, []byte(player.Raw))

	if err := row.Scan(&player.CreatedAt, &player.UpdatedAt); err != nil {
		return nil, fmt.Errorf("upsert dota player: %w", err)
	}
	return player, nil
}

func (r *DotaRepository) UpsertMatches(ctx context.Context, accountID int64, matches []domain.DotaPlayerMatch) error {
	if len(matches) == 0 {
		return nil
	}

	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return fmt.Errorf("begin upsert dota matches: %w", err)
	}
	defer tx.Rollback(ctx)

	if _, err := tx.Exec(ctx, `
		INSERT INTO tbl_dota_players (account_id, updated_at)
		VALUES ($1, now())
		ON CONFLICT (account_id) DO NOTHING
	`, accountID); err != nil {
		return fmt.Errorf("ensure dota player for matches: %w", err)
	}

	for _, match := range matches {
		raw := match.Raw
		if len(raw) == 0 {
			raw = json.RawMessage(`{}`)
		}
		startTime := match.StartTime
		if startTime.IsZero() {
			startTime = time.Unix(0, 0).UTC()
		}

		_, err := tx.Exec(ctx, `
			INSERT INTO tbl_dota_player_matches (
				match_id, account_id, player_slot, radiant_win, won, hero_id, kills,
				deaths, assists, duration_seconds, start_time, raw, updated_at
			)
			VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, now())
			ON CONFLICT (account_id, match_id) DO UPDATE
			SET player_slot = EXCLUDED.player_slot,
			    radiant_win = EXCLUDED.radiant_win,
			    won = EXCLUDED.won,
			    hero_id = EXCLUDED.hero_id,
			    kills = EXCLUDED.kills,
			    deaths = EXCLUDED.deaths,
			    assists = EXCLUDED.assists,
			    duration_seconds = EXCLUDED.duration_seconds,
			    start_time = EXCLUDED.start_time,
			    raw = EXCLUDED.raw,
			    updated_at = now()
		`, match.MatchID, accountID, match.PlayerSlot, match.RadiantWin, match.Won, match.HeroID,
			match.Kills, match.Deaths, match.Assists, match.DurationSeconds, startTime, []byte(raw))
		if err != nil {
			return fmt.Errorf("upsert dota match %d: %w", match.MatchID, err)
		}
	}

	if err := tx.Commit(ctx); err != nil {
		return fmt.Errorf("commit upsert dota matches: %w", err)
	}
	return nil
}

func (r *DotaRepository) SaveSnapshot(ctx context.Context, snapshot *domain.DotaPlayerSnapshot) (*domain.DotaPlayerSnapshot, error) {
	topHeroes, err := json.Marshal(snapshot.TopHeroes)
	if err != nil {
		return nil, fmt.Errorf("marshal top heroes: %w", err)
	}

	if _, err := r.pool.Exec(ctx, `
		INSERT INTO tbl_dota_players (account_id, updated_at)
		VALUES ($1, now())
		ON CONFLICT (account_id) DO NOTHING
	`, snapshot.AccountID); err != nil {
		return nil, fmt.Errorf("ensure dota player for snapshot: %w", err)
	}

	row := r.pool.QueryRow(ctx, `
		INSERT INTO tbl_dota_player_snapshots (
			account_id, matches_count, wins, losses, winrate, avg_kills,
			avg_deaths, avg_assists, kda, top_heroes
		)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
		RETURNING id, created_at
	`, snapshot.AccountID, snapshot.Matches, snapshot.Wins, snapshot.Losses, snapshot.Winrate,
		snapshot.AvgKills, snapshot.AvgDeaths, snapshot.AvgAssists, snapshot.KDA, topHeroes)

	if err := row.Scan(&snapshot.ID, &snapshot.CreatedAt); err != nil {
		return nil, fmt.Errorf("save dota snapshot: %w", err)
	}
	return snapshot, nil
}
