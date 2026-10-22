# Inspect the Target Scaffold

## Canonical Repository

`https://github.com/FREEZONEX/Tier0-App-Scaffold.git`, branch
`feature/cloud-new-architecture-migration` (Tier0 cloud). The baseline verified
on 2026-10-22 is `f8a32025dca37c759ea80ee0b0b0a536538290fd` (merged scaffold
PR #91). Its `package.json.tier0Scaffold` is `{ "version": 9, "ref": "cdd548b" }`;
the SDK dependency is `@tier0/sdk-v2` pinned to `0.1.0`. The repository commit
identifies the inspected source; the marker's `ref` identifies the content
commit stamped by the scaffold maintainer. They need not be equal. After
successful app alignment, copy the selected scaffold's marker object verbatim,
not the merge SHA or the Skill package version.

This is a verified source snapshot, not a permanent version pin or deployment
proof. Recheck the selected commit's manifest and authoritative lockfile for
each alignment and honor a user-selected ref. At v9 the App data layer is the
`@tier0/sdk-v2/data` client: collections are declared in
`src/data/collections.ts` with `defineCollection` from
`@tier0/sdk-v2/data/define`, `src/lib/data/index.ts` builds the App's `data`
instance, and `src/start.ts` opens the SDK request context. There is no
Drizzle, `pg`, `DATABASE_URL`, `DB_SCHEMA`, `drizzle.config.ts` or `db:*`
script. The scaffold's AGENTS.md → App Data and `docs/platform-integration.md`
are authoritative for the data contract; the SDK's own Skills ship in
`node_modules/@tier0/sdk-v2/skills/`. For in-scope UI work, inspect
`docs/component-kit.md`, affected components and the current `AGENTS.md`;
MetaListPage remains the default list-page foundation.

## Verify A Target Commit

Prefer a clean reference checkout and preserve the app's working changes.
Inspect the remote with `git ls-remote` or fetch into a suitable repository,
then record the exact `origin/feature/cloud-new-architecture-migration` SHA. Read files using that commit, not a
moving branch across multiple requests. If a temporary clone is needed, use a
unique directory rather than overwriting a fixed `/tmp` checkout.

A pinned user-selected ref takes precedence over the latest branch head. If remote access
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
| Persistence | `src/lib/data/{index,query}.ts`, `src/data/collections.ts`, `src/data/seed-utils.ts`, `src/start.ts` (request context), `scripts/data-schema.mjs`, `src/lib/data-contracts.test.mjs` |
| SDK/assets | `src/lib/tier0.ts`, `package.json`, root `icon.png`/`cover.png`, `public/app-icon.png`, `.env.example` |

An app still on the Drizzle/PostgreSQL layer of an older scaffold replaces it
with collections as described under "Older data layer" in `SKILL.md`; its
existing PostgreSQL rows are not migrated.

For a full migration, cover every relevant platform area. For a targeted scaffold
update, review changed surfaces and transitive dependencies; do not turn this
inventory into a mandatory whole-app rewrite. Never overwrite app-specific
collections, permissions, navigation, branding, or routes with the blank template.

## Reconciliation And Refresh

Detailed operational rules live in [platform-contract.md](platform-contract.md).
Keep this file focused on provenance and discovery rather than a duplicate
contract checklist.

When updating this Skill against a new commit:

1. Compare the recorded baseline to the target via log and diff.
2. Inspect changed implementation, guidance, and locked tests. A known-good
   upstream baseline can contain defects; do not assume every failure is app drift.
3. Reconcile the entrypoint and all affected references. Search the entire Skill
   for retired role semantics, env names, SDK versions, data-layer behavior, asset
   paths, commands, and packaging assumptions.
4. Preserve product intent and record conflicts instead of silently increasing
   permissions or weakening verification.
5. Update this SHA/date after reconciliation. Validate metadata/references and
   rebuild the distribution ZIP from the reviewed source; verify its contents.

Check freshness when a task needs it. This guidance does not schedule a recurring
job or require a network refresh for unrelated product edits.
