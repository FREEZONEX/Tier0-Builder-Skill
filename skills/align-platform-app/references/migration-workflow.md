# Platform App Alignment Workflow

## Contents

- [1. Source Inventory](#1-source-inventory)
- [2. Strategy Selection](#2-strategy-selection)
- [3. Migration Order](#3-migration-order)
- [4. Verification Checklist](#4-verification-checklist)

## 1. Source Inventory

Before source inventory, fetch or inspect the latest Tier0 platform template as
described in `latest-template-source.md` when the migration depends on platform
contract details.

Inspect these source areas before editing target code:

- `package.json` and lockfiles: scripts, dependencies, framework, module type,
  package manager, peer requirements, and lockfile ownership.
- Entry points: `index.html`, `src/main.*`, `src/App.*`, framework app folders.
- Routing: route arrays, router providers, file routes, dynamic params, redirects,
  each resource's list/detail nesting intent, and whether detail should replace
  the list or render inside a parent/master-detail surface.
- Layout: shells, sidebars, top bars, providers, auth guards, error boundaries.
- Navigation: every clickable leaf, its target, visibility rule, and whether the
  target is a real non-API route.
- Auth/role surface: search legacy login, logout/sign-out, switch-role,
  role-picker, and impersonation in navigation buttons, personal menus, pages,
  modals, API helpers, localStorage/sessionStorage, and cookie role writes.
- Role model: determine whether the source is roleless or role-aware. For a
  role-aware source, inventory role definitions, user-role and permission
  mappings, menu/page/action guards, API authorization rules,
  `PERMISSION_MATRIX`, `ROLE_METADATA`, `roles.json`, and related manifest
  entries. Do not invent roles for a roleless source.
- State: Zustand/Redux/Context stores, `persist` middleware,
  localStorage/sessionStorage calls, IndexedDB wrappers, caches, and reset paths.
- Data access: fetch wrappers, GraphQL clients, REST clients, in-memory
  repositories, mock handlers, JSON fixtures, and SDK clients.
- Server/runtime: API routes, server entry, workers, adapters, cron-like jobs,
  custom middleware, and framework-specific server handlers.
- Data layer: schema files, migrations, seed data, local JSON stores, browser
  storage reliance, and backend persistence assumptions.
- Assets: public paths, imported images, fonts, CSS resets, CDN references.
- App identity/design: product name, locale, in-App icon, platform App metadata,
  default scaffold copy, design tokens, shared UI/form/table/data primitives.
- Environment: `.env*`, `import.meta.env`, `process.env`, hard-coded hosts.
- i18n/theme: locale files, RTL/LTR logic, theme tokens, CSS variables.
- Legacy runtime/deployment assets: containers, reverse proxies, old ports/base
  paths/hosts, schedulers, credentials, reset endpoints, and retired backend
  documentation. Inventory first; do not delete based on a keyword match alone.
- Skill packaging: find any vendored `.agents/skills/` content. Record it for
  removal; platform Builder Skills are orchestrator-injected.

For every local or mock state source, record its keys/store names, data shape,
identifier generation, readers, writers, initialization, reset behavior, and
whether it is durable business data, session/UI preference, cache/derived state,
or seed/test data. Load `local-state-to-drizzle.md` when any production CRUD is
local or mocked.

Write a short migration map when the source is non-trivial:

- source route -> target route file, layout posture, and nesting mode: parent
  outlet plus `.index.tsx`/`.$param.tsx`, intentional master-detail outlet, or
  trailing-`_` standalone detail
- source navigation leaf -> unique target route and permission visibility
- source provider -> target provider/boundary
- source API/server helper -> target service/API/external dependency
- compatibility API -> method, request, response, errors, auth, side effects,
  implementation status, external dependencies, and verification evidence
- source data model -> target schema/runtime-bootstrap-or-`db:push`/service/API/
  client path or external system
- source local/mock data -> PostgreSQL cutover, optional legacy import, or an
  explicitly retained ephemeral state category
- source asset path -> target asset path
- source App name/locale/icon -> `app-chrome` identity and platform metadata
- source env var -> platform/runtime source or removed setting

## 2. Strategy Selection

Use direct conversion when:

- The source has few routes.
- Components and server pieces are already framework-neutral or easy to isolate.
- Data access is easy to remap to scaffold services, API routes, or external
  platform services.
- Styling is contained and compatible with target globals.

Use a compatibility boundary when:

- The source has many routes or a custom router.
- Global state, CSS, or browser-only code is fragile.
- The user requires preserving full business behavior first.
- Build/runtime contract work is urgent and native refactoring can follow.

A compatibility boundary may temporarily read legacy durable state for explicit
import, but it must not legitimize new durable local writes or database-failure
fallback.

A JSON or JSONB compatibility container may complete authoritative-storage
cutover without completing domain normalization. Record which invariants,
relationships, constraints, indexes, transactions, and query fields remain to be
modeled. Do not report storage cutover as full domain migration.

## 3. Migration Order

Prefer this sequence:

1. Establish the selected scaffold's platform shell and build/runtime contract
   when the source lacks them, including `artifact.toml`, production and preview
   entries. Preserve existing business source while converting or adapting it;
   missing scaffold files are migration work, not a reason to stop alignment.
2. Read current `DESIGN.md`; bring in assets, global styles, and source
   providers behind an explicit boundary while composing scaffold primitives.
   Apply workspace `page-shell` and asynchronous dialog migration as described
   in `platform-contract.md`; preserve cancel/submit behavior and avoid double padding.
3. Mount primary routes and navigation. For every list/detail resource, choose
   the nested parent/outlet plus sibling `.index.tsx` and `.$param.tsx` shape, an
   intentional master-detail parent with an outlet, or a trailing-`_`
   non-nested detail. Define real workspace modules through
   `defineNavigationModules`; every clickable leaf has a unique `href` resolving
   to an existing non-API route.
4. Classify local/mock state and define PostgreSQL as the source of truth for
   durable entities.
5. Replace durable local/mock CRUD in vertical slices using
   `appSchema` declarations in `src/db/schema.ts` -> current scaffold
   `bootstrapModule()` with declared table objects / guarded `db:push` -> service
   -> thin API -> client.
6. Import legacy data through an explicit validated, idempotent process when
   retention is required; otherwise document reset/cutover.
7. Keep idempotent runtime DDL bootstrap for tables and indexes in the existing
   platform-injected `DB_SCHEMA`. Remove App-side `CREATE SCHEMA`, including
   `IF NOT EXISTS`, without expanding database-account privileges. Also
   remove startup- or first-request seed callbacks that auto-insert demo, sample,
   or baseline rows for migrated durable business entities. Retain legacy data
   through the explicit import from step 6; run development/test fixtures only
   through an explicit development or test action. For valid retained runtime
   baseline data, use `seedDate()` / `seedTimestamp()` and typed transactional
   Drizzle writes, not raw SQL data writes or mutating `Date` setters.
8. Normalize auth, permissions, and menu visibility. Remove legacy custom login
   and all user-visible logout/sign-out buttons, personal-menu entries, pages,
   routes, and custom logout helpers, together with role-switch, role-picker, and
   impersonation entry points. Reconcile to the current Gateway-only scaffold:
   remove App-local session/logout/select-role code, keep `/api/auth/me` and the
   hidden `/login` error bridge when present, and never clear the Gateway Cookie.
9. Keep a roleless source roleless. For a role-aware source, migrate every role
   definition, user-role and permission mapping, menu/page/action guard, API
   authorization rule, and registration entry across `PERMISSION_MATRIX`,
   `ROLE_METADATA`, and `roles.json`. Validate role keys against
   `^[a-z]+(_[a-z]+)*$`; authorize with `user.roles` permission union, never the
   primary display role. The first version allows at most three materially
   distinct business roles total, with no reserved or fallback role. If the source
   exceeds that cap, stop
   for an explicit user/platform-approved consolidation or phased migration;
   never silently drop, broaden, collapse, or zero-permission a source role.
10. Finish App identity: real name and locale in `app-chrome`, placeholder copy
    removed, and—when generated or rebranded—the same platform-ready
    root `icon.png` copied byte-for-byte to `public/app-icon.png`, then
    registered from the root path. Persist any registered cover as root
    `cover.png`. Follow the identity section in `platform-contract.md`.
11. Incrementally extract reusable components into scaffold-native folders.
12. Remove compatibility shims and durable local stores only after equivalent
   native API-backed routes are verified.
13. When a synchronous helper becomes asynchronous, audit its complete caller
    graph before relying on typecheck. Find callers that use the returned Promise
    as a `Map` (`.get`, `.set`, iteration), array (`.map`, `.filter`, spread), or
    immediate render value. Do not make a React render function or synchronous
    `useMemo` callback async; resolve data in a loader, effect, query, or server
    boundary and render settled state.
14. Treat every retained or introduced `@ts-nocheck` as a runtime-contract risk.
    Add focused runtime smoke coverage for the suppressed module and its callers;
    a successful build is not evidence that values have the expected shape.
15. When compatibility API routes remain, maintain a behavior matrix covering
    method, input, output envelope, pagination, errors, authorization, business
    side effects, backing persistence, external execution, implementation status,
    and verification evidence. Route reachability is not behavioral equivalence.
16. Classify legacy runtime and deployment assets as active dependency, obsolete
    deployment artifact, historical documentation, intentional retirement
    record, or false positive. Remove or replace active-delivery residue only
    after its target behavior and rollback implications are understood.
17. Remove vendored `.agents/skills/` content. Use platform-managed Skills only
    when the App Builder orchestrator injects them.

## 4. Verification Checklist

For each migrated route, verify:

- Check both SSR/server output and the browser console. A clean server log does
  not exclude a browser import, hydration, or event-handler failure.
- Wait for hydration, then exercise links, forms, dialogs, and another stateful
  interaction. Vite `ready` and an HTTP 200 prove transport, not hydration.
- If preserving `react-router-dom`, render `BrowserRouter` only inside
  `ClientOnly`; do not let SSR evaluate its `document`-dependent setup.
- It is reachable by URL and navigation.
- Its list/detail behavior matches the recorded nesting mode: every nested
  detail renders through an outlet, and every standalone detail uses an explicit
  trailing-`_` opt-out.
- Every clickable navigation leaf has a unique `href` resolving to a real
  non-API route.
- It renders without hydration/runtime errors.
- Browser-only libraries are guarded or loaded client-side.
- Server-side logic runs through scaffold API/service boundaries.
- Assets and fonts load under the deployed base path.
- Data reads and writes hit intended APIs, services, or external systems.
- Local App APIs are called through base-path-aware `apiUrl()`.
- Durable data survives reload, another client session, and server restart.
- Database/network failures are visible and never trigger local/mock fallback.
- Empty, loading, error, and success states are real. Scaffold request-hook
  results render through `AsyncView` so a failed first request shows error/retry
  instead of endless loading.
- When historical data is intentionally not imported, reads from a clean schema
  return a genuine empty state with real creation/onboarding actions; they do not
  fall back to browser data, fixtures, mocks, or the retired backend.
- User-facing copy has no placeholder migration language.
- Page content does not repeat the title or explain navigation in an
  introduction subtitle.
- A management route completes its applicable lifecycle, or an intentional
  monitor/report/audit/derived-result route carries an accurate
  `READ_ONLY_SURFACE: <reason>` marker.
- At 375px, interactive content stays usable without page-level horizontal
  overflow. Flexible form controls are bounded, and widths above 375px remain
  inside a local horizontal-scroll region.
- Imported/migrated menus, personal menus, pages, routes, and modals contain no
  user-visible logout/sign-out or app-managed role-switch, role-picker, or
  impersonation entry. Custom logout helpers, App-local auth sessions,
  logout/select-role endpoints, and Gateway Cookie writes are removed.

For the whole app, verify:

- The current normal build command and complete post-build verifier pass.
  Migration-introduced and runtime-risk failures block completion; genuine
  historical non-blocking findings require baseline evidence and a concrete
  follow-up.
- Locked tests and verification scripts remain unchanged. App-specific template
  assertions are confined to the current adaptable template-state test. Locked
  route-nesting and responsive-contract gates pass with App code fixes, not gate
  edits.
- `/api/health` and `/api/manifest` still work.
- Production start path is still valid.
- Production host/port binding is verified from the runtime/startup-probe network
  namespace, not inferred from Vite dev readiness.
- Current scaffold runtime bootstrap / `db:push` succeeds against a clean schema.
- Normal startup and first-request paths do not auto-insert demo, sample, or
  baseline rows for migrated durable business entities; retained legacy data and
  development/test fixtures use explicit flows.
- Valid retained runtime baseline dates use current seed helpers and typed
  transactional Drizzle data writes.
- Repository search shows no production durable CRUD backed by browser storage,
  persisted Zustand slices, IndexedDB, in-memory mocks, or fixtures.
- Required legacy imports are validated, idempotent, and reconciled by result
  counts and conflicts.
- If historical data is intentionally reset, the reset decision, rollback source
  or explicit lack of one, clean-schema result, and expected empty-state behavior
  are recorded in project-local migration documentation.
- Compatibility endpoints have current behavior/status/evidence rows; `partial`
  and `queued-only` behavior is not reported as complete.
- Legacy runtime/deployment scan findings are classified, and no obsolete active
  dependency, credential, destructive reset endpoint, host, proxy, or scheduler
  remains in the delivery path without an explicit decision.
- Repository search finds no user-visible logout/sign-out or app-managed
  role-switch/role-picker/impersonation UI or navigation entry, no custom logout
  helper, and no user-triggerable role storage/cookie write.
- A roleless source has no invented business-role requirement. For a role-aware
  source, every source role, mapping, menu/page/action guard, API authorization
  rule, `PERMISSION_MATRIX`, `ROLE_METADATA`, and `roles.json` entry has a
  verified target equivalent. `role_key` values satisfy
  `^[a-z]+(_[a-z]+)*$`; every matrix role, including a business-defined
  `admin`, appears in `roles.json`. The result fits at most three business roles, or
  has a traceable user/platform-approved consolidation or phased migration with
  no silently lost, broadened, collapsed, or zero-permission source role.
- Role tests cover preview single-role view-as; deployed permission union across
  all `X-Tier0-Business-Roles`; active-role display ordering; known plus trusted
  unknown roles; explicit deployed empty roles; preview without a selected role (zero
  roles and permissions); legacy
  recognized and untrusted unknown roles. Authorization never uses
  `primaryRole`.
- Platform assignment or preview view-as changes take effect on a new request or
  refresh; the App never writes role state optimistically.
- App name/locale/icon and platform metadata meet the current identity contract.
  A generated icon is a 512x512 PNG no larger than 2 MB and the same image is
  used in-App and for platform synchronization.
- No prohibited framework imports were added.
- Route tree generation is handled by tooling, not manual edits. Resource
  list/detail shapes, navigation target uniqueness, lifecycle/read-only
  markers, and 375px behavior satisfy the current locked contracts.
- `artifact.toml`, `vite.config.ts`, `package.json`, and platform integration
  behavior still match the latest template baseline or have an intentional,
  documented reason to differ.
- `artifact.toml` uses canonical literal argv; shell behavior is explicit.
- With a preview local URL, `smoke:routes` covers `/` and changed key routes.
- No platform-managed Skill content is vendored under `.agents/skills/`.
- Last, and only when every item above passes: `package.json` top-level
  `tier0Scaffold` equals the object in the inspected scaffold commit's
  `package.json` (`version` integer and `ref` hex copied as-is). If the scaffold
  has no such field, it stays absent here and the report says so. It is never
  written for a partial or blocked alignment, or before the target scaffold
  contracts are met. A fully migrated external app receives the same marker.

Run persistence acceptance through real HTTP requests against the running app,
not direct service calls or an in-memory test substitute:

1. Generate a unique marker and create one record through the public HTTP API.
2. Read it through HTTP and verify its persisted fields and identifier.
3. Update it through HTTP, read it again, and verify the changed value.
4. Exercise at least one expected failure path, such as invalid input,
   unauthorized access, duplicate conflict, or missing identifier, and assert its
   status and error contract.
5. When the environment is controllable, restart the app/server, then read the
   record again to prove PostgreSQL persistence rather than process memory.
6. Exercise the entity's supported terminal lifecycle action—delete, archive,
   cancel, or close—and verify the expected final state.
7. Use `try/finally` or equivalent teardown when the domain contract permits
   cleanup; otherwise retain the unique marker as explicit test evidence.
