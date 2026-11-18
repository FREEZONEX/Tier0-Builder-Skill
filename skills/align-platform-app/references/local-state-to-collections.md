# Local State to Tier0 UNS Collections

## Contents

- [1. Classify Existing State](#1-classify-existing-state)
- [2. Establish One Source of Truth](#2-establish-one-source-of-truth)
- [3. Migrate in Dependency Order](#3-migrate-in-dependency-order)
- [4. Legacy Browser Data](#4-legacy-browser-data)
- [5. Prohibit Local Fallback on Data Failure](#5-prohibit-local-fallback-on-data-failure)
- [6. Acceptance Evidence](#6-acceptance-evidence)

Use this reference when app-owned business records currently live in browser
storage, persisted client stores, mocks, or fixtures. The target is the
scaffold's App data layer: collections declared in `src/data/collections.ts`
and reached from services through `data` from `@/lib/data` (the
`@tier0/sdk-v2/data` client). The scaffold's AGENTS.md → App Data is the
authoritative contract; this file covers the cutover steps.

## 1. Classify Existing State

Inventory each key, store slice, IndexedDB object store, mock repository, and
fixture. Record shape, identifiers, readers, writers, initialization, and reset
behavior, then classify it:

- **Durable business data:** shared records whose loss or per-browser divergence
  is unacceptable. Migrate to a collection.
- **Session state:** transient workflow context that may expire. Keep client-side
  only when it is not an authoritative business record.
- **UI preference:** theme, density, dismissed hints, draft filters. Browser
  persistence is acceptable when explicitly scoped to the user/device.
- **Cache/derived state:** reproducible API results or computed views. It may be
  cached but must not become authoritative.
- **Seed/test fixture:** deterministic baseline or test input. Baseline records
  become the collection's `seed`; test fixtures stay outside production CRUD.

When classification is uncertain, treat shared mutable records and completed
business actions as durable.

## 2. Establish One Source of Truth

For each durable entity, the collection is the only authoritative store.
Clients may optimistically render or cache server results, but successful writes
must be confirmed by the API. Do not dual-write to the collection and browser
state. Do not read browser state when a data call fails. Surface a clear error
and preserve retry safety instead of pretending the operation succeeded.

Zustand may retain view state and an API-backed cache, but remove `persist` from
durable entity slices. LocalStorage, sessionStorage, and IndexedDB adapters may
remain only for explicitly classified ephemeral state.

## 3. Migrate in Dependency Order

Use this order for each durable entity:

1. **Declaration:** model the entity as a document in `src/data/collections.ts`
   with `defineCollection` from `@tier0/sdk-v2/data/define`, and list it in
   `collections`. Embed what changes with the record (lines, steps, history) as
   bounded arrays and reference shared entities by ID plus a display snapshot
   instead of joins. Use the storage-schema subset (no `.nullable()`,
   `.default()`, string formats or length limits — those belong in API input
   schemas), dates as `YYYY-MM-DD` strings, instants as ISO strings, and indexes
   for the fields lists filter and sort on. `_id` and `_meta` are system fields.
2. **Baseline data:** records the app needs from the start go in the
   declaration's `seed` with fixed `_id`s, cross-referenced through
   `requireSeedRef()` and dated with `seedDate()` / `seedTimestamp()` from
   `src/data/seed-utils.ts`. Seeds are written once, when the collection is
   created; editing `seed` later never reseeds. Remove any startup or
   first-request code that inserts demo, sample, or baseline rows, and never
   insert rows from a service because a list is empty.
3. **Service:** implement reads, writes, invariants, authorization inputs, and
   multi-record changes in `src/services/**` with `data.collection(...)`; state
   transitions put the expected state in the filter (`findOneAndUpdate`),
   concurrent edits use `expectedRevision`, and cross-document invariants use
   `data.transact([...])`. Data access stays here.
4. **API:** add thin `src/routes/api/**` handlers for auth, parsing, service
   delegation, and consistent error responses through `withErrors`.
5. **Client:** replace local CRUD with base-path-aware API requests,
   loading/error/success states, cache invalidation or refetch, and stable
   server-issued identifiers. Render current scaffold request results through
   `AsyncView` so first-load failures expose error/retry instead of endless
   loading.

Cut over complete vertical slices. Do not switch the client to an API before its
declaration and service behavior are ready. `npm run build` validates every
declaration and seed against what UNS can store.

## 4. Legacy Browser Data

Records held only in browser storage, persisted stores, or mocks do not migrate
with alignment; if needed, the user imports historical data on the UNS side,
outside Builder (see
[first-ensure-and-runtime-blockers.md](first-ensure-and-runtime-blockers.md)).
Do not guide an export or build or run an import. Document the cutover and
remove the obsolete durable local state path.

## 5. Prohibit Local Fallback on Data Failure

A data-layer failure (`DataError`, including timeouts and an unavailable
gateway) must produce an observable failure. Never fall back to LocalStorage,
sessionStorage, IndexedDB, Zustand persist, in-memory repositories, mock
handlers, or fixtures for production business reads or writes. Such fallback
creates split-brain data and false success. The data layer already resends
calls that are safe to repeat, so add no retry loop of your own;
`outcomeUnknown: true` (`execution: "unknown"`) means a write may have landed,
so read back before writing again. Let the UI show a recoverable error.

## 6. Acceptance Evidence

Collect current evidence for every migrated durable entity:

- `npm run build` passes, including the data contract checks on declarations
  and seeds.
- Normal startup and first-request paths insert no rows from services; baseline
  records come only from `seed`.
- API-driven create, read, update, and supported terminal lifecycle paths work.
- Data survives browser reload and a different client session; when the
  environment is controllable, it also survives server restart.
- Validation, unique indexes, authorization, revision conflicts and
  transactions behave as designed.
- Network and data-layer failures show errors and create no local authoritative
  records or fixture/mock fallback.
- First-load request failure renders an error/retry state rather than an
  indefinite loading shell.
- Repository search finds no production durable CRUD writes to browser storage,
  persisted Zustand slices, IndexedDB, memory repositories, or fixtures.
- Preview writes land in the same collections as the deployed App: write test
  records only where authorized and remove them afterwards; never `deleteMany` or
  recreate a collection to reset it.
- Typecheck, build, relevant tests, health, manifest, and production-start checks
  pass under the platform contract.
