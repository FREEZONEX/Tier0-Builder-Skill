---
name: align-platform-app
description: >-
  Align applications to the Tier0 platform-standard TanStack Start scaffold
  (FREEZONEX/Tier0-App-Scaffold). Use when migrating an imported legacy SPA, Vite,
  CRA, Next.js, static HTML, React Router, fullstack Node/React, MonoApp, or
  mixed frontend/backend bundle into the platform app shape; also use when an
  app was already built on the Tier0 platform scaffold but the latest template
  changed and the user wants to update, rebase, sync, upgrade, or reconcile
  scaffold files, build/runtime contracts, API/service boundaries, database
  setup, preview behavior, auth/session boundaries, asset handling, routing,
  artifact.toml, Vite config, or platform integration requirements.
---

# Align Platform App

## Overview

Use this skill to align an application with the current Tier0 platform scaffold.
It covers two related situations:

1. Importing or migrating a non-platform app into the Tier0 platform app
   shape.
2. Updating an app that already uses the Tier0 platform scaffold when the
   upstream `FREEZONEX/Tier0-App-Scaffold` template has changed and the user
   chooses to bring the local app forward.

Treat both as standards-gap closure: preserve product behavior first, then move
routes, assets, data access, API/service logic, auth, styling, database setup,
scaffold files, and build/runtime behavior into the latest scaffold-native
patterns.

The canonical platform template is:
`https://github.com/FREEZONEX/Tier0-App-Scaffold.git`.
Before changing migration constraints, fetch or inspect that repository's latest
`main` branch and reconcile the local skill guidance against it.

## Default Stance

- Keep the current scaffold. Do not reinitialize the project.
- Treat this as TanStack Start, not Next.js. Do not introduce `next/*` imports,
  App Router files, server components, `metadata` exports, or Next-specific
  cookie/header APIs.
- Preserve user-visible behavior before refactoring internals. If the source
  project is large or fragile, use a temporary `src/legacy` boundary and migrate
  incrementally.
- Make the target project platform-deployable, not merely buildable. Verify
  runtime entry, health route, manifest route, build output, preview behavior,
  and package/import shape.
- Avoid placeholder screens and "coming soon" states. Empty states should offer
  real actions or route to migrated functionality.

## Workflow

1. **Inventory the source app**
   - For imported projects, identify framework, router, entry points, package
     manager, build command, server/runtime pieces, database assumptions,
     environment variables, static assets, public paths, auth assumptions, and
     API/data access.
   - For already-platform apps, identify local scaffold drift against the latest
     `FREEZONEX/Tier0-App-Scaffold`: package scripts/dependencies, `artifact.toml`,
     `vite.config.ts`, routing/root files, auth/session code, SDK loading,
     preview behavior, health/manifest routes, and docs.
   - Read source route definitions, navigation config, layout shells, global
     styles, state stores, and any runtime/server files.
   - If the source has back-end-like code in client handlers or framework routes, classify whether
     it belongs in `src/routes/api/**`, `src/services/**`, or an external API.

2. **Compare against the platform contract**
   - Load `references/latest-template-source.md` before relying on remembered
     template details. Verify the current `main` commit and inspect at least
     `AGENTS.md`, `README.md`, `package.json`, `artifact.toml`,
     `vite.config.ts`, and `docs/platform-integration.md`.
   - Load `references/platform-contract.md` when checking required target shape.
   - Confirm the target app keeps scaffold files such as `server.mjs`, `vite.config.ts`,
     `artifact.toml`, `/api/health`, `/api/manifest`, and root/router files intact.
   - Confirm managed preview rules: do not manually install dependencies for
     preview startup, and use the platform preview workflow when available.

3. **Choose a migration path**
   - Use a compatibility boundary when the source app is large, route-heavy,
     or relies on global browser state.
   - Use direct conversion only for small projects with clear route/component
     boundaries and no fragile global assumptions.
   - If the source matches a known app-shape specialization, switch to that
     child skill for shape-specific details while keeping this skill's platform
     contract as the parent rule set.
   - Load `references/compatibility-boundary.md` for boundary rules and exit
     criteria.

4. **Migrate into scaffold-native shape**
   - Convert routing to TanStack Router file routes under `src/routes/`.
   - Move reusable UI into `src/components/<domain>/` or route-local modules.
   - Move domain write/read logic into services and thin API wrappers when the
     imported app includes server-side behavior.
   - Move database schema/seed/migration behavior into the scaffold data layer
     only when the source app actually owns data persistence.
   - Map source environment variables to platform/runtime injection. Do not add
     user-facing credential pages for platform-provided SDK credentials.
   - Integrate assets through the scaffold's public/static asset conventions.
   - Preserve localization and directionality when present; normalize user-facing
     copy with the project copy rules.

4a. **Update an existing scaffold-based app**
   - Treat upstream template changes as platform-contract drift, not as a reason
     to overwrite business code.
   - Compare latest template files against local files and classify each
     difference as platform contract, app-specific customization, or unrelated.
   - Patch the smallest set of scaffold files needed to restore compatibility.
   - Preserve business routes, services, schema, permissions, copy, and design
     choices unless the user explicitly asks to refresh them from the template.
   - Ask for user confirmation before broad scaffold rebases, dependency churn,
     or replacing locally customized shell/auth/runtime files.

5. **Verify behavior and deployability**
   - Run typecheck/build and any post-build verifier available in the scaffold.
   - Verify key migrated routes render, navigation works, assets load, and API
     calls do not fall back to local-only state unless intentionally designed.
   - Confirm ZIP/import packaging rules only after checking the target import
     environment. Load `references/import-troubleshooting.md` for failures.

## Reference Routing

- Read `references/migration-workflow.md` for the detailed audit-to-migration
  checklist.
- Read `references/latest-template-source.md` when you need the latest upstream
  template, when current scaffold files conflict with this skill, or before
  updating platform constraints.
- Read `references/platform-contract.md` before changing build, runtime,
  routing, preview, auth, or packaging behavior.
- Read `references/compatibility-boundary.md` when preserving a large imported
  app before native refactoring.
- Read `references/import-troubleshooting.md` when build, preview, health,
  manifest, route generation, assets, or package import fails.

## App-Shape Child Skills

Use child skills as specializations under this parent workflow. They are not a
separate runtime inheritance mechanism; they are routing rules that keep
domain/app-shape details out of the generic migration skill.

- `migrate-node-red-mes-app`: use when the source project is a legacy
  Node-RED + React WMS/MES application, especially when it includes `flow.json`
  APIs, Node-RED function CRUD, production/warehouse/quality/PDA workflows,
  legacy stores, and entity/page migration mapping. This child skill keeps
  app-shape-specific analysis and migration rules out of the generic parent
  workflow.

## Completion Criteria

A migration is not complete until current evidence proves all of the following:

- Source routes and primary workflows are reachable in the target app.
- The app follows TanStack Start routing and scaffold file conventions.
- Platform entry points, health, manifest, preview, and production start paths
  are intact.
- For scaffold-update work, local platform files are reconciled with the latest
  template or intentionally documented as app-specific divergence.
- Source assets, styles, i18n, and navigation behavior are preserved or
  intentionally replaced.
- Build/typecheck/post-build verification passes, or every remaining failure is
  documented with a concrete next action.
- Packaging/import guidance is specific to the actual target environment, not a
  generic ZIP assumption.
- Any claim about the "latest template" is backed by a fresh check of
  `FREEZONEX/Tier0-App-Scaffold` rather than memory.
