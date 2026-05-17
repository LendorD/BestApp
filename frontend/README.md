# GameMentor Frontend

Flutter Web интерфейс для GameMentor: темная esports-панель с CS2 раскидками, Dota 2 аналитикой, тренировками, профилем и админкой.

## Стек

- Flutter Web.
- Riverpod.
- go_router.
- Dio.
- freezed/json_serializable.
- Feature-based структура в `lib/features`.

## Запуск

Mock-режим включен по умолчанию:

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d chrome --web-port 5173
```

Режим реального backend API:

```powershell
flutter run -d chrome --web-port 5173 --dart-define=USE_MOCK_API=false --dart-define=API_BASE_URL=http://localhost:8080/api/v1
```

Если порт занят, запусти на другом:

```powershell
flutter run -d chrome --web-port 5174
```

## Проверки

```powershell
flutter analyze
flutter test
flutter build web
```

## Страницы

- `/` - главная.
- `/cs2` - список гранат CS2.
- `/cs2/:id` - детальная страница гранаты.
- `/dota` - статистика Dota 2.
- `/training` - планы тренировок.
- `/profile` - профиль.
- `/register` - регистрация и вход.
- `/admin` - форма добавления CS2 гранаты.

## API Mode

Конфиг находится здесь:

```text
lib/core/config/app_config.dart
```

Параметры:

```text
USE_MOCK_API=true
USE_MOCK_API=false
API_BASE_URL=http://localhost:8080/api/v1
```

## Картинки

Для надежного локального отображения клади картинки в:

```text
web/assets/gamementor
```

Базовый набор изображений уже скачан в эту папку. Для продакшн-вида лучше заменить demo placeholders на свои скриншоты CS2 и выбранные licensed-изображения.

Например, для гранаты:

```text
web/assets/gamementor/cs2/grenades/mirage-window-smoke.jpg
```

И указывай в API/Admin Panel:

```text
/assets/gamementor/cs2/grenades/mirage-window-smoke.jpg
```

Справочник по нужным файлам: [web/assets/gamementor/README.md](web/assets/gamementor/README.md).
