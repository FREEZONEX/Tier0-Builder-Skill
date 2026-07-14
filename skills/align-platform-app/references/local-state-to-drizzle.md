# Local State to Drizzle/PostgreSQL

## Contents

- [1. Classify Existing State](#1-classify-existing-state)
- [2. Establish One Source of Truth](#2-establish-one-source-of-truth)
- [3. Migrate in Dependency Order](#3-migrate-in-dependency-order)
- [4. Import Legacy Browser Data](#4-import-legacy-browser-data)
- [5. Prohibit Local Fallback on Database Failure](#5-prohibit-local-fallback-on-database-failure)
- [6. Acceptance Evidence](#6-acceptance-evidence)

Use this reference when app-owned business records currently live in browser
storage, persisted client stores, mocks, or fixtures.

## 1. Classify Existing State

Inventory each key, store slice, IndexedDB object store, mock repository, and
fixture. Record shape, identifiers, readers, writers, initialization, and reset
behavior, then classify it:

- **Durable business data:** shared records whose loss or per-browser divergence
  is unacceptable. Migrate to PostgreSQL.
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

For each durable entity, declare PostgreSQL the only authoritative store.
Clients may optimistically render or cache server results, but successful writes
must be confirmed by the API. Do not dual-write to PostgreSQL and browser state.
Do not read browser state when a database request fails. Surface a clear error
and preserve retry safety instead of pretending the operation succeeded.

Zustand may retain view state and an API-backed cache, but remove `persist` from
durable entity slices. LocalStorage, sessionStorage, and IndexedDB adapters may
remain only for explicitly classified ephemeral state or a bounded legacy import.

## 3. Migrate in Dependency Order

Use this order for each durable entity:

1. **Schema:** model stable IDs, ownership/tenant scope, constraints, relations,
   timestamps, lifecycle status, and indexes in the scaffold Drizzle schema.
2. **Scaffold data setup:** update the current scaffold `bootstrapModule()` table
   and index setup, and use `db:push` only where the current template or target
   environment requires it. Test the contract against a clean schema and, when
   relevant, representative existing rows. Preserve this idempotent DDL
   bootstrap, but remove runtime seed callbacks that auto-insert demo, sample, or
   baseline rows for migrated durable business entities during normal startup or
   a first request.
3. **Service:** implement reads, writes, invariants, authorization inputs, and
   multi-step transactions in `src/services/**`. Database access stays here.
4. **API:** add thin `src/routes/api/**` handlers for auth, parsing, service
   delegation, and consistent error responses.
5. **Client:** replace local CRUD with API requests, loading/error/success states,
   cache invalidation or refetch, and stable server-issued identifiers.

Cut over complete vertical slices. Do not switch the client to an API before its
schema, runtime bootstrap / `db:push`, and service behavior are ready.

## 4. Import Legacy Browser Data

Import old local data only when retention is required and the browser can still
provide it. Make the import explicit and bounded:

- Version and validate the legacy payload before sending it to a dedicated API.
- Define identity mapping, ownership, deduplication, conflict precedence, invalid
  row handling, and maximum payload size.
- Make retries idempotent with import IDs or natural uniqueness constraints.
- Run writes transactionally where partial import would violate invariants.
- Return and record attempted, created, updated, skipped, conflicted, and rejected
  counts without logging sensitive payloads.
- Mark successful import completion, then remove or archive legacy keys only
  after server confirmation. Never import silently on every normal application
  read.

If no retention requirement exists, document the reset/cutover decision and
remove the obsolete durable local state path.

## 5. Prohibit Local Fallback on Database Failure

A database outage, timeout, or rejected transaction must produce an observable
failure. Never fall back to LocalStorage, sessionStorage, IndexedDB, Zustand
persist, in-memory repositories, mock handlers, or fixtures for production
business reads or writes. Such fallback creates split-brain data and false
success. Retry only idempotent operations, preserve correlation/error context,
and let the UI show a recoverable error.

## 6. Acceptance Evidence

Collect current evidence for every migrated durable entity:

- Schema and current scaffold runtime bootstrap / `db:push` apply to a clean
  schema.
- Normal startup and first-request paths do not auto-insert demo, sample, or
  baseline rows for migrated durable business entities. Retained legacy data and
  development/test fixtures enter only through explicit import or explicit
  development/test actions.
- API-driven create, read, update, and supported terminal lifecycle paths work.
- Data survives browser reload and a different client session; when the
  environment is controllable, it also survives server restart.
- Server-issued IDs, constraints, validation, authorization, and transaction
  rollback behave as designed.
- Network and database failures show errors and create no local authoritative
  records or fixture/mock fallback.
- Repository search finds no production durable CRUD writes to browser storage,
  persisted Zustand slices, IndexedDB, memory repositories, or fixtures.
- Legacy import, when required, has idempotency and reconciliation evidence with
  attempted/created/updated/skipped/conflicted/rejected counts.
- Typecheck, build, relevant tests, health, manifest, and production-start checks
  pass under the platform contract.
