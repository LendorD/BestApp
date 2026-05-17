# GameMentor Frontend Assets

Эта папка нужна для локальных картинок Flutter Web. Все файлы из `frontend/web` раздаются dev-сервером как обычная статика.

В папку уже положен демо-набор изображений. Для финального вида проекта лучше заменить CS2 grenade screenshots на свои скриншоты из practice-режима.

## Рекомендуемая Структура

```text
frontend/web/assets/gamementor/
├── home/
│   ├── hero.jpg
│   ├── cs2-card.jpg
│   └── dota-card.jpg
├── cs2/
│   ├── maps/
│   │   ├── mirage.jpg
│   │   ├── inferno.jpg
│   │   ├── dust2.jpg
│   │   ├── nuke.jpg
│   │   ├── ancient.jpg
│   │   ├── anubis.jpg
│   │   └── vertigo.jpg
│   └── grenades/
│       ├── mirage-window-smoke.jpg
│       ├── inferno-banana-flash.jpg
│       ├── nuke-hut-molotov.jpg
│       └── anubis-b-main-he.jpg
└── dota/
    └── profile-fallback.jpg
```

## Как Сослаться На Файл

Если файл лежит здесь:

```text
frontend/web/assets/gamementor/cs2/grenades/mirage-window-smoke.jpg
```

То URL для frontend и backend данных будет:

```text
/assets/gamementor/cs2/grenades/mirage-window-smoke.jpg
```

Этот URL можно записывать в поле `image_url` у CS2 гранаты.

## Какие Картинки Делать

- `home/hero.jpg` - широкий esports hero под главную страницу.
- `home/cs2-card.jpg` - картинка для карточки CS2.
- `home/dota-card.jpg` - картинка для карточки Dota 2.
- `cs2/maps/*.jpg` - обложки карт.
- `cs2/grenades/*.jpg` - скриншоты конкретных раскидок.
- `dota/profile-fallback.jpg` - fallback, если у игрока нет аватарки.

Лучший вариант для CS2 гранат - свои скриншоты из practice-режима. Тогда картинка точно соответствует позиции и не зависит от внешних сайтов.
