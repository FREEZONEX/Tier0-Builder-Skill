# Inspect the Target Scaffold

## Canonical Repository

`https://github.com/FREEZONEX/Tier0-App-Scaffold.git`, branch
`feature/cloud-new-architecture-migration` (Tier0 cloud).
Inspected on 2026-11-10 at `ee6f30682954e737fa55b38ba2f20a50953b3c9a` (SDK 0.10.1 companion
branch `codex/sdk-0101-harness`, pending merge into the canonical cloud branch).
Its `package.json.tier0Scaffold` is `{ "version": 30, "ref": "5d1fc93" }`.
For a latest-scaffold request, inspect the canonical branch; do not assume this
companion commit is merged or deployed. An explicit v30 target can select this
commit. v30 supersedes v29's mandatory external-collection confirmation with
SDK 0.10.1's scoped Builder management workflow.

The dependency is `file:vendor/tier0-sdk-v2-0.10.1.tgz`, the unchanged npm
release archive. Copy the archive, dependency spec and reconciled lockfile
together. SHA-256: `667e700c16f679b8284627a53fddc01a4092a277bca3652d91788c10ab5ab945`.
SDK 0.10.1 records Backend contract `07ef8cd30a5465a98c8e6ee0892d02360aee8761`.
Source compatibility is not evidence of deployment or live authorization.

The repository commit is the inspected tree; the marker's `ref` is the content
commit stamped by the maintainer. After full App alignment passes, copy the
marker verbatim, not the merge SHA or a Skill version. This snapshot is not a
permanent pin: recheck the remote for a latest-scaffold request; a user-selected
ref or supplied replacement package takes precedence within its chosen scope.

v28 uses SDK data with collections declared in `src/data/collections.ts` and
the App instance in `src/lib/data/index.ts`. All platform data calls act as the
App; services enforce the visitor's read/write/field rules. `src/start.ts` passes
only the request abort signal with `runWithAbortSignal`. Identity comes from
the front door's plain base64url JSON `X-Tier0-Visitor`, parsed by
`src/lib/visitor.ts`; no legacy identity-header fallback or JWT/JWKS verifier
remains. The front door strips client-supplied Tier0 headers and must be the
only production ingress.

`src/lib/data/changes.ts` uses `createChangeRelay` for one upstream per process;
`src/lib/change-visibility.ts` filters what each user may learn through
`/api/uns/subscribe`. `useRecordChanges` reloads through authorized App APIs.
Stream requests/messages and MQTT are server-only. MQTT topics use `appTopic()`
under the App's own preview/deployed namespace. Platform capabilities are fixed;
linking external collections or expanding access follows
[external collection grant management](platform-contract.md#fixed-app-capabilities-and-external-collections).

Read root `AGENTS.md` with `docs/app-data.md`, `docs/ui-rules.md`,
`docs/component-kit.md` and `docs/platform-integration.md`. Read API Skills from
the installed archive's `node_modules/@tier0/sdk-v2/skills/tier0-sdk-v2/SKILL.md`
and its nested domain Skills; do not substitute
an older globally installed SDK Skill. MetaListPage remains the default list
foundation for in-scope UI work; generation heuristics remain advisories.

Known source inconsistencies: at this SHA, the trust-model paragraph in
`docs/role-registration.md` still mentions signed tokens, and a paragraph in
`docs/platform-integration.md` still says Preview/deployed use the same key.
Use `src/lib/visitor.ts`, `src/start.ts`, the v27/v28 migration sections and
`docs/app-data.md`: identity is an unsigned trusted-ingress header, and the
runtime injects separate preview/deployed keys while records remain shared.
Do not propagate the stale paragraphs or infer production readiness from them.

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
| Identity/roles | `docs/platform-integration.md`, `docs/role-registration.md`, `src/lib/{visitor,auth,server-fn-policy,webhooks,permissions,role-metadata,app-id,app-chrome}.ts`, `roles.json`, auth/role tests |
| Persistence | `src/lib/data/{index,query,changes}.ts`, `src/routes/api/uns/subscribe.ts`, `src/lib/record-changes.ts`, `src/lib/route-handlers.ts`, `src/data/collections.ts`, `src/data/seed-utils.ts`, `src/start.ts` (abort signal), `src/lib/change-visibility.ts`, `scripts/data-schema.mjs`, `src/lib/data-contracts.test.mjs`, `tests/*.test.ts` |
| SDK/assets | `src/lib/tier0.ts`, `package.json`, `vendor/README.md`, referenced SDK archive, `tests/app-streams.test.ts`, root `icon.png`/`cover.png`, `public/app-icon.png`, `.env.example` |

For the old-main/new-cloud comparison, implementation fingerprints, and
version-specific upgrade paths, read
[cloud-architecture-upgrade.md](cloud-architecture-upgrade.md). It distinguishes
replacing SQL persistence from upgrading a client on existing collections.

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
