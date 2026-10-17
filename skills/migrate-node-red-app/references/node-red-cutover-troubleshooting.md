# Node-RED Cutover Troubleshooting

Use this reference for Node-RED-specific false completion signals. Use the parent
skill for scaffold/runtime migration failures and `preview-runtime-stability`
for managed preview installation, port, process, timeout, or HMR failures.

## Browser Cut Over But Node-RED Is Still Required

Check for server-side proxies, scheduled calls, WebSocket/MQTT clients, worker
callbacks, environment-based base URLs, and compatibility routes that still
forward to Node-RED. Browser network silence proves only browser cutover.

## CRUD Exists But Behavior Is Missing

Trace adjacent function/change/switch nodes, error branches, context writes,
multi-step database nodes, derived fields, and audit messages. A replacement
endpoint that performs one record write may omit the source's multi-step
atomicity or state machine; model it with `transact([...])` (atomic across
app collections) or a guarded `findOneAndUpdate` per transition.

## State Reappears Or Differs After Restart

Identify every Node-RED context store and its persistence configuration. Verify
that no flow/global/file context, source database, browser store, fixture, or
fallback path remains authoritative after target cutover.

## Compatibility Route Returns 200 But Is Partial

Compare method, path parameters, query/body/header parsing, response envelope,
pagination, status codes, authorization, side effects, and external execution
against the project-local API compatibility matrix. Route reachability is not
behavioral equivalence.

## Integration Jobs Stay Pending

Confirm that an executor exists, claims jobs safely, renews or recovers leases,
delivers to the external system, records acknowledgement, retries retryable
failures, and surfaces terminal failures. If not, keep the endpoint or workflow
status `queued-only`.

## Duplicate External Effects Appear

Check idempotency-key derivation, unique enforcement, claim/lease semantics,
retry behavior after timeouts, acknowledgement handling, and source/target
parallel operation. Do not rely on a UI-disabled button as idempotency control.

## Compatibility Document Storage Was Reported As Full Migration

Inspect whether relationships, uniqueness, indexes, concurrency checks, state
transitions, reporting fields, and multi-step write ordering are modeled outside
the JSON document. If not, keep `persistence_mode=compatibility_document` and record
the normalization plan.

## Node-RED Was Reported Retired Without Operations Evidence

Separate these facts:

- repository flows or dependencies were removed;
- no local process or port is visible;
- target application calls no Node-RED endpoint;
- an external runtime was disabled;
- external endpoints, writers, schedules, and credentials were revoked;
- monitoring shows no remaining traffic.

Only the responsible operator can evidence externally managed shutdown.

## A Flow Appears Unused

Before retirement, inspect link wires, subflow callers, link-call nodes, disabled
state, inject/timer triggers, external inbound endpoints, status/catch wiring,
and runtime logs. Unreachable from one UI route does not mean unused.
