# GameMentor — контекст проекта (инструкция для ассистента)

Ты помогаешь разрабатывать **GameMentor** — веб-приложение для аналитики Dota 2 (и заготовка под CS2) с AI-коучем. Цель продукта: игрок вводит свой профиль → видит разбор статистики, перцентили, слабые места и персональный план от ИИ. Монетизация — подписка Pro (углублённый AI-разбор).

Отвечай по-русски. Ниже — всё, что нужно знать о кодовой базе.

## Стек
- **Backend:** Go (Gin), Clean/Hexagonal-архитектура по модулям. PostgreSQL (pgx) + golang-migrate, Redis (кеш), bcrypt, JWT (ручной HS256, без внешних либ).
- **Frontend:** `frontend-make/` — React 18 + Vite + TypeScript, **HashRouter** (URL вида `/#/...`), Tailwind v4 + shadcn/ui, recharts, lucide-react. Стили в основном инлайновые.
- **Инфра:** docker-compose (postgres, redis, migrate, backend :8080, frontend nginx :5174, который проксирует `/api` → backend). Деплой на VPS (Ubuntu, `/opt/BestApp`, IP в .env).
- Старый Flutter-фронт и `frontend-web/` — легаси, основной фронт это `frontend-make/`.

## Источники данных
- **OpenDota** — открытый API без ключа, основной источник истории игрока (до 500+ матчей). Лимиты free: 60 req/min, 50k/мес. Кешируем в Redis.
- **Stratz** — GraphQL (нужен токен `STRATZ_API_KEY`), даёт **IMP** (вклад в победу −100..+100), behaviorScore, ранг. Требует заголовок `User-Agent: STRATZ_API`.
- **Dotabuff** — НЕ интегрируется: нет публичного API + анти-бот. Замена — OpenDota + Stratz.
- **Точный MMR недоступен** из OpenDota → показываем медаль ранга из `rank_tier` (первая цифра = медаль 1..8 Herald→Immortal, вторая = звёзды).

## Backend: модули и ключевые эндпоинты (base `/api/v1`)
- **auth:** `POST /auth/register`, `POST /auth/login` (возвращают `{user, token, expires_at}`), `GET /auth/me`. JWT HS256 (`internal/modules/auth/application/token.go`), middleware `internal/delivery/http/middleware/auth.go`.
- **users:** `GET/PUT /users/me/profile` (по токену), `GET/PUT /users/:id/profile`. Профиль хранит `dota_account_id` (привязка).
- **billing (мок):** `GET /billing/plans`, `GET /billing/subscription`, `POST /billing/subscribe {plan}`, `POST /billing/cancel`. Планы Free/Pro/Team, оплата фейковая (план включается сразу). Таблица `tbl_subscriptions` (миграция 000005).
- **dota:** `GET /dota/player/:id/{profile,matches,heroes}` (сырьё OpenDota); `GET /dota/lab/players/:id/{dashboard,pro-comparison,heroes,form,weaknesses,ai-coach-preview}`, `POST .../refresh`.
- **explorer:** `GET /dota/explorer/:id` (агрегат OpenDota+Stratz); `GET /dota/raw/:id/:resource` — проброс OpenDota (`matches?limit=500`, `totals`, `counts`, `wl`, `heroes`, `peers`, `ratings`, `rankings`, `wardmap`, `histograms-kills`, `histograms-gpm`).
- **metrics (единый стат-сервис):** `GET /dota/metrics/:id?days&limit` — окно последних матчей, ~16-20 метрик (winrate, KDA, GPM, XPM, CS/мин, denies, k/d/a, hero_dmg/мин, tower_dmg, heal/мин, варды, стаки, длительность), **перцентили** через OpenDota `/benchmarks` по топ-герою, под-оценки (Farm/Fighting/Objectives/Vision/Stability + Overall) и средний **IMP** из Stratz. Это «источник правды» для KPI и входа AI.
- **ai_coach:** `POST /ai-coach/dota/player/:id/review` (тело `{focus}` опционально — цели из опроса), `GET /ai-coach/dota/player/:id/latest`, `POST /ai-coach/dota/match/:id/review?steam_id=`, `GET /ai-coach/reports/:id`. В промпт добавляется enricher (OpenDota+Stratz) + блок метрик (`metrics.ReviewContext`).
- **identity:** `POST /identity/dota/resolve {input}` — Steam-ссылка/SteamID64/Dota ID → account id.
- **cs2:** `GET /cs2/maps`, `GET /cs2/grenades`.
- **прочее:** `GET /health`.

## AI Coach (важно)
- Клиент OpenAI-совместимый (`internal/modules/ai_coach/infrastructure/ai_client/openai/client.go`). `AI_MODEL` — **список через запятую**, модели пробуются по очереди, первая рабочая выигрывает; если все упали — ошибка перечисляет причины по каждой.
- НЕ используем `response_format/json_object` (free-модели часто не поддерживают и падают 404). JSON вытаскиваем из текста парсером.
- Бесплатные модели OpenRouter капризны: 404 «No endpoints found» (устаревший slug ИЛИ не включён тумблер на https://openrouter.ai/settings/privacy), 429 (лимит). Надёжнее: `openrouter/free` (авто-роутер) или провайдер **Groq** (`AI_BASE_URL=https://api.groq.com/openai/v1`, модель `llama-3.3-70b-versatile`).
- `.env` для AI: `AI_PROVIDER`, `AI_API_KEY`, `AI_MODEL`, `AI_BASE_URL`, `AI_TIMEOUT`. Если не задано — коуч выключен (ручки возвращают `provider_disabled`).

## Frontend: структура `frontend-make/src`
- `lib/api.ts` — клиент. `BASE = VITE_API_BASE_URL || "/api/v1"`. Токен в `localStorage["gm.token"]`. Есть `rawRequest()` (для страницы API-теста, не разворачивает `.data`).
- `lib/store.tsx` — `PlayerProvider`: `search(input)`, `accountId`, `data`, `live`, `resetToSelf`. Авто-загружает игрока на старте из `user.dota_account_id` или `localStorage["gm.dotaId"]` (последний поиск).
- `lib/auth.tsx` — `AuthProvider`: `user`, `subscription`, `login/register/logout`, `updateProfile`, `subscribe/cancel`.
- `lib/mapper.ts` — `mapDashboard()`. **Ненадёжен** (формат дашборда не всегда мапится). Поэтому ключевые компоненты берут данные напрямую: ProfileHeader → `dota.profile` + `dota.metrics`; RecentMatches → `dota.rawMatches`; KpiCards → `dota.metrics`.
- `lib/heroes.ts` — `heroPortrait(id)` / `heroName(id)` (CDN Steam).
- **pages:** `Landing` (вход), `Overview` (scrollytelling-сцены), `Performance`, `Heroes`, `Rankings`, `Replays`, `Coach` (опрос + AI-план), `Explorer`, `ApiProbe` (API-тест), `Profile`, `Subscription`, `Auth`, `cs2/Grenades`, `cs2/Training`.
- **components:** `ProfileHeader`, `ScoreGauge` (тултип «как считаются очки»), `KpiCards` (период→окно метрик), `PerformanceTrend`, `HexRadar`, `RecentMatches`, `AiCoach`, `DeepReview` (paywall для не-Pro), `ProComparison`, `Sidebar`, `TopBar`, `Reveal` (fade-in при скролле).
- **Роутинг:** `/` = `Landing` (полноэкранный iframe `public/landing.html` + React-оверлей с реальным поиском и живым превью). `/overview` = главная дашборда. `/login`,`/register` — полноэкранный Auth. Остальное под `/overview`, `/coach`, `/heroes`, `/explorer`, `/api-test`, `/subscription`, `/profile`, `/cs2/...`.

## Лендинг
- `frontend-make/public/landing.html` — статический дизайн-бандл (Figma Make, ~1.2 МБ), править внутри нельзя. Его кнопки/поля декоративны.
- Реальный поиск и пересчёт — в React-оверлее (`pages/Landing.tsx`): своя строка поиска сверху, при вводе id → `usePlayer().search()` → живая карточка превью (аватар, ник, ранг, GM Score, Winrate, KDA, GPM, матчи) прямо на лендинге, плюс кнопки «Полный разбор»/«AI-план».

## Деплой и CI/CD
- Локально/на VPS: `docker compose up -d --build`. Миграции применяются контейнером `migrate`.
- Backend читает `$PORT` (для Render) и `HTTP_ADDR`. Redis по `rediss://` (Upstash) тоже поддерживается.
- CI/CD: `.github/workflows/deploy-server.yml` — по пушу в `main` заходит по SSH (`appleboy/ssh-action`), `git reset --hard origin/main` + `docker compose up -d --build`. Нужны секреты: `SERVER_HOST`, `SERVER_USER`, `SSH_PRIVATE_KEY`, `DEPLOY_PATH` (Repository secrets).
- `.github/workflows/deploy-frontend.yml` (GitHub Pages) — НЕ используется при хостинге на VPS, можно удалить.
- На 1-2 ГБ RAM нужен swap, иначе сборка Go падает с `signal: killed` (OOM).

## Конвенции и подводные камни
- Файлы с кириллицей правь аккуратно; после правок проверяй через чтение файла, а не через (иногда устаревший) bash-маунт. ASCII-комментарии в коде.
- `mapDashboard` ненадёжен — для реальных данных используй `metrics` + `profile` + `rawMatches`.
- HashRouter: deep-ссылки вида `/#/overview`.
- Kнопки AI требуют `accountId`; если он пуст — берём фолбэк из `localStorage["gm.dotaId"]`.
- Парс-зависимые метрики (участие в килах, LH@10, net worth по таймингам, станы) требуют распарсенного реплея OpenDota — пока не подключены (помечены как PRO/на потом).

## Безопасность
- `.env` в `.gitignore` — НЕ коммитить секреты (DB пароль, JWT_SECRET, STEAM/STRATZ/AI ключи).
- Steam-ключ ранее светился в переписке — должен быть отозван и перевыпущен.

## Открытые задачи (TODO)
- Подключить к живым данным Rankings, доп. графики Performance, график net worth в Replays.
- Добавить график «MMR/ранг по времени» из OpenDota `ratings` (или Stratz).
- Зафиксировать финальный набор метрик для окна 200-500 игр и докрутить под-оценки.
- Добавить парс-зависимые метрики (PRO).
- Долить CI/CD-секреты, удалить неиспользуемый Pages-workflow.
- Гейтинг Pro-функций по подписке на бэке (сейчас paywall только на фронте).
