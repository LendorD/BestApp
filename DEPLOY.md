# Деплой GameMentor бесплатно

Архитектура для бесплатного хостинга:

- **Фронтенд (React)** → GitHub Pages
- **Бэкенд (Go)** → Render (free web service, Docker)
- **PostgreSQL** → Neon (free)
- **Redis** → Upstash (free)

Всё бесплатно. Минусы free-тарифа Render: сервис «засыпает» после ~15 минут без запросов, первый запрос после простоя грузится ~30–50 секунд (потом быстро).

Порядок: БД → Redis → бэкенд → фронт.

---

## 1. PostgreSQL на Neon

1. Зарегистрируйся на https://neon.tech (через GitHub).
2. Create project → регион поближе (EU). Получишь **Connection string** вида:
   `postgresql://user:pass@ep-xxx.eu-central-1.aws.neon.tech/neondb?sslmode=require`
3. Сохрани эту строку — это `DATABASE_URL`.

## 2. Redis на Upstash

1. Зарегистрируйся на https://upstash.com.
2. Create Database → Global/EU. Открой базу → блок **Redis URL** (начинается с `rediss://`).
3. Сохрани — это `REDIS_URL`. (TLS-схема `rediss://` поддерживается, ничего менять не надо.)

## 3. Применить миграции к Neon (один раз)

Из папки проекта на своём компьютере (нужен Docker):

```powershell
docker run --rm -v ${PWD}/backend/migrations:/migrations migrate/migrate:v4.18.2 `
  -path /migrations `
  -database "ВСТАВЬ_СЮДА_DATABASE_URL" up
```

> Если в строке Neon нет `sslmode`, добавь `?sslmode=require`.
> Должно вывести applied migrations до `000005_billing`.

## 4. Бэкенд на Render

1. Залей проект на GitHub (см. раздел 6, если ещё не залит).
2. https://dashboard.render.com → **New → Blueprint** → выбери свой репозиторий.
   Render найдёт `render.yaml` и создаст сервис `gamementor-api`.
3. В сервисе → **Environment** заполни значения (они помечены `sync:false`):
   - `DATABASE_URL` — строка из Neon
   - `REDIS_URL` — строка из Upstash
   - (опц.) `STEAM_API_KEY`, `STRATZ_API_KEY`
   - (опц.) AI: `AI_PROVIDER=openrouter`, `AI_API_KEY=...`, `AI_MODEL=...`,
     `AI_BASE_URL=https://openrouter.ai/api/v1`
   `JWT_SECRET` сгенерируется автоматически.
4. Deploy. Дождись «Live». Проверь здоровье:
   открой `https://<имя-сервиса>.onrender.com/health` → должно быть `{"success":true,...}`.
5. Запомни базовый URL API: `https://<имя-сервиса>.onrender.com/api/v1`.

## 5. Фронтенд на GitHub Pages

1. В репозитории на GitHub: **Settings → Pages → Build and deployment → Source = GitHub Actions**.
2. **Settings → Secrets and variables → Actions → вкладка Variables → New variable**:
   - Name: `API_BASE_URL`
   - Value: `https://<имя-сервиса>.onrender.com/api/v1`
3. Сделай push в `main` (или вкладка **Actions → Deploy frontend → Run workflow**).
4. После зелёной сборки сайт будет на:
   `https://<твой-логин>.github.io/<имя-репозитория>/`

Эту ссылку и кидай друзьям. Регистрация, вход, поиск и AI работают через бэкенд на Render.

## 6. Залить проект на GitHub (если ещё не залит)

```powershell
cd C:\Users\Lendor\Desktop\BestAPP
git init
git add .
git commit -m "GameMentor"
git branch -M main
git remote add origin https://github.com/<логин>/<репо>.git
git push -u origin main
```

> Проверь, что `.env` в `.gitignore` (секреты не должны попасть в репозиторий).

---

## Проверка после деплоя

1. Открой Pages-ссылку → «Войти» → зарегистрируйся.
2. В профиле укажи свой **Dota Account ID** → Сохранить.
3. Вернись на Overview — должна подтянуться твоя статистика (бейдж **LIVE · OpenDota**).
4. В поиск вставь чужой профиль (ссылка Steam / SteamID / Dota ID) — посмотреть других;
   кнопка «← Мои данные» вернёт к себе.

## Частые проблемы

- **Первый запрос долго грузится** — это Render будит уснувший free-сервис. Нормально.
- **CORS / не логинит** — проверь, что `API_BASE_URL` указывает на `…/api/v1` и сервис «Live».
- **502 от бэкенда** — почти всегда не применены миграции (шаг 3) или неверный `DATABASE_URL`.
- **Стили/пустая страница на Pages** — проверь, что переменная `API_BASE_URL` задана и сборка
  прошла; путь должен быть `/<репо>/` (workflow ставит его сам).

## Безопасность

- Никогда не коммить `.env`. Все ключи — только в дашбордах Render/Neon/Upstash.
- Steam-ключ, который ты вставлял в чат, **отзови и перевыпусти** в Steam.
