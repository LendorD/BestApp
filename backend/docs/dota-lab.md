# Dota Lab: как тестировать и как считаются метрики

Этот файл нужен, чтобы быстро понять Dota часть GameMentor без чтения всего проекта.

## Быстрый тест твоего профиля

Твой OpenDota account ID закреплен в frontend config:

```text
369102305
```

Переопределить его можно при запуске frontend:

```powershell
flutter run -d chrome --web-port 5174 `
  --dart-define=USE_MOCK_API=false `
  --dart-define=API_BASE_URL=http://localhost:8080/api/v1 `
  --dart-define=DEFAULT_DOTA_ACCOUNT_ID=369102305
```

Страница Dota сама подставит этот ID. В product select также есть быстрый вход "Мой профиль".

## Запуск backend

Из корня проекта:

```powershell
docker compose up --build
```

Проверка:

```powershell
curl http://localhost:8080/health
curl "http://localhost:8080/api/v1/dota/lab/players/369102305/dashboard?period=30d&role=all"
```

Если хочешь сбросить cache dashboard:

```powershell
curl -X POST "http://localhost:8080/api/v1/dota/lab/players/369102305/refresh?period=30d&role=all"
```

## Запуск frontend

Mock-режим:

```powershell
cd frontend
flutter run -d chrome --web-port 5174 --dart-define=USE_MOCK_API=true
```

Live API:

```powershell
cd frontend
flutter run -d chrome --web-port 5174 `
  --dart-define=USE_MOCK_API=false `
  --dart-define=API_BASE_URL=http://localhost:8080/api/v1
```

## Какие внешние API подключены

Сейчас реально подключен OpenDota:

- `GET https://api.opendota.com/api/players/{account_id}`
- `GET https://api.opendota.com/api/players/{account_id}/recentMatches`

Где смотреть код:

- OpenDota HTTP client: `internal/clients/opendota/client.go`
- OpenDota provider для новой модульной архитектуры: `internal/modules/dota/infrastructure/provider/opendota/provider.go`
- Dota service/cache: `internal/modules/dota/application/service.go`
- Dota Lab расчеты: `internal/modules/analytics/application/dota_lab.go`
- Dota Lab routes: `internal/modules/analytics/delivery/http/routes.go`
- Frontend live API вызов: `frontend/lib/features/dota_stats/data/dota_stats_api.dart`

STRATZ и Steam provider пока лежат как disabled-заготовки. AI Coach provider тоже disabled, а preview в dashboard пока rule-based.

## Канонические Dota Lab endpoints

```http
GET  /api/v1/dota/lab/players/{account_id}/dashboard?period=30d&role=all
GET  /api/v1/dota/lab/players/{account_id}/pro-comparison?period=30d&role=carry
GET  /api/v1/dota/lab/players/{account_id}/heroes?period=30d&role=all
GET  /api/v1/dota/lab/players/{account_id}/form?period=90d&role=all
GET  /api/v1/dota/lab/players/{account_id}/weaknesses?period=30d&role=all
GET  /api/v1/dota/lab/players/{account_id}/ai-coach-preview?period=30d&role=all
POST /api/v1/dota/lab/players/{account_id}/refresh?period=30d&role=all
```

Параметры:

- `period`: `7d`, `30d`, `90d`, `all`
- `role`: `all`, `carry`, `mid`, `offlane`, `support4`, `support5`

## Как считается dashboard

Backend берет профиль и до 100 последних матчей из OpenDota, затем:

- фильтрует матчи по периоду;
- определяет роль по hero pool и fallback-эвристикам GPM/last hits/assists;
- считает средние kills, deaths, assists, KDA, GPM, XPM, last hits, hero damage, tower damage, healing и duration;
- группирует героев по `hero_id`;
- строит timeline формы по последним матчам;
- генерирует weak points;
- собирает AI Coach preview и тренировочный план.

## GameMentor Score

Score состоит из пяти частей:

- Фарм: GPM, XPM, last hits.
- Драки: KDA, kills, hero damage.
- Объекты: tower damage и winrate.
- Стабильность: winrate и средние deaths.
- Командная игра: assists, healing и KDA.

Итоговый score:

```text
farm * 0.22 +
fights * 0.22 +
objectives * 0.18 +
stability * 0.22 +
teamplay * 0.16
```

Все части нормализуются в диапазон `0..100`.

## Сравнение с pro

Backend сравнивает твой профиль с preset-профилями:

- Yatoro
- Nisha
- Save
- Collapse
- Mira
- Pure
- Malr1ne

Метрики:

- GPM
- XPM
- KDA
- Winrate
- Hero Damage
- Tower Damage
- Last Hits
- Net Worth

Сейчас pro-значения - продуктовые baseline-константы для MVP. Позже их можно заменить на STRATZ/ProTracker sync.

## Почему у одного игрока разные ID на разных сайтах

OpenDota обычно использует Dota account ID, то есть 32-bit ID. Steam часто показывает SteamID64. Dotabuff/OpenDota URL тоже могут выглядеть по-разному.

Для продукта лучше сделать отдельную сущность `user_game_accounts`, где у пользователя будет один сохраненный GameMentor Dota аккаунт и несколько внешних идентификаторов.

План:

```text
tbl_user_game_accounts
- id
- user_id
- game: dota2 / cs2
- canonical_account_id
- opendota_account_id
- steam_id64
- profile_url
- provider
- is_primary
- verified_at
- created_at
- updated_at
```

Нормализация:

- если пользователь вводит OpenDota account ID, сохраняем его как `opendota_account_id`;
- если вводит SteamID64, считаем Dota account ID как `steam_id64 - 76561197960265728`;
- если вводит ссылку OpenDota/Dotabuff/Steam, парсим ID из URL;
- frontend всегда показывает одну кнопку "Мой Dota профиль", а backend сам знает, какой внешний ID использовать.

Первый endpoint для этого:

```http
POST /api/v1/identity/dota/resolve
```

Пример тела:

```json
{
  "input": "https://www.opendota.com/players/369102305"
}
```

Ответ:

```json
{
  "canonical_account_id": "369102305",
  "opendota_account_id": "369102305",
  "steam_id64": "76561198329368033",
  "source": "opendota_url"
}
```

Эта ручка уже добавлена в backend. Пока она не пишет в базу, а только нормализует ID. Следующий шаг - сохранить результат в `tbl_user_game_accounts` и привязать к пользователю.
