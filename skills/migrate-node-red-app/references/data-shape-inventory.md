# Node-RED Data Shape Inventory

Use this reference when Node-RED context, files, database nodes, messages, or
payloads carry authoritative application state. Record structure and behavior,
not private records.

## Public-Safe Rule

Record field names, types, relationships, enum/state values, invariants, and
migration risks. Do not store raw business rows, customer identifiers, payload
captures, credentials, or production IDs in the reusable skill.

## Persistence Mode

Declare one mode for every migrated durable entity or aggregate:

```text
persistence_mode = compatibility_document | normalized_domain
```

- `compatibility_document`: an app-owned UNS collection is authoritative, but
  important fields, relationships, constraints, indexes, and state invariants
  may still be hidden inside a loosely typed JSON document.
- `normalized_domain`: required fields (`recordSchema`), relationships (id
  references), indexes (unique indexes for natural keys), and state
  invariants (atomic `findOneAndUpdate` transitions guarded by the current
  state) are represented and enforced in the target model.

Do not use `compatibility_document` to claim that domain normalization or workflow
migration is complete. Record an extraction plan for fields needed by joins,
filters, sorting, uniqueness, permissions, concurrency, or reporting.

## Entity Inventory

| Entity or aggregate | Source store/key | Target owner | Target storage | Persistence mode | Notes |
|---|---|---|---|---|---|
| `<entity>` | `<context/table/file>` | `<service>` | `<table/external>` | `<mode>` | `<risk>` |

## Field Shape

| Entity | Field | Type | Required | Semantic class | Constraints/notes |
|---|---|---|---:|---|---|
| `<entity>` | `id` | string | yes | identifier | `<identity rule>` |
| `<entity>` | `status` | enum | conditional | lifecycle state | `<allowed values>` |
| `<entity>` | `<field>` | `<type>` | yes/no | `<quantity/time/ref>` | `<bounds>` |

Use semantic classes rather than real example values.

## Relationship Inventory

| From | Field | To | Cardinality | Required | Migration rule |
|---|---|---|---|---:|---|
| `<child>` | `<foreign key>` | `<parent>` | many-to-one | yes/no | `<validation>` |

## State Machine

| Entity/workflow | From | To | Preconditions | Actor/source | Side effects |
|---|---|---|---|---|---|
| `<name>` | `<state>` | `<state>` | `<guards>` | `<role/event>` | `<writes/jobs/audit>` |

Capture allowed transitions, forbidden regressions, idempotency, concurrency,
reason fields, quantity/quality gates, and rollback/error behavior.

## Integration Job Shape

When the target uses an integration-job collection, verify that its model can
support:

- stable identity and an idempotency key;
- operation kind and destination;
- pending, claimed/running, succeeded, retryable-failure, and terminal-failure
  states;
- retry scheduling and attempt counts;
- lease/lock ownership and expiry (UNS leases: `lock({ filter, sort, limit, ttlMs })`
  claims work items without duplicates, `lockToken` + `release` on completion);
- request, response, and error evidence with appropriate redaction;
- creation and update timestamps.

These are capability requirements, not a mandatory universal collection schema. A
platform queue or external executor may represent them differently.
