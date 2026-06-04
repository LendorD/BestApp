CREATE TABLE IF NOT EXISTS tbl_users (
    id BIGSERIAL PRIMARY KEY,
    email TEXT NOT NULL UNIQUE,
    username TEXT NOT NULL UNIQUE,
    password_hash TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS tbl_cs2_maps (
    id BIGSERIAL PRIMARY KEY,
    code TEXT NOT NULL UNIQUE,
    display_name TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO tbl_cs2_maps (code, display_name)
VALUES
    ('mirage', 'Mirage'),
    ('inferno', 'Inferno'),
    ('dust2', 'Dust2'),
    ('nuke', 'Nuke'),
    ('ancient', 'Ancient'),
    ('anubis', 'Anubis'),
    ('vertigo', 'Vertigo')
ON CONFLICT (code) DO UPDATE
SET display_name = EXCLUDED.display_name,
    updated_at = now();

CREATE TABLE IF NOT EXISTS tbl_cs2_grenades (
    id BIGSERIAL PRIMARY KEY,
    map_id BIGINT NOT NULL REFERENCES tbl_cs2_maps(id) ON DELETE RESTRICT,
    side TEXT NOT NULL CHECK (side IN ('T', 'CT')),
    type TEXT NOT NULL CHECK (type IN ('smoke', 'flash', 'molotov', 'he')),
    title TEXT NOT NULL,
    description TEXT NOT NULL DEFAULT '',
    from_position TEXT NOT NULL,
    to_position TEXT NOT NULL,
    difficulty TEXT NOT NULL CHECK (difficulty IN ('easy', 'medium', 'hard')),
    image_url TEXT NOT NULL DEFAULT '',
    video_url TEXT NOT NULL DEFAULT '',
    tags TEXT[] NOT NULL DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_cs2_grenades_map_id ON tbl_cs2_grenades(map_id);
CREATE INDEX IF NOT EXISTS idx_cs2_grenades_type ON tbl_cs2_grenades(type);
CREATE INDEX IF NOT EXISTS idx_cs2_grenades_side ON tbl_cs2_grenades(side);
CREATE INDEX IF NOT EXISTS idx_cs2_grenades_difficulty ON tbl_cs2_grenades(difficulty);

CREATE TABLE IF NOT EXISTS tbl_dota_players (
    account_id BIGINT PRIMARY KEY,
    persona_name TEXT NOT NULL DEFAULT '',
    avatar_full TEXT NOT NULL DEFAULT '',
    profile_url TEXT NOT NULL DEFAULT '',
    rank_tier INTEGER,
    raw JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS tbl_dota_player_matches (
    match_id BIGINT NOT NULL,
    account_id BIGINT NOT NULL REFERENCES tbl_dota_players(account_id) ON DELETE CASCADE,
    player_slot INTEGER NOT NULL,
    radiant_win BOOLEAN NOT NULL,
    won BOOLEAN NOT NULL,
    hero_id INTEGER NOT NULL,
    kills INTEGER NOT NULL DEFAULT 0,
    deaths INTEGER NOT NULL DEFAULT 0,
    assists INTEGER NOT NULL DEFAULT 0,
    duration_seconds INTEGER NOT NULL DEFAULT 0,
    start_time TIMESTAMPTZ NOT NULL,
    raw JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (account_id, match_id)
);

CREATE INDEX IF NOT EXISTS idx_dota_player_matches_account_id ON tbl_dota_player_matches(account_id);
CREATE INDEX IF NOT EXISTS idx_dota_player_matches_start_time ON tbl_dota_player_matches(start_time DESC);
CREATE INDEX IF NOT EXISTS idx_dota_player_matches_hero_id ON tbl_dota_player_matches(hero_id);

CREATE TABLE IF NOT EXISTS tbl_dota_player_snapshots (
    id BIGSERIAL PRIMARY KEY,
    account_id BIGINT NOT NULL REFERENCES tbl_dota_players(account_id) ON DELETE CASCADE,
    matches_count INTEGER NOT NULL DEFAULT 0,
    wins INTEGER NOT NULL DEFAULT 0,
    losses INTEGER NOT NULL DEFAULT 0,
    winrate NUMERIC(6, 2) NOT NULL DEFAULT 0,
    avg_kills NUMERIC(8, 2) NOT NULL DEFAULT 0,
    avg_deaths NUMERIC(8, 2) NOT NULL DEFAULT 0,
    avg_assists NUMERIC(8, 2) NOT NULL DEFAULT 0,
    kda NUMERIC(8, 2) NOT NULL DEFAULT 0,
    top_heroes JSONB NOT NULL DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_dota_player_snapshots_account_id ON tbl_dota_player_snapshots(account_id);
CREATE INDEX IF NOT EXISTS idx_dota_player_snapshots_created_at ON tbl_dota_player_snapshots(created_at DESC);
