# Platform Contract For App Alignment

## Contents

- [Target Shape](#target-shape)
- [Dependency And Lockfile Compatibility](#dependency-and-lockfile-compatibility)
- [Routing Contract](#routing-contract)
- [Gateway Identity And Assigned Roles](#gateway-identity-and-assigned-roles)
- [Platform Role Registration](#platform-role-registration)
- [Authentication Verification Environments](#authentication-verification-environments)
- [App Identity And Design Contract](#app-identity-and-design-contract)
- [Data And Server Boundary](#data-and-server-boundary)
- [Server, Client, And Node-Only Module Boundary](#server-client-and-node-only-module-boundary)
- [Database Schema And Runtime Bootstrap Contract](#database-schema-and-runtime-bootstrap-contract)
- [Build And Preview Contract](#build-and-preview-contract)
- [Migration Quality Gate](#migration-quality-gate)
- [Artifact Contract](#artifact-contract)
- [Production Start And Network Binding](#production-start-and-network-binding)
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
- Do not create product login/register, App-local sessions or logout endpoints,
  app-managed role-switch, role-picker, or impersonation flows. Remove imported
  equivalents. Login, logout, identity, and role assignment are platform-owned;
  the App must not read, write, or clear the Gateway login Cookie.
- Keep only auth surfaces present in the freshly inspected template. At the
  verified snapshot, `/api/auth/me` remains and `/login` is a hidden auth-error
  bridge; App-local logout and select-role routes do not exist.
- Do not expose platform-provided API keys, hosts, tokens, or MQTT credentials
  through user-editable forms.
- Keep Node `>=22.12.0` and the latest template script and verification contract.
- Keep the `@tier0/sdk` version and loading contract from the freshly inspected
  template, and access it through server-side lazy helpers rather than
  SSR/page-startup imports.
- Keep `.agents/skills/` free of vendored Skill content. Platform Builder
  guidance is selected and injected by the App Builder orchestrator.
- `package.json` top-level `tier0Scaffold` (`{ "version", "ref" }`) is
  platform-owned: only this Skill writes it, copied from the inspected scaffold
  commit as the final step after verification passes.

## SDK Upgrades

Use the SDK version in the selected scaffold commit as the upgrade target.
SDK 0.5.3 is the baseline for the MQTT fixes described below, not a pin or a
reason to downgrade a newer version. Check the package range, authoritative lockfile, and actual
installed version separately. An existing `^0.5.1` range permits 0.5.3 but a
lockfile pinned to 0.5.1 keeps `npm ci` on 0.5.1. Reconcile both when the requested
upgrade includes this target. Preserve an explicitly pinned user version and
report unsupported behavior instead of silently overriding it. Managed preview
owns dependency installation/restart; use a clean lockfile install only in an
unmanaged checkout.

Notification behavior introduced in SDK 0.5.1 remains applicable:

- Omitted or `undefined` channels expand to `['web', 'mobile']`. `web` covers
  Web & Desktop; there is no `desktop` value. Explicit arrays are deduplicated
  without adding channels; `[]` creates only the inbox message.
- Inspect existing send calls before upgrading from 0.4.0 or earlier. Change
  intentional silent sends to `channels: []`; preserve explicit single-channel
  choices. Generic notify intent can use the default, without inferring scope
  from page type. If an existing call's intended scope is unclear, resolve that
  concrete choice before changing its reminder behavior.
- The expansion is SDK runtime behavior, not a Skill-only instruction or raw
  backend API default. TypeScript restricts values; the SDK does not perform
  runtime channel validation. Keep runtime input validation at the app boundary
  when untyped user input supplies channels.
- Preview/development sends use `mode: 'test'`; published sends use `'live'`.
  Do not synthesize or detect a `[Test]` title prefix; use message mode.
- Preserve recipient selection, business-event idempotency, and runtime App
  identity. Verify request serialization with a stubbed transport; do not send
  real notifications solely to validate an upgrade. Delivery requires separate
  authorized environment verification.

For MQTT, use `toWebSocketUrl()` for a platform broker string and
`parseMqttBroker()` when endpoint fields are needed. Explicit WebSocket URLs
retain scheme/port/path/query. For non-WebSocket inputs, `toWebSocketUrl()` uses
`wssPort` (default 8084); `Tier0MQClient` instead honors a bare `host:port`
(e.g. `emqx:8083` uses WS in Node.js). Do not reuse an explicit TCP/MQTT URL's
port for WebSocket. Port 8084 or an HTTPS browser context selects WSS; other
ports use WS outside HTTPS browsers. `secure: true/false` overrides inference,
while explicit `ws://`/`wss://` URLs retain transport. A server cannot infer the
eventual browser's scheme; pass `secure: true` for browser WSS on other ports.
Handle undefined URL conversion as a configuration error.

Workspace-encoded non-service keys (`sk-<type>-ws<base36>_<secret>`) require SDK
0.5.2 or later for MQTT identity derivation. Target 0.5.3 for the additional
connect-time credential and endpoint fixes. Keep the original key as password
and let the SDK derive username/clientId; legacy keys retain the Enterprise
fallback. Preserve deliberate deployment-specific overrides, but do not invent
hard-coded identity to bypass failed authentication. A changed key passed to
`connect({ password })` recalculates auto-derived fields and preserves each
explicit identity field. Disconnect an established connection before changing
credentials and reconnecting.

After a relevant upgrade, verify the installed version following managed
restart (or clean unmanaged install), then exercise the affected connection and
subscription in an authorized environment. A build or local key-format check
does not prove broker authorization or message delivery. For authentication
failures, follow [MQTT authentication diagnostics](import-troubleshooting.md#mqtt-authentication-fails)
before changing credentials. Keep platform injection and server-side lazy loading.

### Existing App API-key type changes

Before the platform changes an existing App to a workspace-encoded non-service
API key, inspect the SDK version actually running in that App and whether it
uses MQTT. For MQTT apps below 0.5.2, upgrading the SDK is a prerequisite to the
key-type change; target 0.5.3 for the complete fixes described above. Updating
the scaffold or replacing a Skill does not upgrade deployed Apps.

Upgrade and restart the App first, confirm the installed version, and verify
its MQTT connection/subscription. Validate the target key in an authorized
staging or controlled cutover before retiring the old credential; a successful
connection using only the old key does not prove the new key works. If upgrade
or verification cannot be completed, do not automatically switch credentials;
report the compatibility blocker. Preserve a rollback path for the controlled
cutover rather than invalidating the working credential first.

An HTTP-only App must not be marked incompatible solely because its SDK is
below 0.5.2; check the target key's permissions and endpoint support. Unknown
runtime versions or unknown MQTT usage are unresolved checks, not evidence that
a switch is safe. This is a requirement for the platform credential-switch
workflow; this Skill does not implement platform enforcement.

## Dependency And Lockfile Compatibility

Treat the latest platform template dependency set as the target baseline. Before
merging a legacy frontend dependency graph into it:

- Identify the package manager and authoritative lockfile. Do not create a
  second lockfile for convenience.
- Inspect peer requirements for React, React DOM, Vite, the React plugin,
  TanStack Start/Router, UI libraries, browser-only packages, and build plugins.
- Verify that every proposed version exists and that the complete dependency
  graph resolves. Use package-manager-native inspection commands; treat commands
  that regenerate a lockfile as mutations, not read-only checks.
- Upgrade or replace incompatible legacy packages, or isolate them behind a
  compatibility boundary. Do not silently downgrade the platform baseline or
  hide an unresolved graph with force/legacy-peer flags.
- After changing dependency manifests, regenerate the authoritative lockfile in
  a controlled environment and verify an exact install from it.

When a legacy package cannot support the current scaffold baseline, document the
decision and evidence for replacement, isolation, or an explicitly approved
platform pin. A previously working source lockfile is evidence about the source,
not proof that its versions satisfy the target scaffold.

Report locked installation, full build, and runtime verification separately.
If `npm ci` fails on an unmodified upstream lockfile, retain the failing evidence
and reproduce in isolation. An `npm install` diagnostic may change that temporary
lockfile; a subsequent build pass does not prove the original package can pass
`npm ci`. Fix and revalidate the lockfile only within the requested scope; do not
replace production `npm ci` or add force/legacy-peer flags to conceal the defect.

## Routing Contract

Use TanStack Router file routes:

- Workspace/planning/admin pages go under `_app`.
- Scan, tap, confirm, or operator execution flows go under `station`.
- Exception review and approval flows go under `review`.
- Passive wallboards and large-screen displays go under `monitor`.
- Create a custom layout only when none of the built-in layout postures fit.

A resource with list and detail pages uses one of two explicit shapes:

- Nested: the parent renders `<Outlet />` only, the default list lives in a
  sibling `.index.tsx`, and the detail lives in `.$param.tsx`. A component-less
  parent may provide the outlet automatically. A deliberate master-detail parent
  may render its own content plus `<Outlet />`.
- Non-nested: append `_` to the parent segment so the detail renders standalone
  while the list remains a plain route, for example `_app.reports_.$id.tsx`.

Do not put a nested detail behind a parent that renders no outlet. The locked
`route-nesting-contracts` gate fails `npm run build` for invalid shapes, including
arbitrary dynamic parameter names; fix route structure rather than editing the
gate.

Declare workspace navigation through `defineNavigationModules`. Each clickable
leaf must have a unique `href` that resolves to an existing non-API workspace
route. Do not add a generic Overview item unless the product actually needs it.

Do not import from `next/link`, `next/navigation`, `next/image`, or
`next/headers`. Use TanStack Router APIs and scaffold helpers.

## Gateway Identity And Assigned Roles

Identity and roles are read-only Gateway inputs resolved on every request. The
App does not own an authentication session.

Resolve roles by runtime:

1. Preview: use `X-Tier0-Preview-Role` as the single developer-selected view-as
   role.
2. Deployed: use every comma-separated `X-Tier0-Business-Roles` value.
   Deduplicate roles and keep `X-Tier0-Active-Role` first only as primary display
   metadata.
3. Legacy fallback: `X-Tier0-Active-Role`, `X-Tier0-Preview-Role`,
   `X-App-User-Role`, then JSON `user.role`. These legacy sources remain
   single-role and matrix-gated.

Authorization rules:

- Use `AppUser.roles` for authorization. Effective actions are the union of
  `PERMISSION_MATRIX` actions across all assigned roles. Never authorize with
  `AppUser.primaryRole`.
- Do not rank roles or choose a "highest" role. A known assigned role still
  grants its actions when another trusted assigned role is unknown.
- A trusted Tier0 runtime role missing from `PERMISSION_MATRIX` enters with zero
  permissions. It does not fail the request and does not elevate.
- An unknown role from a forgeable legacy source fails closed.
- An explicit deployed empty role set stays empty and never receives admin
  fallback.
- A preview Gateway identity without a selected role enters with zero roles
  and zero permissions. There is no built-in or reserved fallback role.
- Gateway identity with no applicable role context is denied. No Gateway
  identity is unauthenticated.
- The client must not select or write roles through localStorage,
  sessionStorage, cookies, query parameters, request bodies, or request headers.
  Platform assignment or preview view-as changes take effect on the next request
  or refresh.

First determine whether the source is roleless or role-aware. Do not invent
business roles for a roleless source. For a role-aware source, migrate all roles,
permission mappings, navigation/page/action guards, API authorization, and
registration metadata before calling alignment complete.

During import or update, remove custom login/register, App-local session code,
user-visible logout/sign-out, logout/select-role endpoints, role pickers,
impersonation, and Gateway Cookie mutation. Keep `/api/auth/me` and the hidden
`/login` error bridge when they are present in the current template. Logout is
platform-owned for every App.

## Platform Role Registration

Keep every business role aligned across:

1. `src/lib/permissions.ts` — `ACTIONS` and `PERMISSION_MATRIX`.
2. `src/lib/role-metadata.ts` — label, description, and default route.
3. Root `roles.json` — platform registration records.

`role_key` must exactly equal the matrix/metadata key and satisfy
`^[a-z]+(_[a-z]+)*$`: lowercase letters separated by single underscores. Digits,
hyphens, uppercase, leading/trailing underscores, and double underscores are
invalid and cause platform import registration to fail.

Keep `roles.json` as `{ "roles": [] }` for a roleless App. Do not add demo/test roles. A
business-defined `admin` is an ordinary role
and must be registered just like every other matrix role. On import, the platform
uses `roles.json` to create/reuse and bind roles. On export, the platform
regenerates it from registered state; do not treat a hand-edited exported copy
as the durable platform source.

The scaffold starts with empty role definitions and reserves no role name.
Default the first version to no more than three business roles total, chosen
for materially different permission scopes. The current locked gate checks
matrix and metadata counts; a business-defined `admin` counts toward the three. Do not
create one role per page, action, or job title. When a source App
has more materially distinct roles, do not silently omit them, merge them into
broader access, or register them with zero permissions. Stop and obtain an
explicit user/platform decision for a safe consolidation or phased migration,
then keep the approved mapping traceable across permissions, metadata,
navigation, API guards, and `roles.json`.

Registration is distinct from permission. A platform-registered role absent from
the matrix may legitimately enter with zero permissions and produce an advisory;
that is not equivalent to delivering a migrated role's expected capabilities.
Do not delete such a registration or grant broad access just to remove a warning.

## Authentication Verification Environments

Managed preview injects Gateway identity and may provide one view-as role, so a
successful preview request does not prove deployed or unauthenticated behavior.
Separate these surfaces:

- Preview: selected role, and no selected role with zero roles/permissions.
- Deployed: two known assigned roles with permission union; known plus trusted
  unknown; explicit empty assigned-role set; active-role display ordering.
- Legacy: recognized single role and unknown untrusted role failing closed.
- No identity: unauthenticated behavior.
- Browser mutations: same-origin protection when the current scaffold provides
  it.

Use the current scaffold tests and exact headers/statuses. Do not freeze a
historical Cookie, precedence, or status matrix in migrated code.

## App Identity And Design Contract

Before frontend changes, read the current `DESIGN.md`. Compose the shared
button, badge, card, page-header, filter, risk, empty-state, stat, form—including
`FileUpload`—overlay, table, and async-state primitives where the scaffold
provides them. Do not fork token values or hand-roll equivalent primitives in
migrated routes.

Preserve and complete the in-scope business-object lifecycle on management routes;
do not add unrelated operations during a partial scaffold update. A
workspace route is intentionally read-only only when it is a monitor, report,
audit, or derived result and carries `READ_ONLY_SURFACE: <reason>`. Lifecycle
actions must connect reachable UI, validation, permission checks, service/API
mutation, persistence, and visible success/error feedback.

Do not add a page-introduction subtitle that repeats the title or explains
navigation. Put actionable rules and risk beside the affected record or control;
keep role summaries out of page content.

Interactive pages must remain usable at 375px without page-level horizontal
overflow. An `input`, `select`, or `textarea` using `flex-1`, `grow`, or
`flex-auto` needs a maximum or fixed width. A hard minimum width above 375px must
sit inside a local horizontal-scroll region, such as `TableViewport`. The locked
`responsive-contracts` gate enforces these rules during `npm run build`.

Keep App identity centralized in `src/lib/app-chrome.ts`:

- Set `APP_NAME` to the real business App name.
- Set `APP_LOCALE` with the name so document language, native inputs, and shared
  copy stay consistent.
- Replace placeholder product and shell copy.
- Preserve an existing valid brand during alignment; do not rebrand merely
  because the upstream placeholder changed.
- On icon generation/rebrand, persist root `icon.png` (512x512 PNG, <=2 MB),
  copy it byte-for-byte to `public/app-icon.png`, and set
  `APP_ICON = "/app-icon.png"`. Register the root file with
  `update_app_info({ icon_path: "icon.png" })` when available and in scope.
- Persist any designed/changed cover as root `cover.png` (PNG, <=8 MB) before
  registering `cover_path: "cover.png"`. Do not register temporary/external
  files as the only copy. If both images change, persist both before syncing.
- Verify root/public icon bytes and actual metadata sync separately. An
  unavailable or failed sync remains pending, not inferred from source changes.
- Use `resolveAppId()` from `@/lib/app-id` at runtime for technical identity
  such as notification `sender.id`. `APP_ID` is the platform App UUID;
  `local-app` is a local-only fallback. Never hard-code the current UUID or
  equate it to the human App name or `DB_SCHEMA`.

### Workspace Spacing And Dialogs

Ordinary `_app` page roots use `<div className="page-shell ...">`; preserve
page-specific vertical rhythm on that root. The shared class supplies 16px
horizontal / 20px vertical narrow-screen padding, 24px from 640px, and 32px
from 1024px, with shrinkable children. `Shell` retains its centered 1440px cap.
Remove duplicate outer padding rather than nesting another inset. Station,
review, and monitor layouts own their spacing; do not add `page-shell` there.
Preserve intentional app customizations when reconciling this upstream default.

Replace product-interaction `alert`, `confirm`, and `prompt`, including calls
through `window`, `globalThis`, or `self`, with application primitives:

- `toast()` for nonblocking feedback; `Dialog` for acknowledgement.
- `ConfirmDialog` for risky actions: show affected object/consequence, use a
  concrete action label, wire `pending`, and leave data unchanged on cancel.
- `FormDialog` for controlled input with validation and explicit submission.

Native confirmation is synchronous; application dialogs resolve through
callbacks/state. Move the mutation into the confirmed submit path, not directly
after opening the dialog. Verify cancellation, one confirmed write, duplicate
submission prevention, and error feedback. This is generation/migration guidance,
not a new native-dialog scanner or build gate.

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
- External platform I/O uses the scaffold SDK lazy loaders: at the verified
  snapshot these include `loadTier0OpenApi`, `loadTier0Files`,
  `getTier0UnsApi`, `getTier0FlowApi`, `getTier0SystemApi`, and `loadTier0Mq`.
  Invoke loaders inside the concrete server action that needs I/O. Do not
  top-level import `@tier0/sdk/openapi`, `@tier0/sdk/files`, or
  `@tier0/sdk/mq`, and do not replace the SDK with hand-written REST/MQ
  fallbacks.
- Do not derive Tier0 resource namespaces from the default
  `package.json` name `scaffold`. Resolve the human App name from requirements
  or branding; use `APP_ID` or `/api/manifest` `appId` only as the distinct
  technical identifier.
- App-owned durable business data uses PostgreSQL as its single source of truth
  and migrates in this order: Drizzle schema -> current scaffold
  `bootstrapModule()` / `db:push` contract -> service -> API -> client.
- LocalStorage, sessionStorage, IndexedDB, Zustand persist, in-memory mocks, and
  fixtures must not back production durable CRUD or serve as database-failure
  fallback.
- Existing local durable data may enter PostgreSQL only through an explicit,
  validated, idempotent import with defined identity/conflict handling and
  reconciliation evidence.
- Store application-generated and user-uploaded files through the platform
  File Storage API, not the sandbox filesystem.
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

The platform provisions the database schema. App runtime must never execute
`CREATE SCHEMA`, even with `IF NOT EXISTS`: the runtime account need not have
that database-level privilege. Remove legacy runtime creation when aligning;
verify the injected schema exists separately. `IF NOT EXISTS` does not remove
the schema-creation privilege requirement. Do not add admin credentials, grant
database-level `CREATE`, or unset `DB_SCHEMA` to bypass the failure. If the
injected schema is missing, report provisioning failure instead of creating it
in App startup or request code.

Declare all tables/enums with `appSchema.table(...)` / `appSchema.enum(...)` in
`src/db/schema.ts`, never bare `pgTable`/`pgEnum` or declarations elsewhere.
Pass declared table objects to `bootstrapModule()` and await each module's
shared bootstrap promise before queries. Undeclared runtime tables can be
removed by platform schema sync; runtime-only DDL is not a durable declaration.

Before local sync, use `npm run db:push:check`, then the guarded `npm run db:push`.
Do not bypass a DROP/TRUNCATE refusal. Use `DB_SYNC_ALLOW_DESTRUCTIVE=1` only for
an explicitly authorized destructive plan with backup/recovery accounted for.
Ordinary startup must not depend on having run `db:push` or bulk `db:seed`.

Runtime bootstrap is for idempotent table/index DDL inside the provisioned schema. For
imported/migrated durable business entities, normal startup and first-request
paths must not auto-insert demo, sample, or baseline business rows. Retained
legacy rows enter through an explicit validated import, and development/test
fixtures run only through an explicit development or test action. This migration
constraint does not define the seed behavior of a separately generated 0-to-1
app.

When retained runtime baseline data is appropriate, use `seedDate()` for Drizzle
`date()` columns and `seedTimestamp()` for `timestamp()` columns. Write seed data
through typed transactional `tx.insert()` / `tx.update()` / `tx.delete()`
builders. Do not use raw SQL for data writes or pass the numeric return value of
mutating `Date` setters.

## Build And Preview Contract

Use the scaffold's existing scripts and managed preview behavior:

- Do not manually install dependencies just to start managed preview.
- If managed preview already owns dependency installation, wait for it and do
  not launch a concurrent install. Restore dependencies manually only in a local
  or otherwise unmanaged environment, using the authoritative lockfile.
- Run `npm run build` for normal completion and let its automatic `postbuild`
  verifier finish. At the verified snapshot, `postbuild` runs `build:verify`,
  `auth:union:test`, and `runtime:audit`; the verifier also covers typecheck,
  lint, contract tests, and runtime safety. Locked contract coverage includes
  route nesting, navigation, lifecycle/read-only content, role limits, and 375px
  responsiveness. Do not substitute `vite build` or edit locked gates to make
  App code pass.
- If route files change, let the TanStack Router plugin regenerate the route
  tree through dev/build tooling.
- Do not treat a static build success as deployability unless production start,
  health, and manifest behavior are also covered.
- Preserve Vite base path support through `VITE_BASE_PATH`, with
  `NEXT_PUBLIC_BASE_PATH` only as a legacy fallback.
- Preserve `server.watch.ignored: ["**/.tier0/**"]`; platform session-state
  writes are not application source and must not amplify into reloads.
- Preserve preview Gateway header injection when aligning `vite.config.ts`; do
  not add App-session injection.
- When preview returns a local URL, run
  `npm run smoke:routes -- <url> [/changed-route ...]`. Treat the URL as a local
  self-check address, not a user-facing link.
- Use `preview-runtime-stability` for managed install, port/process lifecycle,
  readiness timeout, and HMR failures when the orchestrator injected it. Never
  copy that Skill into `.agents/skills/`.

For persistence cutovers, build success is insufficient. Verify clean-schema
runtime bootstrap / `db:push`, supported API lifecycle operations and constraints,
reload/restart durability, and visible failure without local fallback when
PostgreSQL is unavailable.

## Migration Quality Gate

Use the freshly inspected scaffold scripts rather than assuming historical
script names. Before declaring migration complete:

- Run the current normal build command and its complete post-build verifier.
- Treat migration-introduced failures and type errors that can affect runtime
  behavior as blockers.
- Baseline genuine pre-existing failures before the migration. Historical lint
  or dead-code findings may be recorded as follow-up only when they do not hide
  migration or runtime defects.
- Record each accepted remaining failure with evidence, impact, and a concrete
  next action. Do not describe the platform migration as fully complete while a
  blocking class remains.
- Preserve invariant tests and scripts named by `scripts/gate-integrity.json`.
  For an authorized upstream scaffold update, replace changed locked files
  together with their matching verified upstream manifest; never locally weaken
  assertions or recompute hashes to conceal failing App code. At this snapshot, only
  `src/lib/template-state.test.mjs` is App-adaptable. If a locked gate reports an
  intentional external caller or read-only surface, use its documented marker
  or restructure the App; editing the gate is not the fix.
- Every mutation API route must have a reachable UI caller through `apiUrl()`,
  or a documented external caller marker. First-load request state must render
  through the current async-state primitive so failures do not masquerade as
  endless loading.

## Artifact Contract

The current upstream template's `artifact.toml` defines the platform service
shape:

- `deployment.deploymentTarget = "autoscale"`
- production `serve = "dynamic"` describes deployment serving mode, not a gate
- production build runs `npm ci && npm run build && npm prune --omit=dev`
- production run uses `node server.mjs` on `node:22-alpine`
- service `localPort = 5173`
- startup health path is `/api/health`
- preview runs `npm run dev -- --host 0.0.0.0 --port 5173`
- preview env includes `NODE_ENV`, `HOST`, `BROWSER`, and `VITE_ALLOWED_HOSTS`

Do not replace this with source-project-specific dev server assumptions.

Every `args` array is literal argv under POSIX `execve` semantics:

- Shell behavior must be explicit, for example
  `["sh", "-c", "npm ci && npm run build && npm prune --omit=dev"]`.
- Plain commands remain tokenized argv, for example
  `["npm", "prune", "--omit=dev"]` and `["node", "server.mjs"]`.
- Legacy join-era shell-operator tokens and single-element whole commands may be
  normalized by the platform with a warning, but new or aligned files use the
  canonical forms.
- Do not change build/deploy args unless the task actually requires it.

## Production Start And Network Binding

Run the production entry with the target runtime's host, port, and environment
contract. Verify from the same network namespace used by the startup probe and,
when possible, through the platform-facing route:

- the process binds to the interface and injected port expected by the current
  scaffold and `artifact.toml`;
- `/api/health` and `/api/manifest` respond;
- an SSR page, static client asset, and representative API route respond;
- host selection through `HOST`, `HOSTNAME`, or another runtime variable behaves
  correctly in the actual container/runtime environment.

Do not infer deployability from Vite dev readiness or from a process that merely
stays alive. If loopback and container-network probes behave differently, record
the binding evidence and reconcile it with the latest scaffold instead of
silently inventing a second production entry.

## Packaging Contract

Packaging rules depend on the target import environment. The stable baseline is:

- Confirm whether the importer accepts an app-root archive or one enclosing
  directory. Make `package.json`, `server.mjs`, platform config, and root brand
  assets discoverable at the app root it resolves; do not guess folder depth.
- For source imports that rebuild, include tracked source and the authoritative
  lockfile; exclude generated `dist`/`.output` and dependencies. For a runtime
  artifact, include exactly the output required by the confirmed runtime entry.
  Do not require built output in every source ZIP.
- Include `node_modules` only when the target import environment is offline or
  explicitly supports preinstalled dependencies without reinstalling them.
- Exclude local caches, git/editor metadata, generated temporary folders, and
  real local secret/env files; retain tracked `.env.example` when applicable.
- Do not package platform-managed Skill content in `.agents/skills/`; the
  orchestrator owns Skill selection and injection.
