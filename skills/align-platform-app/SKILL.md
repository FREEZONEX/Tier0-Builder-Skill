---
name: align-platform-app
description: >-
  Migrate imported applications into the Tier0 TanStack Start scaffold, align
  an existing Tier0 app with upstream scaffold changes, or move app-owned
  browser/mock business persistence into Tier0 UNS collections. Use for explicit
  platform alignment, migration, and scaffold upgrades; ordinary feature or
  visual edits alone do not require a full alignment audit. Also use when an
  instruction says "align this app to the latest scaffold" or "追平到最新脚手架",
  or asks to update tier0Scaffold in package.json after aligning.
---

# Align Platform App

Preserve the application's business behavior while closing the platform gaps
within the user's requested scope. The canonical scaffold is
`https://github.com/FREEZONEX/Tier0-App-Scaffold.git`, branch
`feature/cloud-new-architecture-migration` (Tier0 cloud), unless the user
chooses a specific ref. A newer template is not permission to overwrite
business routes, schema, role mappings, branding, or intentional design choices.

At import, the platform compares the app's `package.json` top-level
`tier0Scaffold` marker with the current scaffold; when it is missing or
different, the Builder offers the user one of these instructions:

- `/skill:align-platform-app 将本应用追平到最新脚手架，保留业务代码，完成后更新 package.json 的 tier0Scaffold。`
- `/skill:align-platform-app Align this app to the latest scaffold, keep business code, then update tier0Scaffold in package.json.`

Treat either as an existing scaffold update against the target above, ending
with the `tier0Scaffold` write-back described under Completion.

## Choose The Scope

Identify the source using its marker, Git history, and actual platform files
(`artifact.toml`, `server.mjs`, Gateway middleware, health/manifest routes).
A missing marker or one missing file can be the drift to repair; neither an
`artifact.toml` alone nor its absence proves the app's origin. If the project
is clearly unrelated to the scaffold and only alignment was requested, report
"not a Tier0 scaffold app; alignment not applicable" without changing files or
writing the marker. An explicit import/migration request still proceeds.

- **Imported app migration:** inventory the source and choose direct conversion
  or a temporary compatibility boundary. Read
  [migration-workflow.md](references/migration-workflow.md); for a large or
  fragile source, also read
  [compatibility-boundary.md](references/compatibility-boundary.md).
- **Existing scaffold update:** compare the app's known base, local changes,
  and target scaffold commit where possible; an existing `tier0Scaffold.ref`
  in `package.json` identifies the known base. Classify drift as required platform
  contract, app customization, or unrelated change. Patch the requested surfaces
  and their necessary dependencies. A full v7-to-cloud alignment necessarily
  replaces the old persistence architecture; a scoped SDK/UI repair does not
  authorize that cutover or a full UI rewrite. With no known base, inspect
  diffs and callers rather than treating every difference as template drift.
- **Cross-architecture upgrade:** read
  [cloud-architecture-upgrade.md](references/cloud-architecture-upgrade.md).
  Select the path using both provenance and actual code: v7/Drizzle needs a
  persistence rewrite, v8 replaces its local client, and v9–v11 reconcile
  SDK/runtime contracts. Whether records exist depends on the target
  collections, not the version. Mixed or partially upgraded apps need a
  per-surface inventory, not a version-number shortcut.
- **Persistence cutover:** read
  [local-state-to-collections.md](references/local-state-to-collections.md) only when
  app-owned durable records actually use browser storage, persisted client
  stores, in-memory mocks, or fixtures. UI preferences and caches are not durable
  business records. Preserve external systems of record unless migration of
  their ownership is explicitly in scope.
- **Review only:** inspect and report evidence and proposed changes without
  modifying the app or registering platform metadata.

Honor already-authorized updates without repeatedly asking for permission.
If a needed choice changes business behavior, loses existing data, broadens
access, or expands the requested scope, identify the concrete decision and
continue independent work while awaiting it. Records left untouched in the
original app or environment for a later user import are not lost and need no
decision. Never silently consolidate source roles, or delete or reset existing
records, to make a gate pass.

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

## Initialization, Blockers, and Historical Data

Read [first-ensure-and-runtime-blockers.md](references/first-ensure-and-runtime-blockers.md)
for first initialization or a platform/API blocker. A context 403 saying
`active hosted App data policy required` can mean no policy yet or a disabled
policy; verify identity and the real declarations with ensure dry-run before
assigning a cause. Context success is not a prerequisite for first ensure.
Never override an explicit revoked grant or disabled policy.

Continue independent source reconstruction and available checks while runtime
verification is blocked. A context 403 or unconfirmed collection or import
permissions block only runtime acceptance and the later import. Do not stop at a
migration plan, keep the old data source to protect historical records or
because the target API is blocked, or write a completion marker without required
runtime evidence.

For every pre-v12 source, historical records are whatever the target
collections actually hold; an App moved to another environment gets new
collections from its first ensure there, without the old records. Do not connect
to the original database or environment or request connection configuration.
If historical data is needed, guide the user to export it from the original
application, continue reconstruction without waiting for the export, and import
or manually enter the data only after reconstruction is ready. The original
deployment and its data stay untouched; rewriting this App's source is the
alignment itself. Report "source rewritten", "runtime acceptance pending/passed"
and "historical data not imported/imported" separately; pending historical entry
alone does not block alignment.

## Apply The Relevant Contracts

- Keep the existing TanStack Start project; do not reinitialize it or introduce
  Next.js patterns. Preserve the scaffold production entry, health/manifest,
  router/root, Gateway and Vite boundaries; reconcile changes to these files
  deliberately when platform/runtime alignment is the task. Never hand-edit
  generated `src/routeTree.gen.ts`. `artifact.toml` sets no production run
  `image`: the platform supplies each environment's runtime image, so delete a
  hardcoded `[services.production.run].image` such as `node:22-alpine`.
- Preserve route semantics. A nested list/detail resource needs an outlet and
  index/detail routes; a standalone detail uses trailing-`_` opt-out. Navigation
  leaves must resolve to unique real routes. Use `apiUrl()` for local APIs.
- Gateway owns login, logout, identity, and role assignment. Remove imported
  App-local sessions, logout and role-picker implementations in a full migration.
  Authorize with `user.roles` permission union, never `primaryRole`. Preview
  carries the developer's view-as role set with the same union; without a
  selected role it has zero roles/permissions; there is no admin fallback.
  Every defined role must be represented in matrix, metadata, and `roles.json`.
  The current first-version gate allows three business roles total; `admin`, if
  business-defined, counts as one. Preserve roleless sources without inventing
  privileges. Use the reference's environment-specific auth checks when affected.
- For data changes, declare collections with `defineCollection` from
  `@tier0/sdk-v2/data/define` in `src/data/collections.ts` and list them in
  `collections`; the schema is a storage schema limited to the subset in the
  scaffold's AGENTS.md → App Data. The App ensures every declared collection on
  first data access; there is no SQL database, migration or `db:push` step.
  Preview and the deployed App share the same collections, ensure only widens,
  and narrowing or description changes go through `schema:replace` via the tier0
  MCP. Baseline records are the declaration's `seed`, written once when the
  collection is created.
- HTTP routes authenticate/validate and call services; services own data access
  (`data` from `@/lib/data`), invariants, `data.transact` steps, and supported
  lifecycle transitions. Durable writes must survive reloads, and data-layer
  errors (`DataError`) must not fall back to browser state or fixtures. Migrated
  business data enters through explicit import; services never insert baseline
  rows on startup or when a list is empty. Do not impose blanket CRUD on
  ledgers, audit events, or other domain objects with restricted actions.
- Keep Node-only modules out of client/mixed import graphs. Load Tier0 SDK
  modules lazily inside server actions through `@/lib/tier0`; values from
  `@tier0/sdk-v2/data` stay in services, `src/lib/data` and `src/start.ts`,
  while any file may import declarations from `@tier0/sdk-v2/data/define`. Use
  runtime `resolveAppId()` for platform App identity, not the human name or a
  hard-coded UUID. Application files use platform File Storage.
- The platform SDK is `@tier0/sdk-v2`; copy the exact npm version the selected
  scaffold pins (`0.3.0` at v12). An app
  on `@tier0/sdk` (v1) moves to it: replace the dependency, re-point imports to
  the v2 entries, and rewrite calls whose v1 APIs no longer exist (UNS v1, Flow,
  project members, `getTier0UnsApi` / `getTier0FlowApi` / `getTier0SystemApi`).
  Read [the SDK contract](references/platform-contract.md#sdk-upgrades) and the
  Skills shipped in `node_modules/@tier0/sdk-v2/skills/` before rewriting SDK
  calls. Skill replacement alone does not change the installed SDK. For MQTT
  authentication failures, check the installed SDK and key type before
  replacing credentials or overriding identity.
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
  visible data-layer failures (`DataError`) without local fallback. Preview
  writes land in the same collections as the deployed App, so write test
  records only where authorized and clean them up; never `deleteMany` or
  recreate a collection to reset it. Verify import reconciliation when an import
  runs.
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

## Completion

Report the source/target baseline, scope actually changed, behavior preserved,
verification passed/failed/not run, and remaining concrete blockers. A partial
scaffold update need not complete unrelated migration work; a full migration
cannot be called complete while its required runtime or persistence checks remain
blocked. Distinguish local edits/packages from platform registration, deployment,
and remote publication. Keep retained compatibility boundaries and intentional
app divergence explicit so the next update does not overwrite them.

For full alignment, verify every applicable target contract before writing
its marker. A scoped repair or partial upgrade keeps the previous marker (or
leaves it absent), even if its own checks pass; otherwise the platform would
mistake a mixed architecture for a fully aligned app. Required checks that
could not run are pending, not passes.

After full alignment verification passes, and only then, set the app's `package.json`
top-level `tier0Scaffold` to the exact object in `package.json` of the inspected
scaffold commit: copy `version` (integer) and `ref` (commit hex) as-is; never
invent, bump, or derive them. If that scaffold `package.json` has no
`tier0Scaffold`, do not write the field and say so in the report. Never write
it while any verification fails, when alignment stopped early, or for a
non-scaffold app.

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
