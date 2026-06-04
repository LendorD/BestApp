CREATE TABLE IF NOT EXISTS tbl_dota_player_profiles (
    steam_id TEXT PRIMARY KEY,
    account_id BIGINT NOT NULL,
    persona_name TEXT NOT NULL DEFAULT '',
    avatar_full TEXT NOT NULL DEFAULT '',
    profile_url TEXT NOT NULL DEFAULT '',
    rank_tier INTEGER,
    raw_json JSONB NOT NULL DEFAULT '{}'::jsonb,
    normalized_json JSONB NOT NULL DEFAULT '{}'::jsonb,
    source TEXT NOT NULL DEFAULT 'opendota',
    fetched_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_dota_player_profiles_account_id ON tbl_dota_player_profiles(account_id);
CREATE INDEX IF NOT EXISTS idx_dota_player_profiles_expires_at ON tbl_dota_player_profiles(expires_at);

CREATE TABLE IF NOT EXISTS tbl_dota_matches (
    match_id TEXT PRIMARY KEY,
    raw_json JSONB NOT NULL DEFAULT '{}'::jsonb,
    normalized_json JSONB NOT NULL DEFAULT '{}'::jsonb,
    source TEXT NOT NULL DEFAULT 'opendota',
    fetched_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_dota_matches_expires_at ON tbl_dota_matches(expires_at);

CREATE TABLE IF NOT EXISTS tbl_dota_match_players (
    match_id TEXT NOT NULL REFERENCES tbl_dota_matches(match_id) ON DELETE CASCADE,
    steam_id TEXT NOT NULL,
    account_id BIGINT NOT NULL,
    hero_id INTEGER NOT NULL,
    won BOOLEAN NOT NULL DEFAULT false,
    kills INTEGER NOT NULL DEFAULT 0,
    deaths INTEGER NOT NULL DEFAULT 0,
    assists INTEGER NOT NULL DEFAULT 0,
    gold_per_min INTEGER NOT NULL DEFAULT 0,
    xp_per_min INTEGER NOT NULL DEFAULT 0,
    hero_damage INTEGER NOT NULL DEFAULT 0,
    tower_damage INTEGER NOT NULL DEFAULT 0,
    raw_json JSONB NOT NULL DEFAULT '{}'::jsonb,
    normalized_json JSONB NOT NULL DEFAULT '{}'::jsonb,
    source TEXT NOT NULL DEFAULT 'opendota',
    fetched_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (match_id, steam_id)
);

CREATE INDEX IF NOT EXISTS idx_dota_match_players_steam_id ON tbl_dota_match_players(steam_id);
CREATE INDEX IF NOT EXISTS idx_dota_match_players_hero_id ON tbl_dota_match_players(hero_id);

CREATE TABLE IF NOT EXISTS tbl_dota_hero_stats (
    steam_id TEXT NOT NULL,
    hero_id INTEGER NOT NULL,
    matches INTEGER NOT NULL DEFAULT 0,
    wins INTEGER NOT NULL DEFAULT 0,
    losses INTEGER NOT NULL DEFAULT 0,
    winrate NUMERIC(6, 2) NOT NULL DEFAULT 0,
    kda NUMERIC(8, 2) NOT NULL DEFAULT 0,
    raw_json JSONB NOT NULL DEFAULT '{}'::jsonb,
    normalized_json JSONB NOT NULL DEFAULT '{}'::jsonb,
    source TEXT NOT NULL DEFAULT 'opendota',
    fetched_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (steam_id, hero_id)
);

CREATE INDEX IF NOT EXISTS idx_dota_hero_stats_winrate ON tbl_dota_hero_stats(winrate DESC);

CREATE TABLE IF NOT EXISTS tbl_dota_analytics_snapshots (
    id BIGSERIAL PRIMARY KEY,
    steam_id TEXT NOT NULL,
    raw_json JSONB NOT NULL DEFAULT '{}'::jsonb,
    normalized_json JSONB NOT NULL DEFAULT '{}'::jsonb,
    source TEXT NOT NULL DEFAULT 'analytics',
    fetched_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_dota_analytics_snapshots_steam_id_created_at ON tbl_dota_analytics_snapshots(steam_id, created_at DESC);

CREATE TABLE IF NOT EXISTS tbl_ai_coach_reports (
    id TEXT PRIMARY KEY,
    steam_id TEXT NOT NULL,
    summary TEXT NOT NULL DEFAULT '',
    strengths JSONB NOT NULL DEFAULT '[]'::jsonb,
    weaknesses JSONB NOT NULL DEFAULT '[]'::jsonb,
    main_mistakes JSONB NOT NULL DEFAULT '[]'::jsonb,
    recommendations JSONB NOT NULL DEFAULT '[]'::jsonb,
    training_plan JSONB NOT NULL DEFAULT '[]'::jsonb,
    heroes_to_focus JSONB NOT NULL DEFAULT '[]'::jsonb,
    heroes_to_avoid JSONB NOT NULL DEFAULT '[]'::jsonb,
    next_steps JSONB NOT NULL DEFAULT '[]'::jsonb,
    raw_json JSONB NOT NULL DEFAULT '{}'::jsonb,
    normalized_json JSONB NOT NULL DEFAULT '{}'::jsonb,
    source TEXT NOT NULL DEFAULT 'ai_coach',
    fetched_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_ai_coach_reports_steam_id_created_at ON tbl_ai_coach_reports(steam_id, created_at DESC);

CREATE TABLE IF NOT EXISTS tbl_jobs (
    id TEXT PRIMARY KEY,
    type TEXT NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('pending', 'running', 'completed', 'failed')),
    payload JSONB NOT NULL DEFAULT '{}'::jsonb,
    result JSONB NOT NULL DEFAULT '{}'::jsonb,
    error TEXT NOT NULL DEFAULT '',
    raw_json JSONB NOT NULL DEFAULT '{}'::jsonb,
    normalized_json JSONB NOT NULL DEFAULT '{}'::jsonb,
    source TEXT NOT NULL DEFAULT 'jobs',
    fetched_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    expires_at TIMESTAMPTZ,
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_jobs_status_created_at ON tbl_jobs(status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_jobs_type_created_at ON tbl_jobs(type, created_at DESC);

CREATE TABLE IF NOT EXISTS tbl_provider_logs (
    id BIGSERIAL PRIMARY KEY,
    provider TEXT NOT NULL,
    operation TEXT NOT NULL,
    status TEXT NOT NULL,
    request_json JSONB NOT NULL DEFAULT '{}'::jsonb,
    response_json JSONB NOT NULL DEFAULT '{}'::jsonb,
    error TEXT NOT NULL DEFAULT '',
    raw_json JSONB NOT NULL DEFAULT '{}'::jsonb,
    normalized_json JSONB NOT NULL DEFAULT '{}'::jsonb,
    source TEXT NOT NULL DEFAULT 'provider',
    fetched_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_provider_logs_provider_created_at ON tbl_provider_logs(provider, created_at DESC);

