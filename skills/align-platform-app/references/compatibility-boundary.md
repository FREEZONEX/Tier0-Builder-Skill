# Compatibility Boundary Pattern

## Contents

- [Boundary Shape](#boundary-shape)
- [Rules](#rules)
- [Exit Criteria](#exit-criteria)
- [Common Failure Modes](#common-failure-modes)

Use a compatibility boundary to preserve a large imported app while the
platform shell, routing, and deploy contract are made correct.

## Boundary Shape

A typical boundary includes:

- `src/legacy/` for imported source components, styles, stores, and adapters.
- A small target route that mounts the legacy app or a legacy route adapter.
- A provider wrapper that initializes legacy state once.
- A route bridge that maps target URLs to legacy route keys.
- CSS scoping or import ordering rules to prevent global style damage.
- Optional API/service adapters for legacy server assumptions that cannot be
  converted in the first pass.

Keep the boundary explicit. Do not let legacy conventions silently spread into
new scaffold-native modules.

## Rules

- Do not edit generated route tree files by hand.
- Do not put direct database access, platform credentials, or server-only APIs
  inside legacy client code.
- Do not let legacy code require Next.js runtime APIs in the target client.
- For imported/migrated apps, do not preserve legacy custom login/register,
  user-visible logout/sign-out, switch-role, role-picker, or impersonation UI,
  routes, modals, navigation entries, custom helpers, or user-triggerable role
  writes behind the boundary. Remove App-local session/logout/select-role code
  while keeping `/api/auth/me` and the hidden `/login` error bridge when present
  in the current Gateway-only template.
- Treat Gateway identity and assigned roles as read-only. Deployed authorization
  uses the permission union of all assigned `X-Tier0-Business-Roles`; the primary
  role is display metadata only. Do not let legacy code select or override roles
  through localStorage, sessionStorage, cookies, query parameters, request
  bodies, or request headers.
- Never read, write, or clear the Gateway login Cookie. Logout is
  platform-owned for every App.
- Guard browser-only libraries during SSR.
- A single adapter may temporarily expose LocalStorage, sessionStorage,
  IndexedDB, Zustand persist, memory mocks, or fixtures for compatibility and
  explicit legacy-data export/import.
- Do not add new durable business writes to that adapter. PostgreSQL becomes the
  only source of truth as each entity is cut over.
- Do not catch API/database errors and fall back to legacy local data or report a
  local write as success. Surface the failure and keep retry semantics explicit.
- Keep legacy import versioned, validated, idempotent, conflict-aware, and
  separate from ordinary application reads.
- Preserve idempotent runtime DDL bootstrap, but do not let the boundary or its
  adapters auto-insert demo, sample, or baseline rows for migrated durable
  business entities during startup or a first request.
- Keep a roleless source roleless. For a role-aware source, preserve every role
  definition, user-role and permission mapping, menu/page/action guard, API
  authorization rule, `PERMISSION_MATRIX`, `ROLE_METADATA`, and `roles.json`
  entry. Validate role keys against `^[a-z]+(_[a-z]+)*$`.
- Read current `DESIGN.md` before replacing boundary UI. Compose scaffold
  primitives and render request-hook results through `AsyncView`.
- Do not vendor platform-managed Skill content under `.agents/skills/`.
- Prefer route-by-route and entity-by-entity extraction over a broad rewrite.

## Exit Criteria

Start removing the boundary only when:

- Equivalent scaffold-native routes exist.
- Durable data dependencies use Drizzle schema, the current scaffold runtime
  bootstrap / `db:push` contract, services, thin APIs, and API-backed clients.
- Required legacy data has been imported and reconciled, or an intentional reset
  decision is recorded.
- No production durable CRUD or DB-failure fallback depends on browser storage,
  persisted Zustand slices, IndexedDB, memory mocks, or fixtures.
- Layout and navigation are native to the target shell, with no user-visible
  logout/sign-out or app-managed role-switch, role-picker, or impersonation
  entry and no App-local session/logout/select-role implementation.
- Role-aware Apps verify preview single-role view-as, deployed assigned-role
  union, known plus trusted unknown roles, explicit deployed empty roles, preview
  without a selected role yielding zero permissions, and legacy untrusted unknown-role rejection. Authorization
  never uses the primary display role. Roleless Apps contain no invented
  business-role requirement.
- Normal startup and first-request paths do not auto-insert demo, sample, or
  baseline rows for migrated durable business entities.
- Global CSS side effects are resolved.
- Primary workflows have current verification evidence, including reload/restart
  durability and database failure behavior.

## Common Failure Modes

- The legacy app compiles but is not reachable because routes were not mapped.
- Navigation works only through hash routes and breaks on direct URL load.
- Tables render empty because legacy store initialization was never mounted.
- Actions appear successful but only mutate local storage or an in-memory mock.
- API failures silently read stale local data, creating split-brain state.
- Legacy import duplicates records because retries are not idempotent.
- Global CSS overrides scaffold layout, buttons, or dialogs.
- Browser-only code executes during SSR and breaks hydration.
- A legacy personal menu still writes a role cookie or client role state, causing
  application state to diverge from Gateway-assigned roles.
- A migrated business table is repopulated with demo or baseline rows because a
  legacy runtime seed callback still runs during startup or the first request.
- A copied `.agents/skills/` tree silently freezes old platform guidance inside
  the App.
