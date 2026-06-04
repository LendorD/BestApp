DROP INDEX IF EXISTS idx_users_dota_account_id;

ALTER TABLE tbl_users
    DROP COLUMN IF EXISTS last_login_at,
    DROP COLUMN IF EXISTS dota_account_id,
    DROP COLUMN IF EXISTS favorite_game,
    DROP COLUMN IF EXISTS bio,
    DROP COLUMN IF EXISTS avatar_url,
    DROP COLUMN IF EXISTS display_name;
