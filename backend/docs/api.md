# GameMentor API

Все ответы backend идут в едином envelope:

```json
{
  "success": true,
  "data": {}
}
```

Ошибки:

```json
{
  "success": false,
  "error": {
    "code": "bad_request",
    "message": "..."
  }
}
```

## Health

```http
GET /health
GET /api/v1/health
```

## Dota Lab

Dota Lab - канонический публичный API для Dota продукта. Сырые profile/matches ручки больше не регистрируются наружу: frontend получает продуктовый dashboard, а backend сам ходит в OpenDota и считает нужные блоки.

```http
GET  /api/v1/dota/lab/players/{account_id}/dashboard?period=30d&role=all
GET  /api/v1/dota/lab/players/{account_id}/pro-comparison?period=30d&role=carry
GET  /api/v1/dota/lab/players/{account_id}/heroes?period=30d&role=all
GET  /api/v1/dota/lab/players/{account_id}/form?period=90d&role=all
GET  /api/v1/dota/lab/players/{account_id}/weaknesses?period=30d&role=all
GET  /api/v1/dota/lab/players/{account_id}/ai-coach-preview?period=30d&role=all
POST /api/v1/dota/lab/players/{account_id}/refresh?period=30d&role=all
```

Поддерживаемые периоды:

- `7d`
- `30d`
- `90d`
- `all`

Поддерживаемые роли:

- `all`
- `carry`
- `mid`
- `offlane`
- `support4`
- `support5`

Пример:

```powershell
curl "http://localhost:8080/api/v1/dota/lab/players/369102305/dashboard?period=30d&role=all"
```

Сейчас `{account_id}` - это OpenDota account ID. План нормализации SteamID64, Dotabuff/OpenDota URL и сохранения единого пользовательского игрового аккаунта описан в [docs/dota-lab.md](dota-lab.md).

## AI Coach

```http
POST /api/v1/ai-coach/dota/player/{account_id}/review
GET  /api/v1/ai-coach/dota/player/{account_id}/latest
GET  /api/v1/ai-coach/dota/reports/{report_id}
```

Если AI provider не настроен, `review` вернет `502 provider_disabled`. Для MVP Dota Lab уже отдает rule-based `ai_coach` preview внутри dashboard.

## Identity

Нормализация Dota ID, чтобы пользователь мог один раз вставить OpenDota ID, SteamID64 или ссылку, а продукт сохранил единый account:

```http
POST /api/v1/identity/dota/resolve
```

Пример:

```json
{
  "input": "https://www.opendota.com/players/369102305"
}
```

## Jobs

```http
POST /api/v1/jobs
GET  /api/v1/jobs/{job_id}
```

Создание job:

```json
{
  "type": "build_analytics_snapshot",
  "payload": {
    "steam_id": "369102305"
  }
}
```

Поддерживаемые типы:

- `refresh_player_stats`
- `build_analytics_snapshot`
- `generate_ai_coach_report`
- `update_hero_meta`

## CS2

```http
GET    /api/v1/cs2/maps
GET    /api/v1/cs2/grenades
POST   /api/v1/cs2/grenades
GET    /api/v1/cs2/grenades/{id}
PUT    /api/v1/cs2/grenades/{id}
DELETE /api/v1/cs2/grenades/{id}
```

## Auth / Users

```http
POST /api/v1/auth/register
POST /api/v1/auth/login
GET  /api/v1/users/{id}/profile
PUT  /api/v1/users/{id}/profile
```
