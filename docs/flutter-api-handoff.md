# Lumen Backend — Flutter API Handoff

Drop this file in your Flutter project and implement against it. Every endpoint below reflects what's actually shipped in the NestJS backend (controllers verified against source).

---

## 1. Global Conventions (read first)

### Base URL & versioning

```
{BASE_URL}/api/v1/<resource>
```

- Global prefix: `/api`
- URI versioning: `v1` (e.g. `/api/v1/auth/register`)
- Default port: `3000` (configurable via `APP_PORT`)
- Swagger UI: `{BASE_URL}/docs`

### Headers

| Header          | Value                          | When                                                    |
| --------------- | ------------------------------ | ------------------------------------------------------- |
| `Content-Type`  | `application/json`             | All requests with a body                                |
| `Accept`        | `application/json`             | Recommended on every request                            |
| `Authorization` | `Bearer <accessToken>`         | All protected routes (everything except auth/login/etc) |

CORS is enabled (any origin).

### Universal success envelope

**Every** successful response is wrapped by a global `TransformInterceptor`:

```json
{
  "data": <actual payload — object | array | null>,
  "message": "Success"
}
```

> Flutter implementation note: write a single `ApiResponse<T>` wrapper and unwrap `data` once at the network layer. Models below describe only the contents of `data`.

For `204 No Content` responses, the body is empty (no envelope).

### Universal error envelope

Thrown by the global `HttpExceptionFilter`:

```json
{
  "statusCode": 422,
  "message": "Validation failed",
  "error": {
    "message": ["email must be an email", "password must be longer than or equal to 8 characters"],
    "error": "Unprocessable Entity",
    "statusCode": 422
  },
  "timestamp": "2026-04-26T10:34:11.482Z"
}
```

Notes:
- `error` may be a string OR an object whose `message` is an array of validator errors. Flutter should accept both.
- HTTP status codes used by the API:

| Code | Meaning                                                              |
| ---- | -------------------------------------------------------------------- |
| 200  | OK — normal success                                                  |
| 201  | Created — `POST /auth/register`, `POST /dreams` (default Nest 201)   |
| 204  | No Content — logout, deletes, cancel subscription                    |
| 400  | Bad request (e.g. email already registered)                          |
| 401  | Unauthorized — missing/expired/invalid JWT, bad credentials          |
| 403  | Forbidden — premium-gated content (handled in-band, see below)       |
| 404  | Not found — resource doesn't exist or doesn't belong to this user    |
| 422  | Validation failure (DTO rejected) — `forbidNonWhitelisted: true`     |
| 500  | Server error                                                         |

### Validation rules to know
- `ValidationPipe` runs with `whitelist: true`, `forbidNonWhitelisted: true`, `transform: true`.
- Sending unknown fields → 422 (don't include extra properties).
- Invalid UUID path params → 400 from `ParseUUIDPipe`.

### Auth model
- **Access token** (JWT): sent in `Authorization: Bearer <...>`. TTL is short (configurable via `AUTH_JWT_TOKEN_EXPIRES_IN`, default 15 min).
- **Refresh token** (JWT): sent **in the request body** as `{ "refreshToken": "..." }` to `/auth/refresh` and `/auth/logout`. Not in a header. TTL is long (configurable, default 30 days). Single-use — every refresh rotates and invalidates the previous token (server stores `bcrypt(refreshToken)` and deletes on rotation).
- `tokenExpires` is a **unix epoch in milliseconds** representing the access token's expiry — use it client-side to schedule a refresh.
- On 401 from any protected endpoint: call `POST /auth/refresh`. If that also 401s, log the user out.

### Premium gating (in-band, NOT 403)
For protected premium content the API does **not** throw 403. Instead it returns the resource with the premium fields nulled and a boolean flag:
- `interpretations`: returns `whatReveals: null`, `guidance: null`, `isPremiumLocked: true` for non-premium users.
- `patterns`: returns `weeklySummary: null`, `isSummaryLocked: true` for non-premium users.

Use these flags to render the blur/unlock UI.

---

## 2. Module — `auth`

Base: `/api/v1/auth`

### Shared models

```dart
// AuthResponse (data payload of every auth endpoint that returns one)
class AuthResponse {
  String accessToken;
  String refreshToken;
  int tokenExpires;   // unix ms — access token expiry
  User user;          // see users module
}
```

### POST `/api/v1/auth/register`
Email registration. Auth: **none**.

**Request body**
```json
{
  "email": "user@example.com",       // required, valid email
  "name": "Maya Chen",               // required, min 2 chars
  "password": "Passw0rd!"            // optional, if provided min 8 chars
}
```

**Success** — `201 Created`
```json
{
  "data": {
    "accessToken": "eyJhbGciOi...",
    "refreshToken": "eyJhbGciOi...",
    "tokenExpires": 1745764451000,
    "user": { /* User — see /users/me */ }
  },
  "message": "Success"
}
```

**Errors**
| Status | When                                               |
| ------ | -------------------------------------------------- |
| 400    | Email already registered                           |
| 422    | Validation failure (bad email, name < 2, pwd < 8)  |

---

### POST `/api/v1/auth/login/email`
Email + password login. Auth: **none**.

**Request body**
```json
{
  "email": "user@example.com",
  "password": "Passw0rd!"
}
```

**Success** — `200 OK` — `data: AuthResponse`

**Errors**
| Status | When                                                 |
| ------ | ---------------------------------------------------- |
| 401    | Invalid credentials, password mismatch, or disabled  |
| 422    | Missing/invalid email or password format             |

---

### POST `/api/v1/auth/google`
Exchange a Google ID token for a Lumen session. Creates user on first login. Auth: **none**.

**Request body**
```json
{
  "idToken": "<Google or Firebase ID token>"
}
```

**Success** — `200 OK` — `data: AuthResponse`

**Errors**
| Status | When                                                   |
| ------ | ------------------------------------------------------ |
| 401    | Token invalid, audience mismatch, or Google not configured server-side |

---

### POST `/api/v1/auth/apple`
Exchange an Apple identity token for a Lumen session. Auth: **none**.

**Request body**
```json
{
  "identityToken": "<Apple identity token>",
  "fullName": "Maya Chen"   // optional — Apple only sends name on first login
}
```

**Success** — `200 OK` — `data: AuthResponse`

**Errors**
| Status | When                                                              |
| ------ | ----------------------------------------------------------------- |
| 401    | Malformed token, missing kid, signature/audience/issuer mismatch  |

> Implementation tip: cache `fullName` on Flutter side after the very first Apple login — Apple only returns it once.

---

### POST `/api/v1/auth/refresh`
Rotate refresh token, issue a fresh pair. Auth: **refresh token in body**.

**Request body**
```json
{
  "refreshToken": "<long-lived refresh JWT>"
}
```

**Success** — `200 OK` — `data: AuthResponse` (new accessToken AND new refreshToken — old refresh is now invalid).

**Errors**
| Status | When                                                          |
| ------ | ------------------------------------------------------------- |
| 401    | Refresh token missing, expired, malformed, or already rotated |

---

### POST `/api/v1/auth/logout`
Invalidate one refresh token. Auth: **access token in `Authorization` header AND refresh token in body**.

**Request body**
```json
{ "refreshToken": "<refresh JWT>" }
```

**Success** — `204 No Content` (empty body)

**Errors** — 401 if access token missing/invalid.

---

### DELETE `/api/v1/auth/me`
Soft-delete the current user account. Wipes all refresh tokens. Auth: **Bearer**.

**Request body** — none

**Success** — `204 No Content`

**Errors** — 401 (no token) / 404 (user already deleted).

---

## 3. Module — `users`

Base: `/api/v1/users/me`. **All routes require Bearer access token.**

### Shared models

```dart
class User {
  String id;                  // uuid
  String name;
  String initials;            // up to 4 chars, e.g. "MC"
  String? email;              // null possible (Apple anonymous)
  String role;                // "user" | "admin"
  bool isPremium;
  int dreamCount;
  String memberSince;         // formatted, e.g. "Mar 2026"
  BirthChart? birthChart;     // present only if user has set one
}

class BirthChart {
  String sunSign;             // lowercase, e.g. "scorpio"
  String moonSign;
  String risingSign;
  String birthDate;           // "1995-03-14"
  String? birthTime;          // "04:32" or null
  String? birthLocation;      // "Brooklyn, NY" or null
}
```

---

### GET `/api/v1/users/me`
Current user profile + birth chart + premium flag.

**Success** — `200 OK` — `data: User`

**Errors** — 401.

---

### PATCH `/api/v1/users/me`
Update name and/or initials.

**Request body** (both optional, send only what's changing)
```json
{
  "name": "Maya Chen",        // optional, min 2 chars
  "initials": "MC"            // optional, max 4 chars
}
```

**Success** — `200 OK` — `data: User` (updated)

**Errors** — 401, 422.

---

### GET `/api/v1/users/me/birth-chart`
Read birth chart only.

**Success** — `200 OK` — `data: BirthChart`

**Errors**
| Status | When                       |
| ------ | -------------------------- |
| 404    | Birth chart not yet set    |
| 401    | No / invalid token         |

---

### PUT `/api/v1/users/me/birth-chart`
Create or replace the birth chart.

**Request body**
```json
{
  "sunSign": "scorpio",       // required
  "moonSign": "cancer",       // required
  "risingSign": "leo",        // required
  "birthDate": "1995-03-14",  // required, ISO date
  "birthTime": "04:32",       // optional
  "birthLocation": "Brooklyn, NY"  // optional
}
```

**Success** — `200 OK` — `data: BirthChart`

**Errors** — 401, 422.

> Side effect: on first PUT, the server may async-generate the 3 sign-reveal cards (see guidance module). Don't depend on them being available in the same response.

---

### POST `/api/v1/users/me/onboarding/:step`
Submit an onboarding quiz answer for one of the 8 steps.

**Path parameter** — `:step` integer 1–8.

**Request body**
```json
{
  "step": 5,                       // 1..8 — must match the path param
  "answer": { "anyShape": true }   // free-form JSON object
}
```

**Success** — `200 OK`
```json
{ "data": { "success": true }, "message": "Success" }
```

**Errors** — 401, 422 (step out of range, answer not an object).

---

## 4. Module — `dreams`

Base: `/api/v1/dreams`. **All routes require Bearer access token.** All queries are scoped to the current user — a dream owned by another user returns 404.

### Tag enums (must match exactly, case-sensitive)

```dart
const dreamTypeTags     = ['Nightmare', 'Recurring', 'Lucid', 'Vivid', 'Fragment'];
const dreamEmotionTags  = ['Peaceful', 'Anxious', 'Confused', 'Inspired', 'Heavy'];
```

### Shared models

```dart
class Dream {
  String id;                  // uuid
  String? title;
  String content;
  List<String> typeTags;      // subset of dreamTypeTags
  List<String> emotionTags;   // subset of dreamEmotionTags
  String recordedAt;          // ISO 8601
  String dateNumber;          // "14"  (derived for UI)
  String dateDay;             // "Sun" (derived)
  String timestamp;           // "5:32 AM" (derived)
  bool hasInterpretation;
}

class DreamsPage {
  List<Dream> data;
  int total;
  int page;
  int limit;
}
```

---

### POST `/api/v1/dreams`
Create a dream.

**Request body**
```json
{
  "title": "Optional — extracted later if null",
  "content": "I was in a house...",         // required, min length 1
  "typeTags": ["Recurring"],                 // required (allow empty array)
  "emotionTags": ["Peaceful"],               // required (allow empty array)
  "recordedAt": "2026-04-25T05:32:00Z"      // optional — defaults to now()
}
```

**Success** — `201 Created` — `data: Dream`

**Errors** — 401, 422 (invalid tag value, missing content, bad date).

---

### GET `/api/v1/dreams`
Paginated list. All query params optional.

**Query parameters**
| Name     | Type                    | Notes                                    |
| -------- | ----------------------- | ---------------------------------------- |
| `filter` | `'all' \| 'week' \| 'month'` | Default `all`                            |
| `page`   | int ≥ 1                 | Default 1                                |
| `limit`  | int 1–100               | Default 20                               |
| `search` | string                  | Postgres FTS over title + content        |

Example: `GET /api/v1/dreams?filter=week&page=1&limit=20&search=ocean`

**Success** — `200 OK` — `data: DreamsPage`
```json
{
  "data": {
    "data": [ /* Dream */ ],
    "total": 42,
    "page": 1,
    "limit": 20
  },
  "message": "Success"
}
```

**Errors** — 401, 422 (filter outside enum, page < 1, limit > 100).

---

### GET `/api/v1/dreams/:id`
Fetch a single dream by UUID.

**Success** — `200 OK` — `data: Dream`

**Errors** — 401, 400 (bad UUID), 404 (not found OR not owned).

---

### PATCH `/api/v1/dreams/:id`
Partial update — every field from create-DTO is optional.

**Request body** — any subset of CreateDream fields:
```json
{
  "title": "New title",
  "content": "Edited content",
  "typeTags": ["Vivid"],
  "emotionTags": ["Inspired"]
}
```

**Success** — `200 OK` — `data: Dream`

**Errors** — 401, 400, 404, 422.

---

### DELETE `/api/v1/dreams/:id`
Soft-delete.

**Success** — `204 No Content`

**Errors** — 401, 400, 404.

---

## 5. Module — `interpretations`

Base: `/api/v1/dreams/:dreamId/interpretation`. **Bearer required.** AI-generated; premium fields nulled for free users.

### Shared models

```dart
class Interpretation {
  String id;
  String dreamId;
  String status;                 // "pending" | "processing" | "done" | "failed"
  String? coreMeaning;           // free
  String? whatReveals;           // PREMIUM — null if !isPremium
  String? guidance;              // PREMIUM — null if !isPremium
  List<DreamSymbol> symbols;
  bool isPremiumLocked;          // true → render blur/unlock UI
}

class DreamSymbol {
  String id;
  String emoji;                  // "🌊"
  String name;                   // "Ocean"
  int occurrenceCount;           // count in this user's dreams
  String lastSeenLabel;          // "Last night", "2d ago"
}
```

---

### POST `/api/v1/dreams/:dreamId/interpretation`
Trigger generation (idempotent — returns existing one if already done).

**Request body** — none.

**Success** — `200 OK` — `data: Interpretation`. May return `status: "pending"` initially; poll the GET below until `status === "done"`.

**Errors** — 401, 400 (bad UUID), 404 (dream not found / not owned).

---

### GET `/api/v1/dreams/:dreamId/interpretation`
Fetch the current interpretation. Use this to poll while `status` is `pending` or `processing`.

**Success** — `200 OK` — `data: Interpretation`. Premium fields are nulled and `isPremiumLocked: true` if the user is not premium.

**Errors** — 401, 400, 404 (no interpretation yet → consider POSTing first).

---

## 6. Module — `patterns`

Base: `/api/v1/patterns`. **Bearer required.** Aggregated analytics over the user's dreams.

### Shared models

```dart
class Patterns {
  String weekStart;                          // ISO date — Monday of current week
  List<DreamSymbol> recurringSymbols;        // top symbols this week
  List<EmotionalTheme> themes;               // 30-day rolling distribution
  String? weeklySummary;                     // PREMIUM — null if !isPremium
  bool isSummaryLocked;                      // true → blur the summary card
}

class EmotionalTheme {
  String label;                              // "Peaceful", "Anxious", ...
  double percent;                            // 0..100
  String colorHex;                           // "#C9A7FF"
}
```

---

### GET `/api/v1/patterns`
Returns this week's patterns. Server triggers async regeneration when the cache is older than 24h — your call still returns the latest finalized cache (or empty if first time).

**Success** — `200 OK` — `data: Patterns`

**Errors** — 401.

---

### GET `/api/v1/patterns/symbols`
All-time top 10 symbols across the user's dreams (no week constraint).

**Success** — `200 OK` — `data: List<DreamSymbol>`

**Errors** — 401.

---

## 7. Module — `readings`

Base: `/api/v1/readings`. **Bearer required.** Tarot — 22 Major Arcana, daily deterministic per user.

### Shared models

```dart
class Reading {
  String id;
  TarotCard card;
  String pulledAt;     // ISO 8601
  bool saved;
}

class TarotCard {
  String id;
  String numeral;        // "XVIII"
  String name;           // "The Moon"
  List<String> keywords; // ["INTUITION","DREAMS","ILLUSION"]
  String whatShows;
  String appliesToToday;
  String questionToCarry;
  String deckName;       // "Celestial · 22 Major Arcana"
}
```

---

### GET `/api/v1/readings/daily`
Today's deterministic card. Idempotent — calling repeatedly the same day returns the same `Reading`.

**Success** — `200 OK` — `data: Reading`

**Errors** — 401.

---

### POST `/api/v1/readings/pull`
Pull a random non-daily card. Each call creates a new `Reading` row (initially `saved: false`).

**Request body** — none.

**Success** — `200 OK` — `data: Reading`

**Errors** — 401.

---

### GET `/api/v1/readings`
List of saved readings, sorted by `pulledAt` DESC.

**Success** — `200 OK` — `data: List<Reading>`

**Errors** — 401.

---

### PATCH `/api/v1/readings/:id/save`
Mark an existing reading as saved.

**Success** — `200 OK` — `data: Reading` (with `saved: true`)

**Errors** — 401, 400 (bad UUID), 404.

---

### DELETE `/api/v1/readings/:id`
Delete a reading.

**Success** — `204 No Content`

**Errors** — 401, 400, 404.

---

## 8. Module — `guidance`

Base: `/api/v1/guidance`. **Bearer required.** AI-generated daily astrology and Sun/Moon/Rising profile cards.

### Shared models

```dart
class DailyGuidance {
  String date;        // ISO date "2026-04-26"
  String dateBadge;   // "Sun · Apr 26"  (formatted for chip UI)
  String greeting;    // "Morning, Maya"
  String headline;    // "Today asks you to listen..."
  String subtext;     // "Mercury is settling..."
}

class SignReveal {
  String position;    // "sun" | "moon" | "rising"
  String signName;    // "Scorpio"
  String label;       // "YOUR SUN"
  String description; // 2-sentence personal description
}
```

---

### GET `/api/v1/guidance/daily`
Today's personalized guidance. Generated synchronously the first call of the day, cached afterwards.

**Success** — `200 OK` — `data: DailyGuidance`

**Errors** — 401. If the user has no birth chart, the response is generic (still 200, just non-personalized).

---

### GET `/api/v1/guidance/sign-reveals`
Three reveal cards (one each for Sun / Moon / Rising). Lazy-generated on first call after birth chart is set.

**Success** — `200 OK` — `data: List<SignReveal>` (length 3, may be empty if no birth chart)

**Errors** — 401.

---

### POST `/api/v1/guidance/sign-reveals/regenerate`
Force-regenerate the three reveals. Call after the user updates their birth chart.

**Request body** — none.

**Success** — `200 OK` — `data: List<SignReveal>` (freshly generated)

**Errors** — 401.

---

## 9. Module — `subscriptions`

Base: `/api/v1/subscriptions`. Mixed auth — `plans` is public, the rest require Bearer.

### Shared models

```dart
class SubscriptionPlan {
  String id;          // "weekly" | "monthly" | "annual"
  String title;       // "WEEKLY" | "MONTHLY" | "ANNUAL"
  String price;       // pre-formatted, e.g. "$49.99"
  String unit;        // "/wk" | "/mo" | "/yr"
  String? badge;      // "SAVE 87%" or null
}

class Subscription {
  String planId;          // "weekly" | "monthly" | "annual"
  String status;          // "trial" | "active" | "cancelled" | "expired"
  bool isPremium;
  String? trialEndsAt;    // ISO timestamp, null if not in trial
  String? expiresAt;      // ISO timestamp, null if never expires
  String planLabel;       // "Premium · Annual"
  String renewsLabel;     // "Renews March 14, 2027"
}
```

---

### GET `/api/v1/subscriptions/plans`
Public — list all 3 plans.

**Auth** — none.

**Success** — `200 OK` — `data: List<SubscriptionPlan>` (sorted by `sortOrder`)

**Errors** — 500 (unexpected only).

---

### GET `/api/v1/subscriptions/me`
Current user's subscription. **Bearer required.**

**Success** — `200 OK` — `data: Subscription | null` (null when user has never subscribed and is not in trial)

**Errors** — 401.

> Flutter implementation note: treat `data: null` as "free, no trial" — show paywall and use `User.isPremium = false` from `/users/me`.

---

### POST `/api/v1/subscriptions/validate`
Validate an IAP receipt and activate the subscription. **Bearer required.**

**Request body**
```json
{
  "provider": "apple",                       // "apple" | "google" | "stripe"
  "receiptToken": "<raw receipt or token>",  // required, non-empty string
  "planId": "annual"                         // "weekly" | "monthly" | "annual"
}
```

**Success** — `200 OK` — `data: Subscription` (typically `status: "active"` after successful validation).

**Errors**
| Status | When                                                |
| ------ | --------------------------------------------------- |
| 401    | No / invalid bearer                                 |
| 422    | Bad provider / planId / missing receiptToken        |
| 400    | Receipt validation failed at provider               |

---

### POST `/api/v1/subscriptions/restore`
Restore a previously purchased subscription. **Bearer required.** Use this on app reinstall / login on a new device.

**Request body**
```json
{
  "provider": "apple",                  // "apple" | "google" only (no stripe)
  "receiptToken": "<receipt or token>"
}
```

**Success** — `200 OK` — `data: Subscription`

**Errors** — 401, 422, 400 (no matching purchase at provider).

---

### DELETE `/api/v1/subscriptions/me`
Cancel auto-renew. The user keeps premium until `expiresAt`. **Bearer required.**

**Request body** — none.

**Success** — `204 No Content`

**Errors** — 401, 404 (no active subscription).

---

## 10. Recommended Flutter implementation order

> Section 11 below lists every payload validation rule per DTO — mirror those rules in Flutter forms so the user sees errors before a round-trip.


1. **HTTP client + envelope unwrap + error parser** — implement once, reuse everywhere.
2. **Auth flow** (`register`, `login/email`, refresh, persistent token storage, auto-refresh on 401).
3. **Users** (`/users/me`, birth chart upsert) → unblocks the home screen.
4. **Dreams** CRUD + list with pagination/search.
5. **Interpretations** with polling on `status`.
6. **Patterns** dashboard.
7. **Guidance** (daily card + sign reveals).
8. **Readings** (daily, pull, save, history).
9. **Subscriptions** (plans → IAP buy → validate → me).

---

## 11. Payload validation rules (mirror these client-side)

The backend rejects any payload that fails these rules with **HTTP 422** and a body whose `error.message` is an array of human-readable strings (one per failed rule). Implement matching Flutter-side validation so the user sees errors before a round-trip.

Global rules (apply to every body):
- **Unknown fields → 422.** `forbidNonWhitelisted: true` is set globally. Send only documented fields.
- **`Content-Type: application/json`** is required for any body.
- Path UUIDs are validated by `ParseUUIDPipe` → invalid UUID → **400**, not 422.
- Path integers are validated by `ParseIntPipe` → invalid int → **400**.

### `auth/register` — `AuthRegisterDto`
| Field      | Required | Type   | Rules                                                |
| ---------- | -------- | ------ | ---------------------------------------------------- |
| `email`    | yes      | string | Valid email format (`@IsEmail`)                      |
| `name`     | yes      | string | Min length 2 (`@MinLength(2)`)                       |
| `password` | no       | string | If sent, min length 8 (`@MinLength(8)`)              |

### `auth/login/email` — `AuthLoginDto`
| Field      | Required | Type   | Rules                |
| ---------- | -------- | ------ | -------------------- |
| `email`    | yes      | string | Valid email          |
| `password` | yes      | string | Non-empty string     |

### `auth/google` — `AuthGoogleDto`
| Field     | Required | Type   | Rules            |
| --------- | -------- | ------ | ---------------- |
| `idToken` | yes      | string | Non-empty string |

### `auth/apple` — `AuthAppleDto`
| Field           | Required | Type   | Rules            |
| --------------- | -------- | ------ | ---------------- |
| `identityToken` | yes      | string | Non-empty string |
| `fullName`      | no       | string | Any              |

### `auth/refresh` and `auth/logout` — `AuthRefreshDto`
| Field          | Required | Type   | Rules                                                          |
| -------------- | -------- | ------ | -------------------------------------------------------------- |
| `refreshToken` | yes      | string | Must also be a verifiable JWT signed with the refresh secret   |

If the JWT itself is invalid/expired the response is **401**, not 422.

### `users/me` PATCH — `UpdateProfileDto`
At least one field should be present (sending an empty object is technically accepted but a no-op).
| Field      | Required | Type   | Rules                       |
| ---------- | -------- | ------ | --------------------------- |
| `name`     | no       | string | Min length 2                |
| `initials` | no       | string | Max length 4                |

### `users/me/birth-chart` PUT — `UpsertBirthChartDto`
| Field           | Required | Type   | Rules                                                         |
| --------------- | -------- | ------ | ------------------------------------------------------------- |
| `sunSign`       | yes      | string | Free-form string (lowercase recommended, e.g. `"scorpio"`)    |
| `moonSign`      | yes      | string | Free-form string                                              |
| `risingSign`    | yes      | string | Free-form string                                              |
| `birthDate`     | yes      | string | ISO-8601 date string (`@IsDateString`), e.g. `"1995-03-14"`   |
| `birthTime`     | no       | string | Free-form string, recommended `"HH:mm"` (e.g. `"04:32"`)      |
| `birthLocation` | no       | string | Free-form string                                              |

### `users/me/onboarding/:step` POST — `SubmitQuizStepDto`
| Field    | Required | Type    | Rules                                                  |
| -------- | -------- | ------- | ------------------------------------------------------ |
| `step`   | yes      | integer | Integer in `[1, 8]` (`@Min(1)`, `@Max(8)`)             |
| `answer` | yes      | object  | Must be an object (`@IsObject`); shape is free-form    |

> The `:step` path param is also `1..8` (parsed as int). Send the same value in both — client should set `body.step === path.step`.

### `dreams` POST — `CreateDreamDto`
| Field          | Required | Type     | Rules                                                                                        |
| -------------- | -------- | -------- | -------------------------------------------------------------------------------------------- |
| `title`        | no       | string   | Any string                                                                                   |
| `content`      | yes      | string   | Min length 1                                                                                 |
| `typeTags`     | yes      | string[] | Each value MUST be one of `Nightmare`, `Recurring`, `Lucid`, `Vivid`, `Fragment` (case-sensitive) |
| `emotionTags`  | yes      | string[] | Each value MUST be one of `Peaceful`, `Anxious`, `Confused`, `Inspired`, `Heavy` (case-sensitive)  |
| `recordedAt`   | no       | string   | ISO-8601 datetime; defaults to server `now()` if omitted                                     |

Empty arrays for `typeTags` / `emotionTags` are accepted by the validator (only the values are constrained).

### `dreams/:id` PATCH — `UpdateDreamDto`
Every field from `CreateDreamDto` is optional. Same rules apply when present (`PartialType` of CreateDreamDto).

### `dreams` GET query — `ListDreamsQueryDto`
| Param    | Required | Type    | Rules                                              |
| -------- | -------- | ------- | -------------------------------------------------- |
| `filter` | no       | string  | Must be one of `all`, `week`, `month`              |
| `page`   | no       | integer | Min 1; auto-coerced from query string (`@Type(Number)`) |
| `limit`  | no       | integer | Range `[1, 100]`                                   |
| `search` | no       | string  | Any                                                |

### `dreams/:dreamId/interpretation` POST/GET
No body. `:dreamId` must be a valid UUID (else 400).

### `subscriptions/validate` — `ValidateIapDto`
| Field          | Required | Type   | Rules                                       |
| -------------- | -------- | ------ | ------------------------------------------- |
| `provider`     | yes      | string | One of `apple`, `google`, `stripe`          |
| `receiptToken` | yes      | string | Non-empty string                            |
| `planId`       | yes      | string | One of `weekly`, `monthly`, `annual`        |

### `subscriptions/restore` — `RestorePurchasesDto`
| Field          | Required | Type   | Rules                                       |
| -------------- | -------- | ------ | ------------------------------------------- |
| `provider`     | yes      | string | One of `apple`, `google` (NOT `stripe`)     |
| `receiptToken` | yes      | string | Non-empty string                            |

### Endpoints with no body
The following endpoints reject anything sent in the body (because of `forbidNonWhitelisted`) — send `{}` or omit entirely:
- `POST /auth/logout` (only `refreshToken` allowed)
- `DELETE /auth/me`
- `GET /users/me`, `GET /users/me/birth-chart`
- `GET /dreams`, `GET /dreams/:id`, `DELETE /dreams/:id`
- `POST /dreams/:dreamId/interpretation`, `GET /dreams/:dreamId/interpretation`
- `GET /patterns`, `GET /patterns/symbols`
- `GET /readings`, `GET /readings/daily`, `POST /readings/pull`, `PATCH /readings/:id/save`, `DELETE /readings/:id`
- `GET /guidance/daily`, `GET /guidance/sign-reveals`, `POST /guidance/sign-reveals/regenerate`
- `GET /subscriptions/plans`, `GET /subscriptions/me`, `DELETE /subscriptions/me`

### Sample 422 error payload

```json
{
  "statusCode": 422,
  "message": "Unprocessable Entity Exception",
  "error": {
    "message": [
      "email must be an email",
      "password must be longer than or equal to 8 characters",
      "typeTags must be one of the following values: Nightmare, Recurring, Lucid, Vivid, Fragment"
    ],
    "error": "Unprocessable Entity",
    "statusCode": 422
  },
  "timestamp": "2026-04-26T10:34:11.482Z"
}
```

> Flutter parser: when `error` is an object with `message: List<String>`, surface those strings to the user (e.g. as inline form errors). When `error` is a string, fall back to the top-level `message` field.

---

## 12. Quick test checklist

```bash
BASE=http://localhost:3000/api/v1

# 1. Register
curl -X POST $BASE/auth/register -H 'Content-Type: application/json' \
  -d '{"email":"test@lumen.app","name":"Test User","password":"Passw0rd!"}'
# → 201 { data: { accessToken, refreshToken, tokenExpires, user }, message: "Success" }

ACCESS=<copy accessToken>

# 2. Profile
curl $BASE/users/me -H "Authorization: Bearer $ACCESS"

# 3. Birth chart
curl -X PUT $BASE/users/me/birth-chart -H "Authorization: Bearer $ACCESS" \
  -H 'Content-Type: application/json' \
  -d '{"sunSign":"scorpio","moonSign":"cancer","risingSign":"leo","birthDate":"1995-03-14","birthTime":"04:32","birthLocation":"Brooklyn, NY"}'

# 4. Create dream
curl -X POST $BASE/dreams -H "Authorization: Bearer $ACCESS" \
  -H 'Content-Type: application/json' \
  -d '{"content":"I was in a house...","typeTags":["Recurring"],"emotionTags":["Peaceful"]}'

# 5. Daily tarot
curl $BASE/readings/daily -H "Authorization: Bearer $ACCESS"

# 6. Plans (public)
curl $BASE/subscriptions/plans
```

If every call above returns the documented envelope shape, the API surface matches this document.
