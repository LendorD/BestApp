package postgres

import (
	"context"
	"errors"
	"fmt"

	"gamementor/internal/domain"
	cs2domain "gamementor/internal/modules/cs2/domain"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type Repository struct {
	pool *pgxpool.Pool
}

func NewRepository(pool *pgxpool.Pool) *Repository {
	return &Repository{pool: pool}
}

func (r *Repository) ListMaps(ctx context.Context) ([]cs2domain.CS2Map, error) {
	rows, err := r.pool.Query(ctx, `
		SELECT id, code, display_name, created_at, updated_at
		FROM tbl_cs2_maps
		ORDER BY display_name
	`)
	if err != nil {
		return nil, fmt.Errorf("list cs2 maps: %w", err)
	}
	defer rows.Close()

	maps := make([]cs2domain.CS2Map, 0)
	for rows.Next() {
		var item cs2domain.CS2Map
		if err := rows.Scan(&item.ID, &item.Code, &item.DisplayName, &item.CreatedAt, &item.UpdatedAt); err != nil {
			return nil, fmt.Errorf("scan cs2 map: %w", err)
		}
		maps = append(maps, item)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate cs2 maps: %w", err)
	}
	return maps, nil
}

func (r *Repository) CreateGrenade(ctx context.Context, input cs2domain.CreateCS2GrenadeInput) (*cs2domain.CS2Grenade, error) {
	row := r.pool.QueryRow(ctx, `
		WITH selected_map AS (
			SELECT id FROM tbl_cs2_maps WHERE code = $1
		),
		inserted AS (
			INSERT INTO tbl_cs2_grenades (
				map_id, side, type, title, description, from_position, to_position,
				difficulty, image_url, video_url, tags
			)
			SELECT id, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11
			FROM selected_map
			RETURNING *
		)
		SELECT g.id, m.code, g.side, g.type, g.title, g.description, g.from_position,
		       g.to_position, g.difficulty, g.image_url, g.video_url, g.tags,
		       g.created_at, g.updated_at
		FROM inserted g
		JOIN tbl_cs2_maps m ON m.id = g.map_id
	`, input.Map, input.Side, input.Type, input.Title, input.Description, input.FromPosition,
		input.ToPosition, input.Difficulty, input.ImageURL, input.VideoURL, input.Tags)

	grenade, err := scanGrenade(row)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, domain.NotFound("cs2 map not found")
		}
		return nil, fmt.Errorf("create cs2 grenade: %w", err)
	}
	return grenade, nil
}

func (r *Repository) ListGrenades(ctx context.Context, filter cs2domain.CS2GrenadeFilter) ([]cs2domain.CS2Grenade, error) {
	rows, err := r.pool.Query(ctx, `
		SELECT g.id, m.code, g.side, g.type, g.title, g.description, g.from_position,
		       g.to_position, g.difficulty, g.image_url, g.video_url, g.tags,
		       g.created_at, g.updated_at
		FROM tbl_cs2_grenades g
		JOIN tbl_cs2_maps m ON m.id = g.map_id
		WHERE ($1::text = '' OR m.code = $1)
		  AND ($2::text = '' OR g.side = $2)
		  AND ($3::text = '' OR g.type = $3)
		  AND ($4::text = '' OR g.difficulty = $4)
		ORDER BY g.created_at DESC, g.id DESC
		LIMIT $5 OFFSET $6
	`, filter.Map, filter.Side, filter.Type, filter.Difficulty, filter.Limit, filter.Offset)
	if err != nil {
		return nil, fmt.Errorf("list cs2 grenades: %w", err)
	}
	defer rows.Close()

	grenades := make([]cs2domain.CS2Grenade, 0)
	for rows.Next() {
		grenade, err := scanGrenade(rows)
		if err != nil {
			return nil, fmt.Errorf("scan cs2 grenade: %w", err)
		}
		grenades = append(grenades, *grenade)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate cs2 grenades: %w", err)
	}
	return grenades, nil
}

func (r *Repository) GetGrenade(ctx context.Context, id int64) (*cs2domain.CS2Grenade, error) {
	row := r.pool.QueryRow(ctx, `
		SELECT g.id, m.code, g.side, g.type, g.title, g.description, g.from_position,
		       g.to_position, g.difficulty, g.image_url, g.video_url, g.tags,
		       g.created_at, g.updated_at
		FROM tbl_cs2_grenades g
		JOIN tbl_cs2_maps m ON m.id = g.map_id
		WHERE g.id = $1
	`, id)

	grenade, err := scanGrenade(row)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, domain.NotFound("cs2 grenade not found")
		}
		return nil, fmt.Errorf("get cs2 grenade: %w", err)
	}
	return grenade, nil
}

func (r *Repository) UpdateGrenade(ctx context.Context, id int64, input cs2domain.UpdateCS2GrenadeInput) (*cs2domain.CS2Grenade, error) {
	row := r.pool.QueryRow(ctx, `
		WITH selected_map AS (
			SELECT id FROM tbl_cs2_maps WHERE code = $2
		),
		updated AS (
			UPDATE tbl_cs2_grenades
			SET map_id = (SELECT id FROM selected_map),
			    side = $3, type = $4, title = $5, description = $6,
			    from_position = $7, to_position = $8, difficulty = $9,
			    image_url = $10, video_url = $11, tags = $12, updated_at = now()
			WHERE id = $1 AND EXISTS (SELECT 1 FROM selected_map)
			RETURNING *
		)
		SELECT g.id, m.code, g.side, g.type, g.title, g.description, g.from_position,
		       g.to_position, g.difficulty, g.image_url, g.video_url, g.tags,
		       g.created_at, g.updated_at
		FROM updated g
		JOIN tbl_cs2_maps m ON m.id = g.map_id
	`, id, input.Map, input.Side, input.Type, input.Title, input.Description, input.FromPosition,
		input.ToPosition, input.Difficulty, input.ImageURL, input.VideoURL, input.Tags)

	grenade, err := scanGrenade(row)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, domain.NotFound("cs2 grenade or map not found")
		}
		return nil, fmt.Errorf("update cs2 grenade: %w", err)
	}
	return grenade, nil
}

func (r *Repository) DeleteGrenade(ctx context.Context, id int64) error {
	tag, err := r.pool.Exec(ctx, `DELETE FROM tbl_cs2_grenades WHERE id = $1`, id)
	if err != nil {
		return fmt.Errorf("delete cs2 grenade: %w", err)
	}
	if tag.RowsAffected() == 0 {
		return domain.NotFound("cs2 grenade not found")
	}
	return nil
}

type scanner interface {
	Scan(dest ...any) error
}

func scanGrenade(row scanner) (*cs2domain.CS2Grenade, error) {
	var item cs2domain.CS2Grenade
	if err := row.Scan(
		&item.ID, &item.Map, &item.Side, &item.Type, &item.Title, &item.Description,
		&item.FromPosition, &item.ToPosition, &item.Difficulty, &item.ImageURL,
		&item.VideoURL, &item.Tags, &item.CreatedAt, &item.UpdatedAt,
	); err != nil {
		return nil, err
	}
	return &item, nil
}
