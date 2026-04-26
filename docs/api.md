# API Overview

All routes are under `/api/v1/`. Swagger UI: `http://localhost:3000/docs`.

Auth: `Authorization: Bearer <accessToken>` header on protected routes.

## Endpoints at a glance

### auth
| Method | Path                  | Auth        | Purpose                                      |
| ------ | --------------------- | ----------- | -------------------------------------------- |
| POST   | `/auth/register`      | public      | Email registration                           |
| POST   | `/auth/login/email`   | public      | Email + password login                       |
| POST   | `/auth/google`        | public      | Google ID token exchange                     |
| POST   | `/auth/apple`         | public      | Apple identity token exchange                |
| POST   | `/auth/refresh`       | refresh JWT | Rotate tokens                                |
| POST   | `/auth/logout`        | access JWT  | Invalidate a refresh token                   |
| DELETE | `/auth/me`            | access JWT  | Soft-delete account                          |

### users
| Method | Path                            | Purpose                         |
| ------ | ------------------------------- | ------------------------------- |
| GET    | `/users/me`                     | Profile (+ isPremium, counts)   |
| PATCH  | `/users/me`                     | Update name / initials          |
| GET    | `/users/me/birth-chart`         | Birth chart                     |
| PUT    | `/users/me/birth-chart`         | Upsert birth chart              |
| POST   | `/users/me/onboarding/:step`    | Store quiz step answer          |

### dreams
| Method | Path              | Purpose                         |
| ------ | ----------------- | ------------------------------- |
| POST   | `/dreams`         | Create                          |
| GET    | `/dreams`         | List (filter, search, paginate) |
| GET    | `/dreams/:id`     | Get single                      |
| PATCH  | `/dreams/:id`     | Update                          |
| DELETE | `/dreams/:id`     | Soft-delete                     |

### interpretations (nested under dreams)
| Method | Path                                | Purpose                                 |
| ------ | ----------------------------------- | --------------------------------------- |
| POST   | `/dreams/:dreamId/interpretation`   | Generate or return existing (sync)      |
| GET    | `/dreams/:dreamId/interpretation`   | Fetch interpretation (premium-gated)    |

### patterns
| Method | Path                 | Purpose                                |
| ------ | -------------------- | -------------------------------------- |
| GET    | `/patterns`          | Weekly patterns (AI summary if premium) |
| GET    | `/patterns/symbols`  | All-time top symbols                   |

### guidance
| Method | Path                                  | Purpose                    |
| ------ | ------------------------------------- | -------------------------- |
| GET    | `/guidance/daily`                     | Today's guidance (cached)  |
| GET    | `/guidance/sign-reveals`              | Sun/Moon/Rising reveals    |
| POST   | `/guidance/sign-reveals/regenerate`   | Force regenerate           |

### readings (tarot)
| Method | Path                       | Purpose                  |
| ------ | -------------------------- | ------------------------ |
| GET    | `/readings/daily`          | Today's deterministic pull |
| POST   | `/readings/pull`           | Random pull              |
| GET    | `/readings`                | Saved history            |
| PATCH  | `/readings/:id/save`       | Mark saved               |
| DELETE | `/readings/:id`            | Delete                   |

### subscriptions
| Method | Path                       | Auth       | Purpose                       |
| ------ | -------------------------- | ---------- | ----------------------------- |
| GET    | `/subscriptions/plans`     | public     | 3 plans from seed data        |
| GET    | `/subscriptions/me`        | access JWT | Current subscription / premium|
| POST   | `/subscriptions/validate`  | access JWT | Validate IAP receipt          |
| POST   | `/subscriptions/restore`   | access JWT | Restore prior purchase        |
| DELETE | `/subscriptions/me`        | access JWT | Cancel auto-renew             |

## Response envelope

Every success response is wrapped by `TransformInterceptor`:

```json
{
  "data": { ... },
  "message": "Success"
}
```

## Error envelope

```json
{
  "statusCode": 403,
  "message": "Interpretation requires premium.",
  "error": "Forbidden",
  "timestamp": "2026-04-24T12:34:56.789Z"
}
```

Validation failures return HTTP 422 (class-validator).
