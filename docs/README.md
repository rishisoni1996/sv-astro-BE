# Lumen Backend — Developer Documentation

Lumen is an AI-powered dream-interpretation, tarot, and astrology mobile app. This is the NestJS backend powering its Flutter frontend.

## Contents

- **[development.md](./development.md)** — local setup, environment variables, migrations, seeds, run commands.
- **[architecture.md](./architecture.md)** — module layout (domain-driven, spec-aligned), naming conventions, mappers.
- **[api.md](./api.md)** — high-level API summary; full OpenAPI lives at `/docs` once the server is running.

## Feature modules

| Module            | Responsibility                                                                   |
| ----------------- | -------------------------------------------------------------------------------- |
| `auth`            | Registration, email/Google/Apple login, JWT access + refresh rotation, logout.   |
| `users`           | `/users/me` profile, birth chart upsert, onboarding quiz storage.                |
| `dreams`          | Dream journal CRUD with tag constraints, Postgres FTS, pagination.               |
| `interpretations` | Per-dream AI interpretation (core/reveals/guidance + symbols), premium gating.   |
| `patterns`        | Weekly symbol + emotion analytics with a cached AI weekly summary.               |
| `guidance`        | Daily personalized astrological guidance and Sun/Moon/Rising reveal cards.       |
| `readings`        | Tarot deck (22 cards), deterministic daily pull, saved history.                  |
| `subscriptions`   | Plans listing, Apple/Google IAP validation, premium status.                      |

Full spec (entities, endpoints, schema, business logic) lives in the repo at `backend-api-spec.md`.
