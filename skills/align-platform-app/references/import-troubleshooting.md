# Import And Runtime Troubleshooting

Use `preview-runtime-stability` when injected and logs show managed dependency
installation, port/process ownership, preview readiness timeout, or HMR
problems. This reference owns failures caused by migrated application code,
platform-contract drift, production runtime behavior, or import packaging.

## Contents

- [Browser Shows `fs` Externalized](#browser-shows-fs-externalized)
- [`document is not defined` From BrowserRouter](#document-is-not-defined-from-browserrouter)
- [Vite Is Ready But The Page Loads Forever](#vite-is-ready-but-the-page-loads-forever)
- [Request Failure Looks Like Endless Loading](#request-failure-looks-like-endless-loading)
- [Build Passes, Runtime Fails](#build-passes-runtime-fails)
- [Postbuild Or Gate Integrity Fails](#postbuild-or-gate-integrity-fails)
- [Route Missing, Blank, Or 404](#route-missing-blank-or-404)
- [Responsive Contract Fails](#responsive-contract-fails)
- [Assets Missing](#assets-missing)
- [Tier0 SDK Files Or SSR Import Fails](#tier0-sdk-files-or-ssr-import-fails)
- [MQTT Authentication Fails](#mqtt-authentication-fails)
- [Auth Or API Calls Fail](#auth-or-api-calls-fail)
- [Role Appears Changed But Permissions Did Not](#role-appears-changed-but-permissions-did-not)
- [Migrated App Still Shows Logout](#migrated-app-still-shows-logout)
- [App Data Or Collection Access Fails](#app-data-or-collection-access-fails)
- [Migrated Business Records Reappear Automatically](#migrated-business-records-reappear-automatically)
- [Seed Records Duplicate Or Fail On First Load](#seed-records-duplicate-or-fail-on-first-load)
- [Artifact Args Fail At Deploy](#artifact-args-fail-at-deploy)
- [Build Passes But A Promise Is Used As A Map](#build-passes-but-a-promise-is-used-as-a-map)
- [Import Package Fails](#import-package-fails)

## Browser Shows `fs` Externalized

A warning such as `Module "fs" has been externalized for browser compatibility`
means a client or mixed route, router, component, shared wrapper, or transitive
dependency statically imports Node-only code. Move `fs`/`path`/`url`,
`@/lib/uns.server` and collection/seed work into the scaffold's server-only boundaries or services. Keep
`src/start.ts`, API handlers, and `createServerFn` handler bodies server-only; do
not make the client graph depend on their implementations.

## `document is not defined` From BrowserRouter

`react-router-dom` `BrowserRouter` was evaluated during SSR. Mount the legacy
router subtree inside `ClientOnly`, or complete its conversion to TanStack Router.

## Vite Is Ready But The Page Loads Forever

Vite `ready` and HTTP 200 do not prove hydration. Check SSR output and the browser
console separately, then inspect browser-only import failures, hydration mismatch,
and rejected startup promises. After the page hydrates, exercise an interaction.

## Request Failure Looks Like Endless Loading

If the page has a full-page `if (loading) return ...` path or a `useRequest`
result without the scaffold async-state primitive, a rejected first request may
never expose an error. Render the request result through `AsyncView` so loading,
error with retry, empty, and success states are explicit. Do not suppress the
runtime audit or replace the error state with an infinite skeleton.

## Build Passes, Runtime Fails

Check:

- `server.mjs` still points to the built server entry.
- `artifact.toml` still runs `node server.mjs` in production and checks
  `/api/health`.
- Build output exists where the runtime expects it.
- Browser-only libraries are not executed during SSR.
- Client and mixed modules do not statically pull Node-only dependencies into the
  browser build graph.
- Source project globals were not imported before required providers.
- Environment variables used by imported code are available or removed.
- Gateway identity headers reach the App. Do not add an App-owned
  authentication session.
- The normal completion command was `npm run build`, not `vite build`; the full
  post-build verifier completed.

## Postbuild Or Gate Integrity Fails

Do not edit invariant tests, `scripts/post-build-verify.mjs`,
`scripts/gate-integrity.mjs`, `scripts/runtime-audit.mjs`,
`scripts/route-smoke.mjs`, or `scripts/gate-integrity.json` to make a migrated
App pass. When the task is an upstream gate update, use the complete verified
upstream file/hash set as explained in `platform-contract.md`. At this snapshot, only
`src/lib/template-state.test.mjs` is App-adaptable.

The locked verifier includes route-nesting, navigation, lifecycle/content, role,
and responsive contracts. Read the failing assertion and fix App route/UI code;
do not remove a test from `post-build-verify` or the gate-integrity manifest.

Read the reported stage and fix App code. Use documented `EXTERNAL_CALLER` or
`READ_ONLY_SURFACE` markers only when they accurately describe the surface.
Every mutation API route otherwise needs a reachable UI caller through
`apiUrl()`.

## Route Missing, Blank, Or 404

Check:

- The file route name matches TanStack Router conventions.
- Dynamic params use `$param` file names.
- For nested list/detail resources, the parent renders `<Outlet />`, the list is
  a sibling `.index.tsx`, and the detail is `.$param.tsx`. A component-less
  parent may supply the outlet automatically; a master-detail parent must render
  its content plus the outlet.
- A detail intended to render standalone opts out of nesting with a trailing `_`
  on the parent segment. Do not place a child detail behind a parent with no
  outlet.
- Pathless layouts use leading `_` prefixes correctly.
- The route tree was regenerated by dev/build tooling.
- Navigation is declared through `defineNavigationModules`; every clickable
  leaf has a unique `href` resolving to a real non-API route.
- Route content uses TanStack Router `Link` / `useNavigate`, not Next.js APIs.

## Responsive Contract Fails

When `responsive-contracts` fails or a page scrolls sideways at 375px:

- Give any `input`, `select`, or `textarea` using `flex-1`, `grow`, or
  `flex-auto` a maximum or fixed width, such as `w-full max-w-xs` or
  `min-w-0 flex-1 max-w-sm`.
- Put a hard minimum width above 375px inside a local horizontal-scroll region.
  Follow `TableViewport`: `overflow-x-auto` outside and the wide `min-w-*`
  content inside.
- Inspect the route at 375px after the build passes. A test fix is not sufficient
  if controls, dialogs, or actions remain unusable.
- Fix the App layout; do not edit the locked responsive test or gate manifest.

## Assets Missing

Check:

- Source absolute paths like `/assets/...` still resolve under deployment.
- Imported images moved with their components or into public assets.
- Fonts are installed/imported through package or public paths.
- CSS references do not point to deleted source directories.
- A generated or rebranded App has root `icon.png` (512x512, <=2 MB), an
  identical `public/app-icon.png`, and `APP_ICON = "/app-icon.png"`.
- Registered covers persist as root `cover.png` (PNG, <=8 MB); registration
  uses root paths rather than temporary or public-only copies.
- The same App icon was synchronized to platform metadata; a local file change
  alone does not prove that synchronization.

## Tier0 SDK Files Or SSR Import Fails

Confirm the target uses the selected scaffold SDK version and matching lockfile;
follow the selected scaffold version and never downgrade a newer SDK merely
to match the 0.5.3 compatibility baseline described here. When migrating older notification calls,
follow [SDK Upgrades](platform-contract.md#sdk-upgrades) to preserve silent sends. Import
`loadTier0Files` or other lazy helpers from `@/lib/tier0`, then await the loader
inside the concrete server action. Do not top-level import
`@tier0/sdk/openapi`, `@tier0/sdk/files`, or `@tier0/sdk/mq`; do not move the SDK
into `ssr.noExternal`, and do not replace it with hand-written REST/MQ fallback
clients.

## MQTT Authentication Fails

For `Not authorized`, CONNACK code 5, repeated reconnects, or OpenAPI succeeding
while MQTT fails, distinguish SDK compatibility from invalid credentials:

1. Read `npm ls @tier0/sdk` in the app runtime, not only `package.json`. Check
   injected key presence, non-secret type and workspace-encoded format without
   printing the key. A workspace-encoded non-service key below SDK 0.5.2 needs
   an upgrade; use the selected scaffold SDK version (at least 0.5.3) for the complete
   MQTT fixes described here. An
   OpenAPI HTTP 401 alone does not prove an old SDK: HTTP sends the key opaquely.
2. When the SDK compatibility script is available, run it from the application
   root using its actual path in the package or injected SDK Skill. First check
   that `skills/tier0-sdk/scripts/check-api-key-compat.mjs` exists: the published
   0.5.3 package lacks that script and the PR's final diagnostic guidance. A
   missing script is a packaging limitation, not an authentication failure;
   continue with the version/key checks here. Do not vendor a platform Skill
   into the App. A successful diagnostic only checks local compatibility.
3. Reconcile the dependency range and authoritative lockfile for an authorized
   upgrade. Let managed preview install/restart, then check the actual installed
   version again. Do not race managed installation with `npm install`.
4. If the version already supports this key type, inspect injection into the
   failing runtime, key revocation/expiry/permissions, broker endpoint and
   `ws`/`wss`, then backend support for the key type. For 0.5.2, also consider
   the 0.5.3 connect-time password and embedded-port fixes when those paths
   are used. Do not repeatedly recommend upgrades after those are covered.
5. Keep credentials and workspace-derived username/clientId out of logs,
   business settings and hard-coded workarounds. Preserve intentional custom
   identity only when the deployment calls for it. Disconnect before changing
   connection credentials; retry the affected connection/subscription and
   report separately when runtime verification is unavailable.

## Auth Or API Calls Fail

Check:

- The target app relies on platform/gateway identity instead of custom login.
- API calls use base-path-aware helpers where the scaffold provides them.
- Server logic is not embedded in client-only modules.
- Platform SDK access is lazy-loaded from scaffold helpers when available.
- User-editable settings were not created for platform-injected credentials.
- `VITE_BASE_PATH` / `NEXT_PUBLIC_BASE_PATH` behavior was preserved so `apiUrl()`
  and router base paths work behind platform routing.

## Role Appears Changed But Permissions Did Not

First determine whether the source app actually had a business-role model. A
roleless source should remain roleless: do not invent role gates, and do not treat
a missing role as an error. For a role-aware source, confirm that every source
role definition, user-role and permission mapping, menu/page/action guard, API
authorization rule, and related metadata entry was migrated.

Issue a new request or refresh after platform assignment or preview view-as
changes. Then verify:

- Preview uses one `X-Tier0-Preview-Role`.
- Deployed mode unions permissions across every
  `X-Tier0-Business-Roles` value. `X-Tier0-Active-Role` is primary display
  metadata only.
- `can(user.roles, action)` and route guards use the assigned-role set, not
  `primaryRole`.
- A trusted unknown Tier0 role contributes zero permissions without erasing
  known-role permissions.
- An explicit deployed empty role set stays empty. Preview without a selected
  view-as role likewise has zero roles and permissions; never add a fallback.
- An unknown legacy/untrusted role fails closed.

Remove stale client role stores and query/body/header/Cookie overrides. Confirm
every business role is synchronized across `PERMISSION_MATRIX`,
`ROLE_METADATA`, and `roles.json`, and every `role_key` matches
`^[a-z]+(_[a-z]+)*$`.

The first version supports at most three materially distinct business roles
total, with no reserved role or implicit grant. If the source model exceeds that cap,
stop and obtain an
explicit user/platform-approved consolidation or phased migration. Do not make
the build pass by silently removing roles, broadening access, merging distinct
scopes without approval, or leaving a registered role with zero permissions.

## Migrated App Still Shows Logout

For an imported/migrated app, remove user-visible logout/sign-out buttons,
personal-menu entries, pages, routes, custom logout helpers, App-local session
code, and logout/select-role endpoints. Keep `/api/auth/me` and the hidden
`/login` auth-error bridge when present in the current template. Do not read,
write, or clear the Gateway login Cookie. Logout is platform-owned for every App.

## App Data Or Collection Access Fails

- **Leftover database layer.** Errors such as `DATABASE_URL is not set`,
  `ECONNREFUSED ...:5432`, `relation ... does not exist`, a failing
  `app-data-contracts` test, or an ESLint `no-restricted-imports` error for
  `pg` / `drizzle-orm` / `@/db` mean the app still uses the database of an older
  scaffold. The platform no longer injects a database. Move the tables to
  app-owned collections (`local-state-to-collections.md`) and delete `src/db/`,
  `drizzle.config.ts`, `db:*` scripts and the dependencies; do not reintroduce a
  connection string or an embedded database.
- **503 / `not_configured`.** `TIER0_API_HOST`, `TIER0_API_KEY` or
  `TIER0_APP_COLLECTION_PREFIX` (fallback: the App UUID in `APP_ID`) are
  missing. They are injected in Preview and deployed runs; in plain local
  development show the `isUnsConfigured()` empty state. Never hard-code a key
  or a prefix.
- **403 on a write or collection change.** The app key may write, PATCH and
  purge only its own `app.<appKey>.*` collections. A write to another
  collection (plant data, another app's collection) is forbidden by design;
  read it instead, or store the app's own derived data in an app collection.
  A hard-coded prefix copied from another app also yields 403 — resolve ids
  with `appCollectionId(name)`.
- **400 `validation_failed`.** The record does not satisfy the collection's
  `recordSchema` (after merge for PATCH). Fix the data or relax the schema;
  adding a `required` field to a collection with existing records makes old
  records fail on their next merge write — add fields as optional or backfill.
- **409.** Read `err.code`: `duplicate_key` (the id or a unique index value
  exists — treat as "already exists" for idempotent seeds / imports, or use an
  upsert), `conflict` (stale `revision`), `precondition_failed` (a `transact`
  op with `require: "matched"` matched nothing), `lock_lost` (the lease
  expired). A state transition that lost a race shows up as
  `findOneAndUpdate` returning `null`, not as an error. 412
  `precondition_failed` is a stale `ifMatch` ETag; 423 `locked` means another
  user / worker holds a lease (`err.lockPrincipal`, `err.lockedUntil`).
- **400 `upsert_requires_unique_index` / `lookup_requires_index`.** Declare the
  field as an object-form index (`{ path, unique: true }` / `{ path }`) in the
  collection definition; the handle waits for it to be built.
- Verify with the preview App: first access creates the collections, the
  failing API succeeds, repeat access and a restart stay idempotent (no
  duplicate records, no repeated PATCH churn).

## Migrated Business Records Reappear Automatically

Do not declare `seed` callbacks that insert demo, sample, or baseline records
for migrated durable business entities. `seed` runs whenever a collection is
new or empty; retained legacy records must enter through an explicit validated
import, and development/test fixtures must run only through an explicit
development or test action.

## Seed Records Duplicate Or Fail On First Load

Seed records need fixed ids: a retry or a second process then gets 409 and
leaves the record alone, while `randomUUID()` / `Date.now()` ids create
duplicates (the runtime audit rejects them). Build dates with `seedDate()`,
`seedTimestamp()` (ISO strings) or `seedTimeMs()` (Unix ms); do not pass the
numeric return value of `Date#setDate()`, `setUTCDate()`, or `setTime()`.

## Artifact Args Fail At Deploy

Treat every `artifact.toml` `args` array as literal argv:

- Use `["sh", "-c", "..."]` when shell parsing or operators are required.
- Use tokenized argv for plain commands such as
  `["npm", "prune", "--omit=dev"]`.
- Do not cram a command into one element or place `&&` in plain argv. The
  platform may normalize legacy join-era forms with a warning, but aligned files
  use canonical forms.

## Build Passes But A Promise Is Used As A Map

A helper likely changed from sync to async while callers still invoke `.get`,
`.map`, iteration, spread, or render it directly. Audit the full caller graph,
including `useMemo` and render functions. Resolve the Promise at an async boundary;
do not hide the mismatch with `@ts-nocheck`, and runtime-smoke every suppressed
path.

## Import Package Fails

Check:

- Folder depth matches the actual importer; check whether an enclosing app
  directory is supported.
- `package.json`, lockfile, platform config, `server.mjs`, and root brand assets
  are present. Require build output only for runtime artifacts, not source
  imports that rebuild.
- `node_modules` inclusion matches the target importer behavior.
- Local caches, git metadata, editor folders, and temporary folders are excluded.
- `.agents/skills/` contains no vendored platform Skill content.
- Health and manifest routes respond after production start.
