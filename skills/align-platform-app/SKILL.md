---
name: align-platform-app
description: >-
  Migrate imported applications into the Tier0 TanStack Start scaffold, align
  an existing Tier0 app with upstream scaffold changes, or migrate app-owned
  browser/mock business persistence to Drizzle/PostgreSQL. Use for explicit
  platform alignment, migration, and scaffold upgrades; ordinary feature or
  visual edits alone do not require a full alignment audit. Also use when an
  instruction says "align this app to the latest scaffold" or "追平到最新脚手架",
  or asks to update tier0Scaffold in package.json after aligning.
---

# Align Platform App

Preserve the application's business behavior while closing the platform gaps
within the user's requested scope. The canonical scaffold is
`https://github.com/FREEZONEX/Tier0-App-Scaffold.git`, branch `main`, unless the
user chooses a specific ref. A newer template is not permission to overwrite
business routes, schema, role mappings, branding, or intentional design choices.

At import, the platform compares the app's `package.json` top-level
`tier0Scaffold` marker with the current scaffold; when it is missing or
different, the Builder offers the user one of these instructions:

- `/skill:align-platform-app 将本应用追平到最新脚手架，保留业务代码，完成后更新 package.json 的 tier0Scaffold。`
- `/skill:align-platform-app Align this app to the latest scaffold, keep business code, then update tier0Scaffold in package.json.`

Treat either as a request to align against the target above. Choose an existing
scaffold update or imported app migration from the source structure; the user
does not need to send a separate migration request for a non-scaffold app.
Finish with the `tier0Scaffold` write-back described under Completion.

## Choose The Scope

Recommend alignment for both scaffold-based and external apps. When alignment
is requested, inspect the framework, entry points, runtime files, and platform
integration to choose the path. Missing `artifact.toml`,
`src/services/bootstrap.ts`, or `tier0Scaffold` indicates gaps to investigate,
not grounds to reject alignment. A missing version marker alone does not make
an existing scaffold app an external app; a marker alone does not prove
compatibility. Route a clearly non-scaffold app (including a static site from
another template) into imported app migration and proceed. Explain the required
conversion without asking the user to authorize the same alignment again.
Uploading a package alone is not a request to modify it; review-only requests
remain read-only.

- **Imported app migration:** inventory the source and choose direct conversion
  or a temporary compatibility boundary. Read
  [migration-workflow.md](references/migration-workflow.md); for a large or
  fragile source, also read
  [compatibility-boundary.md](references/compatibility-boundary.md).
- **Existing scaffold update:** compare the app's known base, local changes,
  and target scaffold commit where possible; an existing `tier0Scaffold.ref`
  in `package.json` identifies the known base. Classify drift as required platform
  contract, app customization, or unrelated change. Patch the requested surfaces
  and their necessary dependencies; do not start a data migration, rebrand, or
  full UI rewrite solely because upstream changed. With no known base, inspect
  diffs and callers rather than treating every difference as template drift.
- **Persistence cutover:** read
  [local-state-to-drizzle.md](references/local-state-to-drizzle.md) only when
  app-owned durable records actually use browser storage, persisted client
  stores, in-memory mocks, or fixtures. UI preferences and caches are not durable
  business records. Preserve external systems of record unless migration of
  their ownership is explicitly in scope.
- **Review only:** inspect and report evidence and proposed changes without
  modifying the app or registering platform metadata.

Honor already-authorized updates without repeatedly asking for permission.
If a needed choice changes business behavior, loses data, broadens access, or
expands the requested scope, identify the concrete decision and continue
independent work while awaiting it. Never silently consolidate source roles or
reset legacy data to make a gate pass.

## Establish The Baseline

Read [latest-template-source.md](references/latest-template-source.md) to select
and record an exact upstream commit. Inspect changed contract surfaces relevant
to the task, not every platform subsystem for a narrow update. Read the affected
sections of [platform-contract.md](references/platform-contract.md) before
changing routing, runtime, auth, data, design, or packaging contracts.

If remote access fails, a user-provided package or cached commit may support
bounded work; state the exact baseline and that freshness is unverified. Do not
claim it is latest or rewrite the Skill inside the target App. Platform-managed
Skills are injected by the orchestrator and must not be vendored into the App.

When implementation, docs, and locked tests disagree, trace actual behavior and
record the conflict. Do not grant extra access, delete business behavior, or
weaken a gate to reconcile contradictory guidance.

## Apply The Relevant Contracts

- For an existing scaffold app, keep its TanStack Start project without
  reinitializing it. For an external app, establish the inspected scaffold's
  target structure and bring over business code through direct conversion or
  a compatibility boundary; do not overwrite it with a blank template. Do not
  introduce Next.js patterns into the target. Preserve the scaffold production
  entry, health/manifest, router/root, Gateway and Vite boundaries; reconcile changes to these files
  deliberately when platform/runtime alignment is the task. Never hand-edit
  generated `src/routeTree.gen.ts`.
- Preserve route semantics. A nested list/detail resource needs an outlet and
  index/detail routes; a standalone detail uses trailing-`_` opt-out. Navigation
  leaves must resolve to unique real routes. Use `apiUrl()` for local APIs.
- Gateway owns login, logout, identity, and role assignment. Remove imported
  App-local sessions, logout and role-picker implementations in a full migration.
  Authorize with `user.roles` permission union, never `primaryRole`. Preview
  without a selected role has zero roles/permissions; there is no admin fallback.
  Every defined role must be represented in matrix, metadata, and `roles.json`.
  The current first-version gate allows three business roles total; `admin`, if
  business-defined, counts as one. Preserve roleless sources without inventing
  privileges. Use the reference's environment-specific auth checks when affected.
- For data changes, declare tables/enums via `appSchema` in `src/db/schema.ts`.
  The platform provisions the schema: remove runtime `CREATE SCHEMA`, including
  `IF NOT EXISTS`, while preserving idempotent table/index setup in `DB_SCHEMA`.
  Pass declared tables to `bootstrapModule()` and await its module promise
  before querying. Follow the reference's guarded `db:push` workflow.
- HTTP routes authenticate/validate and call services; services own database
  queries, invariants, transactions, and supported lifecycle transitions. Durable
  writes must survive reloads, and database errors must not fall back to browser
  state or fixtures. Migrated business data enters through explicit import;
  ordinary startup must not silently repopulate demo rows. Do not impose blanket
  CRUD on ledgers, audit events, or other domain objects with restricted actions.
- Keep Node-only modules out of client/mixed import graphs. Load Tier0 SDK
  modules lazily inside server actions through `@/lib/tier0`. Use runtime
  `resolveAppId()` for platform App identity, not the human name, schema name,
  or a hard-coded UUID. Application files use platform File Storage.
- When updating SDK dependencies, reconcile the package range and lockfile with
  the selected scaffold target; do not downgrade a newer SDK to 0.5.3. SDK
  0.5.3 is the baseline for the MQTT fixes described here. Preserve intentional
  silent notifications with `channels: []`; omitted channels now enable Web & Desktop plus Mobile.
  Read [the SDK upgrade contract](references/platform-contract.md#sdk-upgrades)
  for channel, test-mode and MQTT migration details. For MQTT authentication
  failures, check installed SDK/key compatibility before replacing credentials
  or overriding identity. Skill replacement alone
  does not change the installed SDK. Before a platform API-key type change,
  apply the [existing-App compatibility prerequisite](references/platform-contract.md#existing-app-api-key-type-changes);
  do not automatically switch credentials while upgrade/verification is blocked.
- For affected UI, read current `DESIGN.md` and compose the existing primitives.
  Ordinary `_app` roots use `page-shell` for shared responsive padding; avoid
  duplicate outer insets. Station/review/monitor keep their own spacing.
  Interactive pages remain usable at 375px with local wide-content scrolling.
- Replace native product `alert`/`confirm`/`prompt` with toast or application
  dialogs. Follow the reference's asynchronous confirmation pattern: open first,
  mutate only on confirmed submit, preserve cancellation and pending/error states.
  This guidance does not require adding a scanner or build gate.
- Preserve valid branding. For generated/rebranded assets, keep root `icon.png`
  and an identical `public/app-icon.png`, plus root `cover.png` when registering
  a cover. Register root paths only; report local files and remote metadata sync
  separately. Sizes, dimensions, and identity details live in the reference.

## Verify The Changed Behavior

Use the scaffold's full `npm run build`, including automatic postbuild checks;
`vite build` alone is insufficient. Keep locked tests and verification scripts
intact. For a requested upstream gate update, take the verified matching upstream
files/hash set together; do not edit their assertions or hash values merely to
accept failing app code. Only `template-state.test.mjs` is App-adaptable under
the current baseline. Nonblocking UI advisories are not build failures.

Managed preview owns dependency installation and process startup. Use
`preview_start` / logs / restart when available; do not race it with manual
installs or dev servers. In an unmanaged environment use the authoritative
lockfile. Distinguish exact install, full build, and runtime results; an install
that changes the lockfile does not prove the original lockfile works.

Scale further verification to affected behavior:

- **Routes/UI:** run `npm run smoke:routes -- <local-url> [/changed-route ...]`
  when preview supplies a URL, inspect hydration/browser errors, exercise changed
  interactions, and check affected mobile layouts. The container-local URL is a
  self-check address, not the user-facing preview link.
- **Roles/auth:** test relevant Preview, deployed union/empty/unknown roles,
  untrusted legacy roles, and unauthenticated cases from the contract reference.
- **Persistence:** prove supported operations through HTTP, validation and
  authorization failures, reload/restart durability where controllable, and
  visible database failures without local fallback. Use a disposable or explicitly
  authorized test environment for writes; do not disrupt a live database to
  simulate an outage. Verify import reconciliation when data is retained.
- **Runtime/deploy:** when changed or delivering a full migration, verify
  production entry, host/port binding, health, manifest, SSR and client assets
  under the target environment. A static build does not prove deployability.
- **Package:** confirm whether the deliverable is source or a built runtime
  artifact and check the actual importer layout. Verify CRC, exclusions, and
  correspondence to the declared source; do not require build output in a source
  ZIP or ship dependencies by default.

For failures, load only the relevant section of
[import-troubleshooting.md](references/import-troubleshooting.md).
Use `preview-runtime-stability` for managed preview failures only when injected;
otherwise inspect available logs/tools and report unavailable verification.
Use `migrate-node-red-app` for Node-RED-specific migration only when available;
absence does not justify inventing its instructions or deleting flows.

## Completion

Report the source/target baseline, scope actually changed, behavior preserved,
verification passed/failed/not run, and remaining concrete blockers. A partial
scaffold update need not complete unrelated migration work; a full migration
cannot be called complete while its required runtime or persistence checks remain
blocked. Distinguish local edits/packages from platform registration, deployment,
and remote publication. Keep retained compatibility boundaries and intentional
app divergence explicit so the next update does not overwrite them.

After every verification passes, and only then, set the app's `package.json`
top-level `tier0Scaffold` to the exact object in `package.json` of the inspected
scaffold commit: copy `version` (integer) and `ref` (commit hex) as-is; never
invent, bump, or derive them. If that scaffold `package.json` has no
`tier0Scaffold`, do not write the field and say so in the report. Never write
it while any verification fails, when alignment stopped early, or while the
app has not met the target scaffold contracts. An app that started outside the
scaffold receives the same marker after its migration and verification pass.

## List-Page Foundation

When the authorized migration or UI alignment includes creating or rebuilding
list-type pages, default to the selected scaffold's `MetaListPage` and follow
its `docs/component-kit.md`. Map existing metadata, real query services,
permissions and business actions through `ComponentKitProvider` and the page's
extension props. Preserve saved views and existing workflows where applicable;
do not replace business data with gallery fixtures. Lower-level tables are not
the default page shell. A concrete workflow mismatch or explicit user choice
may justify a different composition; record it. This default does not authorize
rewriting working list pages during an unrelated runtime, SDK or auth alignment.
