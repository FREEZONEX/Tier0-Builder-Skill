# Document Fields and Actions

## Inspect capabilities first

Read the selected scaffold's `docs/component-kit.md` and actual component props.
ReferenceInput exists in the v7 baseline; `displayField`, `confirmText`,
`widget.stateManagement`, `LifecycleActions` and `src/lib/lifecycle` are additions
in scaffold PR #89, inspected at `c221b50e91308835fad97ffdad2ef05bd35f862c`.
That PR was OPEN on 2026-10-20. Recheck the chosen source; do not assume these
APIs exist because this Skill is installed. If absent, implement the same
business rules with the app's existing services/controls within authorized scope,
or use an explicitly selected compatible scaffold ref. Do not invent imports,
change the target to an unmerged branch automatically, or stamp a newer marker.

## Relation fields

Use the installed `ReferenceInput` for dialog-backed relations: one select-like
field with a search icon on the right, the whole non-clear area opening the
picker. Do not pair a read-only input with a separate “Reference …” button.
With supporting source, use `displayField="code"` for a code field and retain
`{ id, name, code }` in its selected snapshot. Preserve selection echo, cancel,
clear, disabled and keyboard behavior. Clear dependent fields together; clearing
must not open the picker. Genuine dropdown-search fields may use ReferenceSelect.
Wire the real ComponentKitProvider/data adapter; gallery fixtures are not services.

## Document lifecycle

Define the initial state and each action's source states, permission,
prerequisites, resulting state and business effects before implementing forms.
Do not invent approval stages merely because the object is a document.
Create sets the initial state on the server. Saving a draft does not submit it.
Show lifecycle state as a label in create/edit forms, not an editable dropdown.
State filters and ordinary user-controlled classifications remain selectable.

When supported, mark action-owned fields with `widget.stateManagement: "action"`
and calculated receipt/payment progress with `"derived"`; MetaForm protects
these fields even from custom renderers. Otherwise explicitly render read-only
state and omit it from form payloads. UI protection alone is insufficient.
Reject managed fields in ordinary create/update/import/bulk service inputs;
`assertNoManagedState` supports explicit field lists, not name-based inference.
Reject before a permissive parser strips unknown fields. Domain-approved data
migration is a separate authorized path, not a bypass in the normal edit API.

Requests identify an action, not a target state. Recheck fresh state, authenticated
actor permissions and prerequisites on the server. With supporting source use
`executeLifecycleAction`: its callbacks must use a real database transaction,
atomic ID/state/version conditional update with version increment, transactional
business writes and audit. It does not create the database adapter or routes.
Reject stale/repeated versions without repeating effects, including same-state
actions. Failures roll back state, effects and audit. External operations use a
transactional outbox; an app that needs replayed results must persist its own
unique idempotency key. Preserve the existing service/auth boundaries.

Receipt and settlement progress come from actual receipt/payment/reversal
records; do not replace those workflows with “mark fully settled.” Multiple
independent progress fields may coexist with a workflow state.

Use server-evaluated actions in detail, row and batch entry points. LifecycleActions
is an optional presentation helper when available, not an authorization boundary.
Omit unauthorized actions; disable unmet prerequisites with a useful reason.
The caller owns confirmation where needed, pending/errors and refresh after
success. Batch operations validate each record and state atomic vs per-record
results. Test direct state writes, invalid transitions, permissions, stale
versions, duplicate effects and rollback in the consuming application's actual
adapter, plus picker clear/cancel and state display. Helper unit tests do not
prove an application's database guarantees.
