# Latest Tier0 App Template Source

## Contents

- [Canonical Repository](#canonical-repository)
- [Fetch Or Inspect The Latest Template](#fetch-or-inspect-the-latest-template)
- [Files To Compare First](#files-to-compare-first)
- [Latest Template Constraints To Preserve](#latest-template-constraints-to-preserve)
- [Refresh Rule](#refresh-rule)
- [Reconciliation Rule](#reconciliation-rule)

## Canonical Repository

Use the public Tier0 platform app template repository as the live source of
truth:

```text
https://github.com/FREEZONEX/Tier0-App-Scaffold.git
```

Default branch: `main`.

The latest verified snapshot while this reference was written was:

```text
36e995f9da4f02cdb2e75d334db0e0257b2e6380 (2026-07-31)  refs/heads/main
```

Notable since the previous verified snapshot (`afecc70`):

- Gateway-only authentication replaced App-owned authentication sessions.
- Deployed authorization now unions all `X-Tier0-Business-Roles`; the active
  role is display metadata only.
- Platform role registration now rejects keys outside
  `^[a-z]+(_[a-z]+)*$`.
- App identity, design primitives, first-load error handling, runtime seed
  safety, route smoke, and locked build gates are stronger.
- `@tier0/sdk` includes the server-only Files loader, and the scaffold no longer
  vendors platform-managed Skills.

Do not treat that SHA as permanently current. Re-check it before doing migration
work that depends on latest template behavior.

## Fetch Or Inspect The Latest Template

Prefer non-destructive inspection first:

```bash
git ls-remote https://github.com/FREEZONEX/Tier0-App-Scaffold.git HEAD refs/heads/main
```

To inspect the latest template in a throwaway location:

```bash
git clone --depth 1 https://github.com/FREEZONEX/Tier0-App-Scaffold.git /tmp/tier0-app-scaffold
```

If cloning is unavailable, inspect raw files directly:

```text
https://raw.githubusercontent.com/FREEZONEX/Tier0-App-Scaffold/main/AGENTS.md
https://raw.githubusercontent.com/FREEZONEX/Tier0-App-Scaffold/main/README.md
https://raw.githubusercontent.com/FREEZONEX/Tier0-App-Scaffold/main/package.json
https://raw.githubusercontent.com/FREEZONEX/Tier0-App-Scaffold/main/artifact.toml
https://raw.githubusercontent.com/FREEZONEX/Tier0-App-Scaffold/main/vite.config.ts
https://raw.githubusercontent.com/FREEZONEX/Tier0-App-Scaffold/main/server.mjs
https://raw.githubusercontent.com/FREEZONEX/Tier0-App-Scaffold/main/DESIGN.md
https://raw.githubusercontent.com/FREEZONEX/Tier0-App-Scaffold/main/docs/platform-integration.md
https://raw.githubusercontent.com/FREEZONEX/Tier0-App-Scaffold/main/docs/role-registration.md
```

## Files To Compare First

When aligning an imported app to the latest template, compare these files before
editing business code:

- `AGENTS.md`: task rules, preview workflow, scaffold ownership, hard constraints.
- `DESIGN.md`: current tokens, primitives, layout, form, table, and visual rules.
- `README.md`: current stack, environment model, route conventions, build contract.
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
  permission union, role registration, and internal fallback.
- `src/lib/{app-chrome,tier0}.ts`: App identity and SDK lazy-loader contracts.
- `scripts/{post-build-verify,gate-integrity,runtime-audit,route-smoke}.mjs` and
  `scripts/gate-integrity.json`: current completion gates and locked files.

## Latest Template Constraints To Preserve

As of the verified snapshot, the template requires:

- TanStack Start 1.x with Vite 8/Rolldown, TanStack Router, and React 19.
- Node `>=22.12.0`.
- `package.json` scripts: `dev`, `dev:local`, `dev:force`, `build`,
  `postbuild`, `typecheck`, `build:verify`, `build:check`, `runtime:audit`,
  `auth:union:test`, `smoke:routes`, `start`, `lint`, `db:push`, `db:seed`, and
  `db:studio`. `npm run build` is the completion path; its `postbuild` runs
  verification, multi-role auth tests, and runtime audit.
- `@tier0/sdk` `^0.2.10` in this verified snapshot, loaded through
  `src/lib/tier0.ts` lazy helpers including `loadTier0Files`. Do not top-level
  import `@tier0/sdk/openapi`, `@tier0/sdk/files`, or `@tier0/sdk/mq` on
  SSR/page-startup paths. Re-read `package.json` instead of freezing this version.
- Vite base path from `VITE_BASE_PATH` with `NEXT_PUBLIC_BASE_PATH` as legacy
  fallback.
- Vite SSR external policy: `["pg", "@tier0/sdk", "mqtt"]`.
- Preview Gateway header injection in `vite.config.ts` using `PREVIEW_USER_ID`,
  `PREVIEW_USER_NAME`, `PREVIEW_USER_EMAIL`, and `PREVIEW_USER_ROLE`. The App
  does not create an authentication session.
- Gateway-only authentication: only `/api/auth/me` remains; `/login` is a hidden
  auth-error bridge, and App-local session/logout/select-role code is absent.
- Preview is one view-as role. Deployed authorization uses the permission union
  of all comma-separated `X-Tier0-Business-Roles`; `X-Tier0-Active-Role` is only
  the primary display role.
- Root `roles.json` registers business roles with
  `role_key` matching `^[a-z]+(_[a-z]+)*$`; the built-in admin fallback is not
  registered as a platform business role.
- `artifact.toml` production service running `node server.mjs` on
  `node:22-alpine`, health path `/api/health`, local port `5173`, and
  `deploymentTarget = "autoscale"`. Every `args` array is literal argv; shell
  semantics use an explicit `["sh", "-c", "..."]`.
- Platform env injection owns `DATABASE_URL`, `DB_SCHEMA`, `APP_ID`,
  `VITE_BASE_PATH`, and Tier0 SDK host/key/MQ variables.
- `APP_NAME`, `APP_LOCALE`, and `APP_ICON` are centralized in
  `src/lib/app-chrome.ts`. A generated App replaces the icon placeholder with
  `public/app-icon.png` (512x512 PNG, no more than 2 MB) and synchronizes the
  same image to platform App metadata.
- Frontend changes read `DESIGN.md` and compose scaffold primitives. Request
  results render through `AsyncView`; valid runtime baseline dates use
  `seedDate()` / `seedTimestamp()` and typed Drizzle writes.
- All invariant tests and verification scripts listed by
  `scripts/gate-integrity.json` are locked. Only
  `src/lib/template-state.test.mjs` is App-adaptable.
- `.agents/skills/` contains no vendored guidance. Platform Builder Skills are
  selected and injected by the App Builder orchestrator.

## Refresh Rule

Treat a changed Scaffold `main` SHA as a review trigger, not a version-string
edit:

1. Compare the previously verified SHA with current `main` using `git log` and
   `git diff --name-status`.
2. Inspect every changed volatile contract surface listed above.
3. Reconcile `SKILL.md`, `platform-contract.md`, migration/troubleshooting
   references, and completion criteria; remove instructions contradicted by the
   new template.
4. Search the whole Skill for retired env names, endpoints, headers, role
   semantics, dependency versions, and build commands.
5. Update the verified SHA/date only after the guidance and acceptance evidence
   agree with the new template.

Run this review on a regular schedule and immediately after auth, role, SDK,
artifact, runtime, gate, App identity, or Skill-injection changes.

## Reconciliation Rule

If the local app, this skill, and the latest template disagree:

1. Treat the latest template as the platform baseline.
2. If current Scaffold surfaces disagree, compare `AGENTS.md`, integration docs,
   implementation, and locked tests. Follow actively enforced behavior for the
   migration, record the upstream contract conflict, and do not freeze one stale
   comment into this Skill.
3. Preserve working business behavior through a compatibility boundary.
4. Do not bulk overwrite local scaffold files without understanding local
   changes and the user's migration goal.
5. Patch the smallest set of platform-contract drift needed to make the target
   app deployable and maintainable.
