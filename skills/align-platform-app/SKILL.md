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
  setup, preview behavior, auth/session boundaries, assets, routing,
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
     `vite.config.ts`, routing/root files, auth/session code, SDK loading,
     preview behavior, health/manifest routes, and docs.
   - Read source route definitions, navigation config, layout shells, global
     styles, state stores, and any runtime/server files.
   - If the source has back-end-like code in client handlers or framework routes,
     classify whether it belongs in `src/routes/api/**`, `src/services/**`, or
     an external API.

2. **Compare against the platform contract**
   - Load `references/latest-template-source.md` before relying on remembered
     template details. Verify the current `main` commit and inspect at least
     `AGENTS.md`, `README.md`, `package.json`, `artifact.toml`,
     `vite.config.ts`, and `docs/platform-integration.md`.
   - Load `references/platform-contract.md` when checking required target shape.
   - Confirm the target app keeps scaffold files such as `server.mjs`,
     `vite.config.ts`, `artifact.toml`, `/api/health`, `/api/manifest`, and
     root/router files intact.
   - Confirm managed preview rules: do not manually install dependencies for
     preview startup, and use the platform preview workflow when available.
   - When managed preview installation, port/process ownership, health timeout,
     or HMR fails, use `preview-runtime-stability`; keep this skill focused on
     migration and platform-contract alignment.

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
   - Convert routing to TanStack Router file routes under `src/routes/`.
   - Respect the scaffold's server/client boundary. Client and mixed route,
     component, router, and shared-wrapper modules must not statically pull
     Node-only `fs`, `path`, `url`, `pg`, bootstrap, or seed code into the browser
     build. Keep `src/start.ts`, API routes, and `createServerFn` bodies server-only,
     and keep runtime database bootstrap in services as the latest scaffold
     requires.
   - When temporarily preserving `react-router-dom`, mount `BrowserRouter` inside
     `ClientOnly`; importing or rendering it through SSR can access `document`.
   - Move reusable UI into `src/components/<domain>/` or route-local modules.
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
     scaffold's idempotent `bootstrapModule()` schema/table/index setup, but do
     not let normal startup or a first request auto-insert demo, sample, or
     baseline rows for migrated durable business entities. Retained legacy data
     enters through an explicit import; development/test fixtures require an
     explicit development or test action.
   - Map source environment variables to platform/runtime injection. Do not add
     user-facing credential pages for platform-provided SDK credentials.
   - For imported/migrated apps, remove legacy custom login/register and all
     user-visible logout/sign-out buttons, personal-menu entries, pages, routes,
     and custom logout helpers, together with role-switching, role-picking, and
     impersonation flows. Protected scaffold auth/session bridge endpoints may
     remain when the current platform requires them, but they must not remain as
     a product logout entry. This logout-removal rule does not prohibit a
     separately generated 0-to-1 app from implementing logout when its own
     requirements ask for it.
   - If the source app is roleless, do not invent business roles or role-gated
     behavior. If the source has roles, migrate the complete role model:
     definitions, user-role and permission mappings, menu/page/action guards,
     API authorization, and related metadata. The client must not select or
     override the active role through storage, cookies, query parameters,
     request bodies, or headers.
   - Integrate assets through the scaffold's public/static asset conventions.
   - Preserve localization and directionality when present; normalize
     user-facing copy with the project copy rules.

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
   - Run typecheck/build and any post-build verifier available in the scaffold.
   - Treat Vite `ready` and HTTP 200 as transport checks only. Inspect both SSR
     output and the browser console, wait for hydration, and exercise interactive
     controls before declaring a route rendered.
   - Audit runtime contracts whenever migration uses `@ts-nocheck` or changes a
     helper from synchronous to asynchronous. Trace every caller so no Promise is
     consumed as a `Map`, array, render value, or synchronous `useMemo` result.
   - Verify key migrated routes render, navigation works, assets load, and API
     calls do not fall back to local-only state.
   - For role-aware apps, verify preview and deployed active-role precedence and
     fallback behavior against `references/platform-contract.md`; an explicitly
     supplied unknown role must fail closed, while a missing role first follows
     the scaffold fallback chain and denies protected capabilities only after
     fallbacks are exhausted. A platform role change takes effect only after a
     new request or refresh recomputes menus, default routing, and page/API
     access. For roleless apps, verify that a missing role is accepted and no
     business-role requirement was invented.
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
- Use `preview-runtime-stability` when managed preview installation,
  port/process lifecycle, readiness timeout, or HMR fails.

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
- The app follows TanStack Start routing and scaffold file conventions.
- Platform entry points, health, manifest, preview, and production start paths
  are intact.
- For scaffold-update work, local platform files are reconciled with the latest
  template or intentionally documented as app-specific divergence.
- Source assets, styles, i18n, and navigation behavior are preserved or
  intentionally replaced.
- For imported/migrated apps, repository search finds no user-visible
  logout/sign-out button, personal-menu entry, page, route, or custom logout
  helper, and no app-managed role-switch/role-picker/impersonation UI or
  navigation entry. Protected scaffold auth/session bridge endpoints may remain
  only when required by the current platform and expose no product logout entry.
- A roleless source remains roleless, with no invented business-role requirement.
  For a role-aware source, every source role, mapping, menu/page/action guard, API
  authorization rule, and related metadata entry is migrated. Header tests cover
  the current precedence and fallback chain; a platform role change is reflected
  after refresh/new request, an explicitly supplied unknown role fails closed,
  and missing role input denies protected capabilities only after the scaffold
  fallbacks are exhausted. No app exposes a user-triggerable role write.
- Every app-owned durable entity has PostgreSQL as its single source of truth,
  with schema, current scaffold runtime bootstrap / `db:push`, service, API, and
  client paths connected.
- Current scaffold runtime bootstrap may create schemas, tables, and indexes, but
  normal startup and first-request paths do not auto-insert demo, sample, or
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
- Production host/port binding is verified in the target runtime network
  namespace, and obsolete runtime/deployment assets are removed, replaced, or
  intentionally documented outside the active delivery path.
- Packaging/import guidance is specific to the actual target environment, not a
  generic ZIP assumption.
- Any claim about the "latest template" is backed by a fresh check of
  `FREEZONEX/Tier0-App-Scaffold` rather than memory.
