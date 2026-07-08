# Compatibility Boundary Pattern

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
- Guard browser-only libraries during SSR.
- Keep one adapter layer for localStorage/sessionStorage compatibility if the
  source depends on them.
- Prefer route-by-route extraction over a broad rewrite.

## Exit Criteria

Start removing the boundary only when:

- Equivalent scaffold-native routes exist.
- Data dependencies have been moved to platform-safe API/service paths.
- Layout and navigation are native to the target shell.
- Global CSS side effects are resolved.
- Primary workflows have current verification evidence.

## Common Failure Modes

- The legacy app compiles but is not reachable because routes were not mapped.
- Navigation works only through hash routes and breaks on direct URL load.
- Tables render empty because legacy store initialization was never mounted.
- Actions appear successful but only mutate local storage.
- Global CSS overrides scaffold layout, buttons, or dialogs.
- Browser-only code executes during SSR and breaks hydration.
