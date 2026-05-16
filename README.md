# GameMentor

GameMentor is an educational backend MVP for CS2 grenade guides and Dota 2 player analytics.

## Stack

- Go + Gin
- PostgreSQL
- pgx/pgxpool
- golang-migrate SQL migrations
- Docker Compose
- Clean Architecture style packages: domain, usecase, repository, delivery/http, clients/opendota
- Structured JSON logging with `log/slog`

## Run With Docker Compose

```bash
docker compose up --build
```

The API starts at `http://localhost:8080`.

You can copy `.env.example` to `.env` if you want to override defaults used by Docker Compose.

Useful URLs:

- `GET /health`
- `GET /swagger`
- `GET /swagger/openapi.yaml`

For Flutter Web API mode, the backend includes development CORS headers for local browser requests.

## Local Run

Start Postgres first, then run migrations with golang-migrate:

```bash
make migrate-up DATABASE_URL="postgres://gamementor:gamementor@localhost:5432/gamementor?sslmode=disable"
DATABASE_URL="postgres://gamementor:gamementor@localhost:5432/gamementor?sslmode=disable" go run ./cmd/api
```

On Windows PowerShell:

```powershell
$env:DATABASE_URL="postgres://gamementor:gamementor@localhost:5432/gamementor?sslmode=disable"
go run ./cmd/api
```

## CS2 API

```bash
curl http://localhost:8080/api/v1/cs2/maps
```

```bash
curl -X POST http://localhost:8080/api/v1/cs2/grenades \
  -H "Content-Type: application/json" \
  -d '{
    "map": "mirage",
    "side": "T",
    "type": "smoke",
    "title": "Window smoke from T spawn",
    "description": "Basic lineup for mid control.",
    "from_position": "T spawn",
    "to_position": "Window",
    "difficulty": "easy",
    "image_url": "https://example.com/image.jpg",
    "video_url": "https://example.com/video.mp4",
    "tags": ["mid", "default"]
  }'
```

Other CS2 endpoints:

- `GET /api/v1/cs2/grenades`
- `GET /api/v1/cs2/grenades/:id`
- `PUT /api/v1/cs2/grenades/:id`
- `DELETE /api/v1/cs2/grenades/:id`

Supported query filters for list: `map`, `side`, `type`, `difficulty`, `limit`, `offset`.

CS2 maps are seeded by the first migration in `tbl_cs2_maps`. Grenades reference a map by its `code`, for example `mirage` or `inferno`.

## Dota API

Dota endpoints use OpenDota by default via `OPENDOTA_BASE_URL=https://api.opendota.com`.

- `GET /api/v1/dota/players/:account_id`
- `GET /api/v1/dota/players/:account_id/matches`
- `GET /api/v1/dota/players/:account_id/summary`

The summary endpoint fetches recent matches, calculates winrate, average kills/deaths/assists, KDA and top heroes, then saves a snapshot to PostgreSQL.

## Make Commands

```bash
make tidy
make test
make build
make docker-up
make docker-down
make migrate-up
make migrate-down
make migrate-create name=create_some_table
```

## Frontend

The Flutter Web app lives in `frontend/`.

```bash
cd frontend
flutter pub get
flutter run -d chrome --web-port 5173
```

Mock API mode is enabled by default. To use the Go backend:

```bash
cd frontend
flutter run -d chrome --web-port 5173 --dart-define=USE_MOCK_API=false --dart-define=API_BASE_URL=http://localhost:8080/api/v1
```

Or from the repository root:

```bash
make frontend-run-api
```

## CS2 Grenade Recorder

Local CLI utility for capturing CS2 `getpos` coordinates from `console.log`:

```bash
go run ./cmd/recorder -log-path "C:\Program Files (x86)\Steam\steamapps\common\Counter-Strike Global Offensive\game\csgo\console.log" -map de_mirage -type smoke
```

Full setup guide: [cmd/recorder/README.md](cmd/recorder/README.md).

## Response Format

Success:

```json
{
  "success": true,
  "data": {}
}
```

Error:

```json
{
  "success": false,
  "error": {
    "code": "validation_error",
    "message": "title is required"
  }
}
```
