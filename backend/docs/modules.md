# GameMentor Modules

## Legacy Modules

The project still contains the original layers:

- `internal/domain`
- `internal/usecase`
- `internal/repository/postgres`
- `internal/delivery/http/handler`
- `internal/clients/opendota`

These are intentionally preserved. They power existing endpoints and are not removed during the first modular migration.

## Dota

Path: `internal/modules/dota`

Responsibilities:

- player profile lookup;
- recent matches lookup;
- hero stats aggregation;
- match details contract;
- provider boundary for OpenDota, STRATZ, and Steam.

Providers:

- `infrastructure/provider/opendota` wraps the existing OpenDota client;
- `infrastructure/provider/stratz` is a disabled stub until keys/API shape are added;
- `infrastructure/provider/steam` is a disabled stub until keys/API shape are added.

Public provider interfaces:

```go
type PlayerStatsProvider interface {
    GetPlayerProfile(ctx context.Context, steamID string) (*PlayerProfile, error)
    GetRecentMatches(ctx context.Context, steamID string, limit int) ([]MatchSummary, error)
    GetHeroStats(ctx context.Context, steamID string) ([]HeroStats, error)
}

type MatchDetailsProvider interface {
    GetMatchDetails(ctx context.Context, matchID string) (*MatchDetails, error)
}
```

## Analytics

Path: `internal/modules/analytics`

Responsibilities:

- build Dota analytics snapshots;
- calculate winrate, winrate 7/30/90;
- calculate best/worst heroes;
- calculate average KDA, GPM, XPM;
- calculate impact, stability, farming, fighting, and objective scores;
- expose normalized snapshot data for AI Coach.

Analytics does not call OpenDota directly. It depends on a Dota match reader interface.

## AI Coach

Path: `internal/modules/ai_coach`

Responsibilities:

- request analytics snapshot;
- build a structured Dota review prompt;
- call AI through an `AIClient` interface;
- save and return coach reports.

Current AI client is disabled until `AI_PROVIDER`, `AI_API_KEY`, and `AI_MODEL` are connected to a real provider.

Report shape:

```json
{
  "summary": "...",
  "strengths": [],
  "weaknesses": [],
  "main_mistakes": [],
  "recommendations": [],
  "training_plan": [],
  "heroes_to_focus": [],
  "heroes_to_avoid": [],
  "next_steps": []
}
```

## Jobs

Path: `internal/modules/jobs`

Responsibilities:

- create long-running jobs;
- store job state;
- run job handlers in-process;
- make replacement by Redis Queue or RabbitMQ possible later.

Supported job types:

- `refresh_player_stats`
- `build_analytics_snapshot`
- `generate_ai_coach_report`
- `update_hero_meta`

Statuses:

- `pending`
- `running`
- `completed`
- `failed`

## Platform

Path: `internal/platform`

Responsibilities:

- infrastructure primitives that are not business modules;
- cache, database, logger, queue, HTTP utilities, AI client contracts.

## Future Modules

`auth`, `users`, and `billing` are present as module boundaries. Existing user/auth behavior remains in legacy use-cases until a later migration step.

