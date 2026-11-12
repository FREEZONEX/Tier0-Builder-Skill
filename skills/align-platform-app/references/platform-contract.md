# Platform Contract For App Alignment

## Contents

- [Target Shape](#target-shape)
- [SDK Upgrades](#sdk-upgrades)
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

From v35 the scaffold pins `@tier0/sdk-v2` to an exact npm release (`0.12.2`
at v39). Copy that dependency spec and reconcile the authoritative lockfile
while preserving business dependencies, so the SDK entry resolves from
registry.npmjs.org. Copy a template lockfile only for an otherwise matching
graph. Verify lockfile integrity and installed package version separately.
Delete an old local SDK archive (`vendor/tier0-sdk-v2-*.tgz`) with its `file:`
spec, and `vendor/` itself when nothing else uses it. Honor a user-pinned
target.

Pre-v27 Apps need the coordinated visitor, data, change-relay and credential
migration in [cloud-architecture-upgrade.md](cloud-architecture-upgrade.md#cloud-apps-before-v27).
Updating only the SDK leaves removed imports and can broaden data visibility.
Managed preview owns installation/restart; exact lockfile installs belong in
an unmanaged checkout. Read API Skills/types from the actual installed package.

Keep server SDK loading through `@/lib/tier0`: `loadTier0Sdk()` for
`createClient()`, plus `loadTier0OpenApi()`, `loadTier0Files()` and
`loadTier0Mq()`. Keep Vite SSR external `["@tier0/sdk-v2", "mqtt"]`.
The platform injects `TIER0_API_HOST`, `TIER0_API_KEY`, `TIER0_APP_ID`,
`TIER0_MQTT_HOST`, `TIER0_MQTT_PORT` and `TIER0_RUNTIME` into the App runtime.
Preview and deployment have different App keys. The SDK consumes the key;
App code never reads, copies, logs or returns it, and no browser receives it.
Do not implement hand-written platform REST calls or retired node-proxy headers.

### Fixed App capabilities and external collections

All Apps have the same platform capabilities: member queries, notification
sending, files, Stream requests and Stream messages. Effective access is still
bounded by the key's permissions/mode and workspace plan. No per-App platform
policy, message-topic settings or publish-time capability confirmation exists.

The hosted App allowlist includes data operations, `members.listWorkspace`,
`members.listApp`, `notifications.send`, `client.files` (`assets/files/**`),
`client.streams.requests`, `client.streams.messages`, `capabilities.discover`
and `system.info`. `assets/upload`, `system.whoami`, `notifications.get`,
`mqttAuth` and `agent` are unsupported for hosted Apps; Source/Stream management
is refused too. SDK method existence does not establish hosted App access.

The App accesses its own collections and external collections granted to it.
For task-required access to existing collections, built-in Builder uses its
injected management identity and the installed SDK grant workflow. Verify the
real target App and collection in the same workspace; use only required access.
Read the current policy, apply incremental `changes` with `expectedRevision`,
preserve other grants and disabled status, then verify the committed receipt,
policy readback and effective access with the App identity. A revision conflict
requires rereading; an unknown write outcome requires reconciliation before retry.
Do not request an Owner/Admin role or repeat confirmation solely because this is
Builder; clarify ambiguous targets or access outside the requested task.
Backend authorization still applies. Never use an App runtime key to manage
grants or bypass a 403 by changing credentials or copying collections.
App code uses `data.collection({ collectionId })`
for a granted external collection. A grant or removal applies on the next
request, without republishing. App-level grants are separate from service-level
permissions for the current visitor.

### Members and older SDK callers

App-scoped pickers use `members.listApp({ appId: resolveAppId() })`;
workspace members are not equivalent to people who can use the App. The SDK
maps injected `TIER0_RUNTIME=preview` to draft roles and `deployed` to published
roles. Never pass `scope`, set runtime variables in App config, hard-code
members or block on `published` with a 409/error/"publish first" message.
Render actual members and a normal empty state for an unassigned role.
Hosted member responses have no email; use `userName` for labels.
The local `local-app` placeholder cannot perform App-scoped calls.

An App on v1 (`@tier0/sdk`) migrates its remaining callers before removing the
dependency. Retired `getTier0UnsApi`, `getTier0FlowApi`, `getTier0SystemApi`,
`getTier0ClientHelpers`, UNS v1, project-member and legacy Flow calls have no
name-only translation. App records use `@/lib/data`, not raw `tier0.uns`.
Use the installed SDK types for the business operation or report an unsupported
feature. Do not replace an unsupported hosted route with Source/Stream
management or an extra credential. When crossing older data API versions,
retain capped counts, conditional writes, SDK-owned retries and the error
semantics under [App Data Contract](#app-data-contract).

### Unified SDK and Stream Migration

The earlier dual-package/browser candidate (`@tier0/sdk/cloud`, browser
`client.streams`, `@tier0/sdk-v2/runtime`) is retired. Move those calls to the
App server through `createClient()` with the App key. Pages call authenticated
App routes that enforce user permissions; never import server SDK values into
the browser or fabricate a runtime identity/provider. Remove the old package
only after migrating all callers; preserve business behavior and data identities.

- The workspace plan must include Stream. Each request code needs a grant to
  this App in Stream request grants. Messages follow published manifests:
  subscribe to what a published Stream publishes and publish to what an active
  Stream subscribes to. There is no per-App topic list. Stream logical topics
  are separate from the MQTT namespace below.
- Retired Controls, `ControlError`, execution aliases and interpreter selectors
  are not current APIs. Preserve supported business intent using Stream calls;
  keep `tier0-stream/v3` rather than inventing a compatibility route.
- Requests make one POST without automatic retries. Preserve command
  idempotency; reconcile uncertain outcomes before deliberate replay with the
  same key. `outcomeUnknown: false` is not proof that execution never started.
  This differs from App data calls, where SDK owns retries/idempotency.
- Messages use ephemeral NATS Core WSS credentials (Node.js 22+), with no
  offline queue, replay or receiver ACK. Preserve direction grants, dispose
  resources, and do not promise delivery guarantees the API lacks.
- Pure DataKeys remain data-only. Report missing grants, plan or runtime
  support; do not expand permissions or add a second control credential.

Run the selected target's `test:streams` and verify affected server routes and
browser behavior in an authorized environment. A fixture/build does not prove
Gateway/SYS/broker deployment, live grants or message delivery.

### Notification behavior

- Omitted or `undefined` channels expand to `['web', 'mobile']`. `web` covers
  Web & Desktop; there is no `desktop` value. Explicit arrays are deduplicated
  without adding channels; `[]` creates only the inbox message. Any other value
  throws a `TypeError` before the request.
- Keep intentional silent sends as `channels: []` and explicit single-channel
  choices as they are. If an existing call's intended scope is unclear, resolve
  that concrete choice before changing its reminder behavior. The expansion is
  SDK runtime behavior, not a raw backend API default.
- Do not set `mode`; the platform decides it and ignores the request value.
  Sends from preview or the sandbox are test and appear only in that App's
  Building preview bell; a deployed App's sends are live. Do not synthesize or
  detect a `[Test]` title prefix.
- When the user asks you, the Builder Agent, to send a notification, call
  `POST /openapi/v2/notifications/send` from the Tier0 MCP `execute` tool.
  `sender: { type: 'app', id: <this App's ID> }` (id is required; the platform
  uses the session's App) sends a test notification shown only in this App's
  preview bell, e.g. to try a business notification while building;
  `sender: { type: 'system', id: 'uns-agent' }` sends a live system
  notification to the message center, for news the user needs outside this
  App. `link` is optional; without it, opening the message does not navigate.
- Identify the App with `sender: { type: 'app', id: resolveAppId() }`. Preserve
  recipient selection and business-event idempotency. Verify request
  serialization with a stubbed transport; do not send real notifications solely
  to validate an upgrade. Delivery requires separate authorized verification.

### MQTT

Use `Tier0MQClient` on the App server through `loadTier0Mq()`. It reads the
platform-injected host/port/key. Browsers never connect to the broker; remove
`getMqttToken` and browser token sources. Use a server subscription and an App
route to forward only messages the authenticated visitor may see. Other App
SSE routes use `openEventStream` so hidden pages close, resume positions are
preserved and App wake/reconnect works; do not substitute raw `EventSource`.

Build every publish/subscribe topic with `appTopic(suffix)` from the same lazy
module, e.g. `mq.subscribe(appTopic("alarms/#"), onAlarm)`. Topics are confined
to `apps/<TIER0_APP_ID>/<preview|deployed>/`; wildcards work inside that prefix.
Other Apps, the opposite runtime and arbitrary topics are refused. External
producers for the live App use its deployed namespace with their own credential.
Do not change those systems unless authorized. `appTopic()` throws when App ID
or a valid runtime is absent; do not spoof `TIER0_RUNTIME` for local development.

The SDK derives MQTT identity from a workspace-encoded key and has no Enterprise
fallback. Hosted Apps cannot call `mqttAuth.create()` to work around a failure.
Check actual installed SDK, platform injection, key type and broker support
without exposing credentials. Keep intentional transport configuration and use
the installed SDK's `parseMqttBroker` / `toWebSocketUrl` when needed; do not
guess a WebSocket port from a TCP URL. For diagnostics see
[MQTT authentication failures](import-troubleshooting.md#mqtt-authentication-fails).
An install/build pass is separate from broker connection and topic authorization.

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
gate. An API-only subtree, whose parent and every dynamic child declare `server`
handlers and no `component`, renders no page and needs no index route; a
component that renders no outlet still fails.

Declare workspace navigation through `defineNavigationModules`. Each clickable
leaf must have a unique `href` that resolves to an existing non-API workspace
route. Do not add a generic Overview item unless the product actually needs it.

Do not import from `next/link`, `next/navigation`, `next/image`, or
`next/headers`. Use TanStack Router APIs and scaffold helpers.

## Gateway Identity And Assigned Roles

At v28, the only identity is the front door's plain, unsigned base64url JSON
`X-Tier0-Visitor`. The front door strips client-supplied `X-Tier0-*` before
setting it and must be the only production ingress. Use `parseVisitorHeader`
through `src/lib/visitor.ts` to validate the payload and expected App. Do not
trust this header through an independently exposed App port or implement a
legacy header/session fallback. No JWT/JWKS verifier remains.

- `app_roles` is the complete role set in both runtimes. Preview uses its
  selected view-as set. Effective permissions are the union of actions for
  `AppUser.roles`; `active_role` orders display only when it is assigned.
- Unknown trusted roles grant zero actions without erasing known-role actions.
  Empty roles mean zero permissions; no admin/first-role fallback exists.
- Missing, malformed or wrong-App identity is unauthenticated; missing required
  runtime App identity is a configuration fault. Keep target tests/statuses.
- Only employee visitors are accepted: a machine identity is 401 on every
  path, and there is no `src/lib/webhooks.ts` or `[[webhooks]]`. Server
  functions require an employee unless explicitly named `publicServerFn<Name>`.
  Preserve the target's same-origin mutation checks.
- All platform calls act as the App and carry no visitor delegation. Services
  must filter reads, reject unauthorized writes and trim fields using the
  authenticated user and `can(user.roles, action)`. Menu hiding or role
  registration alone cannot protect data.

Preserve roleless sources without invented roles. For role-aware sources,
preserve every business scope across services, UI, matrix, metadata and
registration. Remove App-local login/register/session/logout, role pickers,
impersonation and Gateway Cookie mutations. Keep `/api/auth/me` and the hidden
`/login` error bridge if present in the target. Client storage, query/body fields
and arbitrary headers cannot override identity. Assignment/view-as changes are
read on subsequent requests; existing event streams reauthenticate on reconnect.

For pre-v27 migration, do not copy stale signed-token wording from
`docs/role-registration.md`; the implementation and migration notes at the
[recorded baseline](latest-template-source.md) establish the current parser.

## Platform Role Registration

Keep every business role aligned across:

1. `src/lib/permissions.ts` — `ACTIONS` and `PERMISSION_MATRIX`.
2. `src/lib/role-metadata.ts` — label, description, and default route.
3. Root `roles.json` — platform registration records.

`role_key` must exactly equal the matrix/metadata key and satisfy
`^[a-z]+(_[a-z]+)*$`: lowercase letters separated by single underscores. Digits,
hyphens, uppercase, leading/trailing underscores, and double underscores are
invalid and cause platform import registration to fail.

Each entry also needs a non-empty `name`. The platform reads only `role_key`
(or the legacy `key`), `name` and `description`; it ignores `display_name` and
`label`, and one entry without `name` rejects the whole file
(`roles[i].name is required`). The App is still imported, but none of its
roles is linked. When aligning, move a `display_name` or `label` value into
`name` and delete the old field; if neither exists, use the role's label in
the App's `ROLE_METADATA`, and ask the user when that is missing too. Editing
the file does not register roles: if they were not linked on import, call
`sync_business_roles` after alignment and follow its confirmation below.

Keep `roles.json` as `{ "roles": [] }` for a roleless App. Do not add demo/test roles. A
business-defined `admin` is an ordinary role
and must be registered just like every other matrix role. On import, the platform
uses `roles.json` to create/reuse and bind roles. On export, the platform
regenerates it from registered state; do not treat a hand-edited exported copy
as the durable platform source.

`sync_business_roles` writes nothing when it returns
`status: "confirmation_required"`: tell the user to confirm or cancel the role
plan card in the chat and end the turn. Do not retry, change a `role_key` to
get around it, or suggest publishing while it waits. The user's next message
reports the result; after a cancellation, adjust the roles as the user says and
sync again. You may propose a new name for a reused role but never change its
`role_key`; the user chooses on the card whether to use the new name. Its
description is merged with yours.

The scaffold starts with empty role definitions and reserves no role name.
Default the first version to no more than three business roles total, chosen
for materially different permission scopes. This is a first-version recommendation,
not a hard gate. Preserve materially distinct source roles and their permissions;
do not stop solely because there are more than three. Consolidation or phased
migration is a business decision, never an automatic way to silence an advisory.

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
- Invalid identity: missing/malformed/wrong-App `X-Tier0-Visitor`; legacy
  headers alone never authenticate. Production needs the trusted front door.
- Caller kind: machine identities are rejected on every path; employee-required
  server functions remain protected.
- Data: reads, writes, fields and change-event visibility for each relevant
  role, including denied cases. Platform App access is not visitor authorization.
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
sit inside a local horizontal-scroll region, such as `TableViewport`. The
`responsive-contracts` checks report layout advisories during `npm run build`;
inspect actual affected layouts rather than treating heuristics as hard failures.

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
  Stream and MQTT calls stay server-side; browser pages use authorized App
  routes, never a browser platform client or credential.
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
- `src/start.ts` wraps every request in `runWithAbortSignal(request.signal, ...)`
  from `@tier0/sdk-v2/data`; queued/in-flight calls cancel with the request.
  There is no employee data context. Work that must outlive the request uses
  `runDetached` with the required business authorization retained.
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
  `collections`. Give new aliases a `directoryPath` (1–16 business-name segments,
  each ≤63 characters) from the workspace root. First inspect and reuse real
  directories; industrial data follows its known ISA-95 equipment scope and
  shared data a suitable common ancestor. Do not invent missing levels or use
  a default root-level App container. An App/business-module directory such as
  MES is valid within a known factory/line scope. A new alias without a path fails; ensure never moves an
  existing alias when a path is omitted or changed. Directory placement does
  not change collection ownership or grants. The schema is a storage schema limited to the documented
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
  `@/lib/record-changes`, not `refetchInterval` / `usePolling`; pass aliases from
  pages. `batch.changes` and `batch.reset` invalidate authorized API reads, not
  client records reconstructed from event order. There is no `restricted` flag,
  collection-level event or `batch.collections` in the v28 contract.
- Keep one `createChangeRelay` upstream per server process. Adapt
  `canSeeChange(user, change)` in `src/lib/change-visibility.ts` to the service
  policy; its blank-template default allows all changes. Record IDs can reveal
  existence. The callback is synchronous and cannot read records; if visibility
  cannot be decided from user/event metadata, suppress that event rather than
  leaking it. Leave the authenticated subscription route and locked relay intact.
  Verify reset, reconnect and hidden-page close/resume through `openEventStream`.
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
  import declarations from `@tier0/sdk-v2/data/define`, and use the selected
  target's `runWithAbortSignal` request wrapper. Complete the pre-v27 visitor
  and service-authorization migration; all target data calls act as the App.
  Take upstream data gates with their gate-integrity manifest; services also
  follow the result/error adaptations above.
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
  `test:guidance`, `auth:union:test`, `runtime:audit`, `test:components`,
  `test:data`, `test:streams` and `test:user-display`; the
  verifier also covers typecheck,
  lint, contract tests, and runtime safety. Locked contract coverage includes
  route correctness, auth, data and runtime boundaries. Generation heuristics
  (role count, copy, lifecycle/caller and layout patterns) are nonblocking
  advisories; inspect them against the actual workflow. Do not substitute `vite build` or edit locked gates to make
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
- Once `/dev/shm/.tier0/preview/state.json` is `ready`, use its port and run
  `npm run smoke:routes -- http://127.0.0.1:<port> [/changed-route ...]`.
  `preview_restart` only triggers restart; inspect that state file and
  `/dev/shm/.tier0/preview/preview.log` for completion/failure. Treat the URL as a local
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
  assertions or recompute hashes to conceal failing App code. Leave
  `src/lib/template-state.test.mjs` unchanged: it asserts the blank template and
  runs only in scaffold CI, not in the App build. If a locked gate reports an
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
- the build's app layer is `include = ["dist", "server.mjs", "server-url.mjs"]`
  (with `artifact.toml`, `package.json` and `roles.json`); a runtime file left
  out of it is missing after deployment
- `[static]` serves `dir = "dist/client"` under `url_prefixes = ["/assets/"]`
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
- Do not create a package-root `tier0-collections/`; the platform reserves it
  for exported collection records.
