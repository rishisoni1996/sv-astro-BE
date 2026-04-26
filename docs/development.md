# Development Guide

## Prerequisites

- Node.js 20+
- PostgreSQL 14+ (locally or via Docker)
- (Optional) OpenAI API key — AI endpoints degrade gracefully with fallbacks when unset

## 1. Install dependencies

```bash
npm install
```

## 2. Environment

Copy `env-example-relational` → `.env` and fill in values.

```bash
cp env-example-relational .env
```

At minimum you'll need `DATABASE_*` values pointing at a running Postgres instance and two JWT secrets (`AUTH_JWT_SECRET`, `AUTH_REFRESH_SECRET`). Apple/Google OAuth + IAP + OpenAI are optional — endpoints that depend on them will return sensible errors or fallbacks.

## 3. Create the database

```bash
createdb lumen     # or via your GUI / docker
```

## 4. Run migrations

```bash
npm run migration:run
```

The initial migration (`src/database/migrations/1700000000000-InitialSchema.ts`) creates every table, enum, index, CHECK constraint, and the `pg_trgm`-free full-text index on `dreams`.

## 5. Seed reference data

Seeds the 3 subscription plans and 22 tarot Major Arcana cards. Idempotent.

```bash
npm run seed:run:relational
```

## 6. Run the server

```bash
npm run start:dev      # watch mode
# or
npm run start:swc      # faster compilation via swc
```

API lives at `http://localhost:3000/api/v1/…`. Swagger UI at `http://localhost:3000/docs`.

## 7. Verification checklist

From the spec, the happy-path cURL sequence. Replace `$TOKEN` with the `accessToken` returned by `/auth/register`.

```bash
# 1. Register
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H 'Content-Type: application/json' \
  -d '{"email":"test@lumen.app","name":"Test User","password":"Passw0rd!"}'

# 2. Birth chart
curl -X PUT http://localhost:3000/api/v1/users/me/birth-chart \
  -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -d '{"sunSign":"scorpio","moonSign":"cancer","risingSign":"leo","birthDate":"1995-03-14","birthTime":"04:32","birthLocation":"Brooklyn, NY"}'

# 3. Create dream
curl -X POST http://localhost:3000/api/v1/dreams \
  -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -d '{"content":"I was in a house...","typeTags":["Recurring"],"emotionTags":["Peaceful"]}'

# 4. Interpretation (returns the full result synchronously)
curl -X POST http://localhost:3000/api/v1/dreams/$DREAM_ID/interpretation \
  -H "Authorization: Bearer $TOKEN"

# 5. Daily tarot
curl http://localhost:3000/api/v1/readings/daily -H "Authorization: Bearer $TOKEN"

# 6. Plans (public)
curl http://localhost:3000/api/v1/subscriptions/plans
```

## 8. Quality gates

```bash
npm run lint           # ESLint (auto-fix)
npm run test           # Jest unit tests
npm run build          # nest build (compile only)
```

Pre-commit hooks run `lint-staged` + `jest --passWithNoTests`. Commit messages are validated via Commitlint (Conventional Commits).

## 9. Creating new migrations

After changing an entity, run:

```bash
npm run migration:generate -- src/database/migrations/DescriptiveName
npm run migration:run
```

## 10. Troubleshooting

| Symptom                                        | Fix                                                             |
| ---------------------------------------------- | --------------------------------------------------------------- |
| `CREATE EXTENSION "pgcrypto"` permission error | Run `CREATE EXTENSION` manually as a DB superuser once          |
| AI endpoints return generic fallback content   | `OPENAI_API_KEY` not set — expected; configure to enable AI     |
| `relation "…" does not exist`                  | Run `npm run migration:run`                                     |
| `no row for sort_order`                        | Run `npm run seed:run:relational` (tarot deck not seeded yet)   |
