# Process Consulting Lens

Use this reference before drafting or revising `specs/spec.md`. It is a
domain-neutral thinking aid within industrial-enterprise software, not a
document section. Apply only the checkpoints that fit the user's requested
scope.

The platform serves industrial companies. Do not reduce that to only shop-floor
or warehouse scenarios: WMS, SRM, CRM, ERP, MES, QMS, EAM, project, order,
supplier, customer, service, resource, compliance, and reporting workflows can
all be industrial-enterprise apps when they support industrial operations.
Avoid defaulting to consumer, restaurant, lifestyle, social, or generic retail
assumptions unless the user explicitly asks for them.

## Core Loop

For each primary workflow, infer the smallest closed loop that would make the
first version useful:

1. Trigger: what event, request, schedule, condition, or user action starts it.
2. Actor: who is responsible for the action and who can review or override it.
3. Input: what information, object, file, quantity, date, status, or reference
   is required.
4. Checkpoint: what must be validated before the workflow can continue.
5. State change: what object changes status, owner, amount, priority, stage, or
   availability.
6. Record: what audit, history, comment, reason, result, or generated document
   must remain visible later.
7. Output: what the system produces for the actor or next process.
8. Downstream effect: what later workflow, report, task, notification, or risk
   calculation depends on the result.
9. Exception: what happens when data is missing, duplicate, out of range,
   late, blocked, rejected, or not permitted.

Do not force every workflow to include every item. Use this loop to prevent
shallow "click button -> done" requirements.

## Action Transparency

Recommended, automatic, optimized, or rule-based actions must be explainable
before they execute. If the system suggests or performs an action based on a
rule, the SRS should specify the visible basis and affected objects:

- what rule or priority produced the recommendation
- which records, batches, orders, tasks, resources, customers, suppliers, or
  other domain objects will be changed
- what quantities, dates, statuses, owners, or assignments will change
- whether the user confirms the recommendation, edits it, or requests an
  exception path
- what record remains after execution, including actor, time, reason, and
  before/after result when relevant

Do not specify opaque primary actions such as "process automatically" or "use
recommended result" when the user cannot see what will be processed. Prefer
"show recommendation details -> confirm or adjust -> execute -> record result".

## Checkpoint Types

Consider these checkpoint categories across industrial-enterprise functions:

| Type | Questions |
|---|---|
| Identity and permission | Who can start, edit, approve, cancel, or override? |
| Object existence | Does the referenced customer, order, asset, case, item, task, contract, or record exist and remain active? |
| Completeness | Which fields, attachments, reasons, quantities, dates, or selections are required before submission? |
| Amount and capacity | Are quantities, budgets, limits, balances, capacity, workload, or thresholds sufficient? |
| Time | Are due dates, effective dates, expiration dates, schedules, service windows, or cutoffs valid? |
| Status | Is the target object in a state that allows this action? |
| Duplicate and conflict | Could this create a duplicate request, double allocation, conflicting booking, or repeated approval? |
| Quality and compliance | Is review, evidence, acceptance, rejection, exception reason, or compliance capture required? |
| Handoff | What queue, owner, next task, notification, or downstream workflow receives the result? |
| Traceability | What actor, timestamp, reason, before/after value, and source should remain auditable? |
| Recommendation transparency | If the system recommends or automates an action, can the actor inspect what will change before confirming? |

## Balanced First Release

- Shape the first version as a balanced product slice, not a minimum demo.
  It should cover the main business map the user expects to see while keeping
  implementation depth proportional to importance.
- Map the lifecycle of the primary operating objects before choosing screens.
  For resources, inventory, orders, assets, tasks, cases, suppliers, customers,
  projects, or similar objects, ask whether the first release needs upstream
  intake/create, current-state control, downstream use/issue/dispatch/
  fulfillment or closure, and exception/alert/recommendation handling.
- Do not stop at "create/list/manage" if the user's request implies that the
  object is later consumed, issued, dispatched, fulfilled, closed, reviewed, or
  handled by exception. The downstream operation can be lightweight, but it
  should be operable when it is part of the product's business meaning.
- Deepen the core operating loop: the most important workflow should include
  create/update, validation, status change, realistic records, and visible
  feedback or history.
- Keep supporting workflows lighter but usable: they may have simpler forms,
  fewer filters, or basic state transitions, but they must not be dead pages,
  fake tabs, or future-promise copy.
- The commitments table (SRS section 2.3) is the first-release delivery
  contract: nothing in it may be silently dropped or deferred by later
  implementation steps.
- Do not maximize breadth by creating many shallow modules, and do not maximize
  depth by building one isolated workflow while omitting the user's expected
  neighboring modules. Choose the smallest broad-enough map that feels like a
  working first product.
- Do not add unrelated enterprise capabilities because a domain usually has
  them.
- Do not add lifecycle stages that the user did not request and the domain
  does not need for first-version coherence. Lifecycle coverage is a floor for
  implied business closure, not a license to build a full suite.
- Convert long PRDs into a balanced first-release operating slice: implement
  the primary user-perceived surface and core operating depth, while leaving
  lower-priority details out unless they affect boundaries, data shape, or
  validation.
- If the user's wording implies a real-world rule but not enough detail, choose
  a conservative generic rule and write it as a configurable or reviewable
  checkpoint only when that does not distort the business meaning.

## Writing Rules

- Use the user's industrial-enterprise domain nouns and verbs.
- Write checkpoints as business rules, not implementation details.
- Make status transitions explicit when they affect what users can do next.
- Include exception behavior where failure would otherwise become ambiguous.
- Keep assumptions out of separate sections; fold necessary assumptions into
  workflow logic, validation rules, or UI behavior.
