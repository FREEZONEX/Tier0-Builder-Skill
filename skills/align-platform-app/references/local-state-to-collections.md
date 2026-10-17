# Local State to App-Owned UNS Collections

## Contents

- [1. Classify Existing State](#1-classify-existing-state)
- [2. Establish One Source of Truth](#2-establish-one-source-of-truth)
- [3. Migrate in Dependency Order](#3-migrate-in-dependency-order)
- [4. Import Legacy Data](#4-import-legacy-data)
- [5. Prohibit Local Fallback on UNS Failure](#5-prohibit-local-fallback-on-uns-failure)
- [6. Acceptance Evidence](#6-acceptance-evidence)

Use this reference when app-owned business records currently live in browser
storage, persisted client stores, mocks, fixtures — or in a database of an
older scaffold version (Drizzle / PostgreSQL, `src/db/`, `DATABASE_URL`).
Tier0 apps have no database: the app's own durable records live in
**app-owned UNS collections** (ids `app.<appKey>.<name>`, prefix injected as
`TIER0_APP_COLLECTION_PREFIX`), accessed only through `@/lib/uns.server`.

## 1. Classify Existing State

Inventory each key, store slice, IndexedDB object store, mock repository,
fixture and database table. Record shape, identifiers, readers, writers,
initialization, and reset behavior, then classify it:

- **Durable business data owned by the app:** records whose loss or
  per-browser divergence is unacceptable. Migrate to an app-owned collection.
- **Workspace data owned elsewhere:** machines, ERP orders, quality results
  already in UNS. Read the existing collection (read-only for the app); never
  copy it into an app collection or a local store.
- **Session state:** transient workflow context that may expire. Keep client-side
  only when it is not an authoritative business record.
- **UI preference:** theme, density, dismissed hints, draft filters. Browser
  persistence is acceptable when explicitly scoped to the user/device.
- **Cache/derived state:** reproducible API results or computed views. It may be
  cached but must not become authoritative.
- **Seed/test fixture:** deterministic development or test input. Keep outside
  production CRUD paths.

When classification is uncertain, treat shared mutable records and completed
business actions as durable.

## 2. Establish One Source of Truth

For each durable entity, the app-owned collection is the only authoritative
store. Clients may optimistically render or cache server results, but
successful writes must be confirmed by the API. Do not dual-write to UNS and
browser state. Do not read browser state when a UNS request fails. Surface a
clear error and preserve retry safety instead of pretending the operation
succeeded.

Zustand may retain view state and an API-backed cache, but remove `persist` from
durable entity slices. LocalStorage, sessionStorage, and IndexedDB adapters may
remain only for explicitly classified ephemeral state or a bounded legacy import.

## 3. Migrate in Dependency Order

Use this order for each durable entity:

1. **Collection:** one collection per entity, declared once in its owning
   service with `defineAppCollection<T>(name, def, { seed? })`. Model stable
   record ids (natural keys such as `WO-0001`, or server-issued UUIDs),
   lifecycle status as a string `enum`, required fields, references as id
   strings, and object-form `indexes` for fields the UI filters, sorts, joins
   or upserts on (`{ path }`, `{ path, unique: true }` for natural keys). Tables of an older
   scaffold map one-to-one to collections; a join table usually becomes an
   array field or a collection keyed by `<parentId>:<childId>`.
2. **First-load setup:** nothing is provisioned in advance. Each handle method
   awaits `ready()`, which creates the collection on 404, PATCHes a changed
   definition, and re-reads on a 409 race. Do not call `ready()` at import time.
   Remove `src/db/`, `drizzle.config.ts`, `db:*` scripts, `pg` / `drizzle-*`
   dependencies, `bootstrapModule()` and ORM transaction code. `seed` is only for
   genuine baseline data (fixed ids, 409 = exists, runs when the collection is
   new or empty); do not auto-insert demo rows for migrated durable entities.
   Build seed dates with `seedDate()` / `seedTimestamp()` / `seedTimeMs()`.
3. **Service:** implement reads, writes, invariants, and authorization inputs in
   `src/services/**`. UNS access stays here, through the MongoDB-style handle
   (scaffold `docs/uns-data.md`): lists with `find` (filter operators, sort,
   `nextCursor`; `lookup` for related records), state transitions with
   `findOneAndUpdate({ _id, status: from }, { $set: { status: to } },
   { returnDocument: "after" })` (`null` → 409), counters / stock with `$inc`,
   natural keys with a unique index + `updateOne(..., { upsert: true })`, and
   multi-record changes that must be atomic with `transact([...])`
   (`require: "matched"`). Replace SQL `SELECT … FOR UPDATE` / row locks held
   across user interaction with `lock()` leases (edit locks, work queues).
   Do not port "read → modify → write with `revision` → retry on 409" loops;
   `handle.update(id, next)` is only for changes operators cannot express.
   Make retries harmless with deterministic ids or `idempotencyKey`.
4. **API:** add thin `src/routes/api/**` handlers for auth, parsing, service
   delegation, and consistent error responses (`withErrors` maps `UnsError`).
5. **Client:** replace local CRUD with base-path-aware API requests,
   loading/error/success states, cache invalidation or refetch (or
   `useUnsChanges()` + `applyUnsChange()` for live updates: record events
   carry the full document, request `delete` / `leave` kinds for lists, reload
   on `onReset`), and stable server-issued identifiers.
   Render request results through `AsyncView` so first-load failures expose
   error/retry instead of endless loading.

Cut over complete vertical slices. Do not switch the client to an API before its
collection definition and service behavior are ready.

## 4. Import Legacy Data

Import old local or database data only when retention is required and the
source can still provide it. Make the import explicit and bounded:

- Version and validate the legacy payload before sending it to a dedicated API
  (or read it once from the old database export the user provides).
- Define identity mapping, ownership, deduplication, conflict precedence, invalid
  row handling, and maximum payload size.
- Make retries idempotent with deterministic record ids: `insertMany` with
  ids (`ordered: false`) reports 409 `duplicate_key` per existing id in
  `writeErrors`; use `bulkWrite` / `updateOne` with `upsert: true` when an
  import should update existing records instead of skipping them.
- Batches are atomic per document only (`atomic: true` for ≤ 1000 documents,
  `transact` for ≤ 100 ops across collections). Import in an order where a
  partial import is still consistent (parents before children, status flags
  last) and make it resumable.
- Return and record attempted, created, updated, skipped, conflicted, and rejected
  counts without logging sensitive payloads.
- Mark successful import completion, then remove or archive legacy keys only
  after server confirmation. Never import silently on every normal application
  read.

If no retention requirement exists, document the reset/cutover decision and
remove the obsolete durable local state path.

## 5. Prohibit Local Fallback on UNS Failure

A UNS outage, timeout, 403, or 409 conflict must produce an observable failure.
Never fall back to LocalStorage, sessionStorage, IndexedDB, Zustand persist,
in-memory repositories, mock handlers, fixtures or a private database for
production business reads or writes. Such fallback creates split-brain data
and false success. Retry only idempotent operations, preserve correlation/error
context, and let the UI show a recoverable error. Plain local development
without UNS credentials shows the `not_configured` empty state
(`isUnsConfigured()`), not mock data.

## 6. Acceptance Evidence

Collect current evidence for every migrated durable entity:

- Each collection is created by first use against a workspace without it, and
  a definition change converges by PATCH without losing records.
- Normal startup and first-request paths do not auto-insert demo or sample
  records for migrated durable business entities. Retained legacy data and
  development/test fixtures enter only through explicit import or explicit
  development/test actions.
- API-driven create, read, update, and supported terminal lifecycle paths work.
- Data survives browser reload, a different client session, and a server
  restart.
- Record ids, schema validation (400 `validation_failed`), authorization, and
  concurrent-change handling (a guarded `findOneAndUpdate` returning `null`,
  409 `duplicate_key` on unique keys, 423 `locked` while someone holds a
  lease) behave as designed.
- Network and UNS failures show errors and create no local authoritative
  records or fixture/mock fallback.
- First-load request failure renders an error/retry state rather than an
  indefinite loading shell.
- Repository search finds no production durable CRUD writes to browser storage,
  persisted Zustand slices, IndexedDB, memory repositories, fixtures, or a
  database driver (`pg`, `drizzle-orm`, `src/db/`).
- Legacy import, when required, has idempotency and reconciliation evidence with
  attempted/created/updated/skipped/conflicted/rejected counts.
- Typecheck, build (including `app-data-contracts`), relevant tests, health,
  manifest, and production-start checks pass under the platform contract.
