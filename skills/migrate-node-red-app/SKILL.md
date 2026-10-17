---
name: migrate-node-red-app
description: >-
  Migrate legacy applications that use Node-RED as a backend, API layer, state
  store, workflow engine, scheduler, or external-integration orchestrator. Use
  together with align-platform-app when the source contains Node-RED flow files,
  HTTP/function/change/switch nodes, flow or global context, database nodes,
  timers, MQTT, external API calls, or Node-RED-owned CRUD and workflows that
  must move into Tier0 TanStack Start services, APIs, app-owned UNS collections,
  or workers.
  Applies across business domains, not only WMS/MES. Do not use solely for
  generic artifact.toml, packaging, build, or managed-preview failures.
---

# Migrate Node-RED App

## Scope And Precedence

Use this skill only for Node-RED-specific source analysis and cutover. Always
apply `align-platform-app` as the parent rule set for the current Tier0 scaffold,
routing, auth/session behavior, app data (app-owned UNS collections; there is
no app database), build/runtime contracts,
packaging, and deployability.

Apply rules in this order:

1. Freshly verified `FREEZONEX/Tier0-App-Scaffold` contract.
2. `align-platform-app` platform and migration invariants.
3. This skill's Node-RED source, behavior, cutover, and retirement rules.
4. Project-local decisions and evidence that do not violate the platform contract.

Use `preview-runtime-stability` for managed install, port/process, health-timeout,
or HMR failures. Do not duplicate those operational playbooks here.

## Public-Safe Boundary

Keep reusable skill files generic:

- Do not store customer, project, plant, user, order, contract, or source archive
  identifiers.
- Do not copy credentials, raw flow credentials, seed rows, production payloads,
  or complete private-project endpoint mappings.
- Generate project-specific mappings, decisions, logs, and verification evidence
  in the target project, for example `docs/migration-analysis.md`.

## Workflow

1. **Inventory the Node-RED source**
   - Locate flow files, subflows, config nodes, context-store configuration,
     credential references, custom nodes, package manifests, and runtime settings.
   - Inventory HTTP-in/response pairs, function/change/switch nodes, database and
     file nodes, timers, inject/catch/status nodes, queues, MQTT, WebSocket, and
     external HTTP or SDK calls.
   - Record disabled nodes and orphaned branches separately; do not assume they
     are production behavior.
   - Classify every flow responsibility as API transport, validation, CRUD,
     workflow/state transition, derived calculation, scheduler, integration,
     audit/observability, or temporary/mock behavior.

2. **Build a project-local migration workbook**
   - Load `references/mapping-workbook.md`.
   - Map flow nodes and paths to target services, API routes, workers, external
     systems, or intentional retirement.
   - Record request/response/error/auth semantics and business side effects. A
     reachable compatibility route is not evidence of equivalent behavior.

3. **Inventory state and data shape**
   - Load `references/data-shape-inventory.md` when Node-RED context, files,
     browser storage, database nodes, or payload-carried state is authoritative.
   - Capture field shapes, identifiers, relationships, lifecycle states,
     invariants, and retention requirements without copying raw business rows.
   - Declare `persistence_mode` as `compatibility_document` or `normalized_domain`
     when app-owned collections receive migrated business state.

4. **Plan cutover by responsibility**
   - Load `references/node-red-cutover.md`.
   - Track browser, CRUD, workflow, and integration cutovers independently.
   - Record whether historical state will be imported, intentionally reset, or
     retained in an external system.
   - Keep repository asset removal separate from external runtime shutdown.

5. **Move behavior behind scaffold-native server boundaries**
   - Put business invariants, state transitions, and derived fields in
     services. A multi-node atomic write becomes `transact([...])` (≤ 100
     single-document ops across app collections, `require: "matched"` as the
     precondition); a single-record state change becomes `findOneAndUpdate`
     with the current state in the filter; counters use `$inc` (scaffold
     `docs/uns-data.md`). Use deterministic ids or `idempotencyKey` for retries.
   - Keep API routes thin: authenticate, parse, call a service, and return the
     documented response/error contract.
   - Move schedules, retries, long-running work, and external delivery into a
     suitable worker, queue consumer, platform facility, or separately operated
     service. Do not hide asynchronous work inside a request handler.
   - Use a compatibility route only as a controlled transition and keep its
     endpoint matrix current.

6. **Preserve and verify behavior**
   - Verify Node-RED state machines and multi-step writes as behavior, not merely
     as CRUD endpoints.
   - Prove that browser calls, durable writes, workflow transitions, and external
     integrations have the owners declared in the cutover plan.
   - Use the parent skill for real HTTP CRUD, auth, first-use collection creation, restart,
     production-start, health, manifest, build, typecheck, and packaging evidence.

7. **Retire Node-RED only with complete evidence**
   - Do not claim retirement because the browser stopped calling Node-RED or the
     repository no longer contains a flow file.
   - Require all cutover layers, repository cleanup or intentional archival,
     external runtime shutdown evidence, and an explicit rollback/retention
     decision before marking `node_red_retired`.

## Node-RED-Specific Rules

- Treat flow/global context as a data store when business behavior depends on it.
- Preserve ordering, atomicity, idempotency, retries, error branches, audit side
  effects, and scheduled behavior encoded across connected nodes.
- A loosely typed compatibility collection (permissive `recordSchema` holding
  the legacy JSON document) can complete durable storage cutover without
  completing domain normalization. Record the remaining invariants,
  relationships, indexes, required fields, and extraction plan.
- Writing an integration job proves durable enqueue only. It does not prove a
  worker claimed, delivered, retried, acknowledged, or reconciled the operation.
- Require explicit confirmation before deleting or disabling flows, context data,
  legacy tables or collections, credentials, endpoints, schedulers, writers, or external
  Node-RED runtimes.
- Never infer external shutdown from local process, port, repository, or package
  state. Assign external shutdown to a named project-local owner and evidence it
  separately.

## Completion Criteria

- The project-local workbook covers active flows, endpoints, state stores,
  workflows, schedules, integrations, and intentional retirements.
- Every production endpoint has documented behavior and implementation status.
- Browser, CRUD, workflow, and integration cutovers are independently evidenced.
- Storage claims distinguish compatibility documents from normalized domain
  collections.
- Queued-only integration behavior is labeled incomplete until execution and
  reconciliation are proven.
- Historical-data, rollback, flow-asset, and external-runtime decisions are
  explicit.
- The parent `align-platform-app` completion criteria pass.
- No reusable skill file contains project-specific or sensitive evidence.

## References

- `references/mapping-workbook.md`: flow, endpoint, workflow, integration, and
  target-owner mapping template.
- `references/data-shape-inventory.md`: public-safe data, relationship, state, and
  persistence-mode inventory.
- `references/node-red-cutover.md`: cutover states, destructive-action decisions,
  retirement gate, and acceptance checklist.
- `references/node-red-cutover-troubleshooting.md`: Node-RED-specific false
  completion signals and failure diagnosis.
