# Upgrade Older Scaffolds to the Cloud Architecture

Read this for an existing scaffold app crossing a data/runtime architecture
boundary. For browser/mock persistence, use
[local-state-to-collections.md](local-state-to-collections.md). Resolve the
actual target commit through [latest-template-source.md](latest-template-source.md)
first; the comparison below is source evidence, not deployed-state evidence.

## Verified Old and New Sources

Compared on 2026-11-12 in `FREEZONEX/Tier0-App-Scaffold`:

- Old `main`: `822dfabf2469bc4d64f6d46f44e79b650fe3ab03`, marker
  `{ "version": 7, "ref": "3a96b2b" }`.
- Cloud `feature/cloud-new-architecture-migration`:
  `90101910ce846b7ee57c2556e7712ec29b50d7d2`, marker
  `{ "version": 39, "ref": "cd4c70a" }`; runtime deployment not verified.

| Surface | Old main / v7 | Cloud / v39 | Migration consequence |
| --- | --- | --- | --- |
| App persistence | `src/db/**`, Drizzle and PostgreSQL | `src/data/collections.ts`, SDK data client via `@/lib/data` | Rewrite declarations and services; preserve business invariants |
| Initialization | `bootstrapModule`, SQL table/index setup, `db:push` | One ensure of declared collections on first access | Remove SQL bootstrap and scripts; never add a parallel ensure cache |
| Runtime configuration | `DATABASE_URL`, `DIRECT_DATABASE_URL`, `DB_SCHEMA` | Injected `TIER0_API_HOST` / `TIER0_API_KEY` | Remove app database connection usage; no credential UI |
| SDK | `@tier0/sdk` `^0.5.4` (locked 0.5.4) | `@tier0/sdk-v2` 0.12.2, exact npm version | Rewrite removed APIs; package rename alone is insufficient |
| Request scope | Gateway auth and CSRF middleware | `X-Tier0-Visitor` plus `runWithAbortSignal(request.signal, ...)` | App services enforce visitor data permissions; platform data calls act as App |
| Live App records | Request hooks / polling | `useRecordChanges` and authenticated `/api/uns/subscribe` | Events invalidate reads; they do not replace authorized API reads |
| Preview roles | Single selected role | Selected role set with permission union | Update Gateway/auth helpers and multi-role tests together |
| Production run | Explicit image in artifact | Platform-selected image | Remove run image pin; keep literal argv and Node entry |
| Verification | SQL/schema contracts | Data declarations, seeds, data-layer and stream tests | Replace retired gates with the complete upstream file/hash set |

The owning evidence is the two commits' `package.json`/lockfile,
`src/start.ts`, `src/lib/{visitor,auth,tier0}.ts` at v39 (older sources use `gateway.ts`), `artifact.toml`, the
added/removed data files, `AGENTS.md`, and `docs/platform-integration.md`.
Compare these at the chosen commits; do not infer a rollout from a merged source.

## Choose by Implementation, Then Provenance

Record the marker, known source commit, installed/locked SDK, data imports and
request-context provider. Marker numbers are clues, not proof: a partially
aligned app may still carry v7 while already using collections. Never migrate
or recreate existing collections merely because the marker is old. Likewise,
check what the target collections hold instead of assuming whether records
exist. At every version, historical data stays outside alignment (the user
imports it on the UNS side if needed), and missing old data never stops source
alignment.

### Drizzle / v7 and Earlier

Reconstruct from source models and business behavior without connecting to the
old PostgreSQL database or requesting its configuration. Historical data does
not migrate with alignment; if needed, the user imports it on the UNS side,
outside Builder. With full alignment or migration authorized, switch every
service to collections without waiting for any data, keep no SQL path, leave
the old deployment and database untouched, and follow
[first-ensure-and-runtime-blockers.md](first-ensure-and-runtime-blockers.md)
for initialization and blocked runtime checks.

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
5. Scan active source, runtime config, tests, dependency files and root
   `AGENTS.md` for old imports and database commands. Historical documentation
   may describe the old architecture; it must not remain active runtime
   guidance, and root `AGENTS.md` is always active guidance. In its
   App-Specific Rules, delete or rewrite only the affected sentences as
   SKILL.md describes; the business rules around them stay.

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
- `src/start.ts` uses the target's abort-signal wrapper. Remove the old
  local/employee context; preserve equivalent service-level user authorization
  before calls that now run as the App.
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
visitor/auth/preview-bridge helpers, route error boundary, and the kit's
`Pagination` / `QueryResult`. Take the matching gate manifest and its listed
files, `eslint.config.mjs`, relevant `tests/*.test.ts` and `test:data` wiring.
Preserve customized business behavior when merging these files.

For v9, adapt capped counts, `execution`/`retry` errors, partial-write
`resumeAfter` handling, batched reads and live subscriptions using
[App Data Contract](platform-contract.md#app-data-contract).
For every old SDK, apply [SDK Upgrades](platform-contract.md#sdk-upgrades):
0.3.0 removes methods as well as changing routes. Unsupported Flow/Agent
features remain blockers, never success-shaped stubs.

### Later Cloud Apps / v12–v26

Preserve existing collections and business code. Reconcile the selected target's
SDK spec/lockfile and complete gate set; apps with the dual-package
Stream candidate consolidate to the target's `@tier0/sdk-v2`. Apply
[Unified SDK migration](platform-contract.md#unified-sdk-and-stream-migration)
for removing browser platform calls, retired Controls, request/message semantics
and scope checks. Apply the pre-v27 migration below as one coordinated change. Refresh root AGENTS.md and its referenced docs while retaining App-owned
rules as described in the entrypoint. UI guidance and role-count advisories do
not authorize a redesign or role consolidation.

### Cloud Apps Before v27

Installing the v28 SDK alone breaks pre-v27 imports and can remove implicit
user filtering. Use the selected target's migration sections and bring over
these surfaces together, merging business customizations deliberately:

- Replace `src/lib/visitor.ts`, its tests and `src/lib/auth.ts` with the plain
  header parser (`parseVisitorHeader`). Retire JWT/JWKS and legacy role-header
  fallbacks; remove `dev-signer.ts` after migrating callers. Reconcile
  `vite.config.ts`'s local front door with `TIER0_RUNTIME` session detection.
- Replace `src/start.ts`, `src/lib/data/index.ts` and the matching lint rules.
  `runWithAbortSignal` replaces employee context; `runAsApp` callers move to
  `runDetached` only when work must outlive the request. Audit every service's
  read, write and field restrictions: the platform now sees only the App key.
  Preserve the existing business policy; unresolved user-scope rules block the
  affected slice rather than silently broadening access.
- Reconcile `src/lib/data/changes.ts`, `src/lib/record-changes.ts` and
  `src/routes/api/uns/subscribe.ts`. Add/adapt `src/lib/change-visibility.ts`.
  `canSeeChange` must match service visibility and must not expose restricted
  record IDs; it is synchronous and does not fetch records. Remove old
  `restricted`, collection-level events and `batch.collections` handling.
- Move browser MQTT and Stream calls into authenticated App server routes.
  Remove `getMqttToken`, browser token sources and `@tier0/sdk-v2/runtime`.
  Use the platform-injected key through SDK helpers, never node-proxy header
  workarounds or browser credentials.
- Take the target's locked files and gate-integrity manifest together, with
  the SDK spec/lockfile. Do not regenerate hashes over customized gates.

Scan active App source/config for removed `createVisitorTokenVerifier`,
`visitorReady`, `dev-signer`, `TIER0_JWKS_DIR`, `TIER0_JWKS_URL`,
`runWithRequestContext`, `runWithRequiredEmployeeContext`, `currentDataSubject`,
`X-Tier0-Delegation`, `runAsApp`, `getMqttToken` and `sdk-v2/runtime`.
Historical text can explain them; no active caller or configuration may rely
on them after full alignment.

### v27 to v28

Replace the SDK spec/lockfile with the selected target's. All MQTT
publish/subscribe topics use `appTopic(suffix)`; coordinate external producers
with the live App namespace without changing devices outside the task scope.
Remove per-App platform-policy configuration. App capabilities are fixed,
external collections require App grants, Stream requests require request grants,
and Stream messages follow published manifests.
Refresh root guidance and verify affected server/browser integration separately
from the source build. Preserve a user-pinned older target when requested.

### v28 to v29

Refresh the App's inherited guidance from the selected scaffold. Linking an
external collection or expanding access required confirmation at v29. v30
replaces this with [Builder grant management](platform-contract.md#fixed-app-capabilities-and-external-collections).
The SDK version was unchanged between v28 and v29. Compare the selected source for other inherited
changes before copying its version marker.

## Cross-Version Acceptance

- Merge target dependencies into the App manifest and regenerate its lockfile;
  preserve business dependencies. Do not copy a blank scaffold lockfile over a
  customized dependency graph. Verify an exact install separately from build.
- Preserve request cancellation through `runWithAbortSignal`. Test the App's
  service-level user filtering, write guards and field trimming through HTTP
  and server functions, including denied cases. Detached work keeps explicit
  business authorization; it does not create a different data identity.
- Refresh App record views through `useRecordChanges` with aliases. Cover
  changes, resets, hidden-page close/resume and `canSeeChange` filtering;
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

## Cloud Apps At v28–v29 → v30

Upgrade the vendor archive, dependency and lockfile to SDK 0.10.1 together.
The stable release preserves the v28 App-key/visitor/data/change-relay model;
do not rerun a persistence migration for an already aligned App. Refresh SDK
discovery to the nested `skills/tier0-sdk-v2/SKILL.md` entry and reconcile
Builder grant management with the current installed SDK. Preserve existing
grants and disabled policies; verify effective access as the App, not only
as the management caller. SDK installation does not prove Backend rollout.

## Cloud Apps At v30 → v39

Apps at v28–v29 first apply the v30 guidance and grant changes above, then
this section; install only the v39 SDK. Bring these over together:

- SDK (v35, v37): set `@tier0/sdk-v2` to the target's exact npm version
  (`0.12.2`) and reconcile the lockfile so its entry resolves from the npm
  registry. Delete old `vendor/tier0-sdk-v2-*.tgz` archives, including the
  v32–v34 `0.10.1-aenv.13` build, and `vendor/` itself when nothing else uses
  it. Check the lockfile entry against
  [latest-template-source.md](latest-template-source.md).
- Employee-only visitors (v32): delete `src/lib/webhooks.ts` and take the
  target's locked `src/start.ts`, `src/lib/auth.ts`, `src/lib/visitor.test.ts`
  and `scripts/gate-integrity.json`. A machine identity is 401 on every path.
  When the App declared webhook paths or `[[webhooks]]`, remove them and tell
  the user in the report that machine visitors are rejected from v32 and those
  webhooks no longer work; do not keep or emulate an inbound machine path.
- Roles (v33): take the target's `src/lib/permissions.test.mjs` and
  `tests/role-contract.test.mjs`, then migrate `roles.json` as in
  [Platform Role Registration](platform-contract.md#platform-role-registration).
- Request origin (v34): copy `server-url.mjs` and `tests/server-url.test.mjs`,
  merge the `requestBaseUrl(...)` call into a customized `server.mjs`, set
  `artifact.toml` `include = ["dist", "server.mjs", "server-url.mjs"]`, and add
  the `test:server` script to `postbuild` and `test`.
- Shell (v35): `src/components/Shell.tsx` hides the sidebar role line when no
  role is assigned; merge it into a customized shell.
- Change-visibility test (v36): the scaffold no longer tests `canSeeChange`.
  If `tests/record-changes.test.ts` still has the "lets every change through
  until the App defines its rules" case and the App has its own rule, delete
  that case or make it test the App's rule.
- API failures (v37): take the target's `src/lib/hooks-contracts.test.mjs`
  and `docs/ui-rules.md`. In `src/lib/utils.ts`, remove the `sendPreviewError`
  import and the 5xx `sendPreviewError(..., "network")` branch of
  `requestJson()` and keep the App's other edits to that file. Pages whose
  data loads relied on that blocking preview card must show the failure in the
  affected `AsyncView` or form.
- Gates (v38): take the target's `scripts/post-build-verify.mjs`,
  `scripts/gate-integrity.mjs`, `scripts/route-nesting.mjs`,
  `src/lib/route-nesting-contracts.test.mjs` and `scripts/gate-integrity.json`
  together with the other locked files that manifest pins. The App build no
  longer runs `src/lib/template-state.test.mjs`; replace an adapted copy with
  the target's file and do not add the scaffold-CI `test:template` script to
  the App.
- Default error component (v39): in `src/router.tsx`, import
  `RouteErrorBoundary` from `@/components/ui` and pass it as
  `defaultErrorComponent` to `createTanStackRouter`, keeping the App's other
  router options. Copy `tests/route-error-default.test.ts`, add it to the
  `test:components` script, and take the target's `docs/ui-rules.md`. Existing
  route `errorComponent`s stay; new pages need none.
- Refresh root `AGENTS.md`, `docs/platform-integration.md` and
  `docs/role-registration.md` as the entrypoint describes, then write the v39
  marker only after full verification.
