# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run Commands

```bash
npm run build                # Compile TypeScript (nest build)
npm run start:dev            # Development with hot reload
npm run start:swc            # Development with SWC (faster compilation)
npm run start:prod           # Production (runs dist/main.js)
```

## Testing

```bash
npm test                     # Run all unit tests (jest)
npm run test:watch           # Watch mode
npm run test:cov             # Coverage report
npm run test:e2e             # E2E tests (requires env-cmd, uses test/jest-e2e.json)
```

Run a single test file: `npx jest path/to/file.spec.ts`

## Linting & Formatting

```bash
npm run lint                 # ESLint
npm run format               # Prettier
```

Pre-commit hooks (Husky) run `npm run lint` and `npm run test -- --passWithNoTests` automatically.

Commit messages must follow [Conventional Commits](https://www.conventionalcommits.org/) (enforced by commitlint).

## Database & Migrations

```bash
npm run migration:generate -- src/database/migrations/MigrationName  # Generate from entity changes
npm run migration:run                                                  # Apply pending migrations
npm run migration:revert                                               # Rollback last migration
npm run seed:run:relational                                            # Run database seeds
```

## Code Generation

```bash
npm run generate:resource:relational    # Scaffold a new module (controller, service, entity, DTOs)
npm run seed:create:relational          # Generate a seed file
```

## Feature Modules

All under `src/modules/<module>/` following the DDD layout in [docs/architecture.md](docs/architecture.md).

| Module            | Scope                                                                            |
| ----------------- | -------------------------------------------------------------------------------- |
| `auth`            | Registration, email/Google/Apple login, JWT access+refresh, logout, soft-delete. |
| `users`           | `/users/me`, birth chart upsert, onboarding quiz answers.                        |
| `dreams`          | Journal CRUD with `type_tags`/`emotion_tags` CHECK constraints + Postgres FTS.   |
| `interpretations` | AI-generated interpretation + symbol aggregation, premium gating.                |
| `patterns`        | Weekly symbol/emotion analytics; `pattern_caches` row per user+week.             |
| `guidance`        | Daily AI astrology guidance; Sun/Moon/Rising sign reveals.                       |
| `readings`        | 22 Major Arcana deck, deterministic daily pull, saved history.                   |
| `subscriptions`   | Plans listing + Apple/Google IAP validation, premium state.                      |

AI provider is OpenAI (`gpt-4o`) via `src/ai/ai.service.ts`. Calls are synchronous; a `status` field on rows leaves room for future async migration. See `backend-api-spec.md` for the full endpoint contract and `docs/` for developer setup + architecture details.

## Architecture

**NestJS modular monolith** with domain-driven design patterns, TypeORM + PostgreSQL, and JWT-based auth.

### Module Structure

Each feature module follows this layered pattern:

```
module-name/
├── module-name.module.ts
├── module-name.controller.ts         # HTTP endpoints
├── module-name.service.ts            # Business logic
├── domain/
│   └── model.ts                      # Domain model (class-transformer decorators, API-facing)
├── dto/
│   └── create-*.dto.ts, update-*.dto.ts  # class-validator decorated DTOs
└── infrastructure/
    └── persistence/
        └── relational/
            ├── entities/*.entity.ts      # TypeORM entity (DB-facing)
            ├── repositories/*.repository.ts
            └── mappers/*.mapper.ts       # Domain ↔ Entity conversion
```

**Key distinction:** Domain models are for API serialization (with `@Expose`/`@Exclude`). Entities are for database persistence. Mappers convert between them.

### Auth System

- Passport.js strategies: JWT, JWT-Refresh, JWT-Registration, Anonymous
- Multi-flow auth: email/password, OTP (Firebase), Google OAuth, Apple Sign-In
- Role-based access via `@Roles()` decorator + `RolesGuard`
- Separate JWT secrets for: access, refresh, forgot-password, email-confirm, registration tokens

### Global Middleware & Pipes

Configured in `src/main.ts`:

- `ValidationPipe` with whitelist + transform (returns 422 on validation failure)
- `ResolvePromisesInterceptor` and `ClassSerializerInterceptor` applied globally
- API prefix: `/api` with URI versioning (v1, v2)
- Swagger docs at `/docs`

### Configuration Pattern

Each config (`src/config/`) uses `registerAs()` with its own `EnvironmentVariablesValidator` class. Config types are unified through `AllConfigType`. Environment variables are defined in `env-example-relational`.

### ESLint Custom Rules

- `configService.get()` calls must include `{ infer: true }` for type safety
- Test descriptions must start with "should"
- No floating promises (`@typescript-eslint/no-floating-promises`)

### Key Services

- **Files:** S3 or local storage, configurable via `FILE_DRIVER` env var
- **Mail:** Two layers — `MailService` (templates + i18n) → `MailerService` (AWS SES transport)
- **Notifications:** Push notifications via Firebase Admin SDK
- **i18n:** `nestjs-i18n` with `x-custom-lang` header resolver
