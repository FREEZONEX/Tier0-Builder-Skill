# Latest Tier0 App Template Source

## Canonical Repository

Use the public Tier0 platform app template repository as the live source of
truth:

```text
https://github.com/FREEZONEX/Tier0-App-Scaffold.git
```

Default branch: `main`.

The latest verified snapshot while this reference was written was:

```text
afecc70fd40b5250e72d7ee4542aa46157a28b8b  refs/heads/main
```

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
https://raw.githubusercontent.com/FREEZONEX/Tier0-App-Scaffold/main/docs/platform-integration.md
```

## Files To Compare First

When aligning an imported app to the latest template, compare these files before
editing business code:

- `AGENTS.md`: task rules, preview workflow, scaffold ownership, hard constraints.
- `README.md`: current stack, environment model, route conventions, build contract.
- `package.json`: Node engine, scripts, dependency versions, `@tier0/sdk` version.
- `artifact.toml`: production build/run image, health path, preview command/env.
- `vite.config.ts`: base path, preview gateway headers, SSR external policy,
  optimizeDeps, TanStack Start plugin options.
- `docs/platform-integration.md`: env injection, auth flow, platform resource
  model, DB schema/app id/base path behavior.

## Latest Template Constraints To Preserve

As of the verified snapshot, the template requires:

- TanStack Start 1.x with Vite 8/Rolldown, TanStack Router, and React 19.
- Node `>=22.12.0`.
- `package.json` scripts: `dev`, `dev:local`, `dev:force`, `build`,
  `postbuild`, `typecheck`, `build:verify`, `build:check`, `start`, `lint`,
  `db:push`, `db:seed`, and `db:studio`.
- `@tier0/sdk` `^0.2.7` in this verified snapshot, loaded through
  `src/lib/tier0.ts` lazy helpers; do not top-level import SDK submodules on
  SSR/page-startup paths. Re-read `package.json` instead of treating this version
  as permanently current.
- Vite base path from `VITE_BASE_PATH` with `NEXT_PUBLIC_BASE_PATH` as legacy
  fallback.
- Vite SSR external policy: `["pg", "@tier0/sdk", "mqtt"]`.
- Preview gateway header/session injection in `vite.config.ts` using
  `PREVIEW_USER_ID`, `PREVIEW_USER_NAME`, `PREVIEW_USER_EMAIL`,
  `PREVIEW_USER_ROLE`, and `SESSION_SECRET`.
- `artifact.toml` production service running `node server.mjs` on
  `node:22-alpine`, health path `/api/health`, local port `5173`, and
  `deploymentTarget = "autoscale"`.
- `SESSION_SECRET` is required for production session signing and may be
  generated locally outside production.
- Platform env injection owns `DATABASE_URL`, `DB_SCHEMA`, `APP_ID`,
  `VITE_BASE_PATH`, and Tier0 SDK host/key/MQ variables.

## Reconciliation Rule

If the local app, this skill, and the latest template disagree:

1. Treat the latest template as the platform baseline.
2. Preserve working business behavior through a compatibility boundary.
3. Do not bulk overwrite local scaffold files without understanding local
   changes and the user's migration goal.
4. Patch the smallest set of platform-contract drift needed to make the target
   app deployable and maintainable.
