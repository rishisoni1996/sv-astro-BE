# Lumen — Backend API Specification

**Handoff document for a new Claude session to implement end-to-end.**

---

## Context

**Lumen** is an AI-powered dream-interpretation, tarot, and astrology mobile app (Flutter frontend already complete). This document specifies the complete NestJS backend: 8 feature modules, all endpoints, database schema, entity/DTO shapes, business rules, and auth guards.

The boilerplate is a **NestJS modular monolith** with TypeORM + PostgreSQL, JWT auth, class-validator/transformer, Swagger, and the domain-driven folder layout shown below. Do not deviate from that architecture.

---

## Global Architecture Reminders

```
src/
├── main.ts                  # Bootstrap: ValidationPipe, ClassSerializerInterceptor, versioning
├── app.module.ts
├── config/                  # registerAs() configs with EnvironmentVariablesValidator
└── <module>/
    ├── <module>.module.ts
    ├── <module>.controller.ts
    ├── <module>.service.ts
    ├── domain/
    │   └── <model>.ts           # API-facing domain model (@Expose/@Exclude)
    ├── dto/
    │   ├── create-*.dto.ts
    │   └── update-*.dto.ts
    └── infrastructure/
        └── persistence/
            └── relational/
                ├── entities/   *.entity.ts    (TypeORM, DB-facing)
                ├── repositories/ *.repository.ts
                └── mappers/    *.mapper.ts    (domain ↔ entity)
```

- API prefix: `/api`, URI versioning `v1`. All routes below are under `/api/v1/`.
- Auth: `JwtAuthGuard` (access token) on all protected routes unless noted.
- Validation: `ValidationPipe({ whitelist: true, transform: true })` — returns 422 on failure.
- Swagger: annotate every DTO and controller with `@ApiProperty` / `@ApiOperation`.
- Soft-deletes: use `@DeleteDateColumn()` on entities where noted.

---

## Module 1 — `auth`

### Purpose

Registration (via onboarding quiz), Google/Apple OAuth, email magic-link or OTP, JWT issue/refresh, logout.

### Entities

**`users` table** (core identity, shared with users module)

```
id            uuid PK default gen_random_uuid()
email         varchar(255) unique nullable
name          varchar(100)
initials      varchar(4) generated or stored
provider      enum('email','google','apple') default 'email'
provider_id   varchar(255) nullable          -- Google/Apple subject ID
role          enum('user','admin') default 'user'
is_active     boolean default true
hash          varchar nullable               -- bcrypt password hash (email flow)
created_at    timestamptz default now()
updated_at    timestamptz default now()
deleted_at    timestamptz nullable           -- soft delete
```

**`auth_tokens` table** (refresh token store)

```
id            uuid PK
user_id       uuid FK → users.id
token_hash    varchar(500)   -- hashed refresh token
expires_at    timestamptz
created_at    timestamptz default now()
```

### DTOs

```typescript
// dto/auth-register.dto.ts
class AuthRegisterDto {
  @IsEmail()
  email: string;

  @IsString()
  @MinLength(2)
  name: string;

  @IsOptional()
  @IsString()
  password?: string;
}

// dto/auth-login.dto.ts
class AuthLoginDto {
  @IsEmail() email: string;
  @IsString() password: string;
}

// dto/auth-google.dto.ts
class AuthGoogleDto {
  @IsString() idToken: string; // Firebase ID token or Google ID token
}

// dto/auth-apple.dto.ts
class AuthAppleDto {
  @IsString() identityToken: string;
  @IsOptional() @IsString() fullName?: string;
}

// dto/auth-refresh.dto.ts
class AuthRefreshDto {
  @IsString() refreshToken: string;
}
```

### Domain Model

```typescript
// domain/auth-response.ts
class AuthResponse {
  @Expose() accessToken: string;
  @Expose() refreshToken: string;
  @Expose() tokenExpires: number; // unix ms
  @Expose() user: UserDomain; // from users module
}
```

### Endpoints

| Method | Path                | Guard      | Description                                                       |
| ------ | ------------------- | ---------- | ----------------------------------------------------------------- |
| POST   | `/auth/register`    | none       | Email registration. Returns AuthResponse.                         |
| POST   | `/auth/login/email` | none       | Email + password login. Returns AuthResponse.                     |
| POST   | `/auth/google`      | none       | Exchange Google ID token → AuthResponse. Create user if new.      |
| POST   | `/auth/apple`       | none       | Exchange Apple identity token → AuthResponse. Create user if new. |
| POST   | `/auth/refresh`     | JwtRefresh | Rotate refresh token. Returns AuthResponse.                       |
| POST   | `/auth/logout`      | Jwt        | Invalidate refresh token. Returns 204.                            |
| DELETE | `/auth/me`          | Jwt        | Soft-delete user account. Returns 204.                            |

### Business Logic

- `POST /auth/register`: hash password with bcrypt(10), generate access + refresh JWTs, store hashed refresh in `auth_tokens`.
- `POST /auth/google` / `/auth/apple`: verify the identity token (use `google-auth-library` / apple's JWK endpoint), upsert user by `provider + provider_id`.
- `POST /auth/refresh`: verify refresh token against `auth_tokens`, rotate (delete old, insert new), return fresh pair.
- `POST /auth/logout`: delete row from `auth_tokens` matching the provided refresh token hash.
- Access token TTL: 15 minutes. Refresh token TTL: 30 days.

---

## Module 2 — `users`

### Purpose

User profile read/update, birth chart management, onboarding quiz completion.

### Entities

**`birth_charts` table**

```
id            uuid PK
user_id       uuid unique FK → users.id
sun_sign      varchar(20)    -- "scorpio"
moon_sign     varchar(20)    -- "cancer"
rising_sign   varchar(20)    -- "leo"
birth_date    date           -- 1995-03-14
birth_time    time nullable  -- 04:32:00
birth_location varchar(200)  -- "Brooklyn, NY"
created_at    timestamptz
updated_at    timestamptz
```

**`onboarding_answers` table**

```
id            uuid PK
user_id       uuid FK → users.id
step          smallint       -- 1, 3, 5, 8
answer_json   jsonb          -- raw quiz answer
created_at    timestamptz
```

### DTOs

```typescript
// dto/update-profile.dto.ts
class UpdateProfileDto {
  @IsOptional() @IsString() @MinLength(2) name?: string;
  @IsOptional() @IsString() @MaxLength(4) initials?: string;
}

// dto/upsert-birth-chart.dto.ts
class UpsertBirthChartDto {
  @IsString() sunSign: string;
  @IsString() moonSign: string;
  @IsString() risingSign: string;
  @IsDateString() birthDate: string; // "1995-03-14"
  @IsOptional() @IsString() birthTime?: string; // "04:32"
  @IsOptional() @IsString() birthLocation?: string;
}

// dto/submit-quiz-step.dto.ts
class SubmitQuizStepDto {
  @IsInt() @Min(1) @Max(8) step: number;
  @IsObject() answer: Record<string, unknown>;
}
```

### Domain Models

```typescript
// domain/user.ts
class UserDomain {
  @Expose() id: string;
  @Expose() name: string;
  @Expose() initials: string;
  @Expose() email: string | null;
  @Expose() role: string;
  @Expose() isPremium: boolean; // derived from active subscription
  @Expose() dreamCount: number; // computed count
  @Expose() memberSince: string; // formatted: "Mar 2026"
  @Expose() birthChart?: BirthChartDomain;
}

// domain/birth-chart.ts
class BirthChartDomain {
  @Expose() sunSign: string;
  @Expose() moonSign: string;
  @Expose() risingSign: string;
  @Expose() birthDate: string;
  @Expose() birthTime: string | null;
  @Expose() birthLocation: string | null;
}
```

### Endpoints

| Method | Path                         | Guard | Description                             |
| ------ | ---------------------------- | ----- | --------------------------------------- |
| GET    | `/users/me`                  | Jwt   | Full profile + birth chart + isPremium. |
| PATCH  | `/users/me`                  | Jwt   | Update name/initials.                   |
| GET    | `/users/me/birth-chart`      | Jwt   | Birth chart details.                    |
| PUT    | `/users/me/birth-chart`      | Jwt   | Create or replace birth chart.          |
| POST   | `/users/me/onboarding/:step` | Jwt   | Submit quiz answer for a step.          |

### Business Logic

- `GET /users/me`: join with `subscriptions` to set `isPremium = subscription.status IN ('active','trial') AND expires_at > now()`. Count dreams via subquery for `dreamCount`.
- `PUT /users/me/birth-chart`: Upsert (INSERT ... ON CONFLICT (user_id) DO UPDATE). After upsert, trigger async job to generate `SignReveal` descriptions (see guidance module).
- `POST /users/me/onboarding/5`: parse `birthDate` + `birthTime` + `birthLocation`, write to `birth_charts` in addition to storing raw JSON.
- `POST /users/me/onboarding/8`: same as step 5 for location, complete the birth chart.

---

## Module 3 — `dreams`

### Purpose

Full CRUD for dream journal entries. Tags stored as arrays. Supports pagination and date-range filtering.

### Entities

**`dreams` table**

```
id            uuid PK
user_id       uuid FK → users.id
title         varchar(300) nullable   -- extracted from transcript or user-supplied
content       text
type_tags     varchar(20)[]   -- ["Recurring","Vivid"]   CHECK each in allowed set
emotion_tags  varchar(20)[]   -- ["Peaceful","Anxious"]  CHECK each in allowed set
recorded_at   timestamptz default now()
created_at    timestamptz default now()
updated_at    timestamptz
deleted_at    timestamptz nullable    -- soft delete
```

Allowed `type_tags` values: `Nightmare | Recurring | Lucid | Vivid | Fragment`
Allowed `emotion_tags` values: `Peaceful | Anxious | Confused | Inspired | Heavy`

### DTOs

```typescript
// dto/create-dream.dto.ts
class CreateDreamDto {
  @IsOptional() @IsString() title?: string;

  @IsString() @MinLength(1) content: string;

  @IsArray()
  @IsString({ each: true })
  @IsIn(['Nightmare', 'Recurring', 'Lucid', 'Vivid', 'Fragment'], { each: true })
  typeTags: string[];

  @IsArray()
  @IsString({ each: true })
  @IsIn(['Peaceful', 'Anxious', 'Confused', 'Inspired', 'Heavy'], { each: true })
  emotionTags: string[];

  @IsOptional() @IsDateString() recordedAt?: string;
}

// dto/update-dream.dto.ts
class UpdateDreamDto extends PartialType(CreateDreamDto) {}

// dto/list-dreams-query.dto.ts
class ListDreamsQueryDto {
  @IsOptional() @IsIn(['all', 'week', 'month']) filter?: string;
  @IsOptional() @IsInt() @Min(1) page?: number;
  @IsOptional() @IsInt() @Min(1) @Max(100) limit?: number;
  @IsOptional() @IsString() search?: string; // full-text on title + content
}
```

### Domain Model

```typescript
// domain/dream.ts
class DreamDomain {
  @Expose() id: string;
  @Expose() title: string | null;
  @Expose() content: string;
  @Expose() typeTags: string[];
  @Expose() emotionTags: string[];
  @Expose() recordedAt: string; // ISO 8601
  @Expose() dateNumber: string; // "14"
  @Expose() dateDay: string; // "Sun"
  @Expose() timestamp: string; // "5:32 AM"
  @Expose() hasInterpretation: boolean;
}

// domain/dreams-page.ts
class DreamsPageDomain {
  @Expose() data: DreamDomain[];
  @Expose() total: number;
  @Expose() page: number;
  @Expose() limit: number;
}
```

### Endpoints

| Method | Path          | Guard | Description                                                  |
| ------ | ------------- | ----- | ------------------------------------------------------------ |
| POST   | `/dreams`     | Jwt   | Create dream. Returns DreamDomain.                           |
| GET    | `/dreams`     | Jwt   | List dreams (paginated). Query: filter, page, limit, search. |
| GET    | `/dreams/:id` | Jwt   | Single dream + interpretation summary.                       |
| PATCH  | `/dreams/:id` | Jwt   | Update title/content/tags.                                   |
| DELETE | `/dreams/:id` | Jwt   | Soft-delete. Returns 204.                                    |

### Business Logic

- Ownership: all dream queries add `WHERE user_id = :currentUserId`. 404 if not found or belongs to another user.
- `filter=week`: `recorded_at >= date_trunc('week', now())`.
- `filter=month`: `recorded_at >= date_trunc('month', now())`.
- `search`: `to_tsvector('english', title || ' ' || content) @@ plainto_tsquery(:q)`.
- `dateNumber`, `dateDay`, `timestamp` are derived in mapper from `recordedAt` (format with `date-fns`).
- `hasInterpretation`: join `dream_interpretations` and return boolean.
- After `POST /dreams`, optionally enqueue a background job for title extraction via AI if `title` is null.

---

## Module 4 — `interpretations`

### Purpose

AI-generated dream interpretation per dream. Premium sections are conditionally returned based on subscription. Uses async job pattern (queue + polling).

### Entities

**`dream_interpretations` table**

```
id             uuid PK
dream_id       uuid unique FK → dreams.id
core_meaning   text
what_reveals   text nullable   -- premium
guidance       text nullable   -- premium
status         enum('pending','processing','done','failed') default 'pending'
created_at     timestamptz
updated_at     timestamptz
```

**`dream_symbols` table**

```
id             uuid PK
interpretation_id uuid FK → dream_interpretations.id
emoji          varchar(10)
name           varchar(100)
occurrence_count smallint
last_seen_label varchar(50)   -- "Last night", "2d ago"
sort_order     smallint
```

### DTOs

```typescript
// dto/create-interpretation.dto.ts
class CreateInterpretationDto {
  // no body required — triggers AI generation for the given dreamId
}

// (response only)
class InterpretationStatusDto {
  @Expose() id: string;
  @Expose() status: 'pending' | 'processing' | 'done' | 'failed';
  @Expose() jobId?: string;
}
```

### Domain Model

```typescript
// domain/interpretation.ts
class InterpretationDomain {
  @Expose() id: string;
  @Expose() dreamId: string;
  @Expose() status: string;
  @Expose() coreMeaning: string | null;
  @Expose() whatReveals: string | null; // null if not premium
  @Expose() guidance: string | null; // null if not premium
  @Expose() symbols: SymbolDomain[];
  @Expose() isPremiumLocked: boolean; // true if user is not premium
}

// domain/symbol.ts
class SymbolDomain {
  @Expose() id: string;
  @Expose() emoji: string;
  @Expose() name: string;
  @Expose() occurrenceCount: number;
  @Expose() lastSeenLabel: string;
}
```

### Endpoints

| Method | Path                              | Guard | Description                                                                                              |
| ------ | --------------------------------- | ----- | -------------------------------------------------------------------------------------------------------- |
| POST   | `/dreams/:dreamId/interpretation` | Jwt   | Trigger AI generation. Returns 202 + `{jobId, status:'pending'}`. Idempotent: if one exists, returns it. |
| GET    | `/dreams/:dreamId/interpretation` | Jwt   | Poll result. Returns InterpretationDomain. Hides `whatReveals`/`guidance` if not premium.                |

### Business Logic

- `POST`: Check if interpretation already exists. If `status='done'`, return it (idempotent). Otherwise enqueue a job (use `@nestjs/bull` or `@nestjs/schedule` for MVP; fallback to synchronous LLM call for simpler boilerplate).
- AI prompt (OpenAI / Claude API): send dream `content + typeTags + emotionTags`. Ask for JSON output: `{ coreMeaning, whatReveals, guidance, symbols: [{emoji, name}] }`.
- `GET`: check `user.isPremium`. If false, return `whatReveals = null`, `guidance = null`, `isPremiumLocked = true`. Always return `coreMeaning` and `symbols`.
- Symbol `occurrenceCount`: count how many of the current user's dreams contain the same symbol name (JOIN across `dream_symbols` → `dream_interpretations` → `dreams WHERE user_id = ?`).
- Symbol `lastSeenLabel`: computed from the most recent dream containing that symbol. Use `date-fns/formatDistanceToNow`.

---

## Module 5 — `patterns`

### Purpose

Aggregate analytics across a user's dreams: recurring symbols, emotional theme breakdown, AI-generated weekly summary. Premium-gated weekly summary.

### Entities

**`pattern_caches` table** (pre-computed per week)

```
id             uuid PK
user_id        uuid FK → users.id
week_start     date           -- Monday of the week
symbols_json   jsonb          -- [{emoji, name, count, lastSeenLabel}]
themes_json    jsonb          -- [{label, percent}]
summary        text nullable  -- AI weekly prose
status         enum('pending','done','failed') default 'pending'
generated_at   timestamptz
created_at     timestamptz
```

### Domain Model

```typescript
// domain/patterns.ts
class PatternsDomain {
  @Expose() weekStart: string;
  @Expose() recurringSymbols: SymbolDomain[];
  @Expose() themes: EmotionalThemeDomain[];
  @Expose() weeklySummary: string | null;      // null if not premium
  @Expose() isSummaryLocked: boolean;
}

// domain/emotional-theme.ts
class EmotionalThemeDomain {
  @Expose() label: string;
  @Expose() percent: number;
  @Expose() colorHex: string;   -- "#C9A7FF", "#7EE6D4", "#FFD89E", "#8B6BC4"
}
```

### Endpoints

| Method | Path                | Guard | Description                                                         |
| ------ | ------------------- | ----- | ------------------------------------------------------------------- |
| GET    | `/patterns`         | Jwt   | Current week's patterns. Triggers async generation if stale (>24h). |
| GET    | `/patterns/symbols` | Jwt   | All-time top symbols (no week constraint).                          |

### Business Logic

- **Symbols**: Query `dream_symbols` joined to user's dreams, group by `name`, count occurrences, order by count DESC, limit 10.
- **Emotional themes**: query `dreams.emotion_tags` for the rolling 30 days, unnest the array, group by value, compute percentage of total. Assign color: Anxious → `#C9A7FF`, Confused → `#7EE6D4`, Heavy → `#FFD89E`, Peaceful → `#8B6BC4`, Inspired → `#A9A5C7`.
- **Weekly summary**: if `pattern_caches` row for `week_start = date_trunc('week', now())` exists and status='done', return it. Otherwise enqueue AI generation: prompt is list of that week's dream titles + symbols. Result: prose paragraph. Store in `summary`.
- Premium gate: always compute symbols + themes (free). Return `weeklySummary = null` + `isSummaryLocked = true` if `!user.isPremium`.

---

## Module 6 — `readings`

### Purpose

Tarot card pulls and saved reading history. 22 Major Arcana seeded at startup. Daily card is deterministic per user per day (hash of userId + date mod 22). Saving a reading links it to the user's journal.

### Entities

**`tarot_cards` table** (seeded, read-only)

```
id             uuid PK
numeral        varchar(10)    -- "XVIII"
name           varchar(100)   -- "The Moon"
keywords       varchar(50)[]  -- ["INTUITION","DREAMS","ILLUSION"]
what_shows     text
applies_today  text           -- personalized stub (see business logic)
question       text           -- "A question to carry"
deck_name      varchar(100)   -- "Celestial · 22 Major Arcana"
sort_order     smallint       -- 0-21
```

**`tarot_readings` table**

```
id             uuid PK
user_id        uuid FK → users.id
card_id        uuid FK → tarot_cards.id
pulled_at      timestamptz default now()
saved          boolean default false
daily_date     date nullable  -- set if this was a daily pull
```

### DTOs

```typescript
// dto/pull-card.dto.ts
class PullCardDto {
  @IsOptional() @IsBoolean() daily?: boolean; // true = daily deterministic pull
}

// dto/save-reading.dto.ts
class SaveReadingDto {
  @IsUUID() readingId: string;
}
```

### Domain Model

```typescript
// domain/tarot-card.ts
class TarotCardDomain {
  @Expose() id: string;
  @Expose() numeral: string;
  @Expose() name: string;
  @Expose() keywords: string[];
  @Expose() whatShows: string;
  @Expose() appliesToToday: string;
  @Expose() questionToCarry: string;
  @Expose() deckName: string;
}

// domain/reading.ts
class ReadingDomain {
  @Expose() id: string;
  @Expose() card: TarotCardDomain;
  @Expose() pulledAt: string;
  @Expose() saved: boolean;
}
```

### Endpoints

| Method | Path                 | Guard | Description                                                                           |
| ------ | -------------------- | ----- | ------------------------------------------------------------------------------------- |
| GET    | `/readings/daily`    | Jwt   | Get today's deterministic card. Creates `tarot_readings` row if not yet pulled today. |
| POST   | `/readings/pull`     | Jwt   | Pull a random card (not daily). Returns ReadingDomain.                                |
| GET    | `/readings`          | Jwt   | Saved readings history, sorted by `pulledAt` DESC.                                    |
| PATCH  | `/readings/:id/save` | Jwt   | Toggle `saved = true` on a reading. Returns 200.                                      |
| DELETE | `/readings/:id`      | Jwt   | Delete a saved reading. Returns 204.                                                  |

### Business Logic

- **Daily card**: `cardIndex = hash(userId + date.toISOString().slice(0,10)) % 22` (use `crypto.createHash('sha256')`). Query `tarot_cards WHERE sort_order = cardIndex`. Upsert `tarot_readings` with `daily_date = today`.
- **applies_today**: stored in DB as a generic string. For a richer experience, this could be an AI-personalized field (see optional enhancement). For MVP, each card has a static `applies_today` seeded value.
- **Seed data**: on `onModuleInit`, check if `tarot_cards` count === 22. If not, insert all 22 Major Arcana with content verbatim from the HTML mockup (The Fool → The World). The Moon (XVIII) is the primary example in the mockup.

---

## Module 7 — `guidance`

### Purpose

Daily personalized astrological guidance for the user, based on their birth chart. Cached per user per day. Also generates the 3 `SignReveal` descriptions (Sun/Moon/Rising) used on the Cosmic screen.

### Entities

**`daily_guidance` table**

```
id             uuid PK
user_id        uuid FK → users.id
guidance_date  date
greeting       varchar(100)   -- "Morning, Maya"
headline       text           -- "Today asks you to listen..."
subtext        text           -- "Mercury is settling..."
astro_context  varchar(200)   -- free-form astrological note
status         enum('pending','done','failed') default 'done'
created_at     timestamptz
```

**`sign_reveals` table**

```
id             uuid PK
user_id        uuid FK → users.id
position       enum('sun','moon','rising')
sign_name      varchar(30)
description    text
generated_at   timestamptz
```

**Unique constraint** on `(user_id, guidance_date)` and `(user_id, position)`.

### Domain Model

```typescript
// domain/daily-guidance.ts
class DailyGuidanceDomain {
  @Expose() date: string;
  @Expose() dateBadge: string;       -- "Sun · Mar 14"
  @Expose() greeting: string;
  @Expose() headline: string;
  @Expose() subtext: string;
}

// domain/sign-reveal.ts
class SignRevealDomain {
  @Expose() position: 'sun' | 'moon' | 'rising';
  @Expose() signName: string;
  @Expose() label: string;           -- "YOUR SUN"
  @Expose() description: string;
}
```

### Endpoints

| Method | Path                                | Guard | Description                                                                                       |
| ------ | ----------------------------------- | ----- | ------------------------------------------------------------------------------------------------- |
| GET    | `/guidance/daily`                   | Jwt   | Today's guidance. Triggers AI gen if not yet cached today.                                        |
| GET    | `/guidance/sign-reveals`            | Jwt   | Three sign reveal cards (Sun/Moon/Rising). Generates once on first call after birth chart is set. |
| POST   | `/guidance/sign-reveals/regenerate` | Jwt   | Force-regenerate sign reveals (e.g. after birth chart update).                                    |

### Business Logic

- **Daily guidance**: check `daily_guidance WHERE user_id = ? AND guidance_date = today`. If found, return it. If not, generate synchronously using AI (prompt: user's sun/moon/rising signs + today's date). Store and return.
- **Sign reveals**: check `sign_reveals WHERE user_id = ?` — expect 3 rows. If missing, generate via AI for each sign. Prompt: `"Write a 2-sentence personal description for someone with {sign} {position} in the style of Lumen app."` Store and return.
- **dateBadge**: formatted as `"Sun · Mar 14"` using `date-fns('EEE · MMM d', today)`.
- **AI prompts**: wrap in `try/catch`, fall back to a static template per sign if AI fails.
- If user has no birth chart set, return generic (non-personalized) guidance with no sign data.

---

## Module 8 — `subscriptions`

### Purpose

Subscription plans listing, IAP receipt validation (Apple/Google), premium status tracking. Premium gates are enforced server-side in `interpretations` and `patterns` modules.

### Entities

**`subscription_plans` table** (seeded, read-only)

```
id       varchar(20) PK     -- "weekly", "monthly", "annual"
title    varchar(20)        -- "WEEKLY"
price    decimal(6,2)       -- 7.99
unit     varchar(5)         -- "/wk"
badge    varchar(30) nullable -- "SAVE 87%"
sort_order smallint
```

**`user_subscriptions` table**

```
id             uuid PK
user_id        uuid unique FK → users.id
plan_id        varchar(20) FK → subscription_plans.id
status         enum('trial','active','cancelled','expired') default 'trial'
provider       enum('apple','google','stripe') nullable
receipt_token  text nullable        -- raw receipt / purchase token
started_at     timestamptz default now()
trial_ends_at  timestamptz          -- started_at + 3 days
expires_at     timestamptz nullable
auto_renew     boolean default true
created_at     timestamptz
updated_at     timestamptz
```

### DTOs

```typescript
// dto/validate-iap.dto.ts
class ValidateIapDto {
  @IsIn(['apple', 'google', 'stripe']) provider: string;
  @IsString() receiptToken: string;
  @IsIn(['weekly', 'monthly', 'annual']) planId: string;
}

// dto/restore-purchases.dto.ts
class RestorePurchasesDto {
  @IsIn(['apple', 'google']) provider: string;
  @IsString() receiptToken: string;
}
```

### Domain Model

```typescript
// domain/subscription.ts
class SubscriptionDomain {
  @Expose() planId: string;
  @Expose() status: string;
  @Expose() isPremium: boolean;
  @Expose() trialEndsAt: string | null;
  @Expose() expiresAt: string | null;
  @Expose() planLabel: string;         -- "Premium · Annual"
  @Expose() renewsLabel: string;       -- "Renews March 14, 2027"
}

// domain/plan.ts
class SubscriptionPlanDomain {
  @Expose() id: string;
  @Expose() title: string;
  @Expose() price: string;        -- "$49.99"
  @Expose() unit: string;         -- "/yr"
  @Expose() badge: string | null;
}
```

### Endpoints

| Method | Path                      | Guard | Description                                   |
| ------ | ------------------------- | ----- | --------------------------------------------- |
| GET    | `/subscriptions/plans`    | none  | List all 3 plans (public).                    |
| GET    | `/subscriptions/me`       | Jwt   | Current user's subscription + `isPremium`.    |
| POST   | `/subscriptions/validate` | Jwt   | Validate IAP receipt, activate subscription.  |
| POST   | `/subscriptions/restore`  | Jwt   | Restore existing purchase from provider.      |
| DELETE | `/subscriptions/me`       | Jwt   | Cancel (set `auto_renew=false`). Returns 204. |

### Business Logic

- `isPremium`: `status IN ('trial','active') AND (expires_at IS NULL OR expires_at > now())`.
- `POST /subscriptions/validate` (Apple): call Apple receipt validation endpoint (`https://buy.itunes.apple.com/verifyReceipt`). On success, set `status='active'`, compute `expires_at` from `expires_date_ms`.
- `POST /subscriptions/validate` (Google): call Google Play Developer API `purchases.subscriptions.get`. On success, set `status='active'`, `expires_at = expiryTimeMillis`.
- **Trial start**: when a user first calls validate, if no existing subscription exists, set `status='trial'`, `trial_ends_at = now() + 3 days`, `expires_at = now() + 3 days`. Full activation happens after provider confirms payment.
- `renewsLabel`: format `expires_at` as `"Renews MMMM d, yyyy"` with `date-fns`.
- `planLabel`: concatenate plan title + period, e.g. `"Premium · Annual"`.

---

## Cross-Cutting Concerns

### Premium Access Guard

Create a shared helper (not a NestJS guard, just a utility function used in services):

```typescript
// utils/premium-check.ts
function assertPremium(user: UserDomain, feature: string): void {
  if (!user.isPremium) {
    throw new ForbiddenException(`${feature} requires a premium subscription.`);
  }
}
```

Use in interpretations and patterns services to gate `whatReveals`, `guidance`, and `weeklySummary`.

Alternatively, return the data with `isPremiumLocked: true` and nulled fields (current frontend pattern) — this is the preferred approach so the frontend can show the blur/unlock UI.

### AI Integration

All AI calls should go through a thin `AiService` (injectable):

```typescript
// ai/ai.service.ts
@Injectable()
class AiService {
  async generateInterpretation(
    content: string,
    typeTags: string[],
    emotionTags: string[],
  ): Promise<InterpretationAiResult>;
  async generateGuidance(
    sunSign: string,
    moonSign: string,
    risingSign: string,
    date: Date,
  ): Promise<GuidanceAiResult>;
  async generateSignReveal(sign: string, position: 'sun' | 'moon' | 'rising'): Promise<string>;
  async generateWeeklySummary(dreamTitles: string[], symbols: string[]): Promise<string>;
}
```

Use Anthropic SDK (or OpenAI). All responses must be parsed via JSON schema validation before storing.

### Error Responses

Use NestJS built-in `HttpException` subclasses. Standard error shape:

```json
{ "statusCode": 403, "message": "Interpretation requires premium.", "error": "Forbidden" }
```

### Database Migrations

Use TypeORM migrations (`typeorm migration:generate`, `migration:run`). Never use `synchronize: true` in production. Create separate migration files for:

1. Core tables (users, auth_tokens, birth_charts)
2. Dreams + interpretations + symbols
3. Tarot cards + readings
4. Guidance + sign reveals
5. Subscriptions + plans
6. Patterns cache
7. Seed data (tarot cards, subscription plans)

---

## Implementation Order

Build in this sequence so each step is independently testable:

1. **Auth module** (register + login + JWT) — unblocks everything.
2. **Users module** (profile + birth chart).
3. **Dreams module** (CRUD + tags).
4. **Interpretations module** (AI generation + premium gate).
5. **Patterns module** (aggregation queries + AI summary).
6. **Guidance module** (daily AI + sign reveals).
7. **Readings module** (tarot deck seed + daily card + saves).
8. **Subscriptions module** (plans + IAP validation).

---

## Seed Data

Place all seed logic in `src/database/seeds/relational/` following the boilerplate pattern. Run via `npm run seed:run:relational`. Seeds are idempotent — check existence before inserting.

### `subscription_plans` — 3 rows

```typescript
// src/database/seeds/relational/subscription-plan/subscription-plan-seed.service.ts
const plans = [
  { id: 'weekly', title: 'WEEKLY', price: 7.99, unit: '/wk', badge: null, sortOrder: 0 },
  { id: 'annual', title: 'ANNUAL', price: 49.99, unit: '/yr', badge: 'SAVE 87%', sortOrder: 1 },
  { id: 'monthly', title: 'MONTHLY', price: 14.99, unit: '/mo', badge: null, sortOrder: 2 },
];
```

### `tarot_cards` — 22 rows (all Major Arcana)

Deck name for all cards: `"Celestial · 22 Major Arcana"`.

```typescript
// src/database/seeds/relational/tarot-card/tarot-card-seed.service.ts
const tarotCards = [
  {
    sortOrder: 0,
    numeral: '0',
    name: 'The Fool',
    keywords: ['BEGINNINGS', 'INNOCENCE', 'SPONTANEITY'],
    whatShows:
      'The Fool stands at the edge of a cliff, unbothered. This is the card of pure potential — the moment before the story starts, when anything is still possible.',
    appliesToToday:
      'Something new is asking you to begin before you feel ready. The ground will catch you.',
    question: 'What would you start today if you stopped needing a guarantee?',
  },
  {
    sortOrder: 1,
    numeral: 'I',
    name: 'The Magician',
    keywords: ['WILLPOWER', 'SKILL', 'MANIFESTATION'],
    whatShows:
      'The Magician holds all four elements — everything needed is already on the table. This is the card of directed intention turning into real action.',
    appliesToToday:
      "You have more tools than you think. Today is a good day to act on what you've been planning.",
    question: 'What have you been waiting for permission to begin?',
  },
  {
    sortOrder: 2,
    numeral: 'II',
    name: 'The High Priestess',
    keywords: ['INTUITION', 'MYSTERY', 'INNER KNOWING'],
    whatShows:
      "The High Priestess sits between two pillars, guarding a threshold. She knows things that haven't been spoken. This is the card of what you sense before you can explain it.",
    appliesToToday:
      "The answer you've been looking for isn't outside you. Go quiet. It's already there.",
    question: 'What do you already know, even without the evidence?',
  },
  {
    sortOrder: 3,
    numeral: 'III',
    name: 'The Empress',
    keywords: ['ABUNDANCE', 'CREATION', 'NURTURE'],
    whatShows:
      "The Empress is surrounded by growing things. She doesn't force — she tends. This is the card of creativity that comes from care, not urgency.",
    appliesToToday:
      "What you've been cultivating quietly is further along than you think. Give it attention today.",
    question: 'What in your life needs tending rather than fixing?',
  },
  {
    sortOrder: 4,
    numeral: 'IV',
    name: 'The Emperor',
    keywords: ['AUTHORITY', 'STRUCTURE', 'STABILITY'],
    whatShows:
      'The Emperor sits on a stone throne. He has built something that holds. This is the card of creating order from chaos — not to control, but to protect.',
    appliesToToday:
      "Where you've felt scattered, choose one thing and make it solid. Structure is a form of care.",
    question: 'What would stability actually look like for you right now?',
  },
  {
    sortOrder: 5,
    numeral: 'V',
    name: 'The Hierophant',
    keywords: ['TRADITION', 'GUIDANCE', 'BELIEF'],
    whatShows:
      'The Hierophant passes down what he knows. This is the card of received wisdom — the value of lineage, of learning from those who came before.',
    appliesToToday:
      "There's wisdom near you that you may be underestimating. Consider who or what you've been dismissing.",
    question: 'Where in your life might tradition be worth listening to?',
  },
  {
    sortOrder: 6,
    numeral: 'VI',
    name: 'The Lovers',
    keywords: ['CHOICE', 'ALIGNMENT', 'CONNECTION'],
    whatShows:
      "The Lovers stand at a crossroads. This card isn't only about romance — it's about choosing in alignment with your deepest values, even when the choice is hard.",
    appliesToToday:
      "A decision is waiting. It won't make itself. Ask which path you'd choose if you weren't afraid.",
    question: 'What are you choosing, and does it reflect who you want to be?',
  },
  {
    sortOrder: 7,
    numeral: 'VII',
    name: 'The Chariot',
    keywords: ['DETERMINATION', 'CONTROL', 'VICTORY'],
    whatShows:
      "The Chariot is pulled by two opposing forces, mastered by will. This is the card of moving forward not because obstacles are gone — but because you've learned to steer.",
    appliesToToday:
      'You have more forward momentum than you feel. The resistance is normal. Keep driving.',
    question: 'What are you steering past right now that deserves acknowledgement?',
  },
  {
    sortOrder: 8,
    numeral: 'VIII',
    name: 'Strength',
    keywords: ['COURAGE', 'COMPASSION', 'INNER POWER'],
    whatShows:
      "Strength shows a figure gently taming a lion. This isn't force — it's the quiet power of meeting something wild with steady hands.",
    appliesToToday:
      "Gentleness with yourself is not weakness. Where you've been harsh, try patience instead.",
    question: 'What would you handle differently if you led with compassion instead of control?',
  },
  {
    sortOrder: 9,
    numeral: 'IX',
    name: 'The Hermit',
    keywords: ['SOLITUDE', 'REFLECTION', 'INNER GUIDANCE'],
    whatShows:
      'The Hermit walks alone with a lantern, lighting only the next step. This is the card of necessary withdrawal — going inward to find what noise was drowning out.',
    appliesToToday:
      "The answer you're looking for won't come from outside input right now. Make space for silence.",
    question: 'What would you hear if you got quiet enough to listen?',
  },
  {
    sortOrder: 10,
    numeral: 'X',
    name: 'Wheel of Fortune',
    keywords: ['CYCLES', 'CHANGE', 'FATE'],
    whatShows:
      'The Wheel turns without asking permission. This card is about cycles — the reminder that what rises falls, and what falls rises again.',
    appliesToToday:
      'Whatever feels stuck is already in motion. You may not control the wheel, but you can decide how you meet the turn.',
    question: 'What cycle in your life is completing right now?',
  },
  {
    sortOrder: 11,
    numeral: 'XI',
    name: 'Justice',
    keywords: ['TRUTH', 'FAIRNESS', 'CAUSE AND EFFECT'],
    whatShows:
      "Justice holds scales and a sword. This is the card of honest reckoning — things falling into place not through luck, but through alignment with what's true.",
    appliesToToday:
      "Something you've been uncertain about is becoming clearer. Trust what you see, even if it complicates things.",
    question: 'What truth have you been avoiding that deserves to be faced?',
  },
  {
    sortOrder: 12,
    numeral: 'XII',
    name: 'The Hanged Man',
    keywords: ['SUSPENSION', 'SURRENDER', 'NEW PERSPECTIVE'],
    whatShows:
      'The Hanged Man is suspended upside down — and at peace. This is the card of voluntary pause, the wisdom that comes from stopping rather than pushing.',
    appliesToToday:
      "The delay you've been fighting might be exactly where the insight lives. Let yourself be still.",
    question:
      'What might you see if you looked at your situation from a completely different angle?',
  },
  {
    sortOrder: 13,
    numeral: 'XIII',
    name: 'Death',
    keywords: ['ENDINGS', 'TRANSITION', 'TRANSFORMATION'],
    whatShows:
      'Death rides slowly, and nothing is the same after. But destruction here is always a clearing — endings that make space for what was waiting to begin.',
    appliesToToday: "Something is completing. Let it. The grief is real, and so is what's coming.",
    question: 'What are you holding onto past its time?',
  },
  {
    sortOrder: 14,
    numeral: 'XIV',
    name: 'Temperance',
    keywords: ['BALANCE', 'PATIENCE', 'MODERATION'],
    whatShows:
      'Temperance pours water between two cups — back and forth, endlessly calibrating. This is the card of long patience, of finding the mix that actually works.',
    appliesToToday:
      "The extremes aren't serving you. Today, look for the middle path — not compromise, but integration.",
    question: 'Where are you out of balance, and what would true equilibrium feel like?',
  },
  {
    sortOrder: 15,
    numeral: 'XV',
    name: 'The Devil',
    keywords: ['SHADOW', 'BONDAGE', 'MATERIALISM'],
    whatShows:
      'Two figures stand chained, but the chains are loose. They could leave. The Devil is the card of what holds us through habit, fear, or attachment — not force.',
    appliesToToday:
      "Notice what you're giving power to today that doesn't deserve it. The chain isn't locked.",
    question: 'What are you staying in that you could actually leave?',
  },
  {
    sortOrder: 16,
    numeral: 'XVI',
    name: 'The Tower',
    keywords: ['UPHEAVAL', 'REVELATION', 'SUDDEN CHANGE'],
    whatShows:
      "The Tower is struck by lightning and people fall. This is the card of sudden collapse — but only of what was never real. What's true survives.",
    appliesToToday:
      'Something may shake loose today. Trust that what remains after the disruption is what was always worth keeping.',
    question: 'What false structure in your life is overdue for collapse?',
  },
  {
    sortOrder: 17,
    numeral: 'XVII',
    name: 'The Star',
    keywords: ['HOPE', 'RENEWAL', 'SERENITY'],
    whatShows:
      "After the storm, a figure kneels by still water under a sky full of stars. This is the card of hope that doesn't need proof — the quiet knowing that things will come right.",
    appliesToToday:
      'Rest is not retreat. Receiving is not weakness. Let something restore you today.',
    question:
      'What would it feel like to believe, even without certainty, that things are moving toward good?',
  },
  {
    sortOrder: 18,
    numeral: 'XVIII',
    name: 'The Moon',
    keywords: ['INTUITION', 'DREAMS', 'ILLUSION'],
    whatShows:
      'The Moon is the card of the unseen. It speaks to what you sense before you can explain, what pulls at you before you understand why.',
    appliesToToday:
      'Your gut has been trying to tell you something about the week ahead. Today, stop asking for proof. Listen.',
    question: 'What do you already know, even without the evidence?',
  },
  {
    sortOrder: 19,
    numeral: 'XIX',
    name: 'The Sun',
    keywords: ['JOY', 'CLARITY', 'VITALITY'],
    whatShows:
      "The Sun shines without condition. A child rides freely beneath it. This is the card of uncomplicated joy — the kind you don't have to earn.",
    appliesToToday: "Something genuinely good is available to you today. Don't overthink it.",
    question: "Where in your life is the sun already shining that you've forgotten to notice?",
  },
  {
    sortOrder: 20,
    numeral: 'XX',
    name: 'Judgement',
    keywords: ['REFLECTION', 'CALLING', 'ABSOLUTION'],
    whatShows:
      "Figures rise in response to a call. Judgement is not punishment — it's the moment of honest reckoning that frees you from what you've been dragging.",
    appliesToToday:
      'What verdict have you been withholding from yourself? You already know. Say it.',
    question: "What would you do differently if you'd fully forgiven yourself for the past?",
  },
  {
    sortOrder: 21,
    numeral: 'XXI',
    name: 'The World',
    keywords: ['COMPLETION', 'INTEGRATION', 'WHOLENESS'],
    whatShows:
      'A figure dances at the center of a wreath. The World is the card of full arrival — not perfection, but completion. The cycle done. The lesson integrated.',
    appliesToToday:
      'Something in you has come full circle. Take a moment to acknowledge it before moving on.',
    question: 'What chapter of your story deserves a proper ending before you begin the next?',
  },
];
```

---

## Environment Variables Required

```bash
# Database
DATABASE_HOST=
DATABASE_PORT=5432
DATABASE_NAME=lumen
DATABASE_USER=
DATABASE_PASSWORD=

# JWT
AUTH_JWT_SECRET=
AUTH_JWT_TOKEN_EXPIRES_IN=900    # 15 min in seconds
AUTH_REFRESH_SECRET=
AUTH_REFRESH_TOKEN_EXPIRES_IN=2592000  # 30 days

# AI
OPENAI_API_KEY=   (or ANTHROPIC_API_KEY=)
AI_MODEL=claude-sonnet-4-6   (or gpt-4o)

# Apple IAP
APPLE_IAP_SHARED_SECRET=

# Google Play
GOOGLE_PLAY_SERVICE_ACCOUNT_JSON=

# Optional (from boilerplate)
FILE_DRIVER=local
MAIL_HOST=
FIREBASE_PROJECT_ID=
```

---

## Verification Checklist (for implementing Claude session)

After implementation, verify each module with these curl commands:

```bash
# 1. Register
POST /api/v1/auth/register  {"email":"test@lumen.app","name":"Test User","password":"Passw0rd!"}
# → 201 {accessToken, refreshToken, user}

# 2. Complete birth chart
PUT /api/v1/users/me/birth-chart  {"sunSign":"scorpio","moonSign":"cancer","risingSign":"leo","birthDate":"1995-03-14","birthTime":"04:32","birthLocation":"Brooklyn, NY"}
# → 200 {sunSign,moonSign,...}

# 3. Create dream
POST /api/v1/dreams  {"content":"I was in a house...","typeTags":["Recurring"],"emotionTags":["Peaceful"]}
# → 201 {id, dateNumber, dateDay,...}

# 4. Generate interpretation
POST /api/v1/dreams/:id/interpretation
# → 202 {status:'pending'} (or 200 {coreMeaning,...} if synchronous)

# 5. List dreams with filter
GET /api/v1/dreams?filter=week&page=1&limit=20
# → 200 {data:[...], total, page, limit}

# 6. Patterns
GET /api/v1/patterns
# → 200 {recurringSymbols, themes, weeklySummary (null if not premium)}

# 7. Daily guidance
GET /api/v1/guidance/daily
# → 200 {dateBadge, greeting, headline, subtext}

# 8. Sign reveals
GET /api/v1/guidance/sign-reveals
# → 200 [{position:'sun', signName:'Scorpio', description:'...'}]

# 9. Daily tarot
GET /api/v1/readings/daily
# → 200 {id, card:{numeral:'XVIII', name:'The Moon',...}, pulledAt, saved:false}

# 10. Subscription plans
GET /api/v1/subscriptions/plans
# → 200 [{id:'weekly', price:'$7.99', unit:'/wk'}, ...]

# 11. Subscription status
GET /api/v1/subscriptions/me
# → 200 {planId, status, isPremium, expiresAt, renewsLabel}

# Run flutter analyze equivalent:
npm run lint && npm run test
```

`flutter analyze` equivalent: all `npm run lint` must pass zero errors. All module unit tests (service layer) must pass.
