# GameMentor Backend Architecture

GameMentor is moving to an incremental modular backend architecture. The migration keeps the existing business logic alive while new features are added behind explicit module boundaries.

## Goals

- Preserve existing CS2, users, and legacy Dota endpoints.
- Move new Dota, analytics, AI Coach, cache, and jobs behavior into `internal/modules`.
- Keep domain packages free from database, HTTP, Redis, AI, and provider dependencies.
- Pass all dependencies through constructors.
- Use `context.Context` for all I/O.
- Keep DTOs separate from domain entities.

## Runtime Layout

```text
cmd/
  api/main.go
  app/main.go

internal/
  app/
    app.go
    bootstrap.go
    modules.go
  config/
  platform/
    ai/
    cache/
    database/
    http/
    logger/
    postgres/
    queue/
  modules/
    auth/
    users/
    dota/
    analytics/
    ai_coach/
    billing/
    jobs/
```

`cmd/api` is the existing entrypoint. `cmd/app` is the new target entrypoint requested by the modular layout. Both call the same `app.Run()` function.

## Layers

Each new business module follows this direction of dependencies:

```text
delivery/http -> application -> domain
infrastructure -> domain/application interfaces
```

Domain is pure business data, contracts, and errors. Application owns use-cases. Infrastructure owns external clients, providers, repositories, and framework adapters. Delivery owns HTTP handlers and route registration only.

## Bootstrap

`internal/app/bootstrap.go` creates platform dependencies such as PostgreSQL and cache.

`internal/app/modules.go` wires repositories, use-cases, module services, handlers, and job handlers.

`internal/delivery/http/router.go` registers:

- legacy routes that existed before the refactor;
- new modular routes for Dota, analytics, AI Coach, and jobs.

## Cache

`internal/platform/cache` exposes:

```go
type Cache interface {
    Get(ctx context.Context, key string, dest any) error
    Set(ctx context.Context, key string, value any, ttl time.Duration) error
    Delete(ctx context.Context, key string) error
}
```

Implementations:

- `memory` for local development;
- `redis` for production-ready deployment.

Current TTLs:

- Dota profile: 24h
- Recent matches: 30m
- Hero stats: 30m
- Match details: 7d
- Analytics snapshot: 15m
- AI report: no TTL until manual refresh

## Graceful Degradation

OpenDota remains the first working Dota provider. STRATZ, Steam, and AI provider clients can be disabled without breaking the application. Disabled providers return:

```text
provider disabled or api key is missing
```

## Database Strategy

Existing tables remain untouched. Migration `000004_modular_dota_ai_jobs` adds new modular tables with `raw_json`, `normalized_json`, `source`, `fetched_at`, `expires_at`, `created_at`, and `updated_at` so analytics can be recalculated later without another external API call.

