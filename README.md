# GameMentor

GameMentor - учебно-продуктовая платформа для игроков CS2 и Dota 2.

Проект сделан как монорепозиторий:

- `backend/` - Go API, PostgreSQL migrations, Swagger/OpenAPI, CS2 recorder.
- `frontend/` - Flutter Web приложение.
- `docker-compose.yml` - единый запуск PostgreSQL, миграций, backend и frontend.

## Что Делает Приложение

GameMentor помогает игроку тренироваться и анализировать свою игру:

- CS2 Lab: база раскидок, карты, гранаты, импорт JSON из recorder.
- Dota Lab: анализ OpenDota профиля, GameMentor Score, форма, герои, слабые места, AI Coach preview.
- Profile: сохранение Dota ID и пользовательских настроек.
- Admin Panel: добавление CS2 гранат.

## Стек

- Backend: Go, Gin, pgx/pgxpool, PostgreSQL, golang-migrate.
- Frontend: Flutter Web, Riverpod, go_router, Dio, freezed/json_serializable, fl_chart.
- Infra: Docker Compose, nginx для frontend, Swagger/OpenAPI.

## Структура

```text
.
├── backend/
│   ├── cmd/
│   │   ├── api/                 # HTTP backend
│   │   ├── app/                 # modular app entrypoint
│   │   └── recorder/            # CS2 grenade recorder CLI
│   ├── internal/                # Go application code
│   ├── migrations/              # PostgreSQL migrations
│   ├── docs/                    # Swagger/OpenAPI и backend docs
│   ├── Dockerfile
│   ├── go.mod
│   └── .env.example
├── frontend/
│   ├── lib/                     # Flutter Web code
│   ├── web/assets/gamementor/   # локальные изображения
│   ├── Dockerfile
│   └── nginx.conf
├── docker-compose.yml
├── Makefile
├── .env.example
└── README.md
```

## Запуск Одной Командой

Из корня проекта:

```powershell
docker compose up --build
```

После запуска:

- Frontend: `http://localhost:5174`
- Backend API: `http://localhost:8080`
- Healthcheck: `http://localhost:8080/health`
- Swagger UI: `http://localhost:8080/swagger`
- OpenAPI YAML: `http://localhost:8080/swagger/openapi.yaml`

Остановить:

```powershell
docker compose down
```

## Запуск По Отдельности

Только backend + database:

```powershell
make docker-backend-up
```

Только frontend docker service:

```powershell
make docker-frontend-up
```

Backend локально без Docker:

```powershell
cd backend
go run ./cmd/api
```

Frontend локально в mock-режиме:

```powershell
cd frontend
flutter pub get
flutter run -d chrome --web-port 5174 --dart-define=USE_MOCK_API=true
```

Frontend локально с реальным backend:

```powershell
cd frontend
flutter run -d chrome --web-port 5174 `
  --dart-define=USE_MOCK_API=false `
  --dart-define=API_BASE_URL=http://localhost:8080/api/v1 `
  --dart-define=DEFAULT_DOTA_ACCOUNT_ID=369102305
```

## Swagger

Swagger backend доступен здесь:

```text
http://localhost:8080/swagger
```

Сырой OpenAPI файл:

```text
http://localhost:8080/swagger/openapi.yaml
```

Сейчас в Swagger описаны основные публичные ручки:

- health;
- auth/register и auth/login;
- users profile;
- CS2 maps и CS2 grenades CRUD;
- Dota Lab dashboard;
- Identity Dota resolver.

Более полный текстовый список API лежит в [backend/docs/api.md](backend/docs/api.md).

## Dota Lab

Главная ручка Dota продукта:

```http
GET /api/v1/dota/lab/players/{account_id}/dashboard?period=30d&role=all
```

Быстрая проверка твоего профиля:

```powershell
curl "http://localhost:8080/api/v1/dota/lab/players/369102305/dashboard?period=30d&role=all"
```

Что считает backend:

- winrate;
- average kills/deaths/assists;
- KDA;
- GPM/XPM;
- last hits;
- hero damage;
- tower damage;
- hero healing;
- GameMentor Score;
- лучшие и проблемные герои;
- timeline формы;
- слабые места;
- AI Coach preview;
- training plan.

Подробно про формулы и тестирование Dota Lab:

[backend/docs/dota-lab.md](backend/docs/dota-lab.md)

## Dota ID Resolver

Чтобы пользователю не приходилось понимать, почему на разных сайтах разные ID, добавлена ручка нормализации:

```http
POST /api/v1/identity/dota/resolve
```

Пример:

```powershell
curl -X POST "http://localhost:8080/api/v1/identity/dota/resolve" `
  -H "Content-Type: application/json" `
  -d '{"input":"https://www.opendota.com/players/369102305"}'
```

Она принимает:

- OpenDota account ID;
- SteamID64;
- OpenDota URL;
- Dotabuff URL;
- Steam profile URL.

Пока resolver только нормализует ID. Следующий шаг - сохранять результат в таблицу игровых аккаунтов пользователя.

## CS2 Recorder

Recorder лежит в backend:

```text
backend/cmd/recorder
```

Быстрый тест без CS2:

```powershell
cd backend
New-Item -ItemType Directory -Force ..\tmp
go run ./cmd/recorder -log-path "..\tmp\console.log" -map de_mirage -type smoke -out "..\tmp\grenade.json" -yes
```

Во втором терминале:

```powershell
Add-Content .\tmp\console.log 'setpos -1032.42 -789.12 -167.97; setang -18.40 91.20 0.00'
Start-Sleep -Milliseconds 500
Add-Content .\tmp\console.log 'setpos -820.11 -1020.44 -160.97; setang 0.00 0.00 0.00'
Get-Content .\tmp\grenade.json
```

Полная инструкция:

[backend/cmd/recorder/README.md](backend/cmd/recorder/README.md)

## Makefile

Основные команды из корня:

```powershell
make docker-up
make docker-down
make docker-backend-up
make docker-frontend-up
make backend-run
make backend-test
make frontend-run
make frontend-run-api
make frontend-stop
make frontend-build
make frontend-analyze
make test
```

## Проверки

Backend:

```powershell
cd backend
go test ./...
```

Frontend:

```powershell
cd frontend
flutter analyze
flutter test
```

Из корня:

```powershell
make test
```

## Env

Корневой пример env для Docker Compose:

[.env.example](.env.example)

Backend env:

[backend/.env.example](backend/.env.example)

Важные переменные:

```env
OPENDOTA_BASE_URL=https://api.opendota.com
OPENDOTA_TIMEOUT=10s
USE_MOCK_API=false
API_BASE_URL=http://localhost:8080/api/v1
DEFAULT_DOTA_ACCOUNT_ID=369102305
```
