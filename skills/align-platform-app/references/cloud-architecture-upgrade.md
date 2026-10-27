# Upgrade Older Scaffolds to the Cloud Architecture

Read this for an existing scaffold app crossing a data/runtime architecture
boundary. For browser/mock persistence, use
[local-state-to-collections.md](local-state-to-collections.md). Resolve the
actual target commit through [latest-template-source.md](latest-template-source.md)
first; the comparison below is source evidence, not deployed-state evidence.

## Verified Old and New Sources

Compared on 2026-10-27 in `FREEZONEX/Tier0-App-Scaffold`:

- Old `main`: `822dfabf2469bc4d64f6d46f44e79b650fe3ab03`, marker
  `{ "version": 7, "ref": "3a96b2b" }`.
- New `feature/cloud-new-architecture-migration`:
  `a9697cc343b63699ffa25db73b6bcda9ebf32952`, marker
  `{ "version": 13, "ref": "22e39fc" }`.

| Surface | Old main / v7 | Cloud / v13 | Migration consequence |
| --- | --- | --- | --- |
| App persistence | `src/db/**`, Drizzle and PostgreSQL | `src/data/collections.ts`, SDK data client via `@/lib/data` | Rewrite declarations and services; preserve business invariants |
| Initialization | `bootstrapModule`, SQL table/index setup, `db:push` | One ensure of declared collections on first access | Remove SQL bootstrap and scripts; never add a parallel ensure cache |
| Runtime configuration | `DATABASE_URL`, `DIRECT_DATABASE_URL`, `DB_SCHEMA` | Injected `TIER0_API_HOST` / `TIER0_API_KEY` | Remove app database connection usage; no credential UI |
| SDK | `@tier0/sdk` `^0.5.4` (locked 0.5.4) | `@tier0/sdk-v2` exact `0.3.0` | Rewrite removed APIs; package rename alone is insufficient |
| Request scope | Gateway auth and CSRF middleware | Same plus SDK `runWithRequestContext(request, ...)` | Preserve employee data subject and cancellation on all requests |
| Live App records | Request hooks / polling | `useRecordChanges` and authenticated `/api/uns/subscribe` | Events invalidate reads; they do not replace authorized API reads |
| Preview roles | Single selected role | Selected role set with permission union | Update Gateway/auth helpers and multi-role tests together |
| Production run | Explicit image in artifact | Platform-selected image | Remove run image pin; keep literal argv and Node entry |
| Verification | SQL/schema contracts | Data declarations, seeds, data-layer and stream tests | Replace retired gates with the complete upstream file/hash set |

The owning evidence is the two commits' `package.json`/lockfile,
`src/start.ts`, `src/lib/{gateway,auth,tier0}.ts`, `artifact.toml`, the
added/removed data files, `AGENTS.md`, and `docs/platform-integration.md`.
Compare these at the chosen commits; do not infer a rollout from a merged source.

## Choose by Implementation, Then Provenance

Record the marker, known source commit, installed/locked SDK, data imports and
request-context provider. Marker numbers are clues, not proof: a partially
aligned app may still carry v7 while already using collections. Never migrate
or recreate existing collections merely because the marker is old. Likewise,
check what the target collections hold instead of assuming records exist: an
App exported from one environment and imported into another gets new collections
from its first ensure there, and its old records stay behind. At every version,
such history follows the v7 export and later-import path, and missing old data
never stops source alignment.

### Drizzle / v7 and Earlier

Reconstruct from source models and business behavior without connecting to the
old PostgreSQL database or requesting its configuration. Historical data is not
copied during alignment: guide the user to export it from the original app and
import or manually enter it after reconstruction. With full alignment or
migration authorized, switch every service to collections without waiting for
exported files or import permissions, keep no SQL path, leave the old
deployment and database untouched, and follow
[first-ensure-and-runtime-blockers.md](first-ensure-and-runtime-blockers.md)
for initialization, blocked runtime checks, and the later import handoff.

1. Map each service's tables, SQL queries, constraints, triggers/defaults,
   transactions, scheduled writes and API response types to its business
   operation. Keep external systems of record outside this conversion unless
   their ownership is in scope.
2. Model documents in `src/data/collections.ts` and list every declaration in
   `collections`. Embed bounded children that change with a parent; keep shared
   entities as references with deliberate snapshot semantics. Do not translate
   every join table into a collection mechanically.
3. Rewrite a complete service/API/client slice using the semantic mapping below.
   Preserve routes, validation, authorization and observable lifecycle outcomes.
   Report an invariant that the target cannot represent rather than replacing
   it with best-effort writes.
4. After callers are converted, remove retired `src/db/**`, SQL-only service
   helpers (`bootstrap`, `db-results`, `seed-utils`), `drizzle.config.ts`,
   `scripts/db-sync-guard.mjs`, `db:*` scripts, Drizzle/`pg` dependencies and
   database env usage. Move valid date/reference seed usage to
   `src/data/seed-utils.ts`. Inspect imports before removal; preserve unrelated
   business logic in customized files. Reconcile old SQL gate removal as part
   of the target's complete gate set.
5. Scan active source, runtime config, tests and dependency files for old
   imports and database commands. Historical documentation may describe the
   old architecture; it must not remain active runtime guidance.

| SQL behavior to inventory | Cloud equivalent or decision |
| --- | --- |
| PK and returned row `id` | `_id`; map deliberately at API boundaries and in reference fields |
| DB-managed timestamps | `_meta.createdAt` / `updatedAt` in Unix milliseconds; preserve separate business dates where meaningful |
| Nullable columns | Optional storage fields, absence instead of `null`, `$unset` when clearing; normalize old API/form payloads |
| Date / numeric / JSON columns | Storage-supported Zod shapes; ISO/date strings, bounded closed objects; resolve precision or unbounded-shape conflicts explicitly |
| DB defaults / validation | Service defaults and derived API input validation; storage schemas cannot use transforms/defaults |
| Unique / foreign-key / cascade rules | Declared unique indexes plus explicit service/reference/lifecycle checks; no implicit SQL FK or cascade remains |
| SQL joins and aggregates | Document model, supported aggregate/query APIs, `get(ids)` and `data.queryBatch`; avoid per-record request loops |
| List count | Capped `{ count, capped }`, mapped with `toQueryResult`; preserve capped-count UI semantics |
| State transition | Expected state in the update filter; handle no match as conflict |
| Concurrent edit | Form carries `_meta.revision`; pass `expectedRevision`, handle `VERSION_CONFLICT` |
| `db.transaction(async tx => ...)` | Declarative `data.transact` steps with checks/bindings, at most 200; no interactive read-then-decide transaction callback |
| Multi-record write | One atomic call where required; `updateMany`/`deleteMany` and multiple chunks are not globally atomic |
| Sequence generation | Atomic counter update; upsert needs `_id` or all fields of a ready unique index |
| Delete | UNS soft deletion requires App `uns.delete`; preserve archive/cancel business semantics and do not broaden access to pass tests |

Read the target's `AGENTS.md` App Data section and SDK types for exact supported
operators, transaction steps and storage limits. Do not invent SQL-equivalent
isolation, decimal handling, or foreign-key enforcement.

### Local Collections Client / v8

Existing target collections and their records stay in place. The old
`src/lib/data` contains `bootstrap`, `client`, `collection`, `context`,
`define`, `index`, `query`, `schema`, and `transport`. Replace platform
implementations with the selected target's `index.ts`, `query.ts`, and
`changes.ts`; remove the seven retired modules after remapping callers.

- `@/lib/data/define` becomes `@tier0/sdk-v2/data/define`.
- Types such as `WithMeta` and values such as `DataError` from retired modules
  move to the target's `@/lib/data` exports or SDK data exports.
- `src/start.ts` opens only the SDK context. A leftover local context may
  silently execute employee work as the App.
- Keep collection aliases and existing declaration/record identities. Do not
  copy the template's empty `collections` array over business declarations.
- Reconcile v1 SDK calls, changed data result/error shapes and live subscriptions
  below. A client upgrade is not a data-reset operation.

### SDK Data Client / v9–v11

v9 already uses SDK data at 0.1.0; v10/v11 use 0.2.0. Keep the target's
existing collections and records. Compare against the actual marker ref or known
commit rather than reinstalling every platform file blindly.

Before 0.3.0 (v8–v11), seeds and `insertMany` call `records:insertMany`, which
newer backends no longer serve (404), so a collection can exist without its seed.
The upgraded SDK never reseeds an existing collection; never recreate one to
reseed it. Write missing baseline rows once through the tier0 MCP or an explicit
import, or report them.

Reconcile changed runtime surfaces together: `src/start.ts`,
`src/lib/route-handlers.ts`, `src/lib/data/**`,
`src/routes/api/uns/subscribe.ts`, `src/lib/record-changes.ts`,
Gateway/auth/preview-bridge helpers, route error boundary, and the kit's
`Pagination` / `QueryResult`. Take the matching gate manifest and its listed
files, `eslint.config.mjs`, relevant `tests/*.test.ts` and `test:data` wiring.
Preserve customized business behavior when merging these files.

For v9, adapt capped counts, `execution`/`retry` errors, partial-write
`resumeAfter` handling, batched reads and live subscriptions using
[App Data Contract](platform-contract.md#app-data-contract).
For every old SDK, apply [SDK Upgrades](platform-contract.md#sdk-upgrades):
0.3.0 removes methods as well as changing routes. Unsupported Flow/Agent
features remain blockers, never success-shaped stubs.

## Cross-Version Acceptance

- Merge target dependencies into the App manifest and regenerate its lockfile;
  preserve business dependencies. Do not copy a blank scaffold lockfile over a
  customized dependency graph. Verify an exact install separately from build.
- Preserve one SDK request context and test employee-scoped behavior through
  authenticated requests, including server functions. Keep background work's
  `runAsApp` scope explicit; do not turn request services into App-level calls
  to bypass a permission failure.
- Refresh App record views through `useRecordChanges` with aliases. Cover
  `batch.reset` and collection-level invalidations for employee-filtered data;
  reload through authorized APIs instead of applying event payloads as records.
- In an authorized test environment, exercise state/revision conflicts and
  all-or-nothing behavior, not only happy-path CRUD. Verify unknown write
  outcomes are read back and not blindly resent. Split batches only when the
  domain permits partial completion.
- Preview shares deployed collections. Neither a test nor an upgrade authorizes
  schema reset/recreation, old database deletion, or a production data backfill.
- Run the full build with the matching gate set, then the affected HTTP,
  hydration, persistence and runtime checks. Record unavailable checks as
  pending. Only full alignment writes the target marker; partial repairs keep
  the previous marker even when their own checks pass.
