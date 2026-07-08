# WMS/MES Data Shape Inventory

Use this reference to document source data shape without copying raw business
records into the reusable skill.

## Public-Safe Rule

Record field names, types, relationships, enum values, and migration risks.
Do not store customer names, contract numbers, work order numbers, serial
numbers, addresses, operators, timestamps from real records, or raw JSON rows in
this skill.

If raw examples are required for implementation, keep them in the target
project's local docs or temporary analysis files.

## Entity Inventory Template

| Entity | Source key/table | Target table | Cardinality | State machine | Notes |
|--------|------------------|--------------|-------------|---------------|-------|
| `<entity>` | `<source-key>` | `<table_name>` | `<count/range>` | yes/no | `<risk>` |

## Field Shape Template

| Entity | Field | Inferred type | Required | Example class | Notes |
|--------|-------|---------------|----------|---------------|-------|
| `<entity>` | `id` | string | yes | source identifier | preserve if compatibility requires |
| `<entity>` | `status` | enum | yes | workflow state | enumerate allowed transitions |
| `<entity>` | `quantity` | number | conditional | measurement | validate units and bounds |
| `<entity>` | `createdAt` | timestamp | no | audit field | normalize to target convention |

Use "example class" rather than raw value. For example, write "source
identifier" or "workflow state", not the actual ID or state-bearing record.

## Relationship Template

| From entity | Field | To entity | Relationship | Migration rule |
|-------------|-------|-----------|--------------|----------------|
| `<child>` | `<foreign-key>` | `<parent>` | many-to-one | validate parent exists |

## State Machine Template

| Entity | From | To | Required actor | Side effects |
|--------|------|----|----------------|--------------|
| `<entity>` | `<state>` | `<state>` | `<role/action>` | `<audit/inventory/event>` |

For each state machine, identify:

- Allowed transitions.
- Forbidden regressions.
- Required reason fields.
- Quantity or quality gates.
- Side effects such as material movement, audit events, or downstream tasks.

## Temporary JSON Container Decision

Use a JSON container column only when it reduces initial migration risk for a
large legacy entity. Record:

- Why normalized columns are delayed.
- Which fields are required for filters, sorting, permissions, or joins.
- Which fields must be extracted in the next normalization step.

Do not use the JSON container decision to avoid modeling core invariants.
