# Inspect the Target Scaffold

Use `FREEZONEX/Tier0-App-Scaffold` as the template source. Inspect current main
unless the user explicitly pins a version. Record the exact SHA in task-local
evidence; do not copy dependency versions or historical release notes into
reusable migration instructions.

Fetch in a clean reference checkout or inspect files at a resolved commit.
Preserve existing app changes. A remote SHA alone is not a contract review:
read the affected implementation, instructions, and tests at that SHA.

## Files To Compare First

When aligning an imported app to the latest template, compare these files before
editing business code:

- `AGENTS.md`: task rules, preview workflow, scaffold ownership, hard constraints.
- `DESIGN.md`: current tokens, primitives, layout, form, table, and visual rules.
- `README.md`: current stack, environment model, route conventions, build contract.
- `.gitignore`: generated/runtime state that must stay outside source control.
- `package.json`: Node engine, scripts, dependency versions, `@tier0/sdk` version.
- `artifact.toml`: production build/run image, health path, preview command/env.
- `server.mjs`: production request/response bridge and stream-abort behavior.
- `.env.example`: App-owned versus platform-injected environment boundary.
- `vite.config.ts`: base path, preview gateway headers, SSR external policy,
  optimizeDeps, TanStack Start plugin options.
- `docs/platform-integration.md`: env injection, auth flow, platform resource
  model, DB schema/app id/base path behavior.
- `docs/role-registration.md`, `roles.json`, and
  `src/lib/{auth,gateway,users,permissions,role-metadata}.ts`: Gateway roles,
  permission union, role registration, and empty-role behavior.
- `src/lib/{app-chrome,tier0}.ts`: App identity and SDK lazy-loader contracts.
- `scripts/{post-build-verify,gate-integrity,runtime-audit,route-smoke,route-nesting,responsive-contract}.mjs`,
  `scripts/gate-integrity.json`, `src/lib/permissions.test.mjs`, and
  `src/lib/{navigation,content,route-nesting,responsive}-contracts.test.mjs`:
  current completion gates, locked files, navigation/lifecycle/role limits,
  route nesting, and 375px responsiveness.

## Reconcile Differences

- Read dependency versions and commands from package.json and its authoritative
  lockfile, not from an old skill snapshot.
- For role/auth changes, inspect implementation and tests as well as AGENTS.md.
  The 2026-09-09 role/schema review used
  `8a6ac304a12f74e9079afc0871f942017e4d1904`: no reserved role, no preview
  fallback, and platform-provisioned schema. This is evidence for those checked
  surfaces, not a claim that every contract in this skill was refreshed.
- If instructions and implementation disagree, record the conflict and use
  the enforced target behavior without silently broadening access.
- Preserve working business behavior and reconcile the smallest necessary set
  of files. Keep explicit approval requirements for broad rebases or replacing
  customized auth/runtime files.
- After a contract change, search this skill and its references for retired
  role semantics, environment names, endpoints, versions, and commands.
