# GameMentor

![Go](https://img.shields.io/badge/Go-1.25-00ADD8?style=for-the-badge&logo=go&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-Web-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?style=for-the-badge&logo=docker&logoColor=white)

GameMentor - учебно-продуктовый проект для игроков CS2 и Dota 2.

Идея простая: игрок открывает платформу, изучает раскидки CS2, анализирует свой Dota 2 профиль через OpenDota и получает понятные подсказки, что тренировать дальше. Проект сделан как полноценная база для pet-проекта в портфолио: backend на Go, Flutter Web frontend, PostgreSQL, Docker Compose, миграции, API-слой, чистая структура и отдельная CLI-утилита для записи координат гранат.

## Что Уже Реализовано

- Backend API на Go + Gin.
- PostgreSQL без GORM, работа через `pgx/pgxpool`.
- SQL migrations через `golang-migrate`.
- Clean Architecture: `domain`, `usecase`, `repository`, `delivery/http`, `clients/opendota`.
- Единый JSON-формат успешных ответов и ошибок.
- Structured logging через `log/slog`.
- Graceful shutdown.
- Healthcheck endpoint.
- Swagger/OpenAPI страница.
- Регистрация пользователя и сохранение профиля.
- CS2 CRUD для базы гранат.
- Dota 2 интеграция с OpenDota API.
- Расчет Dota статистики: winrate, KDA, средние kills/deaths/assists, экономика, урон, лечение, last hits, top heroes.
- Сохранение Dota snapshots в PostgreSQL.
- Flutter Web интерфейс с темной esports-темой.
- Mock/API режим фронта через `--dart-define`.
- Локальные изображения для главной, CS2 карт, демо-гранат и Dota fallback профиля.
- Локальная CLI-утилита `cs2-grenade-recorder` для чтения `console.log` из CS2.

## Быстрый Старт

Нужны:

- Docker Desktop.
- Go 1.25+.
- Flutter SDK.
- Git.

Запуск backend + PostgreSQL:

```powershell
docker compose up --build
```

API будет доступен здесь:

```text
http://localhost:8080
```

Полезные URL:

- `GET http://localhost:8080/health`
- `GET http://localhost:8080/swagger`
- `GET http://localhost:8080/swagger/openapi.yaml`
- `GET http://localhost:8080/api/v1/cs2/maps`
- `GET http://localhost:8080/api/v1/dota/players/369102305/summary`

Запуск frontend в mock-режиме:

```powershell
cd frontend
flutter pub get
flutter run -d chrome --web-port 5173
```

Запуск frontend с реальным backend API:

```powershell
cd frontend
flutter run -d chrome --web-port 5173 --dart-define=USE_MOCK_API=false --dart-define=API_BASE_URL=http://localhost:8080/api/v1
```

Если порт `5173` занят:

```powershell
cd ..
make frontend-stop
```

Или запусти на другом порту:

```powershell
cd frontend
flutter run -d chrome --web-port 5174 --dart-define=USE_MOCK_API=false --dart-define=API_BASE_URL=http://localhost:8080/api/v1
```

## Архитектура Проекта

```text
.
├── cmd/
│   ├── api/                  # main.go для HTTP backend
│   └── recorder/             # CLI утилита записи CS2 координат
├── internal/
│   ├── app/                  # сборка приложения и graceful shutdown
│   ├── clients/opendota/     # HTTP клиент OpenDota
│   ├── config/               # env config
│   ├── delivery/http/        # Gin router, handlers, middleware, responses
│   ├── domain/               # бизнес-сущности и доменные ошибки
│   ├── repository/postgres/  # pgx репозитории
│   ├── usecase/              # бизнес-логика
│   ├── parser/               # parser для CS2 getpos
│   ├── watcher/              # tail-like file watcher
│   └── exporter/             # JSON export recorder-сессии
├── migrations/               # SQL миграции PostgreSQL
├── docs/                     # Swagger/OpenAPI
├── frontend/                 # Flutter Web приложение
├── docker-compose.yml
├── Dockerfile
├── Makefile
└── .env.example
```

### Backend Поток

HTTP request проходит такой путь:

```text
Gin handler -> usecase -> repository/client -> domain model -> response
```

Например, Dota summary:

```text
GET /api/v1/dota/players/:account_id/summary
  -> DotaHandler
  -> DotaUsecase
  -> OpenDotaClient получает профиль и матчи
  -> DotaRepository сохраняет player/matches/snapshot
  -> backend возвращает агрегированную статистику
```

### Почему Без GORM

Проект специально использует `pgx/pgxpool`, чтобы явно видеть SQL, индексы, транзакции и структуру таблиц. Это ближе к реальной backend-разработке, где важно понимать, какие запросы уходят в базу.

## Backend API

Base URL:

```text
http://localhost:8080/api/v1
```

### Response Format

Успех:

```json
{
  "success": true,
  "data": {}
}
```

Ошибка:

```json
{
  "success": false,
  "error": {
    "code": "validation_error",
    "message": "title is required"
  }
}
```

### Auth / Profile Endpoints

Auth в MVP сделан как простая регистрация без JWT: backend создает пользователя, а frontend сохраняет `user_id` в browser storage и по нему загружает профиль. Это уже позволяет сохранять профиль, Dota account ID и настройки. Полноценные access/refresh tokens можно добавить следующим шагом.

```text
POST /auth/register
POST /auth/login
GET  /users/:id/profile
PUT  /users/:id/profile
```

Пример регистрации:

```powershell
curl -X POST http://localhost:8080/api/v1/auth/register `
  -H "Content-Type: application/json" `
  -d '{
    "email": "player@gamementor.local",
    "username": "lendor",
    "password": "123456",
    "display_name": "Lendor"
  }'
```

Пример сохранения профиля:

```powershell
curl -X PUT http://localhost:8080/api/v1/users/1/profile `
  -H "Content-Type: application/json" `
  -d '{
    "display_name": "Lendor",
    "avatar_url": "/assets/gamementor/dota/profile-fallback.jpg",
    "bio": "Тренирую CS2 utility и разбираю Dota решения.",
    "favorite_game": "CS2 + Dota 2",
    "dota_account_id": 369102305
  }'
```

### CS2 Endpoints

```text
GET    /cs2/maps
GET    /cs2/grenades
GET    /cs2/grenades/:id
POST   /cs2/grenades
PUT    /cs2/grenades/:id
DELETE /cs2/grenades/:id
```

Фильтры для списка гранат:

```text
map
side
type
difficulty
limit
offset
```

Пример создания гранаты:

```powershell
curl -X POST http://localhost:8080/api/v1/cs2/grenades `
  -H "Content-Type: application/json" `
  -d '{
    "map": "mirage",
    "side": "T",
    "type": "smoke",
    "title": "Смок Window с T spawn",
    "description": "Базовая раскидка для раннего контроля мида.",
    "from_position": "T spawn",
    "to_position": "Window",
    "difficulty": "easy",
    "image_url": "/assets/gamementor/cs2/grenades/mirage-window-smoke.jpg",
    "video_url": "https://example.com/video",
    "tags": ["mid", "default", "execute"]
  }'
```

### Как Добавить Новую Карту CS2

Карты хранятся в `tbl_cs2_maps`. Сейчас в первой миграции уже добавлены:

- Mirage
- Inferno
- Dust2
- Nuke
- Ancient
- Anubis
- Vertigo

Чтобы добавить новую карту, создай миграцию:

```powershell
make migrate-create name=add_train_map
```

В `up.sql`:

```sql
INSERT INTO tbl_cs2_maps (code, display_name)
VALUES ('train', 'Train')
ON CONFLICT (code) DO UPDATE
SET display_name = EXCLUDED.display_name,
    updated_at = now();
```

После этого перезапусти миграции:

```powershell
docker compose down
docker compose up --build
```

Frontend берет список карт через `GET /cs2/maps`, поэтому фильтр подтянет новую карту автоматически.

### Dota Endpoints

```text
GET /dota/players/:account_id
GET /dota/players/:account_id/matches
GET /dota/players/:account_id/summary
```

Пример:

```powershell
curl http://localhost:8080/api/v1/dota/players/369102305/summary
```

Что делает summary:

- получает профиль игрока из OpenDota;
- получает последние матчи;
- сохраняет игрока и матчи в PostgreSQL;
- считает winrate, KDA, средние kills/deaths/assists;
- считает GPM, XPM, last hits, hero damage, tower damage, hero healing;
- считает top heroes;
- сохраняет snapshot статистики в `tbl_dota_player_snapshots`.

## База Данных

Миграции лежат в [migrations](migrations).

Основные таблицы:

- `tbl_users` - задел под будущую авторизацию.
- `tbl_cs2_maps` - справочник карт CS2.
- `tbl_cs2_grenades` - база раскидок.
- `tbl_dota_players` - профиль Dota игрока.
- `tbl_dota_player_matches` - последние матчи игрока.
- `tbl_dota_player_snapshots` - сохраненные снимки агрегированной статистики.

## Frontend

Flutter Web приложение находится в [frontend](frontend).

Стек:

- Flutter Web.
- Riverpod.
- go_router.
- Dio.
- freezed/json_serializable.
- Feature-based architecture.

Страницы:

- Главная.
- CS2 Grenades.
- Dota 2 Stats.
- Training Plans.
- Profile.
- Register / Login.
- Admin Panel.

Режимы API:

```text
USE_MOCK_API=true   # mock data, backend не нужен
USE_MOCK_API=false  # реальные HTTP запросы в Go backend
```

Конфиг находится в:

```text
frontend/lib/core/config/app_config.dart
```

## Картинки Для Фронта

Картинки уже скачаны в `frontend/web/assets/gamementor`, а frontend использует локальные пути. Если захочешь заменить placeholder на свои реальные скриншоты, просто перезапиши файлы с теми же именами.

Сейчас в проекте лежат:

```text
frontend/web/assets/gamementor/home/hero.jpg
frontend/web/assets/gamementor/home/cs2-card.jpg
frontend/web/assets/gamementor/home/dota-card.jpg

frontend/web/assets/gamementor/cs2/maps/mirage.jpg
frontend/web/assets/gamementor/cs2/maps/inferno.jpg
frontend/web/assets/gamementor/cs2/maps/dust2.jpg
frontend/web/assets/gamementor/cs2/maps/nuke.jpg
frontend/web/assets/gamementor/cs2/maps/ancient.jpg
frontend/web/assets/gamementor/cs2/maps/anubis.jpg
frontend/web/assets/gamementor/cs2/maps/vertigo.jpg

frontend/web/assets/gamementor/cs2/grenades/mirage-window-smoke.jpg
frontend/web/assets/gamementor/cs2/grenades/inferno-banana-flash.jpg
frontend/web/assets/gamementor/cs2/grenades/nuke-hut-molotov.jpg
frontend/web/assets/gamementor/cs2/grenades/anubis-b-main-he.jpg

frontend/web/assets/gamementor/dota/profile-fallback.jpg
```

Рекомендованные размеры:

- Home hero: `1920x900` или `1920x1080`.
- Feature cards: `1200x700`.
- CS2 map covers: `1600x900`.
- CS2 grenade screenshots: `1280x720` или `1920x1080`.
- Dota profile fallback: `512x512`.

Как использовать локальную картинку в базе гранат:

```json
{
  "image_url": "/assets/gamementor/cs2/grenades/mirage-window-smoke.jpg"
}
```

Откуда брать изображения:

- Для CS2 гранат лучше делать свои скриншоты в practice-режиме. Так ты получишь честные картинки конкретной раскидки.
- Для CS2 обложек карт можно сделать скриншоты карты без HUD или использовать официальные промо-материалы Valve/Steam.
- Для Dota героев frontend уже умеет грузить портреты с Steam CDN по hero slug:

```text
https://cdn.cloudflare.steamstatic.com/apps/dota2/images/dota_react/heroes/invoker.png
https://cdn.cloudflare.steamstatic.com/apps/dota2/images/dota_react/heroes/social/invoker.jpg
```

Если хочешь полностью локальные Dota картинки, скачай портреты и большие social-обложки для героев, которых показываешь чаще всего:

```text
invoker.png
invoker.jpg
pudge.png
pudge.jpg
faceless_void.png
faceless_void.jpg
phantom_lancer.png
phantom_lancer.jpg
tiny.png
tiny.jpg
queenofpain.png
queenofpain.jpg
witch_doctor.png
witch_doctor.jpg
```

Подробный справочник по папке ассетов лежит здесь: [frontend/web/assets/gamementor/README.md](frontend/web/assets/gamementor/README.md).

## CS2 Grenade Recorder

`cs2-grenade-recorder` - локальная Go CLI-утилита, которая читает `console.log` из CS2 и ловит строки от команды `getpos`.

Она не читает память процесса CS2 и не вмешивается в игру. Только tail-like чтение лог-файла.

Что делает:

- следит за `console.log`;
- находит строки вида `setpos ...; setang ...`;
- парсит координаты и углы;
- первую точку сохраняет как `throw_position`;
- вторую точку сохраняет как `landing_position`;
- экспортирует JSON в `grenade.json`.

Быстрый тест без CS2:

```powershell
New-Item -ItemType Directory -Force .\tmp
go run ./cmd/recorder -log-path ".\tmp\console.log" -map de_mirage -type smoke -out ".\tmp\grenade.json" -yes
```

Во втором терминале:

```powershell
Add-Content .\tmp\console.log 'setpos -1032.42 -789.12 -167.97; setang -18.40 91.20 0.00'
Start-Sleep -Milliseconds 500
Add-Content .\tmp\console.log 'setpos -820.11 -1020.44 -160.97; setang 0.00 0.00 0.00'
Get-Content .\tmp\grenade.json
```

Полная инструкция: [cmd/recorder/README.md](cmd/recorder/README.md).

## Env

Пример лежит в [.env.example](.env.example).

```env
APP_ENV=local
HTTP_ADDR=:8080
DATABASE_URL=postgres://gamementor:gamementor@postgres:5432/gamementor?sslmode=disable
OPENDOTA_BASE_URL=https://api.opendota.com
OPENDOTA_TIMEOUT=10s
HTTP_READ_HEADER_TIMEOUT=5s
HTTP_SHUTDOWN_TIMEOUT=10s
```

Для Docker Compose можно ничего не менять: дефолты уже прописаны.

## Makefile

Основные команды:

```powershell
make test
make build
make docker-up
make docker-down
make migrate-up
make migrate-down
make migrate-create name=create_some_table
make frontend-run
make frontend-run-api
make frontend-stop
make frontend-build
make frontend-analyze
```

## Проверки

Backend:

```powershell
go test ./...
go vet ./...
```

Frontend:

```powershell
cd frontend
flutter analyze
flutter test
flutter build web
```

## Частые Проблемы

### `No pubspec.yaml file found`

Команду Flutter нужно запускать из папки `frontend`:

```powershell
cd frontend
flutter run -d chrome --web-port 5173
```

### `Failed to bind web development server`, порт 5173 занят

Останови процесс:

```powershell
make frontend-stop
```

Или используй другой порт:

```powershell
cd frontend
flutter run -d chrome --web-port 5174
```

### Dota ID не ищется

Проверь три вещи:

- backend запущен на `http://localhost:8080`;
- frontend запущен с `USE_MOCK_API=false`;
- профиль игрока доступен в OpenDota.

Команда для проверки backend напрямую:

```powershell
curl http://localhost:8080/api/v1/dota/players/369102305/summary
```

### После новой миграции база не обновилась

Перезапусти compose:

```powershell
docker compose down
docker compose up --build
```

## Roadmap

Ближайшие улучшения:

- JWT access/refresh tokens вместо локального MVP `user_id`;
- избранные гранаты;
- полноценные training plans;
- загрузка CS2 изображений через backend;
- локальное хранилище ассетов;
- расширенная Dota аналитика по ролям, героям и патчам;
- прямой upload изображений и видео для CS2 гранат через backend;
- автогенерация превью для раскидок.

## Лицензия

Пока лицензия не выбрана. Для публичного GitHub лучше позже добавить `MIT` или `Apache-2.0`.
