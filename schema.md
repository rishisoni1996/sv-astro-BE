# Lumen Database Schema

ER diagram for all tables defined in `src/database/migrations/1700000000000-InitialSchema.ts`. Relationships reflect foreign keys + uniqueness constraints.

```mermaid
erDiagram
    users ||--o{ auth_tokens : has
    users ||--o| birth_charts : has
    users ||--o{ onboarding_answers : quiz
    users ||--o{ dreams : authored
    users ||--o{ pattern_caches : cache
    users ||--o{ daily_guidance : cache
    users ||--o{ sign_reveals : reveals
    users ||--o{ tarot_readings : pulled
    users ||--o| user_subscriptions : subscribed
    dreams ||--o| dream_interpretations : interpretation
    dream_interpretations ||--o{ dream_symbols : symbols
    tarot_cards ||--o{ tarot_readings : card
    subscription_plans ||--o{ user_subscriptions : plan

    users {
        uuid id PK
        varchar email
        varchar name
        varchar initials
        enum provider
        varchar provider_id
        enum role
        boolean is_active
        varchar hash
        timestamptz created_at
        timestamptz updated_at
        timestamptz deleted_at
    }

    auth_tokens {
        uuid id PK
        uuid user_id FK
        varchar token_hash
        timestamptz expires_at
        timestamptz created_at
    }

    birth_charts {
        uuid id PK
        uuid user_id FK
        varchar sun_sign
        varchar moon_sign
        varchar rising_sign
        date birth_date
        time birth_time
        varchar birth_location
        timestamptz created_at
        timestamptz updated_at
    }

    onboarding_answers {
        uuid id PK
        uuid user_id FK
        smallint step
        jsonb answer_json
        timestamptz created_at
    }

    dreams {
        uuid id PK
        uuid user_id FK
        varchar title
        text content
        varchar_array type_tags
        varchar_array emotion_tags
        timestamptz recorded_at
        timestamptz created_at
        timestamptz updated_at
        timestamptz deleted_at
    }

    dream_interpretations {
        uuid id PK
        uuid dream_id FK
        text core_meaning
        text what_reveals
        text guidance
        enum status
        timestamptz created_at
        timestamptz updated_at
    }

    dream_symbols {
        uuid id PK
        uuid interpretation_id FK
        varchar emoji
        varchar name
        smallint occurrence_count
        varchar last_seen_label
        smallint sort_order
    }

    pattern_caches {
        uuid id PK
        uuid user_id FK
        date week_start
        jsonb symbols_json
        jsonb themes_json
        text summary
        enum status
        timestamptz generated_at
        timestamptz created_at
    }

    daily_guidance {
        uuid id PK
        uuid user_id FK
        date guidance_date
        varchar greeting
        text headline
        text subtext
        varchar astro_context
        enum status
        timestamptz created_at
    }

    sign_reveals {
        uuid id PK
        uuid user_id FK
        enum position
        varchar sign_name
        text description
        timestamptz generated_at
    }

    tarot_cards {
        uuid id PK
        varchar numeral
        varchar name
        varchar_array keywords
        text what_shows
        text applies_today
        text question
        varchar deck_name
        smallint sort_order
    }

    tarot_readings {
        uuid id PK
        uuid user_id FK
        uuid card_id FK
        timestamptz pulled_at
        boolean saved
        date daily_date
    }

    subscription_plans {
        varchar id PK
        varchar title
        numeric price
        varchar unit
        varchar badge
        smallint sort_order
    }

    user_subscriptions {
        uuid id PK
        uuid user_id FK
        varchar plan_id FK
        enum status
        enum provider
        text receipt_token
        timestamptz started_at
        timestamptz trial_ends_at
        timestamptz expires_at
        boolean auto_renew
        timestamptz created_at
        timestamptz updated_at
    }
```

## Relationship key

| Mermaid   | Meaning                                  |
| --------- | ---------------------------------------- |
| `\|\|--o{` | exactly one on the left → zero-or-many   |
| `\|\|--o\|` | exactly one on the left → zero-or-one    |

## Schema notes (not visible in the diagram)

- **Enums:**
  - `users.provider`: `email`, `google`, `apple`
  - `users.role`: `user`, `admin`
  - `dream_interpretations.status` / `pattern_caches.status` / `daily_guidance.status`: `pending`, `processing`, `done`, `failed` (processing only on dream_interpretations)
  - `sign_reveals.position`: `sun`, `moon`, `rising`
  - `user_subscriptions.status`: `trial`, `active`, `cancelled`, `expired`
  - `user_subscriptions.provider`: `apple`, `google`, `stripe`

- **Soft deletes:** `users` and `dreams` use `deleted_at`. Queries exclude rows where it's non-null.

- **Unique constraints:**
  - `users.email` — unique only among non-deleted rows (partial unique index)
  - `birth_charts.user_id`, `user_subscriptions.user_id` — one per user
  - `onboarding_answers(user_id, step)` — one answer per user per step
  - `dream_interpretations.dream_id` — one per dream
  - `pattern_caches(user_id, week_start)` — one per user per week
  - `daily_guidance(user_id, guidance_date)` — one per user per day
  - `sign_reveals(user_id, position)` — one per user per position
  - `tarot_readings(user_id, daily_date)` — unique only when `daily_date IS NOT NULL` (non-daily pulls can repeat)
  - `tarot_cards.sort_order` — 0–21, unique

- **Cascade:** every `user_id` FK is `ON DELETE CASCADE`. `dream_interpretations` cascades to `dream_symbols`; `dreams` cascades to its interpretation.

- **Full-text search:** GIN index on `dreams` over `to_tsvector('english', coalesce(title,'') || ' ' || content)`.

- **CHECK constraints on `dreams`:**
  - `type_tags ⊆ {Nightmare, Recurring, Lucid, Vivid, Fragment}`
  - `emotion_tags ⊆ {Peaceful, Anxious, Confused, Inspired, Heavy}`

- **Reference tables:** `tarot_cards` (22 rows) and `subscription_plans` (3 rows) are seeded via `npm run seed:run:relational` and are read-only at runtime.
