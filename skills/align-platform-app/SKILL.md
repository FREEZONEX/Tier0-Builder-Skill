---
name: align-platform-app
description: >-
  Align applications to the Tier0 platform-standard TanStack Start scaffold
  (FREEZONEX/Tier0-App-Scaffold). Use when migrating an imported legacy SPA, Vite,
  CRA, Next.js, static HTML, React Router, fullstack Node/React, MonoApp, or
  mixed frontend/backend bundle into the platform app shape; when a Tier0 app
  alignment or migration must replace LocalStorage, sessionStorage, IndexedDB,
  Zustand persist, in-memory mocks, or fixture CRUD with real
  Drizzle/PostgreSQL persistence; or when updating,
  rebasing, syncing, upgrading, or reconciling an existing platform app's
  scaffold files, build/runtime contracts, API/service boundaries, database
  setup, preview behavior, Gateway identity/role boundaries, assets, routing,
  artifact.toml, Vite config, or platform integration requirements.
---

# Align Platform App

## Overview

Use this skill to align an application with the current Tier0 platform scaffold.
It covers three related situations:

1. Importing or migrating a non-platform app into the Tier0 platform app shape.
2. Replacing browser-local, persisted client, mock, or fixture-backed business
   CRUD with Drizzle/PostgreSQL as the durable source of truth.
3. Updating an app that already uses the Tier0 platform scaffold when the
   upstream `FREEZONEX/Tier0-App-Scaffold` template has changed and the user
   chooses to bring the local app forward.

Treat these as standards-gap closure: preserve product behavior first, then move
routes, assets, data access, API/service logic, auth, styling, database setup,
scaffold files, and build/runtime behavior into the latest scaffold-native
patterns.

The canonical platform template is:
`https://github.com/FREEZONEX/Tier0-App-Scaffold.git`.
Before changing migration constraints, fetch or inspect that repository's latest
`main` branch and reconcile the local skill guidance against it.

## Default Stance

- Keep the current scaffold. Do not reinitialize the project.
- Treat this as TanStack Start, not Next.js. Do not introduce `next/*` imports,
  App Router files, server components, `metadata` exports, or Next-specific
  cookie/header APIs.
- Preserve user-visible behavior before refactoring internals. If the source
  project is large or fragile, use a temporary `src/legacy` boundary and migrate
  incrementally.
- Make the target project platform-deployable, not merely buildable. Verify
  runtime entry, health route, manifest route, build output, preview behavior,
  and package/import shape.
- Treat login, logout, identity, and role assignment as platform-owned. Do not
  create App-local authentication sessions, logout endpoints, role pickers, or
  credential configuration for Gateway-managed concerns.
- Avoid placeholder screens and "coming soon" states. Empty states should offer
  real actions or route to migrated functionality.
- For app-owned durable business data, use PostgreSQL as the single source of
  truth. Do not hide database failures by reading from or writing to local
  browser state, memory mocks, or fixtures.

## Workflow

1. **Inventory the source app**
   - For imported projects, identify framework, router, entry points, package
     manager, build command, server/runtime pieces, database assumptions,
     environment variables, static assets, public paths, auth assumptions, and
     API/data access.
   - Inventory every `localStorage`/`sessionStorage` call, IndexedDB wrapper,
     Zustand `persist` store, in-memory repository, mock server, JSON fixture,
     and client-generated CRUD path. Classify each value as durable business
     data, session/UI preference, cache, seed/test fixture, or derived state;
     record its readers, writers, keys, shape, identifiers, and reset behavior.
   - Search for legacy login, logout/sign-out, switch-role, role-picker, and
     impersonation behavior across navigation buttons, personal menus, pages,
     modals, API helpers, and localStorage/sessionStorage/cookie role writes.
   - Determine whether the source app has a business-role model. If it does,
     inventory every role definition, user-role mapping, permission mapping,
     menu/page/action guard, API authorization rule, and related manifest or
     metadata entry. If it does not, record the app as roleless rather than
     inventing roles during migration.
   - For already-platform apps, identify local scaffold drift against the latest
     `FREEZONEX/Tier0-App-Scaffold`: package scripts/dependencies, `artifact.toml`,
     `vite.config.ts`, `server.mjs`, routing/root files, Gateway auth/role code,
     role registration, SDK loading, App identity, design primitives, verification
     gates, preview behavior, health/manifest routes, and docs.
   - Read source route definitions, list/detail nesting intent, navigation
     targets, layout shells, global styles, state stores, and any runtime/server
     files. Record whether each resource detail should replace the list or render
     inside a parent/master-detail surface.
   - If the source has back-end-like code in client handlers or framework routes,
     classify whether it belongs in `src/routes/api/**`, `src/services/**`, or
     an external API.

2. **Compare against the platform contract**
   - Load `references/latest-template-source.md` before relying on remembered
     template details. Verify the current `main` commit and inspect at least
     the volatile contract surfaces listed there.
   - Load `references/platform-contract.md` when checking required target shape.
   - Confirm the target app keeps scaffold files such as `server.mjs`,
     `vite.config.ts`, `artifact.toml`, `/api/health`, `/api/manifest`, and
     root/router files intact.
   - Confirm managed preview rules: do not manually install dependencies for
     preview startup, and use the platform preview workflow when available.
   - When managed preview installation, port/process ownership, health timeout,
     or HMR fails, use `preview-runtime-stability` when the platform has injected
     it; keep this skill focused on migration and platform-contract alignment.
     Never copy platform-managed Skill content into the target App.

3. **Choose a migration path**
   - Use a compatibility boundary when the source app is large, route-heavy,
     or relies on global browser state.
   - Use direct conversion only for small projects with clear route/component
     boundaries and no fragile global assumptions.
   - If durable CRUD currently depends on browser storage, Zustand persist,
     IndexedDB, memory mocks, or fixtures, load
     `references/local-state-to-drizzle.md` and define the database cutover and
     optional one-time legacy-data import before changing client writes.
   - If the source matches a known app-shape specialization, switch to that
     child skill for shape-specific details while keeping this skill's platform
     contract as the parent rule set.
   - Load `references/compatibility-boundary.md` for boundary rules and exit
     criteria.

4. **Migrate into scaffold-native shape**
   - Convert routing to TanStack Router file routes under `src/routes/`. For a
     resource with list and detail routes, choose one explicit shape: nested
     routes use a parent with `<Outlet />`, a sibling `.index.tsx` list, and a
     `.$param.tsx` detail; a component-less parent may provide the outlet
     automatically, and an intentional master-detail parent may render content
     plus `<Outlet />`. A standalone detail opts out of nesting with a trailing
     `_` on the parent segment. Do not leave a detail child behind a parent that
     renders no outlet.
   - Respect the scaffold's server/client boundary. Client and mixed route,
     component, router, and shared-wrapper modules must not statically pull
     Node-only `fs`, `path`, `url`, `pg`, bootstrap, or seed code into the browser
     build. Keep `src/start.ts`, API routes, and `createServerFn` bodies server-only,
     and keep runtime database bootstrap in services as the latest scaffold
     requires.
   - When temporarily preserving `react-router-dom`, mount `BrowserRouter` inside
     `ClientOnly`; importing or rendering it through SSR can access `document`.
   - Before changing frontend UI, read the target scaffold's current `DESIGN.md`.
     Compose its shared UI, form, overlay, table, and data-state primitives
     instead of recreating them in migrated routes. Render scaffold request-hook
     results through its `AsyncView` contract so first-load failures remain
     visible and retryable.
   - Declare real workspace navigation with `defineNavigationModules`. Every
     clickable leaf needs a unique `href` that resolves to a real non-API route.
     Do not add a page-introduction subtitle that repeats the title or explains
     navigation.
   - Complete each management object's applicable lifecycle end to end. Use an
     intentional read-only workspace only for a monitor, report, audit, or
     derived result, and mark it `READ_ONLY_SURFACE: <reason>`.
   - Keep interactive pages usable at 375px without page-level horizontal
     overflow. Bound `input`, `select`, and `textarea` controls that use
     `flex-1`, `grow`, or `flex-auto`; place any hard minimum width above 375px
     inside a local horizontal-scroll region.
   - For app-owned durable data, migrate in dependency order: schema -> current
     scaffold `bootstrapModule()` / `db:push` contract -> service -> thin API route
     -> client request/cache invalidation. Keep database access in services and
     preserve transactions and business invariants there.
   - Replace durable CRUD writes in LocalStorage, sessionStorage, IndexedDB,
     Zustand persist, memory mocks, and fixtures with API calls. Keep only
     explicitly classified ephemeral UI/session preferences client-local.
   - If existing browser data must survive, implement an explicit, validated,
     idempotent one-time import with conflict policy and audit evidence; never
     silently merge it during ordinary reads.
   - Move database schema and migration behavior into the scaffold data layer
     only when the source app owns the persistence. Preserve the current
     scaffold's idempotent `bootstrapModule()` table/index setup inside the
     platform-provisioned `DB_SCHEMA`. Remove runtime `CREATE SCHEMA`, including
     `IF NOT EXISTS`, from legacy bootstrap code; the app account must not need
     database-level schema-creation permission. Do not let normal startup or a
     first request auto-insert demo, sample, or
     baseline rows for migrated durable business entities. Retained legacy data
     enters through an explicit import; development/test fixtures require an
     explicit development or test action. Where retained runtime baseline data
     is valid, use current scaffold seed helpers and typed Drizzle writes rather
     than raw SQL writes or mutating `Date` setter return values.
   - Map source environment variables to platform/runtime injection. Do not add
     user-facing credential pages for platform-provided SDK credentials.
   - For imported/migrated apps, remove legacy custom login/register and all
     user-visible logout/sign-out buttons, personal-menu entries, pages, routes,
     and custom logout helpers, together with role-switching, role-picking, and
     impersonation flows. Remove obsolete App-local session, logout, and
     role-selection code when reconciling with the current Gateway-only
     scaffold. Logout remains platform-owned for every App; do not clear the
     Gateway Cookie or create an App-local substitute.
   - If the source app is roleless, do not invent business roles or role-gated
     behavior. If the source has roles, migrate the complete role model:
     definitions, user-role and permission mappings, menu/page/action guards,
     API authorization, `PERMISSION_MATRIX`, `ROLE_METADATA`, and `roles.json`.
     Use the current platform `role_key` format. Authorize with the complete
     Gateway-assigned role set and permission union; never authorize with the
     primary display role. The client must not write role state through storage,
     cookies, query parameters, request bodies, or headers. The first version is
     limited by the target scaffold role contract (currently no more than three
     materially distinct business roles, with no reserved role). If the source has more distinct roles, do not silently drop, collapse,
     or map them to zero permissions; stop and obtain a user/platform-approved
     consolidation or phased migration decision.
   - Integrate assets through the scaffold's public/static asset conventions.
     Preserve or finish the real App name, locale, and icon through current
     `app-chrome` conventions. When generating or rebranding an icon, use the
     same platform-ready image in-App and in platform App metadata.
   - Preserve localization and directionality when present; normalize
     user-facing copy with the project copy rules.
   - Keep `.agents/skills/` empty of vendored guidance. Builder Skills are
     selected and injected by the platform orchestrator, not packaged in Apps.

4a. **Update an existing scaffold-based app**
   - Treat upstream template changes as platform-contract drift, not as a reason
     to overwrite business code.
   - Compare latest template files against local files and classify each
     difference as platform contract, app-specific customization, or unrelated.
   - Patch the smallest set of scaffold files needed to restore compatibility.
   - Preserve business routes, services, schema, permissions, copy, and design
     choices unless the user explicitly asks to refresh them from the template.
   - Ask for user confirmation before broad scaffold rebases, dependency churn,
     or replacing locally customized shell/auth/runtime files.

5. **Verify behavior and deployability**
   - Run the current scaffold's normal completion build command and let its full
     post-build verifier finish; do not replace it with a direct bundler command.
     When preview returns a local URL, run the scaffold route-smoke command
     against `/` plus every changed key route.
   - Treat Vite `ready` and HTTP 200 as transport checks only. Inspect both SSR
     output and the browser console, wait for hydration, and exercise interactive
     controls before declaring a route rendered.
   - Audit runtime contracts whenever migration uses `@ts-nocheck` or changes a
     helper from synchronous to asynchronous. Trace every caller so no Promise is
     consumed as a `Map`, array, render value, or synchronous `useMemo` result.
   - Verify key migrated routes render, list/detail nesting behaves as chosen,
     every clickable navigation leaf resolves uniquely, assets load, and API
     calls do not fall back to local-only state. Exercise management lifecycle
     actions or verify an accurate `READ_ONLY_SURFACE` reason, and inspect the
     affected routes at 375px.
   - For role-aware apps, verify preview single-role view-as and deployed
     multi-role permission-union behavior against
     `references/platform-contract.md`. Cover mixed known/unknown trusted roles,
     explicit deployed empty roles, legacy untrusted unknown roles, and preview
     without a selected role yielding zero permissions. For roleless apps, verify that no business roles were
     invented.
   - For persistence migrations, prove supported lifecycle operations through
     the API, reload and—when the environment is controllable—restart durability,
     current scaffold bootstrap / `db:push` behavior on a clean schema,
     authorization and validation failures, and visible DB outage errors with no
     local fallback. Capture legacy-import counts/conflicts when applicable.
   - Confirm ZIP/import packaging rules only after checking the target import
     environment. Load `references/import-troubleshooting.md` for failures.

## Reference Routing

- Read `references/migration-workflow.md` for the detailed audit-to-migration
  checklist.
- Read `references/local-state-to-drizzle.md` whenever durable app data or CRUD
  is stored in LocalStorage, sessionStorage, IndexedDB, Zustand persist,
  in-memory mocks, mock servers, or fixtures, or when planning legacy-data
  import and persistence acceptance evidence.
- Read `references/latest-template-source.md` when you need the latest upstream
  template, when current scaffold files conflict with this skill, or before
  updating platform constraints.
- Read `references/platform-contract.md` before changing build, runtime,
  routing, preview, auth, persistence boundaries, or packaging behavior.
- Read `references/compatibility-boundary.md` when preserving a large imported
  app before native refactoring.
- Read `references/import-troubleshooting.md` when migrated code causes SSR,
  build, routing, assets, auth/API, database, production runtime, or package
  import failures.
- Use `preview-runtime-stability` when the orchestrator injected it and managed
  preview installation, port/process lifecycle, readiness timeout, or HMR fails.

## App-Shape Child Skills

Use child skills as specializations under this parent workflow. They are not a
separate runtime inheritance mechanism; they are routing rules that keep
domain/app-shape details out of the generic migration skill.

- `migrate-node-red-app`: use together with this parent when Node-RED acts as a
  backend, API layer, state store, workflow engine, scheduler, or external-
  integration orchestrator. It covers flow analysis, context/data mapping,
  behavior-preserving replacement, layered cutover, and retirement evidence
  across application domains.

## Completion Criteria

A migration is not complete until current evidence proves all of the following:

- Source routes and primary workflows are reachable in the target app.
- The app follows TanStack Start routing and scaffold file conventions. Every
  list/detail resource uses a valid nested parent/index/detail shape with an
  outlet, an intentional master-detail outlet, or an explicit trailing-`_`
  non-nested detail.
- Platform entry points, health, manifest, preview, and production start paths
  are intact.
- For scaffold-update work, local platform files are reconciled with the latest
  template or intentionally documented as app-specific divergence.
- Source assets, styles, i18n, and navigation behavior are preserved or
  intentionally replaced. `defineNavigationModules` has one unique real
  non-API route per clickable leaf.
- Management surfaces complete their applicable business lifecycle. Intentional
  read-only monitor/report/audit/derived-result routes carry an accurate
  `READ_ONLY_SURFACE: <reason>` marker.
- Interactive pages remain usable at 375px without page-level horizontal
  overflow; flexible form controls are bounded and widths above 375px stay
  inside local horizontal-scroll regions. Page content does not repeat its title
  or explain navigation in an introduction subtitle.
- For imported/migrated apps, repository search finds no user-visible
  logout/sign-out button, personal-menu entry, page, route, or custom logout
  helper, and no app-managed role-switch/role-picker/impersonation UI or
  navigation entry. No App-local session/logout/select-role implementation or
  Gateway Cookie mutation remains.
- A roleless source remains roleless, with no invented business-role requirement.
  For a role-aware source, every source role, mapping, menu/page/action guard, API
  authorization rule, and related metadata entry is migrated across
  `PERMISSION_MATRIX`, `ROLE_METADATA`, and `roles.json`. Role keys satisfy the
  current platform validator, and the effective model follows the target
  scaffold role limit without assuming any reserved role. Any source model that exceeds
  that cap has an explicit user/platform-approved consolidation or phased
  migration decision; no role is silently dropped, collapsed, or left with zero
  permissions. Header tests prove preview view-as, deployed
  assigned-role union, trusted unknown-role zero permissions, explicit deployed
  empty roles, and legacy unknown-role rejection. No App exposes a
  user-triggerable role write or authorizes with a display-only primary role.
- Every app-owned durable entity has PostgreSQL as its single source of truth,
  with schema, current scaffold runtime bootstrap / `db:push`, service, API, and
  client paths connected.
- Runtime bootstrap creates tables and indexes inside the existing platform-injected
  `DB_SCHEMA`; no App startup or request path executes `CREATE SCHEMA`, including
  `IF NOT EXISTS`. Preserve idempotent initialization. Normal startup and
  first-request paths do not auto-insert demo, sample, or
  baseline rows for migrated durable business entities. Retained legacy data and
  development/test fixtures enter only through their explicit flows.
- No production CRUD path uses browser storage, Zustand persist, IndexedDB,
  memory mocks, or fixtures as durable storage or as a database-failure fallback.
- Persistence evidence covers supported lifecycle operations, reload and—when
  controllable—restart durability, clean-schema bootstrap / `db:push`,
  validation/authorization, DB failure behavior, and any required legacy-data
  import reconciliation.
- When historical data is intentionally not imported, clean-schema reads return
  genuine empty states with real actions and no browser/mock/retired-backend
  fallback; the reset and rollback decisions are recorded project-locally.
- Compatibility JSON/JSONB storage is not reported as normalized-domain
  completion, and retained compatibility APIs have behavior/status/evidence rows.
- For persistence migrations, run a real HTTP CRUD smoke through the running
  app/API rather than calling services directly: create a uniquely identified
  record, read it, update it, and verify the change. When the environment is
  controllable, restart and verify persistence. Exercise the entity's supported
  terminal lifecycle action—delete, archive, cancel, or close—and verify the
  expected final state. Clean up when the domain contract allows it, and exercise
  at least one expected validation, authorization, conflict, or not-found failure
  path.
- Build/typecheck/post-build verification passes. Migration-introduced or
  runtime-risk failures block completion; genuine pre-existing non-blocking
  findings require baseline evidence and a concrete next action.
- First-load request failures render an error/retry state rather than endless
  loading. Retained runtime seed values use current typed helpers and encoders.
- App name, locale, icon, and platform metadata follow the current scaffold
  identity contract; icon/platform synchronization is not inferred from source
  changes alone.
- Locked scaffold gates remain intact, and preview route smoke covers `/` plus
  changed key routes when a local preview URL is available.
- No platform-managed Skill content is vendored into the App package.
- Production host/port binding is verified in the target runtime network
  namespace, and obsolete runtime/deployment assets are removed, replaced, or
  intentionally documented outside the active delivery path.
- Packaging/import guidance is specific to the actual target environment, not a
  generic ZIP assumption.
- Any claim about the "latest template" is backed by a fresh check of
  `FREEZONEX/Tier0-App-Scaffold` rather than memory.
