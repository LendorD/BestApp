# GameMentor API

Base path: `/api/v1`. All responses use the envelope:
`{ "success": true, "data": ... }` or `{ "success": false, "error": { "code", "message" } }`.

Each group below is owned by one backend module and registered via that module's
`RegisterRoutes` (see internal/delivery/http/router.go).

## auth  (module: internal/modules/auth)
- `POST /auth/register` — create account `{ email, username, password, display_name }`
- `POST /auth/login` — `{ identity, password }`

## users  (module: internal/modules/users)
- `GET  /users/:id/profile`
- `PUT  /users/:id/profile` — `{ display_name, avatar_url, bio, favorite_game, dota_account_id }`

## cs2  (module: internal/modules/cs2)
- `GET    /cs2/maps`
- `GET    /cs2/grenades?map=&side=&type=&difficulty=&limit=&offset=`
- `POST   /cs2/grenades`
- `GET    /cs2/grenades/:id`
- `PUT    /cs2/grenades/:id`
- `DELETE /cs2/grenades/:id`

## dota  (module: internal/modules/dota)
All `/dota/*` routes live here. The dota handler -> dota usecase (application).
Player data comes from the OpenDota/Stratz provider; lab/analytics data is
delegated by the usecase to the **statistics** service (`SetStatistics`).

Player:
- `GET  /dota/player/:steam_id/profile`
- `GET  /dota/player/:steam_id/matches?limit=`
- `GET  /dota/player/:steam_id/heroes?limit=`

Lab / analytics (served by dota handler, computed by statistics service):
- `GET  /dota/lab/players/:steam_id/dashboard?period=&role=`
- `GET  /dota/lab/players/:steam_id/pro-comparison`
- `GET  /dota/lab/players/:steam_id/heroes`
- `GET  /dota/lab/players/:steam_id/form`
- `GET  /dota/lab/players/:steam_id/weaknesses`
- `GET  /dota/lab/players/:steam_id/ai-coach-preview`
- `POST /dota/lab/players/:steam_id/refresh`

## statistics  (module: internal/modules/statistics — formerly "analytics")
Pure, game-agnostic **service layer** (no HTTP). Computes snapshots, performance
scores, form timelines, pro comparisons. Used by the dota module and ai_coach.
CS2 and future games plug in via data ports. (Old HTTP delivery is deprecated.)

## ai_coach  (module: internal/modules/ai_coach)
- `POST /ai-coach/dota/player/:steam_id/review`
- `GET  /ai-coach/dota/player/:steam_id/latest`
- `POST /ai-coach/dota/match/:match_id/review?steam_id=`
- `GET  /ai-coach/reports/:report_id`

## identity  (module: internal/modules/identity)
- `POST /identity/dota/resolve` — `{ input }` (Steam vanity URL / SteamID64 / profile URL / account id)

## jobs  (module: internal/modules/jobs)
- `POST /jobs`
- `GET  /jobs/:job_id`

## health / docs
- `GET /health`, `GET /api/v1/health`
- `GET /swagger`, `GET /swagger/openapi.yaml`

All HTTP routes are unchanged from before the refactor, so the existing frontend keeps working.
