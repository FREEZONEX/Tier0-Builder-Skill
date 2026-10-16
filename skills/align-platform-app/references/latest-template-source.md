# Inspect the Target Scaffold

## Canonical Repository

`https://github.com/FREEZONEX/Tier0-App-Scaffold.git`, branch `main`.
The upstream `main` baseline verified on 2026-10-16 is
`822dfabf2469bc4d64f6d46f44e79b650fe3ab03` (merged scaffold PR #88).
Its `package.json.tier0Scaffold` is `{ "version": 7, "ref": "3a96b2b" }`;
the SDK range remains `^0.5.4`, locked to 0.5.4. The repository commit identifies
the inspected source; the marker's `ref` identifies the content commit stamped
by the scaffold maintainer. They need not be equal. After successful app
alignment, copy the selected scaffold's marker object verbatim, not the merge
SHA or the Skill package version.

This is a verified source snapshot, not a permanent version pin or deployment
proof. Recheck the selected commit's manifest and authoritative lockfile for
each alignment; honor a user-selected ref and do not downgrade a newer SDK.
Since the prior 2026-09-20 v3 snapshot, the relevant additions are the generic
component kit/provider and its dependencies, component build checks, right-side
single required markers, and MetaListPage as the default list-page foundation.
For in-scope UI work, inspect `docs/component-kit.md`, affected components and
the current `AGENTS.md`; retain application-specific services and permissions.
The new list default does not require rewriting untouched pages during an
unrelated platform upgrade.

This Skill covers the existing role/schema/runtime/File Storage contracts and
adds the SDK 0.5.3 MQTT upgrade path. Preserve the SDK 0.5.1 notification rules,
including explicit silent-send migration and test/live message mode.

SDK PR #33 merged at `d795a4c263ec1a14c7cbd47f0744a29e6ecdeee0`; npm latest was
verified as 0.5.3 on 2026-09-14. Its published runtime includes the MQTT fixes,
but the package lacks `check-api-key-compat.mjs` and carries configuration
reference version 0.2.1 rather than the PR's final 0.2.2. Check actual Skill
resources before executing a documented diagnostic. Skill reference versions
are independent of npm package versions; matching version numbers are not a
publication or compatibility check. These source/package facts do not prove
Builder has loaded matching guidance or an existing App has upgraded. Recheck
when freshness matters.

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

Compare and patch `src/services/bootstrap.ts` first when it still runs a
runtime `create schema if not exists` block: remove the block outright, with no
try/catch or fallback. The platform pre-creates the schema and the app role has
no database-level `CREATE`, so PostgreSQL rejects it with `42501`. Repair steps
are in
[import-troubleshooting.md](import-troubleshooting.md#database-startup-or-schema-fails).

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
