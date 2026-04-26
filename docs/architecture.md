# Architecture

## Layout

Each feature module follows the spec's domain-driven layout:

```
src/modules/<module>/
├── <module>.module.ts
├── <module>.controller.ts          # HTTP
├── <module>.service.ts             # Business logic
├── domain/                         # API-facing types (@Expose, @ApiProperty)
├── dto/                            # class-validator request shapes
└── infrastructure/
    └── persistence/
        └── relational/
            ├── entities/           # TypeORM entities (DB-facing)
            ├── repositories/       # Thin typed wrappers around Repository<T>
            └── mappers/            # Entity ↔ Domain conversion
```

**Strict rule:** entities never leave the service layer. Controllers receive DTOs and return domain objects. Mappers cross the boundary.

## Shared infrastructure

| Path                                 | Purpose                                                          |
| ------------------------------------ | ---------------------------------------------------------------- |
| `src/config/*.config.ts`             | `registerAs()` configs with per-file `EnvironmentVariablesValidator` |
| `src/database/data-source.ts`        | Exported TypeORM `DataSource` for CLI (`migration:*`)            |
| `src/database/typeorm-config.service.ts` | Nest-side `TypeOrmOptionsFactory` used by `AppModule`          |
| `src/database/migrations/`           | SQL migrations (hand-written initial, autogen'd thereafter)      |
| `src/database/seeds/relational/`     | Seed modules for read-only reference tables                      |
| `src/ai/ai.service.ts`               | `AiModule` (global) wraps OpenAI SDK with graceful fallbacks     |
| `src/utils/*`                        | `premium-check`, `deterministic-hash`, `date-format`, `pagination`, `validate-config` |
| `src/common/*`                       | Global HTTP filter, response interceptor, request types          |

## Request lifecycle

1. `main.ts` wires global pipes (`ValidationPipe` whitelist + transform → 422 on invalid), `ClassSerializerInterceptor`, `TransformInterceptor`, and the global `HttpExceptionFilter`.
2. `JwtAuthGuard` (on protected routes) triggers `JwtStrategy.validate()` → injects `req.user = { id, role }`.
3. Services consume repositories; mappers convert entities to domain objects before they're returned from the controller.
4. The response interceptor wraps payloads as `{ data, message: 'Success' }`.

## Auth

- Access token: 15-minute TTL, signed with `AUTH_JWT_SECRET`, payload `{ sub, role }`.
- Refresh token: 30-day TTL, signed with `AUTH_REFRESH_SECRET`, payload `{ sub, sessionId }`. Its bcrypt hash is stored in `auth_tokens` (rotated on every refresh).
- Social auth: Google via `google-auth-library` `verifyIdToken`; Apple via `jwks-rsa` + `jsonwebtoken` against `appleid.apple.com/auth/keys`.

## Premium gating

- Derived from `user_subscriptions` row: `status IN ('trial','active') AND (expires_at IS NULL OR expires_at > now())`.
- Services return the data with premium fields `null` and `isPremiumLocked: true` when the user is not premium. This mirrors the frontend's blur/unlock UI pattern (no 403 needed).
- `assertPremium(user, feature)` utility exists for cases that should hard-block.

## AI integration

- One `AiService` (global, injectable) with methods per use case. All methods:
  - `try/catch` around OpenAI calls.
  - Return `null` on failure so callers can fall back to static content.
  - JSON responses use `response_format: { type: 'json_object' }`.
- No Redis / queue. Everything is synchronous; status fields (`pending`, `processing`, `done`, `failed`) exist for future async migration.

## Naming conventions

- Entities: `UserEntity`, `DreamEntity`, `TarotCardEntity`. Table names are `snake_case` via `@Entity({ name: '…' })`.
- Domains: `UserDomain`, `DreamDomain`, `TarotCardDomain`.
- Mappers: `UserMapper.toDomain(entity, extras)`.
- Repositories: custom class (`UserRepository`) wrapping the injected `Repository<UserEntity>`.
- Enums/tags: `users.enums.ts`, `dreams.enums.ts`, etc. at module root.

## What's intentionally simple

- No queue / Redis — synchronous AI calls.
- No RBAC routes yet — `RolesGuard` exists but only `user`/`admin` are defined; no admin endpoints in the current spec.
- No file storage driver beyond the boilerplate placeholder.
- Tests are skeletal; the build is the primary quality gate today. Unit-test scaffolding follows the `*.spec.ts` convention if added.
