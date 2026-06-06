# Backend Migration Plan (legacy -> modular)

Current legacy (only these remain outside modules):
- internal/usecase/{cs2.go,user.go}
- internal/delivery/http/handler/{cs2_handler.go,user_handler.go}
- internal/repository/postgres/{cs2_repository.go,user_repository.go}
- internal/domain/{cs2.go,user.go}  (dota.go/errors.go are shared platform-ish)

Already modular: dota, analytics, ai_coach, jobs, identity.
Empty stubs: modules/users, modules/auth, modules/billing (doc.go only).

## Steps (each step must `go build ./... && go test ./...` green before the next)

1. **CS2 module** — create internal/modules/cs2:
   - domain/        <- internal/domain/cs2.go (entities + errors + repo port)
   - application/   <- internal/usecase/cs2.go (CS2 service)
   - infrastructure/repository/postgres/ <- internal/repository/postgres/cs2_repository.go
   - delivery/http/ <- internal/delivery/http/handler/cs2_handler.go + RegisterRoutes
   - update modules.go to build cs2 module; router.go to call cs2http.RegisterRoutes
   - delete legacy cs2 files
   - keep routes identical: GET/POST/PUT/DELETE /api/v1/cs2/...

2. **Users module** — same pattern for user.go (profiles, settings).
   - routes identical: GET/PUT /api/v1/users/:id/profile

3. **Auth module** — extract register/login from user handler into modules/auth.
   - routes identical: POST /api/v1/auth/register, /auth/login

4. **Statistics module** — rename/relocate `analytics` -> `statistics`:
   - keep the same HTTP routes (/dota/lab/...) for frontend compatibility, OR add
     /statistics/... aliases. Introduce game-agnostic DataSource ports so CS2 can plug in later.
   - lowest risk: keep analytics package, add statistics as the public name; defer deep split.

5. **Cleanup** — remove now-empty internal/usecase, internal/delivery/http/handler,
   internal/repository/postgres; move shared internal/domain/errors.go to a platform/shared pkg.

6. **Docs + tests** — update api.md; add tests for cs2 + users application services.

## Compatibility
All existing endpoints stay byte-identical so the frontend keeps working:
- /api/v1/auth/register|login
- /api/v1/users/:id/profile
- /api/v1/cs2/maps|grenades...
- /api/v1/dota/lab/players/:steam_id/...
- /api/v1/identity/dota/resolve
- /api/v1/ai-coach/dota/...
- /api/v1/jobs...
