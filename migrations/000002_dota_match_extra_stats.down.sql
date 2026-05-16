ALTER TABLE tbl_dota_player_matches
    DROP COLUMN IF EXISTS game_mode,
    DROP COLUMN IF EXISTS party_size,
    DROP COLUMN IF EXISTS average_rank,
    DROP COLUMN IF EXISTS hero_healing,
    DROP COLUMN IF EXISTS tower_damage,
    DROP COLUMN IF EXISTS hero_damage,
    DROP COLUMN IF EXISTS last_hits,
    DROP COLUMN IF EXISTS xp_per_min,
    DROP COLUMN IF EXISTS gold_per_min;
