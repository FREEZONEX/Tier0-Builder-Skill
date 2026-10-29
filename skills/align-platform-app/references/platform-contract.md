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
- [App Data Contract](#app-data-contract)
- [Build And Preview Contract](#build-and-preview-contract)
- [Migration Quality Gate](#migration-quality-gate)
- [Artifact Contract](#artifact-contract)
- [Production Start And Network Binding](#production-start-and-network-binding)
- [Packaging Contract](#packaging-contract)

## Target Shape

The target is the existing Tier0 TanStack Start scaffold, aligned to the latest
`FREEZONEX/Tier0-App-Scaffold` `feature/cloud-new-architecture-migration` branch
unless the user explicitly asks to pin a specific commit. Keep the scaffold's platform contract intact while importing
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
- Keep the `@tier0/sdk-v2` version and loading contract from the freshly
  inspected template, and access it through server-side lazy helpers rather than
  SSR/page-startup imports. App records go through the scaffold data layer.
- Keep `.agents/skills/` free of vendored Skill content. Platform Builder
  guidance is selected and injected by the App Builder orchestrator.
- `package.json` top-level `tier0Scaffold` (`{ "version", "ref" }`) is
  platform-owned: only this Skill writes it, copied from the inspected scaffold
  commit as the final step after full alignment verification passes. A scoped
  repair keeps the old marker; a passing partial build cannot certify full alignment.

## SDK Upgrades

The platform SDK is `@tier0/sdk-v2`; use the version pinned by the selected
scaffold commit as the target: copy its exact npm version (`0.3.0` at the
verified v13 snapshot). Reconcile that dependency into the App manifest and
regenerate its authoritative lockfile while preserving business dependencies;
copy the template lockfile only for an otherwise matching template dependency
graph. Check the package spec,
authoritative lockfile, and actual installed version separately.
Preserve an explicitly pinned user version and report unsupported behavior
instead of silently overriding it. Managed preview owns dependency
installation/restart; use a clean lockfile install only in an unmanaged checkout.

An app still on `@tier0/sdk` (v1) moves to v2 as part of alignment:

- Replace the dependency and keep the scaffold's loading contract: SSR external
  `["@tier0/sdk-v2", "mqtt"]` in `vite.config.ts` and the `@/lib/tier0` lazy
  loaders `loadTier0Sdk()` (root module, `createClient()`),
  `loadTier0OpenApi()`, `loadTier0Files()` and `loadTier0Mq()`. The v1 helpers
  `getTier0UnsApi`, `getTier0FlowApi`, `getTier0SystemApi` and
  `getTier0ClientHelpers` no longer exist.
- `createClient()` exposes `system`, `members`, `notifications`, `files`,
  `mqttAuth`, `capabilities`, `controls`, `source`, `stream`, `uns` and `agent`.
  Reuse one client for work done as the App; create a fresh client per request
  when passing employee data delegation. The App key never reaches the browser.
- v2 has no UNS v1, legacy Flow, project member queries or
  `getCurrentProjectId()`. App records move to the scaffold data layer (see
  [App Data Contract](#app-data-contract)); there is no Flow replacement, so
  report a source feature that depended on Flow as a concrete blocker instead
  of inventing one. Workspace members are not the members who can use this App:
  App-scoped pickers use `members.listApp({ appId: resolveAppId() })`, which the
  platform rejects locally (`local-app` placeholder) — that failure is expected.
- Read the Skills in `node_modules/@tier0/sdk-v2/skills/` for the exact API of
  the domain being rewritten instead of translating v1 calls by name.

An app on `@tier0/sdk-v2` 0.1.x / 0.2.x moves to 0.3.0, which calls only
`/openapi/v2` and removes retired methods without a fallback route:

- Platform calls (`system`, `members`, `notifications`, `files`, `mqttAuth`,
  `capabilities`, `agent`) go to `/openapi/v2/*` and Controls to
  `/openapi/v2/uns/controls/*`; the SDK does this, so delete any hand-written
  call to `/openapi/v1`. `tier0.api` / `loadTier0OpenApi()` expose the 44
  platform v2 operations only.
- Source: `source.list` / `get` / `create` / `update` and
  `source.connection.update` are gone; use `source.documents.*`.
- Stream: `stream.programs.get` / `create` / `update` / `validate` / `disable`
  are gone; drafts use `stream.documents.*` (disable passes both
  `expectedRevision` and `expectedActiveRelease`), publish and rollback stay on
  `stream.programs.deploy` / `rollback`.
- Agent: `agent.nodes.*` and `agent.relations.*` are gone with no v2
  replacement; report a source feature that needs them as a blocker.
- Low-level UNS calls (`tier0.uns`, `createUnsV2Client()`): `recordInsertMany`,
  `recordFindOneAnd*` and `recordDistinct` are gone; use `recordBulkWrite` with
  `insertOne` items, `recordUpdateOne` / `recordReplaceOne` / `recordDeleteOne`
  with `returnDocument`, and an aggregate `$group`. App records still go through
  `@/lib/data`, whose `insertMany`, `findOneAnd*` and `distinct` stay.
- `ControlError.errorCode` is the UNS `error.code`, with `requestId`,
  `execution` and `retry` alongside; branch on those codes.
- A write whose outcome was unknown before the upgrade is reconciled by
  reading back, never by resending it to the new route with its old key.

Notification behavior:

- Omitted or `undefined` channels expand to `['web', 'mobile']`. `web` covers
  Web & Desktop; there is no `desktop` value. Explicit arrays are deduplicated
  without adding channels; `[]` creates only the inbox message. Any other value
  throws a `TypeError` before the request.
- Keep intentional silent sends as `channels: []` and explicit single-channel
  choices as they are. If an existing call's intended scope is unclear, resolve
  that concrete choice before changing its reminder behavior. The expansion is
  SDK runtime behavior, not a raw backend API default.
- Preview/development sends use `mode: 'test'`; published sends use `'live'`.
  Do not synthesize or detect a `[Test]` title prefix; use message mode.
- Identify the App with `sender: { type: 'app', id: resolveAppId() }`. Preserve
  recipient selection and business-event idempotency. Verify request
  serialization with a stubbed transport; do not send real notifications solely
  to validate an upgrade. Delivery requires separate authorized verification.

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

`Tier0MQClient` reads `TIER0_MQTT_HOST` / `TIER0_MQTT_PORT` and uses
`TIER0_API_KEY` as the password. A workspace-encoded key
(`sk-<type>-ws<base36>_<secret>`) supplies the MQTT identity: the client derives
username and clientId from it. A key it cannot parse is rejected unless
username, clientId and password are all passed explicitly; there is no
Enterprise fallback. Dedicated credentials can be created with
`mqttAuth.create()` (returned only once). Do not invent hard-coded identity to
bypass failed authentication. A changed key passed to `connect({ password })`
recalculates auto-derived fields and preserves each explicit identity field.
Disconnect an established connection before changing credentials and
reconnecting.

After a relevant upgrade, verify the installed version following managed
restart (or clean unmanaged install), then exercise the affected connection and
subscription in an authorized environment. A build or local key-format check
does not prove broker authorization or message delivery. For authentication
failures, follow [MQTT authentication diagnostics](import-troubleshooting.md#mqtt-authentication-fails)
before changing credentials. Keep platform injection and server-side lazy loading.

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

1. Preview: use every comma-separated `X-Tier0-Preview-Role` value as the
   developer-selected view-as role set (one or several roles, permission
   union); the first value is the primary display role.
2. Deployed: use every comma-separated `X-Tier0-Business-Roles` value.
   Deduplicate roles and keep `X-Tier0-Active-Role` first only as primary display
   metadata, and only when it is one of them; otherwise it grants nothing.
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

Managed preview injects Gateway identity and may provide a view-as role set, so a
successful preview request does not prove deployed or unauthenticated behavior.
Separate these surfaces:

- Preview: one and several selected roles (permission union), and no selected
  role with zero roles/permissions.
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

When frontend alignment touches forms, required titles use `FieldGroup required`
or `FieldLabel required` with plain text: one red asterisk on the right. Keep
control validation and `required` / `aria-required` separate from the marker.
For list pages created or rebuilt within the requested scope, follow the
entrypoint's MetaListPage default and the selected scaffold's component-kit
provider/data/permission contract. Preserve working pages outside that scope.

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
  equate it to the human App name.

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
- App data access (`data` from `@/lib/data`) belongs behind services only.
- External platform I/O uses the scaffold SDK lazy loaders: at the verified
  snapshot these are `loadTier0Sdk` (root module, `createClient()`),
  `loadTier0OpenApi`, `loadTier0Files`, and `loadTier0Mq`. Invoke loaders inside
  the concrete server action that needs I/O. Do not top-level import the SDK
  root, `@tier0/sdk-v2/openapi`, `@tier0/sdk-v2/files`, or `@tier0/sdk-v2/mq`,
  and do not replace the SDK with hand-written REST/MQ/UNS fallbacks.
- Do not derive Tier0 resource namespaces from the default
  `package.json` name `scaffold`. Resolve the human App name from requirements
  or branding; use `APP_ID` or `/api/manifest` `appId` only as the distinct
  technical identifier.
- App-owned durable business data lives in Tier0 UNS collections as its single
  source of truth and migrates in this order: collection declaration (and
  `seed` for baseline records) -> service -> API -> client.
- LocalStorage, sessionStorage, IndexedDB, Zustand persist, in-memory mocks, and
  fixtures must not back production durable CRUD or serve as data-failure
  fallback.
- Store application-generated and user-uploaded files through the platform
  File Storage API, not the sandbox filesystem.
- Source persistence (an own database, migrations, an ORM) moves into the
  scaffold data layer only when the app owns that persistence; an external
  system of record stays external unless its ownership is in scope.

## Server, Client, And Node-Only Module Boundary

Respect the latest scaffold's explicit boundaries:

- Route components, UI components, `src/router.tsx`, client hooks, and shared
  wrappers are client or mixed modules. Do not statically pull Node-only `fs`,
  `path`, `url` modules or values from `@tier0/sdk-v2/data` / `@/lib/data` into
  their browser graph; declarations from `@tier0/sdk-v2/data/define` and types
  are browser-safe.
- `src/start.ts`, API route handlers, and `createServerFn` handler bodies are
  server-only boundaries. Keep server work there or in services called from those
  boundaries; do not force `src/start.ts` through a browser-safe wrapper.
- `src/start.ts` opens the SDK data request context
  (`runWithRequestContext(request, ...)` from `@tier0/sdk-v2/data`, which also
  cancels data calls when the caller goes away); do not add a second context,
  or data calls silently lose the employee subject.
- `src/routes/api/uns/subscribe.ts` is the one route that imports a data-layer
  module (`@/lib/data/changes`); keep it and its `requireAuth()` as upstream.
- Treat `react-router-dom` `BrowserRouter` as browser-only compatibility code.
  Render it inside the scaffold `ClientOnly` boundary so SSR does not evaluate
  `document`-dependent setup.

## App Data Contract

The scaffold's AGENTS.md → App Data and `docs/platform-integration.md` are
authoritative; read them before changing data. The essentials for alignment:

- Business data lives in Tier0 UNS collections owned by this App. There is no
  SQL database, ORM, connection string, migration or `db:push` step, and no
  `DATABASE_URL` / `DB_SCHEMA`. `TIER0_API_HOST` / `TIER0_API_KEY` are injected
  by the platform; never add them to `.env.example` or UI.
- Declare every collection with `defineCollection` from
  `@tier0/sdk-v2/data/define` in `src/data/collections.ts` and list it in
  `collections`. The schema is a storage schema limited to the documented
  subset; `npm run build` rejects anything UNS cannot store and validates every
  seed. Keep input rules (formats, lengths, defaults) in API input schemas.
- The App ensures every declared collection on first data access; do not add
  manual ensure calls, import-time data access, or initialization flags to App
  code. Worker-side ensure diagnostics follow
  [first-ensure-and-runtime-blockers.md](first-ensure-and-runtime-blockers.md):
  context can return 403 before first ensure creates the policy, and dry-run
  checks do not create it. Preview and the deployed App share the same collections, so ensure
  only widens. Narrowing a schema, changing descriptions, archive and restore
  are explicit worker operations through the tier0 MCP (`schema:replace`,
  `dryRun` first) and must not appear in runtime code.
- Baseline records are the declaration's `seed` (fixed `_id`s,
  `seedDate()` / `seedTimestamp()` / `requireSeedRef()` from
  `src/data/seed-utils.ts`), written once when the collection is created.
  For imported/migrated durable business entities, services never insert demo,
  sample or baseline rows on startup, on first request or when a list is empty.
- Never `deleteMany` or recreate a collection to reset a schema or test data:
  it deletes the deployed App's records too.
- Runtime data failures are `DataError`s (`execution`, `retry`,
  `outcomeUnknown`); let them reach `withErrors`, which adds `Retry-After` only
  for a 429 / 503 that is safe to repeat. The data layer already resent every
  call `retry.safe` allowed and keys each write itself, so the App adds no
  retry loops and passes no idempotency keys. `outcomeUnknown: true`
  (`execution: "unknown"`) means a write may have landed — read back before
  writing again. Branch on `code` / `reason`, never on message text.
- App records shown live refresh through `useRecordChanges(aliases, ...)` from
  `@/lib/record-changes`, not `refetchInterval` / `usePolling`; pass collection
  aliases, never declarations, from pages.
- A v9 app (`@tier0/sdk-v2` 0.1.0) keeps the target's existing collections and
  records. SDK 0.2.0 and later (UNS v2 contract 5.0.0) change App data code in
  these places:
  - `findPage` returns `total: { count, capped }` and `countDocuments` returns
    `{ count, capped }` instead of a number. List services answer
    `toQueryResult(page, { map, groups })` from `@/lib/data`, so a capped
    total renders as "N+"; never page through records to count them.
  - `DataError.retryable` and `retryAdvice` are gone (see `execution` /
    `retry` above). Remove App-side retry loops and explicitly passed
    `idempotencyKey`s, including stable keys per import chunk; fixed `_id`s
    and conditional updates keep re-run work from duplicating.
  - A failed `updateMany` / `deleteMany` with `execution: "committed"` has
    committed part of its matches: continue with
    `{ resumeAfter: error.details.resumeAfter }`, never rerun the whole call.
  - The data-access lint rule also flags `countBy`, `distinct`, `queryBatch`
    and `get([...])` per loop iteration: read by ID with one `get(ids)` and
    combine a screen's reads into one `data.queryBatch`.
  - Replace polling of App records with `useRecordChanges`, as above.
- A v8 app already stores records in UNS collections through its own
  `src/lib/data`: keep the target's existing collections and records, keep only
  the selected scaffold's `src/lib/data/**` (`index`, `query`, `changes`),
  import declarations from `@tier0/sdk-v2/data/define`, and open the request
  context only through `runWithRequestContext` from `@tier0/sdk-v2/data` — a
  leftover second context makes data calls silently run as the App. Take the
  upstream data gates with their gate-integrity manifest; services then follow
  the v9 points above.
- A v7-or-earlier app on Drizzle/PostgreSQL replaces that layer with
  collections without connecting to the old database or requesting credentials.
  Historical data does not migrate; if needed, the user imports it on the UNS
  side, outside Builder. Remove the Drizzle, `pg` and `db:*`
  dependencies, scripts and env usage together; leave the original deployment
  and database untouched.

## Build And Preview Contract

Use the scaffold's existing scripts and managed preview behavior:

- Do not manually install dependencies just to start managed preview.
- If managed preview already owns dependency installation, wait for it and do
  not launch a concurrent install. Restore dependencies manually only in a local
  or otherwise unmanaged environment, using the authoritative lockfile.
- Run `npm run build` for normal completion and let its automatic `postbuild`
  verifier finish. At the verified snapshot, `postbuild` runs `build:verify`,
  `auth:union:test`, `runtime:audit`, `test:components` and `test:data`; the
  verifier also covers typecheck,
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

For persistence cutovers, build success is insufficient. Verify supported API
lifecycle operations and constraints, reload/restart durability, and visible
failure without local fallback when the data layer fails (`DataError`).

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
- production run is `["node", "server.mjs"]` with no `image`: the platform
  supplies each environment's default runtime image. When aligning an older
  App, delete a hardcoded `[services.production.run].image`; `node:22-alpine`
  from docker.io cannot be pulled in environments without docker.io access
  (Aliyun), so the deployment fails with `ImagePullBackOff`
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
