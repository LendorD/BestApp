CREATE TABLE IF NOT EXISTS tbl_subscriptions (
    user_id BIGINT PRIMARY KEY REFERENCES tbl_users(id) ON DELETE CASCADE,
    plan TEXT NOT NULL DEFAULT 'free',
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'canceled', 'past_due')),
    current_period_end TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_subscriptions_plan ON tbl_subscriptions(plan);
