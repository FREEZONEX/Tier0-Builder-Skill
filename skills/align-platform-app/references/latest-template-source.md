# Latest Tier0 App Template Source

## Canonical Repository

`https://github.com/FREEZONEX/Tier0-App-Scaffold.git`, branch `main`.
The upstream `main` baseline verified on 2026-09-09 is
`8a6ac304a12f74e9079afc0871f942017e4d1904`. The SDK upgrade target is
`da7ebf85fb9352f6623671c5a214f02317eae0f5` on `codex/sdk-051` in the same repository.
The target is a PR branch, not yet evidence of a merge to `main` or deployment.
When aligning to default `main`, inspect its actual dependency version; use the
upgrade target only when the requested scope selects it or it has merged.

This Skill reconciles the current contracts:

- No reserved roles or Preview admin fallback; at most three business roles.
- Platform-owned schema, `appSchema` declarations, typed bootstrap table objects,
  and guarded local schema sync.
- Runtime `resolveAppId()`, root icon/cover persistence, and File Storage.
- SDK upgrade target `^0.5.1`, locked to `0.5.1`, with server-side lazy loading.
  The preceding main baseline uses `^0.3.4`, locked to `0.3.4`.
- SDK default notification channels, explicit silent-send migration, message-mode
  handling without a title prefix, and MQTT broker/WebSocket normalization.
- Application-dialog guidance and responsive workspace `page-shell`.

The SDK source is `FREEZONEX/Tier0-sdk` at
`33dfa86f34d3ddad082d64fc0953f7fd6a64691f`; npm `latest` was verified as
`0.5.1` on 2026-09-09. Its notification Skill is `1.5.5`. These are separate
source/package facts, not evidence that Builder has loaded a matching Skill or
that an existing App has upgraded. Recheck them when a task requires freshness.

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
