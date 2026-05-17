# cs2-grenade-recorder

Локальная CLI-утилита для записи координат CS2 гранат из `console.log`.

Утилита не читает память процесса CS2, не подключается к игре и не делает ничего запрещенного. Она только следит за лог-файлом, куда CS2 пишет вывод команды `getpos`.

## Зачем Это Нужно

Когда ты хочешь добавить новую раскидку в GameMentor, тебе нужны две точки:

- позиция, откуда игрок бросает гранату;
- позиция, куда граната должна прилететь.

В CS2 эти координаты можно получить через `getpos`. Рекордер автоматизирует скучную часть: ловит строки `setpos ...; setang ...`, парсит координаты и сохраняет готовый JSON.

## Настройка CS2

Открой консоль разработчика в CS2 и включи запись консоли в файл:

```text
con_logfile "console.log"
```

Назначь `getpos` на удобную клавишу:

```text
bind "F9" "getpos"
```

Типичный путь к логу на Windows:

```text
C:\Program Files (x86)\Steam\steamapps\common\Counter-Strike Global Offensive\game\csgo\console.log
```

Если Steam установлен на другой диск, путь будет отличаться. Главное найти файл `game\csgo\console.log`.

## Запуск

Из корня репозитория:

```powershell
go run ./cmd/recorder -log-path "C:\Program Files (x86)\Steam\steamapps\common\Counter-Strike Global Offensive\game\csgo\console.log" -map de_mirage -type smoke
```

Или из папки `cmd/recorder`:

```powershell
go run main.go -log-path "C:\Program Files (x86)\Steam\steamapps\common\Counter-Strike Global Offensive\game\csgo\console.log" -map de_mirage -type smoke
```

Можно один раз задать путь через env:

```powershell
$env:CS2_CONSOLE_LOG="C:\Program Files (x86)\Steam\steamapps\common\Counter-Strike Global Offensive\game\csgo\console.log"
go run ./cmd/recorder -map de_mirage -type smoke
```

## Как Записать Раскидку

1. Запусти рекордер.
2. В CS2 встань на позицию броска.
3. Нажми `F9`.
4. Перейди к точке приземления гранаты.
5. Нажми `F9` второй раз.
6. Подтверди экспорт JSON.

Первая строка `getpos` становится:

- `throw_position`;
- `view_angle`.

Вторая строка `getpos` становится:

- `landing_position`.

## Тест Без CS2

Можно проверить рекордер на фейковом лог-файле.

Терминал 1:

```powershell
New-Item -ItemType Directory -Force .\tmp
go run ./cmd/recorder -log-path ".\tmp\console.log" -map de_mirage -type smoke -out ".\tmp\grenade.json" -yes
```

Терминал 2:

```powershell
Add-Content .\tmp\console.log 'setpos -1032.42 -789.12 -167.97; setang -18.40 91.20 0.00'
Start-Sleep -Milliseconds 500
Add-Content .\tmp\console.log 'setpos -820.11 -1020.44 -160.97; setang 0.00 0.00 0.00'
Get-Content .\tmp\grenade.json
```

Ожидаемые логи:

```text
Throw position captured
Landing position captured
JSON exported
```

## Флаги

```text
-log-path   путь к CS2 console.log
-map        карта для JSON, по умолчанию de_mirage
-type       тип гранаты, по умолчанию smoke
-out        путь экспорта, по умолчанию grenade.json
-debounce   окно игнорирования дублей getpos, по умолчанию 800ms
-yes        экспортировать JSON без подтверждения
```

## Формат JSON

```json
{
  "map": "de_mirage",
  "grenade_type": "smoke",
  "throw_position": {
    "x": -1032.42,
    "y": -789.12,
    "z": -167.97
  },
  "view_angle": {
    "pitch": -18.4,
    "yaw": 91.2
  },
  "landing_position": {
    "x": -820.11,
    "y": -1020.44,
    "z": -160.97
  }
}
```

## Как Перенести Данные В GameMentor

Импорт JSON в админку автоматизирован. Базовый сценарий теперь такой:

1. Записал JSON через рекордер.
2. Сделал screenshot или короткое видео раскидки.
3. Положил картинку в `frontend/web/assets/gamementor/cs2/grenades`.
4. Открыл Admin Panel и импортировал `grenade.json`.
5. При необходимости указал `image_url` вида:

```text
/assets/gamementor/cs2/grenades/mirage-window-smoke.jpg
```

Следующий логичный шаг проекта уже реализован: `grenade.json` можно импортировать в Admin Panel и сразу сохранять через сайт.

## Новый Workflow Через Сайт

Теперь `grenade.json` можно загружать в админку без ручного копирования координат.

1. Запусти recorder и получи `grenade.json`.
2. Открой раздел Admin Panel в frontend.
3. Нажми `Открыть grenade.json` или вставь содержимое файла в блок `Импорт из recorder`.
4. Нажми `Импортировать в форму`.
5. Проверь `side` и `difficulty`.
6. При желании поправь `title`, `from`, `to`, `image_url` и `tags`.
7. Нажми `Добавить гранату`.

Что импортируется автоматически:

- map (`de_mirage` -> `mirage`);
- grenade type;
- throw position;
- landing position;
- view angle;
- базовое описание;
- теги;
- fallback image по карте.

Это позволяет быстро занести новую гранату на сайт сразу после записи в CS2, а красивый скриншот или видео можно добавить позже отдельным редактированием.
