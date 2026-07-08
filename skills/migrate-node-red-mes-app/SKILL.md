---
name: migrate-node-red-mes-app
description: >-
  Specialized app-shape migration guide for legacy Node-RED plus React WMS/MES
  applications. Use as a child skill of align-platform-app when the source
  project combines Node-RED flow.json APIs, React business screens, WMS/MES
  entities, legacy stores, route/API mapping, MonoApp packaging, artifact.toml
  deployment checks, or enterprise-new import troubleshooting.
---

# Node-RED WMS/MES App Migration

## Overview

Use this skill as the app-shape child of `align-platform-app` for legacy
**Node-RED backend + React frontend + WMS/MES business applications**.

It specializes the parent workflow with Node-RED `flow.json` analysis, WMS/MES
entity discovery, legacy screen mounting, state-transition preservation,
artifact packaging, and import troubleshooting.

This public version intentionally contains no customer-specific case data,
source archive paths, raw seed rows, or completed project mappings. Generate
those artifacts from the user's current source project and keep them in that
project's local docs or worktree, not inside this reusable skill.

## Relationship To The Parent Skill

- Parent skill: `align-platform-app`
- Child skill: `migrate-node-red-mes-app`
- Switch to this child skill when the parent migration inventory finds
  Node-RED flows, WMS/MES domain entities, old React business screens,
  warehouse/quality/production/PDA workflows, or legacy stores.
- Return to the parent skill for platform template alignment, preview rules,
  build/runtime contracts, authentication boundaries, packaging, and deployment
  requirements.

## Public-Safe Boundary

Do not store project-specific migration evidence in this skill:

- No customer names, contract numbers, work order numbers, project names, or
  source archive paths.
- No raw seed data, sample rows, production IDs, or business records.
- No completed endpoint/entity/page mapping from a private project.
- No local Docker image tags or one-off environment patches unless they are
  already approved public platform guidance.

When exact mappings are needed, generate them in the target application under
local project docs, for example `docs/migration-analysis.md`.

## Core Workflow

1. **Inventory the source**
   - Locate Node-RED `flow.json`, React entry points, router definitions,
     global stores, static assets, i18n files, package scripts, and deployment
     metadata.
   - Identify whether the source uses in-memory `flow.get/set`, external API
     calls, file storage, browser storage, or a database.
   - Record raw source-specific evidence in local project docs only.

2. **Build the migration workbook**
   - Load `references/mapping-workbook.md`.
   - Derive HTTP endpoint inventory from Node-RED HTTP nodes.
   - Derive Node-RED function responsibilities from function node names and
     bodies.
   - Map source pages to TanStack Router route files.
   - Map source stores/entities to target services, tables, and API routes.

3. **Build the data-shape inventory**
   - Load `references/data-shape-inventory.md`.
   - Capture field names, inferred types, required/optional status, enum/state
     values, relationships, and migration risks.
   - Store field shapes instead of raw business values.

4. **Create or align the target app**
   - Keep the Tier0 platform scaffold from `align-platform-app`.
   - Preserve platform files: `server.mjs`, `artifact.toml`, `vite.config.ts`,
     health route, manifest route, root route, router factory, and auth/session
     boundary files.
   - Do not reinitialize the project.

5. **Move backend behavior into scaffold layers**
   - Use `src/db/schema.ts` for tables and Zod schemas.
   - Use one `src/services/<entity>.ts` file per domain entity or cohesive
     domain aggregate.
   - Use `src/routes/api/**` as thin HTTP wrappers around services.
   - Keep Node-RED state machines, multi-step writes, derived fields, and audit
     side effects in services.

6. **Mount legacy React screens safely**
   - Use TanStack Router file routes under the layout chosen by
     `app-layout-patterns`.
   - Preserve large or fragile screens behind a `src/legacy` boundary first.
   - Native-refactor gradually after core workflows are reachable and verified.

7. **Validate behavior**
   - Verify source routes and primary WMS/MES workflows are reachable.
   - Verify key state transitions persist through API calls, not only
     localStorage.
   - Verify build, health, manifest, preview, and import/package behavior.

## Target Structure

Use this shape as the default target unless the parent scaffold has changed:

```text
<target-app>/
├── artifact.toml
├── package.json
├── drizzle.config.ts
├── server.mjs
├── src/
│   ├── db/
│   │   ├── index.ts
│   │   ├── schema.ts
│   │   └── seed.ts
│   ├── routes/api/
│   ├── services/
│   ├── components/
│   ├── legacy/
│   └── routes/
└── docs/
    └── migration-analysis.md
```

## Backend Rules

- Put database reads and writes in `src/services/**`, never in route handlers
  or client components.
- Keep API route files thin: auth guard, parse input, call service, return JSON.
- Preserve source IDs only when compatibility requires it. Use placeholders
  such as `<source-id>` in docs; do not copy real business identifiers into
  reusable skill files.
- JSON container storage can be a temporary compatibility bridge for broad
  legacy entities, but record a later normalization plan when the source fields
  are known.
- Wrap multi-step writes in transactions in the service layer.
- Do not use Drizzle relational query helpers in generated services; prefer
  explicit SQL builder queries.

## Frontend Rules

- Use TanStack Router file conventions, not Next.js routing.
- Keep route files in `src/routes/`; never hand-edit `routeTree.gen.ts`.
- Preserve `i18next`/`react-i18next` only when the source app actually uses
  them or the target requirements call for i18n.
- Register navigation modules, route guards, actions, and permission matrix
  entries together.
- If legacy screens depend on a global store, mount a small initializer
  component from the layout instead of scattering fetch effects through route
  files.
- If large legacy chunks trigger Vite size warnings, verify route-level code
  splitting before adjusting `build.chunkSizeWarningLimit`.

## Packaging And Import

Load `references/artifact-toml-cheatsheet.md` when creating or debugging
`artifact.toml`.

Default checks:

- ZIP root must directly contain `package.json`, `server.mjs`, `artifact.toml`,
  and `dist` after build.
- `services[0].production.run.image` must exist.
- `services[0].production.health.startup.path` must be reachable.
- Runtime must listen on `0.0.0.0` when deployed behind the platform gateway.
- If using Drizzle, keep `drizzle.config.ts` compatible with runtime-injected
  environment variables.
- Do not rely on dev-only packages in production startup.

Load `references/import-troubleshooting.md` when import, health, preview, or
deployment checks fail.

## Completion Criteria

- The mapping workbook was generated for the current source project.
- Source entities, API routes, screens, and state transitions have target
  owners.
- Primary WMS/MES workflows are reachable in the target app.
- State-changing actions persist through service/API calls.
- The app validates against the parent Tier0 platform scaffold contract.
- No reusable skill file contains project-specific customer data or raw seed
  records.

## References

- `references/mapping-workbook.md`: template for endpoint/entity/page mapping.
- `references/data-shape-inventory.md`: template for field and state inventory.
- `references/artifact-toml-cheatsheet.md`: public-safe artifact.toml guidance.
- `references/import-troubleshooting.md`: public-safe import troubleshooting.
