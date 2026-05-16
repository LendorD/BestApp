# GameMentor Frontend

Flutter Web frontend for GameMentor: CS2 utility learning, Dota 2 stats and training plans.

## Stack

- Flutter Web
- Riverpod
- go_router
- Dio
- freezed + json_serializable
- Feature-based structure under `lib/features`

## Run

Mock mode is enabled by default:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d chrome --web-port 5173
```

Use the Go backend API:

```bash
cd frontend
flutter run -d chrome --web-port 5173 \
  --dart-define=USE_MOCK_API=false \
  --dart-define=API_BASE_URL=http://localhost:8080/api/v1
```

## Build

```bash
flutter build web
```

## Checks

```bash
flutter analyze
flutter test
```

## Pages

- `/` Главная
- `/cs2` Гранаты CS2
- `/cs2/:id` Детальная страница гранаты
- `/dota` Статистика Dota 2
- `/training` План тренировок
- `/profile` Профиль
- `/admin` Админ-панель

The Dota page supports period switching, hero images from Steam CDN, rank explanation and extended OpenDota metrics.

## API Mode

Configuration lives in `lib/core/config/app_config.dart`.

- `USE_MOCK_API=true` uses local mock data.
- `USE_MOCK_API=false` uses Dio with `API_BASE_URL`.
