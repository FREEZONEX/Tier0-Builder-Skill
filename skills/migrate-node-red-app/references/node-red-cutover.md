# Node-RED Cutover And Retirement

Use this reference to distinguish partial migration from complete Node-RED
retirement and to control destructive or externally coordinated actions.

## Contents

- [Cutover Layers](#cutover-layers)
- [Decision Record](#decision-record)
- [Explicit Confirmation Gate](#explicit-confirmation-gate)
- [Integration Execution Gate](#integration-execution-gate)
- [Legacy Asset Scan](#legacy-asset-scan)
- [Retirement Gate](#retirement-gate)
- [Acceptance Checklist](#acceptance-checklist)

## Cutover Layers

Track these states independently:

| State | Completion evidence |
|---|---|
| `node_red_browser_cutover` | Production clients no longer call a Node-RED host, port, proxy, or retired endpoint. |
| `node_red_crud_cutover` | Target services and authoritative storage own all production durable reads/writes previously handled by Node-RED. |
| `node_red_workflow_cutover` | State machines, multi-step writes, schedules, derived fields, audit effects, and failure branches have target owners and tests. |
| `node_red_integration_cutover` | External delivery, retries, idempotency, acknowledgement, reconciliation, and operations ownership no longer depend on Node-RED. |

Do not set `node_red_retired` until every applicable layer is complete and the
operational retirement gate below passes.

## Decision Record

Record these decisions in the target project's migration documentation:

```text
Historical state: import | retain externally | intentionally reset
Cutover mode: phased | parallel | direct
Rollback source: <source and owner> | none by explicit decision
Flow assets: retain temporarily | archive | exclude from delivery | delete
Context stores: migrate | archive | intentionally discard
Repository runtime assets: replace | archive | remove
External Node-RED runtime: owner, environment, shutdown method, evidence
External writers/endpoints/schedules: owner, action, evidence
```

Do not couple these decisions implicitly. For example, an empty target collection
does not automatically authorize deleting flow assets or shutting down an
external runtime.

## Explicit Confirmation Gate

Obtain explicit confirmation immediately before destructive or externally
state-changing actions such as:

- deleting or disabling active flows, subflows, mock/historical flows, or
  context stores;
- stopping a local, containerized, or external Node-RED runtime;
- deleting legacy tables, files, backups, credentials, or retained history;
- disabling HTTP endpoints, MQTT writers/subscribers, timers, schedulers, or
  downstream integration credentials.

Repository inspection can authorize repository edits only within the user's
scope. It cannot prove or authorize production shutdown.

## Integration Execution Gate

A durable `PENDING` job proves enqueue, not delivery. Before declaring an
integration cut over, prove the applicable sequence:

```text
accepted -> persisted -> claimed -> delivered -> acknowledged/reconciled
                              \-> retryable failure -> scheduled retry
                              \-> terminal failure -> surfaced and owned
```

Verify idempotency, retry limits/backoff, lease recovery, redacted evidence,
manual recovery where required, and visibility for terminal failures.

## Legacy Asset Scan

Search the target project for possible runtime residue. Adapt patterns to the
source inventory rather than adding customer-specific paths to the skill.

```bash
rg -n "node-red|Node-RED|:1880|flows(_cred)?\\.json|NODE_RED|legacy.*proxy|clear-all-data" \
  --glob '!node_modules/**' \
  --glob '!dist/**' .
```

Classify each match as:

- `runtime dependency`: still required by production behavior;
- `deployment artifact`: obsolete runtime/deploy configuration to replace;
- `historical documentation`: retained but explicitly non-runnable;
- `intentional retirement record`: evidence explaining the cutover;
- `false positive`: unrelated text or generated output.

Do not delete a match solely because the scan found it.

## Retirement Gate

Set `node_red_retired` only when:

- all applicable cutover layers are complete;
- no production client, service, scheduler, worker, or integration depends on
  Node-RED;
- repository runtime and deployment assets are removed, replaced, or explicitly
  archived outside the active delivery path;
- historical state and rollback decisions are explicit;
- external Node-RED runtimes, endpoints, writers, schedules, and credentials are
  disabled by the responsible operator and evidenced separately;
- monitoring confirms the target behavior and no required traffic reaches the
  retired runtime.

## Acceptance Checklist

- [ ] Browser, CRUD, workflow, and integration cutover states are evidenced.
- [ ] App-owned UNS collections or another approved target are the only
      authoritative store for migrated durable data.
- [ ] Compatibility documents are not reported as normalized-domain completion.
- [ ] Compatibility endpoints have behavior/status/evidence rows in the matrix.
- [ ] Queued-only integrations are labeled incomplete.
- [ ] Historical state and rollback decisions are explicit.
- [ ] Destructive repository actions received explicit confirmation.
- [ ] External shutdown has a responsible owner and separate evidence.
- [ ] Parent skill HTTP, auth, persistence, build, runtime, and packaging checks
      pass.
