# Align Reference Fields and Document Lifecycle

Apply only to requested alignment surfaces and their necessary dependencies.
Inspect the selected scaffold source first, following latest-template-source.md;
its PR #89 capability snapshot is not the default main target. Inspect app
callers, form metadata, create/update/import/bulk writers, actions and audit.

## Reference fields

Reuse the selected scaffold's ReferenceInput: one select-like trigger, persistent
right-hand search icon and whole-field activation. Preserve relation IDs,
name/code snapshots, query conditions, selection mode, cancel, clear and dependent
field fill rules. When the inspected implementation supports them, use
`displayField="code"` for code fields and `confirmText` for the confirmation label.
Do not blindly replace genuine dropdown-search controls. Test disabled/keyboard
behavior and clearing without opening the dialog against the real app adapter.

## Lifecycle fields

Classify each field as action-owned workflow state, business-derived progress,
or ordinary user-controlled classification. Do not infer this from a `status`
name or migrate all enum fields. Keep list filters selectable. On compatible
source mark workflow state `widget.stateManagement: "action"` and calculated
progress `"derived"`; inspect MetaForm, form-model and types together. Preserve
existing values/history and server-defined initial states; remove managed fields
from normal client save payloads and reject their direct writes at all ordinary
service entry points. Retain an explicitly authorized migration/import path only
when it follows the agreed business/data migration policy.

Map existing business actions to the selected scaffold's lifecycle definitions
and `executeLifecycleAction` when available. Preserve valid transitions and role
semantics; do not introduce approval stages, reset historical statuses, fabricate
audit history or equate “paid” with “approved.” Derive receipt/settlement progress
from real business records. If a legacy manual status selector encodes an unclear
workflow, present its concrete mapping/behavior decision and continue independent
alignment; do not silently reinterpret it.

The execution helper requires real transaction/load/authorize/validate/
compareAndSet/apply/audit adapters. Use atomic ID/state/version updates, increment
version, roll back all database effects on failure and use an outbox for external
effects. Frontend action availability is advisory; recheck on every server call.
Wire confirmation, pending/errors and record/action refresh in UI callers.
Preserve batch semantics and test each affected entry point.

Verify direct-state-write rejection, illegal transitions, unauthorized actions,
stale/repeated versions and transactional rollback in the app's actual adapter.
A copied helper or its in-memory tests do not prove database behavior. If the
selected target lacks these APIs, keep compatible existing behavior or report
which authorized dependency update is needed; never fabricate imports or claim
full alignment. Copy the target marker only under the entrypoint's completion
rules, and report the exact source SHA even when markers are identical.
