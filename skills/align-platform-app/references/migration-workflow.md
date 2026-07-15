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
- Routing: route arrays, router providers, file routes, dynamic params, redirects.
- Layout: shells, sidebars, top bars, providers, auth guards, error boundaries.
- Auth/role surface: search legacy login, logout/sign-out, switch-role,
  role-picker, and impersonation in navigation buttons, personal menus, pages,
  modals, API helpers, localStorage/sessionStorage, and cookie role writes.
- Role model: determine whether the source is roleless or role-aware. For a
  role-aware source, inventory role definitions, user-role and permission
  mappings, menu/page/action guards, API authorization rules, and related
  manifest or metadata entries. Do not invent roles for a roleless source.
- State: Zustand/Redux/Context stores, `persist` middleware,
  localStorage/sessionStorage calls, IndexedDB wrappers, caches, and reset paths.
- Data access: fetch wrappers, GraphQL clients, REST clients, in-memory
  repositories, mock handlers, JSON fixtures, and SDK clients.
- Server/runtime: API routes, server entry, workers, adapters, cron-like jobs,
  custom middleware, and framework-specific server handlers.
- Data layer: schema files, migrations, seed data, local JSON stores, browser
  storage reliance, and backend persistence assumptions.
- Assets: public paths, imported images, fonts, CSS resets, CDN references.
- Environment: `.env*`, `import.meta.env`, `process.env`, hard-coded hosts.
- i18n/theme: locale files, RTL/LTR logic, theme tokens, CSS variables.
- Legacy runtime/deployment assets: containers, reverse proxies, old ports/base
  paths/hosts, schedulers, credentials, reset endpoints, and retired backend
  documentation. Inventory first; do not delete based on a keyword match alone.

For every local or mock state source, record its keys/store names, data shape,
identifier generation, readers, writers, initialization, reset behavior, and
whether it is durable business data, session/UI preference, cache/derived state,
or seed/test data. Load `local-state-to-drizzle.md` when any production CRUD is
local or mocked.

Write a short migration map when the source is non-trivial:

- source route -> target route file
- source provider -> target provider/boundary
- source API/server helper -> target service/API/external dependency
- compatibility API -> method, request, response, errors, auth, side effects,
  implementation status, external dependencies, and verification evidence
- source data model -> target schema/runtime-bootstrap-or-`db:push`/service/API/
  client path or external system
- source local/mock data -> PostgreSQL cutover, optional legacy import, or an
  explicitly retained ephemeral state category
- source asset path -> target asset path
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

1. Stabilize the platform shell and build/runtime contract.
2. Bring in assets, global styles, and source providers behind an explicit
   boundary.
3. Mount primary routes and navigation.
4. Classify local/mock state and define PostgreSQL as the source of truth for
   durable entities.
5. Replace durable local/mock CRUD in vertical slices using
   schema -> current scaffold `bootstrapModule()` / `db:push` contract -> service
   -> thin API -> client.
6. Import legacy data through an explicit validated, idempotent process when
   retention is required; otherwise document reset/cutover.
7. Keep idempotent runtime DDL bootstrap for schemas, tables, and indexes, but
   remove startup- or first-request seed callbacks that auto-insert demo, sample,
   or baseline rows for migrated durable business entities. Retain legacy data
   through the explicit import from step 6; run development/test fixtures only
   through an explicit development or test action.
8. Normalize auth, permissions, and menu visibility. Remove legacy custom login
   and all user-visible logout/sign-out buttons, personal-menu entries, pages,
   routes, and custom logout helpers, together with role-switch, role-picker, and
   impersonation entry points. Preserve protected scaffold gateway/session bridge
   endpoints only when required, with no product logout entry. This
   logout-removal requirement is migration-specific and does not define
   separately generated 0-to-1 app behavior. Consume the platform active role
   read-only and never let client storage, cookies, query/body/header values
   select or override it.
9. Keep a roleless source roleless. For a role-aware source, migrate every role
   definition, user-role and permission mapping, menu/page/action guard, API
   authorization rule, and related metadata entry before considering auth and
   permissions complete.
10. Incrementally extract reusable components into scaffold-native folders.
11. Remove compatibility shims and durable local stores only after equivalent
   native API-backed routes are verified.
12. When a synchronous helper becomes asynchronous, audit its complete caller
    graph before relying on typecheck. Find callers that use the returned Promise
    as a `Map` (`.get`, `.set`, iteration), array (`.map`, `.filter`, spread), or
    immediate render value. Do not make a React render function or synchronous
    `useMemo` callback async; resolve data in a loader, effect, query, or server
    boundary and render settled state.
13. Treat every retained or introduced `@ts-nocheck` as a runtime-contract risk.
    Add focused runtime smoke coverage for the suppressed module and its callers;
    a successful build is not evidence that values have the expected shape.
14. When compatibility API routes remain, maintain a behavior matrix covering
    method, input, output envelope, pagination, errors, authorization, business
    side effects, backing persistence, external execution, implementation status,
    and verification evidence. Route reachability is not behavioral equivalence.
15. Classify legacy runtime and deployment assets as active dependency, obsolete
    deployment artifact, historical documentation, intentional retirement
    record, or false positive. Remove or replace active-delivery residue only
    after its target behavior and rollback implications are understood.

## 4. Verification Checklist

For each migrated route, verify:

- Check both SSR/server output and the browser console. A clean server log does
  not exclude a browser import, hydration, or event-handler failure.
- Wait for hydration, then exercise links, forms, dialogs, and another stateful
  interaction. Vite `ready` and an HTTP 200 prove transport, not hydration.
- If preserving `react-router-dom`, render `BrowserRouter` only inside
  `ClientOnly`; do not let SSR evaluate its `document`-dependent setup.
- It is reachable by URL and navigation.
- It renders without hydration/runtime errors.
- Browser-only libraries are guarded or loaded client-side.
- Server-side logic runs through scaffold API/service boundaries.
- Assets and fonts load under the deployed base path.
- Data reads and writes hit intended APIs, services, or external systems.
- Durable data survives reload, another client session, and server restart.
- Database/network failures are visible and never trigger local/mock fallback.
- Empty, loading, error, and success states are real.
- When historical data is intentionally not imported, reads from a clean schema
  return a genuine empty state with real creation/onboarding actions; they do not
  fall back to browser data, fixtures, mocks, or the retired backend.
- User-facing copy has no placeholder migration language.
- Imported/migrated menus, personal menus, pages, routes, and modals contain no
  user-visible logout/sign-out or app-managed role-switch, role-picker, or
  impersonation entry. Custom logout helpers are removed; protected scaffold
  auth/session bridge endpoints remain only when required and expose no product
  logout entry.

For the whole app, verify:

- Typecheck/build/post-build checks pass. Migration-introduced and runtime-risk
  failures block completion; genuine historical lint/dead-code findings require
  baseline evidence and a concrete follow-up.
- `/api/health` and `/api/manifest` still work.
- Production start path is still valid.
- Production host/port binding is verified from the runtime/startup-probe network
  namespace, not inferred from Vite dev readiness.
- Current scaffold runtime bootstrap / `db:push` succeeds against a clean schema.
- Normal startup and first-request paths do not auto-insert demo, sample, or
  baseline rows for migrated durable business entities; retained legacy data and
  development/test fixtures use explicit flows.
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
  rule, and related metadata entry has a verified target equivalent.
- Active-role tests cover the current scaffold precedence: preview runtime role,
  active role, preview-role fallback, legacy `X-App-User-Role`, then JSON
  `user.role`. If `X-Tier0-Business-Roles` is present, it is treated only as an
  available-role set. In role-aware apps, explicitly supplied unknown roles fail
  closed; missing roles follow the scaffold session/admin/login fallback chain
  and protected capabilities deny only after the fallbacks are exhausted. In
  roleless apps, missing role input is not an error.
- After changing role through the Tier0 platform, a refresh or new request reads
  the new role and recomputes permissions; the app never switches optimistically.
- No prohibited framework imports were added.
- Route tree generation is handled by tooling, not manual edits.
- `artifact.toml`, `vite.config.ts`, `package.json`, and platform integration
  behavior still match the latest template baseline or have an intentional,
  documented reason to differ.

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
