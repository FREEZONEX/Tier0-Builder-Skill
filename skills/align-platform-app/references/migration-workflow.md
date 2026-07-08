# Platform App Alignment Workflow

## 1. Source Inventory

Before source inventory, fetch or inspect the latest Tier0 platform template as
described in `latest-template-source.md` when the migration depends on platform
contract details.

Inspect these source areas before editing target code:

- `package.json`: scripts, dependencies, framework, module type, package manager.
- Entry points: `index.html`, `src/main.*`, `src/App.*`, framework app folders.
- Routing: route arrays, router providers, file routes, dynamic params, redirects.
- Layout: shells, sidebars, top bars, providers, auth guards, error boundaries.
- State: Zustand/Redux/Context stores, localStorage/sessionStorage use, caches.
- Data access: fetch wrappers, GraphQL clients, REST clients, mocks, SDK clients.
- Server/runtime: API routes, server entry, workers, adapters, cron-like jobs,
  custom middleware, and framework-specific server handlers.
- Data layer: schema files, migrations, seed data, local JSON stores, browser
  storage reliance, and backend persistence assumptions.
- Assets: public paths, imported images, fonts, CSS resets, CDN references.
- Environment: `.env*`, `import.meta.env`, `process.env`, hard-coded hosts.
- i18n/theme: locale files, RTL/LTR logic, theme tokens, CSS variables.

Write a short migration map when the source is non-trivial:

- source route -> target route file
- source provider -> target provider/boundary
- source API/server helper -> target service/API/external dependency
- source data model -> target schema/seed/service boundary or external system
- source asset path -> target asset path
- source env var -> platform/runtime source or removed setting

## 2. Strategy Selection

Use direct conversion when:

- The source has few routes.
- Components and server pieces are already framework-neutral or easy to isolate.
- Data access is easy to remap to scaffold services, API routes, or external
  platform services.
- Styling is contained and compatible with target globals.

Use a compatibility boundary when:

- The source has many routes or a custom router.
- Global state, CSS, or browser-only code is fragile.
- The user requires preserving full business behavior first.
- Build/runtime contract work is urgent and native refactoring can follow.

## 3. Migration Order

Prefer this sequence:

1. Stabilize the platform shell and build/runtime contract.
2. Bring in assets, global styles, and source providers behind an explicit
   boundary.
3. Mount primary routes and navigation.
4. Replace mock/local-only data with platform-safe API/service/data paths.
5. Normalize auth, permissions, and menu visibility.
6. Incrementally extract reusable components into scaffold-native folders.
7. Remove compatibility shims only after equivalent native routes are verified.

## 4. Verification Checklist

For each migrated route, verify:

- It is reachable by URL and navigation.
- It renders without hydration/runtime errors.
- Browser-only libraries are guarded or loaded client-side.
- Server-side logic runs through scaffold API/service boundaries.
- Assets and fonts load under the deployed base path.
- Data reads and writes hit intended APIs, services, or external systems.
- Empty, loading, error, and success states are real.
- User-facing copy has no placeholder migration language.

For the whole app, verify:

- Typecheck/build/post-build checks pass.
- `/api/health` and `/api/manifest` still work.
- Production start path is still valid.
- No prohibited framework imports were added.
- Route tree generation is handled by tooling, not manual edits.
- `artifact.toml`, `vite.config.ts`, `package.json`, and platform integration
  behavior still match the latest template baseline or have an intentional,
  documented reason to differ.
