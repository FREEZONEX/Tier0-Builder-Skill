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
- [Data Calls Or Collection Ensure Fail](#data-calls-or-collection-ensure-fail)
- [Migrated Business Rows Reappear Automatically](#migrated-business-rows-reappear-automatically)
- [Seed Records Missing Or Rejected](#seed-records-missing-or-rejected)
- [Artifact Fails At Deploy](#artifact-fails-at-deploy)
- [Build Passes But A Promise Is Used As A Map](#build-passes-but-a-promise-is-used-as-a-map)
- [Import Package Fails](#import-package-fails)

## Browser Shows `fs` Externalized

A warning such as `Module "fs" has been externalized for browser compatibility`
means a client or mixed route, router, component, shared wrapper, or transitive
dependency statically imports Node-only code (also `node:async_hooks` /
`node:crypto` from a value import of `@tier0/sdk-v2/data` or `@/lib/data`). Move
`fs`/`path`/`url` work and data access into the scaffold's server-only
boundaries or services, and import declarations from
`@tier0/sdk-v2/data/define` in client code. Keep
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
- In v15 these source-pattern findings are advisories. Review the rendered
  layout; if an old test blocks the build, install the verified v15 gate set
  rather than changing assertions or recomputing pins locally.

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

Confirm the target uses `@tier0/sdk-v2` at the selected scaffold version with a
matching lockfile, and that no `@tier0/sdk` (v1) import remains. A type error
or `is not a function` on `source.list`, `stream.programs.get`, `agent.nodes`,
`recordInsertMany` or similar after the move to 0.3.0 is a retired method;
follow [SDK Upgrades](platform-contract.md#sdk-upgrades). Import
`loadTier0Sdk`, `loadTier0Files` or the other lazy helpers from `@/lib/tier0`,
then await the loader inside the concrete server action. Do not top-level import
the SDK root, `@tier0/sdk-v2/openapi`, `@tier0/sdk-v2/files` or
`@tier0/sdk-v2/mq`; do not move the SDK into `ssr.noExternal`, and do not replace
it with hand-written REST/MQ fallback clients. A value import of
`@tier0/sdk-v2/data` outside services, `src/lib/data` and `src/start.ts` pulls
Node-only code into the browser bundle; components import declarations from
`@tier0/sdk-v2/data/define` instead. When migrating notification calls, follow
[SDK Upgrades](platform-contract.md#sdk-upgrades) to preserve silent sends.

## MQTT Authentication Fails

For `Not authorized`, CONNACK code 5, repeated reconnects, or OpenAPI succeeding
while MQTT fails, distinguish configuration from invalid credentials:

1. Read `npm ls @tier0/sdk-v2` in the app runtime, not only `package.json`.
   Check injected key presence and non-secret type without printing the key.
   v2 derives the MQTT identity from a workspace-encoded key
   (`sk-<type>-ws<base36>_<secret>`) and rejects a key it cannot parse unless
   username, clientId and password are all passed explicitly; there is no
   Enterprise fallback. An OpenAPI HTTP 401 alone says nothing about MQTT: HTTP
   sends the key opaquely.
2. Inspect injection into the failing runtime (`TIER0_MQTT_HOST`,
   `TIER0_MQTT_PORT`, `TIER0_API_KEY`), key revocation/expiry/permissions, the
   broker endpoint and `ws`/`wss`, then backend support for the key type. Use
   dedicated credentials from `mqttAuth.create()` when the injected key cannot
   carry an MQTT identity.
3. Let managed preview install/restart after an authorized dependency change,
   then check the actual installed version again. Do not race managed
   installation with `npm install`.
4. Keep credentials and workspace-derived username/clientId out of logs,
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

- Preview unions permissions across the comma-separated
  `X-Tier0-Preview-Role` set the developer selected.
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

At v15 role count does not block builds. If an old App still reports
`Keep at most 3 roles`, its gate set was not fully upgraded. Follow
[v15-guidance-gates.md](v15-guidance-gates.md); preserve all distinct roles and
retain registration, metadata, key-format and authorization checks.

## Migrated App Still Shows Logout

For an imported/migrated app, remove user-visible logout/sign-out buttons,
personal-menu entries, pages, routes, custom logout helpers, App-local session
code, and logout/select-role endpoints. Keep `/api/auth/me` and the hidden
`/login` auth-error bridge when present in the current template. Do not read,
write, or clear the Gateway login Cookie. Logout is platform-owned for every App.

## Data Calls Or Collection Ensure Fail

For `403 active hosted App data policy required`, follow
[first-ensure-and-runtime-blockers.md](first-ensure-and-runtime-blockers.md).
Context cannot distinguish an absent policy from a disabled one. Check App
binding and ensure dry-run with the real declarations; never treat this context
error alone as proof that an administrator must initialize the App. Explicit
`APP_GRANT_REVOKED` must not be bypassed. Runtime failures leave dependent
acceptance checks pending, not all source reconstruction.

Read the `DataError` (`status`, `code`, `reason`, `details`) in the server log
before assigning a cause; the frontend message alone does not identify it. The
mapping is in the scaffold's `docs/platform-integration.md` → Errors.

- `npm run build` rejects a declaration UNS cannot store, an invalid index or an
  invalid seed document, naming the replacement. Change the declaration; do
  not edit the data contract gate.
- `DATA_NOT_CONFIGURED` (503): `TIER0_API_HOST` / `TIER0_API_KEY` are missing
  in that runtime. They are platform-injected; report the injection gap instead
  of adding values to `.env.example` or UI.
- `SCHEMA_CONFLICT` fails the request in Preview (a deployment logs it and
  keeps serving the existing collection): the declaration cannot be joined with
  storage. Follow the per-reason hint — usually a new field name instead of a
  type change — and never `deleteMany` or recreate the collection to clear it.
- A 503 (`APP_NOT_READY` right after an import, `DEPENDENCY_UNAVAILABLE`,
  `OUTCOME_UNKNOWN`, `HTTP_502/503/504` during a rollout, `DATA_TIMEOUT`,
  `DATA_UNREACHABLE`) is a platform state the data layer already resent where
  `retry.safe` allowed: retry later, and do not add an App retry loop. A 502
  from a UNS 401 is a platform credential problem, not the user's session.
- `OVERLOADED` (429) that reaches the App means it sends too many data
  requests: combine a screen's reads into one `data.queryBatch` and drop
  per-record loops. `QUERY_TIMEOUT` is not resent: narrow the query with an
  indexed condition.
- A type error on `findPage(...).total` or a `countDocuments` result comes from
  a v9 service on SDK 0.2.0 or later: counts are `{ count, capped }`; answer list pages
  with `toQueryResult`.
- `APP_PERMISSION_MISSING` with `missingPermission: "uns.delete"` means deletes
  need that permission on the App key; model removal as a status or ask an
  admin. `COLLECTION_NOT_GRANTED` / `COLLECTION_NOT_FOUND` trigger one automatic
  re-ensure; if they persist, the grant or collection was removed by an admin.
- `BATCH_LIMIT_EXCEEDED` (400): independent writes may be split into chunks of
  at most 200. Chunks are not one transaction: if a business operation requires
  all-or-nothing across more than 200 steps, redesign the operation or report
  the limit; never silently weaken atomicity.
- Leftover Drizzle/`pg` code from an older data layer (`src/db/**`,
  `bootstrapModule()`, `DATABASE_URL` / `DB_SCHEMA`) has no place in the
  current scaffold;
  replace it with collections rather than restoring a database connection.

## Migrated Business Rows Reappear Automatically

A service or startup path is inserting demo, sample, or baseline rows. Remove
it: baseline records belong only in the declaration's `seed`, written once when
the collection is created, and services never insert rows because a list is
empty. Retained legacy rows must enter through an explicit validated import;
development/test fixtures run only through an explicit development or test
action.

## Seed Records Missing Or Rejected

Seeds are written only when ensure creates the collection; editing `seed` later
never reseeds an existing collection, and a failed seed chunk is logged and not
retried on later starts. Dates come from `seedDate(offsetDays)` (`YYYY-MM-DD`)
and `seedTimestamp(offsetDays, utcHour?)` (ISO instant) in
`src/data/seed-utils.ts`; cross-references use fixed `_id`s through
`requireSeedRef()`. The build validates every seed against its schema and unique
indexes, so a rejected seed is fixed in `src/data/collections.ts`. To add rows
to an existing collection, write them once through the tier0 MCP or an explicit
action, not by editing `seed`.

## Artifact Fails At Deploy

Treat every `artifact.toml` `args` array as literal argv:

- Use `["sh", "-c", "..."]` when shell parsing or operators are required.
- Use tokenized argv for plain commands such as
  `["npm", "prune", "--omit=dev"]`.
- Do not cram a command into one element or place `&&` in plain argv. The
  platform may normalize legacy join-era forms with a warning, but aligned files
  use canonical forms.

A production pod stuck in `ImagePullBackOff` on `node:22-alpine` (or another
docker.io image) means `artifact.toml` still pins
`[services.production.run].image`. Delete that line; the platform supplies the
environment's default runtime image.

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
