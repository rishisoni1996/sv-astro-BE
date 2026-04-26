# Lumen Backend — Open Questions from Flutter

Status legend: ✅ resolved · ⏳ open · 🆕 new ask

---

## ✅ 1. Birth chart computation from onboarding answers

**Backend answer:** No. `submitQuizStep` only stores raw `answer` JSON in
`onboarding_answers` — it does not touch `birthChart`. Frontend must call
`PUT /users/me/birth-chart` separately, with `sunSign` / `moonSign` /
`risingSign` already computed.

**Implication for FE:** The quiz captures `birthDate` / `birthTime` /
`birthLocation`, but **not** the three signs — those need to come from
somewhere. This blocks populating `User.birthChart` and the cosmic /
sign-reveal screens until we have a source for the signs.

**Current FE behavior:** `/users/me.birthChart` stays `null` after onboarding.
Cosmic screen continues to show mock data. See **🆕 #7** below.

---

## ✅ 5. Replay idempotency

**Backend answer:** Yes, idempotent on `(userId, step)`. Repository does
lookup-then-update-or-insert; entity has a DB-level unique index on
`(userId, step)`. Replay-after-crash is safe.

**FE:** No change needed — current parallel replay-after-register is safe.

---

## ✅ 2. Submitting only a subset of the 8 onboarding steps

**Backend answer:** Subset is fine. There is no "user is onboarded" check
anywhere in the backend — `onboarding_answers` rows are write-only storage,
nothing reads them to gate behavior. Submitting just steps 1, 3, 5, 8 (or
any subset) is supported indefinitely. The `step` column is a `smallint`
with no enum/range constraint, so the set of valid steps is whatever the
FE and backend agree on out-of-band.

**FE assumption was correct.**

---

## ✅ 3. Detecting onboarding completion on `/users/me`

**Backend answer:** No flag today — `UserDomain` only exposes
`id, name, initials, email, role, isPremium, dreamCount, memberSince,
birthChart`. Since there's also no completeness gate (see #2), the FE
assumption ("any `/users/me` fetch = onboarded") works as-is.

If the FE later wants explicit routing signal, we'll add
`onboardingStepsCompleted: number[]` to `UserDomain` (cheap — one extra
query in `toDomain`, populated from `onboarding_answers` for the user).
Prefer the array over a boolean so the FE can resume mid-flow on a
re-install rather than only "all-or-nothing".

**Decision needed from FE:** want the array now, or defer until you actually
hit the resume-flow case?

---

## ✅ 4. Confirming the `answer` payload shapes

**Backend answer:** Storage is `jsonb` with no schema validation
(`answer_json: Record<string, unknown>`), so anything you send round-trips
intact. The proposed shapes are all fine. One note worth calling out:

The step 5 / 8 keys (`birthDate`, `birthTime`, `birthLocation`) **already
match `UpsertBirthChartDto` field names**, which is what the Option A
auto-upsert (#7) will read out of the JSONB. Please keep these exact key
names — renaming them later means a coordinated FE+BE change. Other steps
(1, 3) have no such constraint, name them however reads best on the FE.

---

## 🆕 6. (was #6) Out-of-scope this pass — for awareness

Remaining 7 modules (dreams, interpretations, patterns, readings, guidance,
subscriptions, real Google/Apple OAuth) are deferred to follow-up FE passes.
No new backend asks based on the current spec.

---

## ✅ 7. Sign computation — going with Option A

**Backend decision:** Option A (auto-upsert inside `submitQuizStep`).

**Status:** skeleton in place this branch.
- Migration `1761500000000-BirthChartGeoFields` adds `birth_latitude`,
  `birth_longitude`, `birth_timezone`; makes `rising_sign` nullable.
- New `AstrologyModule` (`src/astrology/`) with `geocode()` + `computeSigns()`
  service methods. Sun sign computes today (pure date math); moon + rising
  are stubbed pending ephemeris lib pick (`circular-natal-horoscope-js`
  leading) and Google Maps Geocoding wiring.
- `submitQuizStep` not yet wired to call it — that lands once libs are in.

**Failure mode (important for FE expectations):** sign-compute is
best-effort. Sun will always populate; moon usually; rising only when
`birthTime` was provided AND geocoding resolved. Missing signs come back
as `null` on `/users/me.birthChart`, not as an error. Cosmic screen should
treat each sign as independently nullable rather than gating on the whole
chart.

**No FE action required** beyond keeping the step 5/8 payload key names
stable (see #4). Next `/users/me` after onboarding will return the chart.

---

## 7-history. Original three options (kept for reference)

Follows from the answer to #1. Steps 5 + 8 give the backend `birthDate`,
`birthTime`, `birthLocation` as raw JSON. To populate the user's birth chart
we need `sunSign`, `moonSign`, `risingSign` from somewhere. **Computing
these on every client is a bad architecture** — needs an ephemeris (Swiss
Ephemeris file, ~10 MB), needs geocoding to turn `"Brooklyn, NY"` into
lat/lng, and would have to be reimplemented identically across iOS, Android,
and any future web build. Server-side is the right home for this.

Three options, my preference order:

**Option A (preferred): auto-upsert birth chart inside `submitQuizStep`.**
When steps 5 + 8 have both been submitted, the service computes the three
signs and upserts the row in `birth_charts`. FE does nothing extra — onboarding
replay finishes, then the next `/users/me` fetch returns a fully populated
`birthChart`. Smallest FE change (none), saves a round-trip, keeps the quiz
flow declarative.

**Option B: helper endpoint.** Expose
`POST /astrology/compute-signs { birthDate, birthTime, birthLocation } → { sunSign, moonSign, risingSign }`.
The FE calls this between onboarding-replay and `PUT /users/me/birth-chart`.
Slightly more FE code, but lets the FE decide *when* to write the chart
(useful if the user later edits their birth data from settings).

**Option C: I implement it client-side.** Adds a Dart astrology library +
ephemeris asset + geocoding step + duplicated logic across platforms. Not
recommended; would only do this if A and B are blocked.

**FE will stay on mock data** for the cosmic / `/you` birth-chart sections
until one of these is in place. Onboarding still feels real (user picks date
/ time / location and their answers persist) — just the "your sun is
Scorpio" reveal stays placeholder.
