# Node-RED Migration Mapping Workbook

Use this template to create a project-local migration map. Store the completed
map in the target project, not in this reusable skill.

## Output

Use a project-local path such as:

```text
docs/migration-analysis.md
```

## Source Inventory

| Source area | File, flow, or node group | Active | Responsibility | Notes |
|---|---|---:|---|---|
| Flow files | `<path>` | yes/no | `<api/workflow/integration>` | `<risk>` |
| Subflows | `<name>` | yes/no | `<shared behavior>` | `<callers>` |
| Context stores | `<flow/global/file>` | yes/no | `<state>` | `<retention>` |
| Custom nodes | `<package/type>` | yes/no | `<capability>` | `<replacement>` |
| Runtime config | `<path>` | yes/no | `<setting>` | `<target source>` |

Never copy credential values. Record only the credential category, owning node,
target secret source, and migration owner.

## Flow Responsibility Inventory

| Flow or node group | Trigger | Responsibility | Reads | Writes | Side effects | Target owner |
|---|---|---|---|---|---|---|
| `<name>` | `<http/timer/message>` | `<validation/CRUD/workflow>` | `<state>` | `<state>` | `<external/audit>` | `<service/worker/retired>` |

Trace connected error, catch, status, retry, and timeout branches. A function
node body alone may not describe the full behavior.

## API Compatibility Matrix

Use this matrix for every retained or replaced Node-RED HTTP endpoint, including
endpoints routed through a compatibility catch-all.

| Method and path | Request contract | Response contract | Errors | Auth | Side effects | Target owner | Status | Evidence |
|---|---|---|---|---|---|---|---|---|
| `<method path>` | `<params/body/headers>` | `<envelope/paging>` | `<codes>` | `<rule>` | `<writes/jobs/events>` | `<route/service>` | `<status>` | `<test>` |

Allowed implementation statuses:

- `implemented`: behavior and evidence are complete.
- `partial`: only part of the source behavior exists.
- `queued-only`: a durable job is created but execution is not complete.
- `not-started`: no target behavior exists.
- `retired`: the endpoint is intentionally unavailable and callers were removed.

## State And Persistence Mapping

| Source state | Target entity or aggregate | Target storage | Service owner | Persistence mode | Notes |
|---|---|---|---|---|---|
| `<context/table/file>` | `<entity>` | `<table/external>` | `<service>` | `<mode>` | `<identity/invariant>` |

Classify state as durable business data, workflow coordination, cache/derived
state, session/UI preference, fixture/mock data, or operational telemetry.

## Workflow And State-Transition Mapping

| Workflow | Trigger | From | To | Preconditions | Transactional writes | Side effects | Target owner |
|---|---|---|---|---|---|---|---|
| `<workflow>` | `<event>` | `<state>` | `<state>` | `<guards>` | `<writes>` | `<jobs/audit>` | `<service>` |

Record forbidden transitions, idempotency behavior, rollback/error branches, and
concurrency expectations.

## Schedule And Integration Mapping

| Source node/flow | Trigger or protocol | Destination | Retry/idempotency | Target executor | Status | Evidence |
|---|---|---|---|---|---|---|
| `<name>` | `<cron/MQTT/HTTP/...>` | `<system>` | `<rules>` | `<worker/platform/external>` | `<status>` | `<result>` |

Do not mark an integration complete when the target only inserts a pending job.

## Page And Caller Mapping

| Source caller or screen | Source endpoint | Target route/API | Cutover status | Evidence |
|---|---|---|---|---|
| `<caller>` | `<endpoint>` | `<target>` | `<status>` | `<browser/network/test>` |

Choose target layouts and routes through the current parent platform contract.
Do not invent role-based layouts or depend on an undeclared layout skill.

## Verification Matrix

| Capability | Source behavior | Target check | Evidence location |
|---|---|---|---|
| `<capability>` | `<what must stay true>` | `<HTTP/UI/worker check>` | `<project-local evidence>` |

At minimum verify browser cutover, real persistence, workflow transitions,
integration execution or queued-only status, failure behavior, and all parent
skill completion criteria.
