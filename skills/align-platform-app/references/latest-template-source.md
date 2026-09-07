# Latest Tier0 App Template Source

## Canonical Repository

`https://github.com/FREEZONEX/Tier0-App-Scaffold.git`, branch `main`.
Verified on 2026-09-07 at `8a6ac304a12f74e9079afc0871f942017e4d1904`.
This is a recorded source baseline, not evidence of any deployed runtime.

The September 7 review reconciled the Skill against this commit, including
contracts omitted from its older August 19 reference snapshot:

- No reserved roles or Preview admin fallback; at most three business roles.
- Platform-owned schema, `appSchema` declarations, typed bootstrap table objects,
  and guarded local schema sync.
- Runtime `resolveAppId()`, root icon/cover persistence, and File Storage.
- `@tier0/sdk` range `^0.3.4`, with server-side lazy loading.
- Application-dialog guidance and responsive workspace `page-shell`.

## Verify A Target Commit

Prefer a clean reference checkout and preserve the app's working changes.
Inspect the remote with `git ls-remote` or fetch into a suitable repository,
then record the exact `origin/main` SHA. Read files using that commit, not a
moving branch across multiple requests. If a temporary clone is needed, use a
unique directory rather than overwriting a fixed `/tmp` checkout.

A pinned user-selected ref takes precedence over latest `main`. If remote access
is unavailable, identify the cached/package commit and limit freshness claims.
A version string or previously delivered ZIP filename is not commit evidence.

## Surfaces To Inspect By Change

Read the relevant current files and their changes since the app's known base:

| Area | Source surfaces |
| --- | --- |
| Generation/design | `AGENTS.md`, `DESIGN.md`, `src/styles/globals.css`, affected components |
| Dependencies/build | `package.json`, `package-lock.json`, `artifact.toml`, `scripts/post-build-verify.mjs`, `scripts/gate-integrity.json` and its listed files |
| Runtime/routing | `server.mjs`, `vite.config.ts`, `src/start.ts`, `src/router.tsx`, root/layout routes, health/manifest, route-nesting tests |
| Identity/roles | `docs/platform-integration.md`, `docs/role-registration.md`, `src/lib/{auth,gateway,permissions,role-metadata,app-id,app-chrome}.ts`, `roles.json`, auth/role tests |
| Persistence | `src/db/{index,schema}.ts`, `src/services/bootstrap.ts`, `src/services/seed-utils.ts`, `scripts/db-sync-guard.mjs`, `drizzle.config.ts` |
| SDK/assets | `src/lib/tier0.ts`, `package.json`, root `icon.png`/`cover.png`, `public/app-icon.png`, `.env.example` |

For a full migration, cover every relevant platform area. For a targeted scaffold
update, review changed surfaces and transitive dependencies; do not turn this
inventory into a mandatory whole-app rewrite. Never overwrite app-specific schema,
permissions, navigation, branding, or routes with the blank template.

## Reconciliation And Refresh

Detailed operational rules live in [platform-contract.md](platform-contract.md).
Keep this file focused on provenance and discovery rather than a duplicate
contract checklist.

When updating this Skill against a new commit:

1. Compare the recorded baseline to the target via log and diff.
2. Inspect changed implementation, guidance, and locked tests. A known-good
   upstream baseline can contain defects; do not assume every failure is app drift.
3. Reconcile the entrypoint and all affected references. Search the entire Skill
   for retired role semantics, env names, SDK versions, bootstrap behavior, asset
   paths, commands, and packaging assumptions.
4. Preserve product intent and record conflicts instead of silently increasing
   permissions or weakening verification.
5. Update this SHA/date after reconciliation. Validate metadata/references and
   rebuild the distribution ZIP from the reviewed source; verify its contents.

Check freshness when a task needs it. This guidance does not schedule a recurring
job or require a network refresh for unrelated product edits.
