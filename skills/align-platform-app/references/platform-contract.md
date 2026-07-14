# Platform Contract For App Alignment

## Contents

- [Target Shape](#target-shape)
- [Routing Contract](#routing-contract)
- [Identity And Active Role Contract](#identity-and-active-role-contract)
- [Data And Server Boundary](#data-and-server-boundary)
- [Server, Client, And Node-Only Module Boundary](#server-client-and-node-only-module-boundary)
- [Database Schema And Runtime Bootstrap Contract](#database-schema-and-runtime-bootstrap-contract)
- [Build And Preview Contract](#build-and-preview-contract)
- [Artifact Contract](#artifact-contract)
- [Packaging Contract](#packaging-contract)

## Target Shape

The target is the existing Tier0 TanStack Start scaffold, aligned to the latest
`FREEZONEX/Tier0-App-Scaffold` `main` branch unless the user explicitly asks to pin
an older template. Keep the scaffold's platform contract intact while importing
or updating app functionality.

Required target invariants:

- Keep `server.mjs` as the production Node entry.
- Keep `vite.config.ts` as the Vite/TanStack Start configuration source.
- Keep `src/router.tsx`, `src/start.ts`, and `src/routes/__root.tsx` unless a
  user explicitly asks for platform-level changes.
- Keep `/api/health` and `/api/manifest` route behavior intact.
- Do not edit generated `src/routeTree.gen.ts` directly.
- Do not add Next.js framework patterns.
- Do not create product login/register, app-managed role-switch, role-picker, or
  impersonation flows when identity and active role are platform/gateway managed.
  During import/migration, also remove user-visible logout/sign-out product
  entries. This logout-removal rule does not prohibit a separately generated
  0-to-1 app from implementing logout when its own requirements ask for it.
- Do not expose platform-provided API keys, hosts, tokens, or MQTT credentials
  through user-editable forms.
- Keep Node `>=22.12.0` and the latest template script contract, including
  `postbuild -> npm run build:verify`.
- Keep `@tier0/sdk` at least `0.1.3` and access it through server-side lazy
  helpers rather than SSR/page-startup imports.

## Routing Contract

Use TanStack Router file routes:

- Workspace/planning/admin pages go under `_app`.
- Scan, tap, confirm, or operator execution flows go under `station`.
- Exception review and approval flows go under `review`.
- Passive wallboards and large-screen displays go under `monitor`.
- Create a custom layout only when none of the built-in layout postures fit.

Do not import from `next/link`, `next/navigation`, `next/image`, or
`next/headers`. Use TanStack Router APIs and scaffold helpers.

## Identity And Active Role Contract

Identity and active role are read-only platform/gateway runtime inputs. Resolve
gateway-provided roles in the current scaffold order:

1. `X-Tier0-Runtime: preview` + `X-Tier0-Preview-Role`
2. `X-Tier0-Active-Role`
3. `X-Tier0-Preview-Role`
4. `X-App-User-Role`
5. JSON `user.role`

- If the platform also supplies `X-Tier0-Business-Roles`, treat it only as an
  available-role set, never as the active role.
- First determine whether the source app is roleless or role-aware. A roleless
  source remains roleless: do not invent role definitions, permission matrices,
  or role-gated behavior, and do not treat a missing role as an error. For a
  role-aware source, migrate every source role definition, user-role and
  permission mapping, menu/page/action guard, API authorization rule, and related
  manifest or metadata entry before calling the migration complete.
- Do not treat `X-App-User-Role` or a scaffold session cookie as a user-editable
  role switch. Do not add app-managed role pickers, impersonation, or client role
  writes. The client must not select or override active role through localStorage,
  sessionStorage, cookies, query parameters, request bodies, or request headers.
- Role changes occur only in Tier0 platform controls. After a platform change,
  read the new active role on a new request or refresh, then recompute menus,
  default route, page guards, API authorization, and active-role filtering. Never
  optimistically switch role inside the app.
- In a role-aware app, fail closed when the gateway explicitly supplies a role
  that is unknown to the migrated permission matrix. When no gateway role is
  present, preserve the current scaffold fallback chain through the signed
  session, admin fallback, and hidden `/login` bridge; deny protected
  capabilities only after those fallbacks are exhausted. This runtime fail-closed
  rule is distinct from migration completeness: it must not be used to excuse a
  missing source-role mapping. A roleless app does not fail merely because no
  role was supplied.

Do not blindly delete protected scaffold auth routes or files used by the current
platform template for gateway/session bridging. During import/migration, remove
legacy custom login, all user-visible logout/sign-out buttons, personal-menu
entries, pages, routes, and custom logout helpers, plus role-selection and
impersonation flows. Preserve only the protected scaffold auth/session bridge and
fallback behavior required by the current platform; protected endpoints must not
remain exposed as a product logout entry.

## Data And Server Boundary

Imported apps often hide server behavior inside API helpers, mock services,
local storage, persisted Zustand stores, IndexedDB, fixtures, Next route
handlers, custom middleware, or Node server files. Reclassify that code:

- UI-only data shaping can stay route-local or component-local.
- Session state, UI preferences, and reproducible caches may remain client-local
  only when they are not authoritative business records.
- Shared client requests should use scaffold hooks or explicit abort-safe fetch.
- HTTP handlers belong in `src/routes/api/**` and stay thin.
- Business logic, invariants, and transactions belong in `src/services/**`.
- Database access belongs behind services only.
- External platform I/O should use scaffold SDK lazy loaders when available.
- App-owned durable business data uses PostgreSQL as its single source of truth
  and migrates in this order: Drizzle schema -> current scaffold
  `bootstrapModule()` / `db:push` contract -> service -> API -> client.
- LocalStorage, sessionStorage, IndexedDB, Zustand persist, in-memory mocks, and
  fixtures must not back production durable CRUD or serve as database-failure
  fallback.
- Existing local durable data may enter PostgreSQL only through an explicit,
  validated, idempotent import with defined identity/conflict handling and
  reconciliation evidence.
- Existing database schema/migration behavior and any explicit development/test
  fixture setup should move into the scaffold data layer only when the app owns
  that persistence.

## Server, Client, And Node-Only Module Boundary

Respect the latest scaffold's explicit boundaries:

- Route components, UI components, `src/router.tsx`, client hooks, and shared
  wrappers are client or mixed modules. Do not statically pull Node-only `fs`,
  `path`, `url`, `pg`, bootstrap, or seed modules into their browser graph.
- `src/start.ts`, API route handlers, and `createServerFn` handler bodies are
  server-only boundaries. Keep server work there or in services called from those
  boundaries; do not force `src/start.ts` through a browser-safe wrapper.
- Runtime database bootstrap belongs in `src/services/**` through the current
  scaffold `bootstrapModule()` contract, not in client or shared modules.
- Treat `react-router-dom` `BrowserRouter` as browser-only compatibility code.
  Render it inside the scaffold `ClientOnly` boundary so SSR does not evaluate
  `document`-dependent setup.

## Database Schema And Runtime Bootstrap Contract

Use the platform-injected `DB_SCHEMA` as the application schema source of truth;
fall back to `public` only when it is absent, as the current scaffold does. Runtime
queries, `bootstrapModule()`, and any `db:push` verification must resolve to the
same schema.

The platform is responsible for provisioning the project database and session
schema. Preserve the current scaffold's idempotent runtime bootstrap behavior. If
`CREATE SCHEMA` fails with a permission error, verify platform provisioning and
the injected `DB_SCHEMA` before changing application code. Do not add a privileged
admin database connection to the application or invent a second schema-selection
path.

Runtime bootstrap is for idempotent DDL such as schemas, tables, and indexes. For
imported/migrated durable business entities, normal startup and first-request
paths must not auto-insert demo, sample, or baseline business rows. Retained
legacy rows enter through an explicit validated import, and development/test
fixtures run only through an explicit development or test action. This migration
constraint does not define the seed behavior of a separately generated 0-to-1
app.

## Build And Preview Contract

Use the scaffold's existing scripts and managed preview behavior:

- Do not manually install dependencies just to start managed preview.
- Run typecheck/build verification after meaningful migration steps.
- Keep post-build verification active.
- If route files change, let the TanStack Router plugin regenerate the route
  tree through dev/build tooling.
- Do not treat a static build success as deployability unless production start,
  health, and manifest behavior are also covered.
- Preserve Vite base path support through `VITE_BASE_PATH`, with
  `NEXT_PUBLIC_BASE_PATH` only as a legacy fallback.
- Preserve preview gateway header/session injection when aligning
  `vite.config.ts` with the latest template.

For persistence cutovers, build success is insufficient. Verify clean-schema
runtime bootstrap / `db:push`, supported API lifecycle operations and constraints,
reload/restart durability, and visible failure without local fallback when
PostgreSQL is unavailable.

## Artifact Contract

The current upstream template's `artifact.toml` defines the platform service
shape:

- `deployment.deploymentTarget = "autoscale"`
- production build runs `npm ci && npm run build`
- production run uses `node server.mjs` on `node:22-alpine`
- service `localPort = 5173`
- startup health path is `/api/health`
- preview runs `npm run dev -- --host 0.0.0.0 --port 5173`
- preview env includes `NODE_ENV`, `HOST`, `BROWSER`, `VITE_ALLOWED_HOSTS`, and
  `SESSION_SECRET`

Do not replace this with source-project-specific dev server assumptions.

## Packaging Contract

Packaging rules depend on the target import environment. The stable baseline is:

- ZIP root should be the app root, with `package.json`, `server.mjs`, and
  platform config at the top level.
- Preserve build output required by the runtime, commonly `dist`.
- Include `node_modules` only when the target import environment is offline or
  explicitly supports preinstalled dependencies without reinstalling them.
- Exclude local caches, git metadata, editor metadata, and generated temporary
  folders.
