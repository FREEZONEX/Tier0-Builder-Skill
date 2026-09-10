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
- [Auth Or API Calls Fail](#auth-or-api-calls-fail)
- [Role Appears Changed But Permissions Did Not](#role-appears-changed-but-permissions-did-not)
- [Migrated App Still Shows Logout](#migrated-app-still-shows-logout)
- [Database Startup Or Schema Fails](#database-startup-or-schema-fails)
- [Migrated Business Rows Reappear Automatically](#migrated-business-rows-reappear-automatically)
- [Runtime Seed Dates Fail On First Load](#runtime-seed-dates-fail-on-first-load)
- [Artifact Args Fail At Deploy](#artifact-args-fail-at-deploy)
- [Build Passes But A Promise Is Used As A Map](#build-passes-but-a-promise-is-used-as-a-map)
- [Import Package Fails](#import-package-fails)

## Browser Shows `fs` Externalized

A warning such as `Module "fs" has been externalized for browser compatibility`
means a client or mixed route, router, component, shared wrapper, or transitive
dependency statically imports Node-only code. Move `fs`/`path`/`url`/`pg` and
bootstrap/seed work into the scaffold's server-only boundaries or services. Keep
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
the SDK upgrade target is `^0.5.1`. When migrating older notification calls,
follow [SDK Upgrades](platform-contract.md#sdk-upgrades) to preserve silent sends. Import
`loadTier0Files` or other lazy helpers from `@/lib/tier0`, then await the loader
inside the concrete server action. Do not top-level import
`@tier0/sdk/openapi`, `@tier0/sdk/files`, or `@tier0/sdk/mq`; do not move the SDK
into `ssr.noExternal`, and do not replace it with hand-written REST/MQ fallback
clients.

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

## Database Startup Or Schema Fails

- An API 500 with `Failed query: create schema if not exists ...` or
  `permission denied for database ...` can surface as `Couldn't load data` /
  `Internal error`. Inspect the failed SQL and server error before assigning a
  cause; the frontend message alone does not identify a schema-permission issue.
- When legacy `src/services/bootstrap.ts` or another startup/request path issues
  `CREATE SCHEMA`, remove that statement, including its `IF NOT EXISTS` form.
  The platform provisions `DB_SCHEMA`; the App account need not have database-level
  schema-creation permission. Preserve idempotent table/index bootstrap inside
  that existing schema. Do not add an admin connection, grant database-level
  `CREATE`, or remove `DB_SCHEMA` as a workaround.
- If the injected schema is actually absent, report a platform provisioning or
  environment mismatch. Do not recreate it in App code or silently switch schemas.
- Declare tables/enums through `appSchema` in `src/db/schema.ts` and pass table
  objects to `bootstrapModule()`. Use `db:push:check` before guarded sync;
  do not turn on destructive sync merely to get startup working.
- Confirm runtime queries, `bootstrapModule()`, and any `db:push` verification use
  the same platform-injected `DB_SCHEMA`, with `public` only as the documented
  fallback when it is absent.
- Verify with the preview App account: first access initializes business tables
  and indexes in the existing schema, the previously failing API succeeds, and
  repeat access (plus a restart when controllable) remains idempotent. Confirm
  startup/request paths no longer issue `CREATE SCHEMA`; a build alone does not
  prove the permission failure is fixed.

## Migrated Business Rows Reappear Automatically

Keep the current scaffold's idempotent table/index bootstrap in the platform-provisioned
schema, but remove
seed callbacks that insert demo, sample, or baseline rows for migrated durable
business entities during normal startup or a first request. Retained legacy rows
must enter through an explicit validated import; development/test fixtures must
run only through an explicit development or test action.

## Runtime Seed Dates Fail On First Load

Use `seedDate(offsetDays)` for Drizzle `date()` columns and
`seedTimestamp(offsetDays, utcHour?)` for `timestamp()` columns. Write runtime
baseline data through typed transactional `tx.insert()` / `tx.update()` /
`tx.delete()` builders. Do not use raw SQL for data writes or pass the numeric
return value of `Date#setDate()`, `setUTCDate()`, or `setTime()`.

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
