# Upgrade pre-v15 guidance gates

Read when an existing App aligns to scaffold v15 or later, including a mixed
App whose marker already says v15 but whose gates are older. The verified v15
source is `c285b43b355b8bc379d50c16aadeaf25826e43eb` on
`feature/cloud-new-architecture-migration`; its marker is
`{ "version": 15, "ref": "0fcc599" }`. Recheck the requested target before
using it; later targets use their own complete file set and marker.

## Preserve behavior, replace the inherited checks

There is no role-count build limit. Preserve all distinct source roles and
their actions, metadata, registration, navigation and API guards. Do not copy
empty template permissions, roles.json, collections or branding over the App.
No data reset, role consolidation or UI rewrite is needed for v13/v14 to v15.
Earlier SQL/SDK versions still require their separate architecture migration.

Source-pattern checks for copy, page introductions/role explanations,
lifecycle actions, UI callers, component choices, required markers, option
labels, visual recipes and layout are review advisories. Malformed/missing
scaffold markers also do not block App builds. Do not add fake actions,
confirmation words or opt-out comments, or remove useful copy, to silence them.
Design recommendations elsewhere in this Skill are defaults; explicit product
requirements and equivalent working implementations take precedence.

Authentication, permission union and role registration/metadata/key validity,
data declarations, server boundaries, route correctness and runtime exceptions
remain blocking. The guidance helper catches assertion findings only; an
analyzer exception is not a successful check.

## Install one coherent upstream set

1. Pin the source commit and inventory the App's scripts, tests, gate manifest,
   package scripts and local modifications. A marker alone is not evidence of
   alignment. Identify app-owned checks separately from inherited template ones.
2. Take `scripts/gate-integrity.json` and every file in its `locked` mapping
   from that same commit, including `scripts/gate-integrity.mjs`, the new
   `scripts/guidance-test.mjs`, `scripts/post-build-verify.mjs`, changed `src/lib/*.test.mjs`, and their
   transitive imports. Compare destination bytes with the pinned source.
   Apply the upstream replacement of inherited gates; do not retain old count
   or heuristic blockers under another npm command. Preserve genuine app-owned
   correctness/security tests. Review customized locked-file behavior explicitly
   instead of hiding a mismatch by regenerating hashes locally.
3. Also replace the unpinned `scripts/runtime-audit.mjs` explicitly; copying
   only the manifest entries leaves the old AsyncView/loading blockers active.
   Include unpinned build dependencies `tests/guidance.test.mjs` and
   `tests/role-contract.test.mjs`. Merge package scripts rather than replacing
   the whole manifest. At v15 `test:guidance` is
   `node --test tests/guidance.test.mjs tests/role-contract.test.mjs`, and
   `postbuild` runs it before `build:verify`, `auth:union:test`, `runtime:audit`,
   `test:components` and `test:data`. Preserve necessary app scripts and business
   dependencies; reconcile their own inherited duplicate blockers. Check the
   target's actual scripts for later versions.
4. Merge relevant `AGENTS.md`, `docs/role-registration.md` and
   `docs/ui-rules.md` guidance. Remove stale App instructions that require
   at most three roles or treat these heuristics as build failures. Preserve
   business specifications, valid design choices and app-adaptable
   `src/lib/template-state.test.mjs` assertions.
5. Ordinary App builds must not set `SCAFFOLD_GUIDANCE_STRICT=1`. That switch
   belongs to scaffold-maintainer CI for testing template defaults, not to
   generated-App build scripts, deployment configuration or inherited CI.
   Do not copy `.github/workflows/scaffold-guidance.yml` into an App. If an
   existing App inherited it, remove/adjust that specific template-default job
   without disabling its app-owned safety or correctness checks.

## Acceptance

- Run `node scripts/gate-integrity.mjs` without `--update`, then
  `npm run test:guidance` and full `npm run build` in normal App mode. Ensure
  every required file/import and package command exists; a new hash manifest
  alone is not a migration.
- The upstream regression fixtures exercise 4/8-role models, invalid role
  configuration, contextual copy/read-only pages, custom loading UI, strict
  mode, analyzer errors and import-time service work. Retain them unchanged.
  On an affected real App also verify preserved roles/actions and changed UI;
  never seed roles or weaken permissions merely to create a test.
- Warnings are review evidence, not failing checks. Do not block completion
  solely because they remain. A real runtime/data/auth failure still blocks
  the corresponding acceptance; continue independent work as described in
  `first-ensure-and-runtime-blockers.md`.
- Only after full applicable alignment acceptance, copy the target marker
  verbatim. A gate-only repair to an otherwise outdated App keeps its previous
  marker; neither a v15 string nor a successful compile proves full alignment.
