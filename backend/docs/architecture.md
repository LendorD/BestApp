# GameMentor Backend — Architecture

GameMentor is a multi-game esports analytics platform (Dota 2, CS2, and future
titles). The backend is a Go service built around **modular Clean / Hexagonal
architecture**: every business domain is an isolated module with the same
internal layering, wired together centrally.

## Layering (per module)

```
internal/modules/<module>/
  domain/                       # entities, value objects, domain errors, ports (interfaces)
  application/                  # use-case services (business logic), DTOs for services
  delivery/http/                # Gin handlers + RegisterRoutes + request/response DTOs
  infrastructure/
    repository/postgres/        # pgx repositories (implement domain ports)
    provider/                   # external API clients (OpenDota, Stratz, Steam, OpenAI...)
```

### Dependency rule (strict, inward-only)
- `delivery/http` → `application` → `domain`
- `infrastructure` → implements interfaces declared in `domain`/`application`
- **`domain` imports nothing technical** (no Gin, pgx, Redis, OpenAI, OpenDota, Steam, HTTP).
- All external dependencies are reached through interfaces.
- Every I/O method takes `context.Context`.

### Handler rules
HTTP handlers only: bind/validate request DTO → call application service →
map result to response DTO. No business logic, no SQL, no provider calls.

## Modules

| Module | Responsibility |
|--------|----------------|
| `users` | user profiles, settings (Dota ID, preferences) |
| `auth` | registration, login, sessions/tokens |
| `cs2` | CS2 maps & grenade library, recorder import |
| `dota` | Dota player profile, matches, hero stats (OpenDota/Stratz/Steam providers) |
| `statistics` | game-agnostic stats/analytics service (Dota now, CS2 + future games later) |
| `ai_coach` | LLM-based reviews of players and individual matches |
| `jobs` | background jobs (refresh stats, build snapshots, generate reports) |
| `identity` | resolve Steam vanity/SteamID/profile URL → account id |
| `billing` | subscriptions / paid features (planned) |

## Platform (cross-cutting, not business)
```
internal/platform/cache         # cache.Cache interface + memory & redis impls
internal/platform/...            # logger, http server, postgres pool helpers
internal/config                  # env config
internal/clients/<vendor>        # low-level external HTTP clients (opendota, steam)
internal/app                     # bootstrap + wiring + module registration (the ONLY composition root)
internal/delivery/http/router.go # registers each module's routes; no business logic
```

## Wiring
`internal/app/bootstrap.go` builds config, db pool, cache, logger.
`internal/app/modules.go` constructs every module's repos/providers/services/handlers
and exposes them to the router. `router.go` calls each module's `RegisterRoutes(group, handler)`.

## Adding a new game (e.g. Valorant)
1. `internal/modules/valorant/{domain,application,delivery/http,infrastructure/provider}`.
2. Implement a provider for the data source behind a domain port.
3. Register the game in the `statistics` service (game-agnostic metrics).
4. Wire it in `modules.go`, register routes in `router.go`. No other module changes.

## Statistics as a separate service
`statistics` does NOT own raw data. It depends on per-game data ports
(`DotaDataSource`, `CS2DataSource`, ...) and computes normalized metrics,
performance scores, form timelines, pro comparisons. This keeps scoring logic in
one place and reusable across games and across `ai_coach`.
