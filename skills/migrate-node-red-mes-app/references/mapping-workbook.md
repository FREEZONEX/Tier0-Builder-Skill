# Node-RED WMS/MES Mapping Workbook

Use this workbook to create a project-local migration map from the current
source application. Do not store completed private-project mappings in the
reusable skill.

## Output Location

Write the completed mapping to the target project, for example:

```text
docs/migration-analysis.md
```

## Source Inventory

Record the source files that were inspected:

| Source area | File or folder | Notes |
|-------------|----------------|-------|
| Node-RED flows | `<path-to-flow.json>` | HTTP nodes, function nodes, stores |
| React entry | `<path-to-entry>` | App mount, providers |
| Router | `<path-to-router>` | HashRouter, BrowserRouter, custom router |
| Stores | `<path-to-store>` | Global store, localStorage, API wrappers |
| Assets | `<path-to-assets>` | Static paths and imports |
| Deployment | `<path-to-config>` | Package scripts, artifact config |

## HTTP Endpoint Inventory

Derive this from Node-RED HTTP-in nodes and adjacent function nodes.

| Method | Source URL | Handler/function | Target route file | Target service |
|--------|------------|------------------|-------------------|----------------|
| `GET` | `/api/<entity>` | `<function-name>` | `src/routes/api/<entity>.ts` | `src/services/<entity>.ts` |
| `POST` | `/api/<entity>` | `<function-name>` | `src/routes/api/<entity>.ts` | `src/services/<entity>.ts` |
| `PUT` | `/api/<entity>/:id` | `<function-name>` | `src/routes/api/<entity>/$id.ts` | `src/services/<entity>.ts` |

Check each endpoint for:

- Input source: path params, query params, body fields, headers.
- Output shape: list, single entity, status object, export payload.
- Side effects: state transition, audit event, inventory move, genealogy link.
- Error behavior: validation, not found, conflict, permission failure.

## Entity And Store Mapping

Use this for Node-RED `flow.get/set`, global stores, localStorage, or source
database tables.

| Source key/table/store | Target entity | Target table | Target service | Notes |
|------------------------|---------------|--------------|----------------|-------|
| `<source-key>` | `<entity>` | `<table_name>` | `src/services/<entity>.ts` | `<state/risk>` |

Classify each entity:

- Master data: material, equipment, route, user, configuration.
- Transactional data: order, lot, movement, inspection, handover, return.
- State machine: work order, batch, quality hold, shipment, rework.
- Derived/reporting data: dashboard metrics, summaries, export rows.

## Page Mapping

Map old React screens to TanStack Router files. Choose the layout through
`app-layout-patterns`, not by user role alone.

| Source screen | Workflow shape | Target route | Layout |
|---------------|----------------|--------------|--------|
| `<Dashboard>` | Workspace overview | `src/routes/_app.index.tsx` | `_app` |
| `<ExecutionScreen>` | Scan/tap/confirm | `src/routes/station.<name>.tsx` | `station` |
| `<ReviewQueue>` | Evidence/decision | `src/routes/review.<name>.tsx` | `review` |
| `<Wallboard>` | Passive display | `src/routes/monitor.<name>.tsx` | `monitor` |

## Node-RED Function Mapping

| Node-RED function | Responsibility | Target owner | Notes |
|-------------------|----------------|--------------|-------|
| `<function-name>` | CRUD read | `src/services/<entity>.ts` | Explicit SQL builder query |
| `<function-name>` | State transition | `src/services/<entity>.ts` | Validate allowed transitions |
| `<function-name>` | Multi-step write | `src/services/<entity>.ts` | Wrap in transaction |
| `<function-name>` | HTTP wrapper | `src/routes/api/**` | Keep thin |

## Verification Matrix

| Workflow | Source behavior | Target check | Evidence location |
|----------|-----------------|--------------|-------------------|
| `<workflow>` | `<what must stay true>` | `<test/manual/API check>` | `<local evidence>` |

At minimum, verify:

- Main list/detail pages load.
- Create/update actions persist.
- State transitions cannot skip required states.
- Inventory or production quantities do not violate source invariants.
- Permission and menu visibility match target roles.
- Build, health, manifest, and package import checks pass.
