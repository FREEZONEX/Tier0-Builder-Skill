# Preview Error Playbooks

Read only the matching failure section. Apply the ownership boundary in SKILL.md
before any process cleanup.

## Known Error Playbooks

### Dependencies not installed (missing or partial `node_modules`)

Error examples:

```text
Cannot find module 'react' (or '@tanstack/react-start', 'vite', ...)
sh: vite: command not found
Failed to resolve import "..." — the package is not installed
```

This happens when an uploaded or imported project ships **without** `node_modules` (common when a user uploads a zip that excludes dependencies). The port and health checks in [Process lifecycle](process-lifecycle.md) assume dependency restore already succeeded; if it did not, no port/health work will help — install first. `node_modules` can also be *partial* after an interrupted install, so treat a missing `node_modules/.bin/vite` or any startup `Cannot find module` as "restore dependencies".

Detect:

```bash
[ -d node_modules ] && [ -x node_modules/.bin/vite ] && echo "deps present" || echo "deps missing/partial"
```

Fix sequence:

1. Confirm you are at the project root (the directory holding `package.json`).
2. If a managed install owns dependency restoration, wait for it to finish; do
   not start a second install that writes `node_modules` concurrently.
3. In a local or otherwise unmanaged environment, restore dependencies with the
   project's package manager and authoritative lockfile. For npm, run `npm ci`
   when a valid `package-lock.json` exists; use `npm install` only when the
   project intentionally has no lockfile or is regenerating it.
4. Always restore **before** `npm run build` or starting preview; build/preview keeps failing until install completes.
5. After install succeeds, run the preflight and start preview normally.

```bash
[ -f package-lock.json ] && npm ci || npm install
```

### Managed dependency install failed

Error examples:

```text
install failed: install exited: exit status 1
ERESOLVE unable to resolve dependency tree
No matching version found for <package>@<version>
Failed to resolve import "<package>"
```

Fix sequence:

1. Read the managed install/task log before restarting preview.
2. Classify the failure as peer-dependency conflict, unavailable version,
   manifest/lockfile drift, missing dependency, interrupted install, or network/
   registry failure.
3. For a peer conflict, inspect the legacy package peer requirements and the
   target scaffold versions. Resolve, replace, or isolate the incompatible
   package; do not hide the conflict with force or legacy-peer flags.
4. For an unavailable or missing package, verify the intended package name and
   published version before editing the manifest. Copy the exact npm version
   of `@tier0/sdk-v2` that the scaffold pins; do not change it to a GitHub
   reference or another version.
5. Regenerate the authoritative lockfile only in a controlled, unmanaged install
   step, then verify an exact install from it.
6. Restart preview once after the dependency graph resolves so Vite can rebuild
   its dependency cache. Do not loop preview restarts while install still fails.

### Dev server exited with status 1

Error examples:

```text
dev server exited: exit status 1
error when starting dev server:
Error: Port 5173 is already in use
```

Treat `exit status 1` as "Vite crashed before readiness", not as a generic preview timeout. Always inspect preview logs or the dev server stderr before editing app code.

Common causes, in order:

1. Stale preview process still owns port `5173`. This is the most common cause when `vite.config.ts` uses `server.strictPort = true`; Vite exits immediately instead of drifting to `5174`.
2. Route tree or file-route compile error after adding, renaming, or deleting files under `src/routes`.
3. Missing dependency or stale import after removing component libraries, for
   example imports from deleted shared or legacy component folders.
4. CSS/Tailwind startup failure, especially stale `@import` entries for deleted packages.
5. Server-only imports leaking into client-bundled route/component files, such as using `@tanstack/react-start/server` outside a server handler, middleware, or `createServerFn().handler(...)` body.

Fix sequence:

1. Check preview logs. If the log contains `Port 5173 is already in use`, run the preflight cleanup and restart preview. Do not change application code for a stale-port failure.
2. If the log shows a route-generation or import error, fix the exact file path in the stack trace, then restart preview.
3. If the log shows a deleted shared/legacy component import, replace it with
   scaffold-native or intentionally retained local components. Do not restore a
   removed component library unless it belongs in the target dependency plan.
4. If the log shows a CSS import error, remove the stale import from `src/styles/globals.css` or add the missing package only when it is intentionally part of the template.
5. If the log shows `does not provide an export named` from `@tanstack/react-start/server`, move that call inside a valid server boundary.
6. When logs are unavailable or ambiguous, first verify port ownership and `/api/health`; then run `npm run build` only if dependencies are installed and the managed install is not running.

Useful checks:

```bash
PREVIEW_PORT=5173 HEALTH_PATH=/api/health ./.agents/skills/preview-runtime-stability/scripts/preview_preflight.sh --cleanup
rg -n '@/components/(ui|legacy)' src --glob '!routeTree.gen.ts'
rg -n '@tanstack/react-start/server|from "motion/react"' src --glob '!routeTree.gen.ts'
rg -n '@import "shadcn|@import "@/components|@import "@tier0' src/styles
```

The first two commands intentionally over-report. The scaffold ships its own `src/components/ui`, so only imports of files missing from it are stale. `@tanstack/react-start/server` is allowed in server-route handlers, middleware, `src/lib/auth.ts`, and inside `createServerFn().handler(...)` bodies. `motion/react` is allowed only in the shared `src/lib/motion.ts` wrapper.

### Tier0 SDK SSR external mismatch

Error examples:

```text
Named export ... not found
does not provide an export named ...
require is not defined in ES module scope
ReferenceError: exports is not defined in ES module scope
```

When the stack points at `@tier0/sdk-v2` (any subpath, including
`@tier0/sdk-v2/data`) or `mqtt` during SSR, separate SDK package/export failures
from app-code eager loading failures. Read the freshly inspected scaffold and
installed package metadata instead of assuming a historical SDK version.
Preserve the current scaffold's SSR external and server-side loading contract
so optional platform I/O does not run during page initialization.

Fix sequence:

1. Open `vite.config.ts`.
2. Ensure the SDK and `mqtt` are externalized for Vite SSR; the package name
   also externalizes its subpaths (`/data`, `/mq`, `/openapi`, ...):

```ts
ssr: {
  external: ["@tier0/sdk-v2", "mqtt"],
}
```

3. Do not add `@tier0/sdk-v2` or `mqtt` to `ssr.noExternal`. Let package exports
   choose the correct runtime condition instead of forcing Vite to rebundle
   SDK internals.
4. Search for SDK imports outside their server-side homes:

```bash
rg -n '@tier0/sdk-v2' src --glob '!routeTree.gen.ts'
```

   Expected homes: `src/lib/tier0.ts` (lazy loaders), `src/lib/data/**` and
   `src/services/**` (`@tier0/sdk-v2/data`), `src/start.ts`
   (`runWithRequestContext`), and declarations in `src/data/**` or anywhere
   from `@tier0/sdk-v2/data/define` (browser-safe). A value import of
   `@tier0/sdk-v2/data` from a route component, component or client hook pulls
   Node-only code into the browser bundle; `npm run build` flags it.
5. If an optional platform operation (notification, file upload, MQTT command
   send) imports the SDK root, `/files` or `/mq` at module top level, move the
   call behind the `@/lib/tier0` lazy loaders and invoke it only inside the
   action that needs platform I/O. Top-level imports of lazy helper functions
   from `@/lib/tier0` are fine; top-level calls to those helpers are not. Do not
   import SDK values while rendering a page or loading preview.
6. Do not replace the SDK with fallback MQTT clients or hand-written UNS fetch
   wrappers; App records go through `data` from `@/lib/data` in services.
7. Run `npm run build:check` when available.

### TanStack Start HTTPError 500

Error example:

```json
{"status":500,"unhandled":true,"message":"HTTPError"}
```

This means an HTTP-shaped error escaped through TanStack Start/Router instead of being translated into a normal `Response.json(...)`. It is usually not fixed by restarting the preview process.

Common causes:

1. An API route calls `requireAuth()` or a service that throws `HttpError`, but the handler is not wrapped in `withErrors(...)`.
2. A service or loader throws `new HttpError(...)` from a route `beforeLoad`, loader, or `createServerFn` where no route error mapper converts it to a Response.
3. Gateway identity headers are missing, so `requireAuth()` throws 401 on a public path such as `/_serverFn`; other paths already get a 401 or 403 JSON from `src/start.ts`.
4. The preview role set lacks a role the page requires; that failure reaches the Builder as kind `role`, see [Preview role error](#preview-role-error-kind-role).
5. A public endpoint needed by preview, especially `/api/health`, was changed to require auth or throw.

Fix sequence:

1. Identify the request path that returned the JSON error. Do not assume it is `/api/health`.
2. For `src/routes/api/**`, wrap every handler in `withErrors(...)` and keep the route body thin: auth, parse, service call, `Response.json`.
3. Keep `HttpError` throwing in services and route handlers only when a `withErrors` boundary will catch it. In page loaders or `createServerFn` calls, return `null`, throw `redirect(...)`, or map the error locally.
4. Identity and roles come only from Gateway headers; the App has no session
   cookie or session secret. Keep `src/start.ts`, `src/lib/auth.ts`,
   `src/lib/gateway.ts`, and the `previewGatewayHeaders()` plugin in
   `vite.config.ts` as the scaffold ships them.
5. Keep `/login`, `/api/health`, `/api/manifest`, and the TanStack runtime/build paths public in `src/start.ts`; preview readiness depends on `/api/health` staying unauthenticated.

Useful checks:

```bash
rg -n 'requireAuth|HttpError|withErrors' src/routes src/services src/lib
rg -n 'PUBLIC_PATHS' -A 10 src/start.ts
```

### Preview role error (kind `role`)

Error examples:

```text
Requires role: <role> or <role>
HTTP 403 /api/<path>: <detail>
```

The Builder preview receives `tier0.preview.error` with kind `role` when a
route `errorComponent` (`RouteErrorBoundary`) catches a 403 from `requestJson`
or a server-function error whose message contains `Requires role:`
(`isPreviewRoleError` in `src/lib/preview-bridge.ts`). The App code ran; the
roles the preview is viewing as do not grant this page. Do not rewrite the
page or add a fallback role to clear the error.

Preview roles arrive as `X-Tier0-Runtime: preview` plus `X-Tier0-Preview-Role`,
a comma-separated set chosen in the preview role picker (one or several
roles, absent when none is selected). Permissions are the union across that
set: `requireAuth("a", "b")` passes when any selected role matches, and
`can(user.roles, action)` is true when any selected role grants the action. A
role missing from `PERMISSION_MATRIX` contributes zero permissions; with no
role selected, the request enters with zero roles and every role check fails.

Fix sequence:

1. Read the failing page's role requirements: `requireAuth(...)` arguments in
   its server functions and API routes, and the `can(...)` actions they check.
2. Compare them with the selected preview roles. If no selected role is listed
   there, ask the user to select a role that should have access in the preview
   role picker, then retry.
3. If a selected role should have access, grant it in `PERMISSION_MATRIX` or
   add it to the `requireAuth(...)` list, following the business rules.
4. If a needed role is absent from the picker, it is not registered. Register
   it in `src/lib/permissions.ts`, `src/lib/role-metadata.ts`, and `roles.json`
   together (see the scaffold's `docs/role-registration.md`).

Useful checks:

```bash
rg -n 'requireAuth\(|can\(' src/routes src/services src/lib --glob '!*.test.*'
rg -n 'PERMISSION_MATRIX' -A 20 src/lib/permissions.ts
cat roles.json
```

### Artifact preview port mismatch

Error example:

```text
cannot restart preview: restart preview: parse artifact.toml: artifact: service "web" preview.port=3000 but must be 5173 (PreviewPort constant)
```

This is a configuration error, not a runtime process conflict. Do not keep retrying preview restart before fixing the files.

Fix sequence:

1. Open `artifact.toml` and find the `web` service.
2. Set `[services.preview].port = 5173`.
3. Ensure `[services.preview].args` passes `--host 0.0.0.0 --port 5173` to the dev server.
4. Keep `[[services]].localPort` aligned with the preview/runtime contract when this template is used for managed preview.
5. Open `package.json` and ensure `scripts.dev` starts Vite/TanStack on port `5173`, for example `vite dev --host 0.0.0.0 --port 5173`.
6. Retry preview only after the artifact and package script are synchronized.

### Preview loading timed out

Error example:

```text
Preview loading timed out. Try refreshing and send this error to the agent if the problem persists.
```

Treat this as a readiness failure. First determine whether the dev server is absent, bound to the wrong port, unhealthy, or still compiling.

Fix sequence:

1. Check preview logs before changing code. Look for install failures, build errors, route/runtime exceptions, or Vite binding to a port other than `5173`.
2. Verify `artifact.toml` uses preview port `5173` and the preview args include `--host 0.0.0.0 --port 5173`.
3. Verify `package.json` `scripts.dev` also uses port `5173`; if it omits `--port 5173`, add it.
4. Probe `http://127.0.0.1:5173/api/health` from inside the sandbox when possible.
5. If the port is occupied but health is not 2xx, run the preflight cleanup and restart preview.
6. If the server is compiling slowly but healthy afterward, increase the configured preview health timeout only when the app consistently needs more startup time.
7. If health never succeeds, fix the application runtime error or missing `/api/health` route before retrying preview.

### Frequent full page reloads during dev/HMR

Symptom: editing a file reloads the whole page instead of hot-updating, repeatedly. The dev server is healthy and on `5173`; this is a developer-experience defect, not a startup failure. Do not restart preview to "fix" it — change the code/config below.

Two distinct root causes:

1. **React Fast Refresh incompatibility (mixed exports).** Fast Refresh only hot-replaces a module when every export is a React component. If a `.tsx` file also exports a constant, plain function, or hook, editing it (or any module that invalidates it) forces a full reload. The worst offenders are widely-imported files such as an app shell or shared overlay/layout module, because they reload on almost every edit.

   Fix: move the non-component exports (constants, helpers, hooks) into a sibling `.ts` module and re-import them, so each `.tsx` exports components only. `export type`/`export interface` are fine (type-only, erased at build). TanStack route files that export `Route` are handled by the router plugin and are exempt.

   ```bash
   # list .tsx files that export BOTH a component and a non-component value
   for f in $(rg -l --glob 'src/**/*.tsx' '^export (default )?(function|const) [A-Z]'); do
     rg -q '^export (const|function|async function) [a-z]' "$f" && echo "$f"
   done
   ```

2. **optimizeDeps not pre-bundling code-split deps.** When Vite discovers a dependency *after* its initial scan (because the dep is only imported inside a code-split route/component), it re-optimizes and forces a full reload. Watch dev logs for `optimized dependencies changed. reloading` or `new dependencies optimized`.

   Fix: add such client deps to `vite.config.ts` `optimizeDeps.include`, using the exact imported subpath (e.g. `"motion/react"`, not `"motion"`), then restart dev once.

To keep generated apps clean from the start, enforce both as code conventions: component `.tsx` files export components only, and `optimizeDeps.include` lists client deps reached only through code-split boundaries.

