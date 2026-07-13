# Platform Contract For App Alignment

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
- Do not create login/register flows when identity is platform/gateway managed.
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

## Data And Server Boundary

Imported apps often hide server behavior inside API helpers, mock services,
local storage, Next route handlers, custom middleware, or Node server files.
Reclassify that code:

- UI-only data shaping can stay route-local or component-local.
- Shared client requests should use scaffold hooks or explicit abort-safe fetch.
- HTTP handlers belong in `src/routes/api/**`.
- Business logic belongs in `src/services/**`.
- Database access belongs behind services only.
- External platform I/O should use scaffold SDK lazy loaders when available.
- Existing database/schema/seed behavior should move into the scaffold data
  layer only when the app owns that persistence.

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
