---
name: app-builder
description: "Use when the user asks to create, build, generate, implement, or substantially expand a runnable industrial-enterprise app, especially from specs/spec.md. Applies to internal tools, dashboards, CRUD workspaces, management platforms, WMS, MES, QMS, ERP, CRM, OA, inventory, warehouse, factory, approval, reporting, admin, and operations apps. Do not use for requirements-only drafting, small copy/field/style edits, UI-only debugging, backend-only fixes, SDK-only scripts, or pure research."
---

# App Builder

## Purpose

Turn `specs/spec.md`, the conversation, or the user's implementation request
into a runnable industrial-enterprise app. This is the V8 Builder profile:
shorter than V7, but stricter about the failure mode we observed: Builder must
not count hidden routes, backend plumbing, smoke-tested URLs, or final-report
route lists as delivered product capability.

## Core Principle

Deliver the first user-visible product slice, not a pile of files.

Preserve the model's freedom to design the app, but enforce these floors:

- Keep the user's domain language and default app language.
- Use the existing stack, components, routes, services, and design rules.
- Implement committed first-version capabilities as visible, operable product
  paths.
- Show realistic example records and lifecycle states.
- Connect visible actions to real state, services, APIs, or routes.
- Verify build and runtime page load before reporting completion.

## Work Modes

- **First Release Mode:** first-time app generation after SRS. Build a balanced
  first release: visible business breadth plus usable core workflow depth.
- **Delta Feature Mode:** substantial module or workflow expansion. Preserve
  existing behavior, update affected `specs/spec.md` lines, then implement.
- **Light Edit Mode:** copy, small field/table/style/validation tweaks. Do not
  run the heavy first-release flow; update SRS only if product meaning changes.

If first-time generation has no `specs/spec.md`, use `$app-srs` first and then
return here automatically unless clarification is required.

## Required Flow

1. Inspect the repo before creating files.
2. Read `specs/spec.md` first when present. It is the primary product source.
3. Identify stack conventions: routes, shell, components, data layer, package
   manager, checks, and preview workflow.
4. Classify the work mode.
5. **Before coding, create an FC Delivery Map.** This can be a short working
   checklist in the response or private notes, but it must drive implementation.
6. Implement product surface first: navigation, entry page, queues/lists,
   forms, row actions, and example records. Then implement data/API/service
   depth behind those visible paths.
7. Run available checks. For first release, typecheck/lint are not enough when
   preview or route smoke is available.
8. Report concrete user paths, checks, and any undelivered commitment at the
   top. Do not bury missing committed work in "next steps."

## FC Delivery Map

For First Release Mode, map every SRS section 2.3 First-Version Commitment:

| FC | Visible entry | Executable user path | Data/state proof | Done |
|---|---|---|---|---|

Rules:

- Every committed FC needs a visible entry from the primary app surface:
  sidebar, first-screen action, dashboard queue, row action, or obvious
  in-page module link.
- Hidden routes do not count. `/station`, `/review`, `/monitor`, modal-only
  paths, dashboard metrics, smoke-tested URLs, and final-report route lists are
  not delivery unless users can discover and start the work from the main app.
- For normal management, warehouse, inventory, approval, R&D, CRM, SRM, QMS,
  EAM, and operations apps, keep issue, dispatch, review, approval, exception,
  and alert queues in the workspace by default.
- Use `station` or `review` only when the user asked for a dedicated no-sidebar
  surface or the interaction truly needs it. If used for a committed FC, also
  expose a workspace entry that links to it.
- A KPI such as "pending approval: 1" is not an entry. Pair it with a queue,
  list, primary button, or row action.
- If an FC cannot be delivered in this run, say so before implementation or at
  the top of the completion report. Do not silently downgrade it to future work.

## Scope Balance

First release is neither a minimum demo nor the full long-term product. It
should feel about 70-80% complete from the user's first-run perception:

- Main business map visible.
- Core operating loop deep enough to execute.
- Supporting loops lighter but still usable.
- Explicitly requested capabilities shipped, not listed as future work.

For resource, inventory, order, task, asset, case, supplier, customer, project,
or similar operating objects, include the lifecycle users expect:

`intake/create -> current state -> downstream use/issue/dispatch/fulfillment or closure -> exception/alert/recommendation`

Receiving plus inventory listing is not enough when the request or SRS implies
issuing, consumption, allocation, dispatch, FIFO/FEFO use, approval, or
exception handling.

## Product Rules

- Do not downgrade a specific operational request into a generic dashboard.
- The first screen should look like the user's workbench: priority work,
  risks, exceptions, next actions, and real domain words.
- Every capability named in navigation, tabs, page titles, dashboard cards,
  primary actions, or row actions needs an executable user path.
- Committed capability: implement it. Speculative visible capability:
  implement it or remove it.
- Management apps need connected write paths when the workflow implies create,
  edit, receive, issue, approve, configure, publish, close, or resolve:
  button -> form/dialog/drawer/page -> validation -> mutation -> feedback.
- Recommended, automatic, optimized, rule-based, and bulk actions must show
  basis, affected records, quantities/statuses/dates/owners, and confirmation
  before mutation. Use scaffold action primitives when available.
- If a recommendation names an operation, the operation must be executable or
  the recommendation should be shown as informational, not a primary action.
- Example records are required product surface. They should cover lifecycle
  states declared in SRS data models. Placeholder/TODO copy is still banned.
- Preserve existing technology choices unless the user asks to change them.
- For Tier0 integration, use the installed SDK and scaffold helpers; do not
  hand-write platform clients or user credential pages unless requested.

## Capability Loops

When these concepts appear as committed capabilities or visible UI, make the
loop operable:

| Archetype | Minimum loop |
|---|---|
| Exception / deviation | reason form -> saved record -> status change -> history |
| Approval / review | submit -> approve/reject with reason -> status transition |
| Alert handling | acknowledge -> assign/escalate/resolve -> recorded note |
| Adjustment / correction | validated form -> before/after delta -> audit record |
| Hold / freeze / release | impact preview -> confirm -> status transition |
| Assignment / dispatch | select target -> preview work -> owner/status change |
| Resource use / fulfillment | select demand -> choose resource -> confirm use/issue/dispatch -> quantity/status change |
| Recommendation / automation | basis -> affected records -> adjust/confirm -> execution record |

Do not expose these words in product UI unless the loop works.

## UI Baseline

- Use `DESIGN.md`, existing tokens, and scaffold primitives as source of truth.
- `/` should land in the selected app experience, not a blank scaffold.
- Business apps default to modern enterprise hierarchy: layered surfaces,
  active navigation, semantic accents, selected/priority rows, and one dominant
  work surface. Severe MES/terminal styling is for station, monitor,
  safety-critical, or explicitly requested contexts.
- Each primary page needs one visual center.
- Do not make every card, table, filter, and panel equal white boxes.
- Use shared form, overlay, record-select, table, and action-transparency
  primitives when the scaffold provides them.
- Forms keep labels, required markers, controls, helper text, and errors in
  stable field groups.
- Dialogs/drawers keep header/footer fixed, body vertically scrollable, and no
  accidental horizontal scroll.
- Ordinary dialogs use one column on narrow widths and at most two columns on
  desktop. Line items stack or get an internal scroll viewport.
- Dense tables use internal table viewports or intentional responsive layouts;
  status/action cells stay readable and nowrap.
- Selects/dropdowns show enough metadata to choose the right record.
- Date-only fields use `type="date"`.
- Product copy uses one language unless bilingual output is explicitly asked.

## Scaffold And Verification

- For substantial work, scan `references/implementation-checklist.md`.
- Before finishing, scan `references/verification-checklist.md`.
- If preview startup, port reuse, or health checks fail, use
  `$preview-runtime-stability` when available.
- In this TanStack/Drizzle scaffold, normalize raw `db.execute()` /
  `tx.execute()` results with `rowsOf()` before `.map()`, `.filter()`,
  `.length`, or index access.

## Completion Gate

Before reporting completion, enumerate visible capabilities from navigation,
tabs, page titles, dashboard cards, primary actions, and row actions. Verify:

- Every FC in the Delivery Map has a visible primary entry and executable user
  path.
- Hidden routes do not count unless linked from the primary workspace.
- All visible links/actions resolve to implemented routes or intentional
  in-page behavior.
- Core lifecycle states and example records are visible.
- Required write/review/issue/approval/resolve paths mutate state and show
  feedback.
- Recommended or automatic actions expose impact before execution.
- No page shows "Page failed to load" or equivalent route-level runtime error.
- Forms, overlays, dense tables, and responsive layouts avoid clipping,
  overlap, accidental horizontal overflow, and broken status/action wrapping.
- Build, lint, tests, postbuild, and preview/route smoke have run when
  available, or the blocker is stated clearly.

Completion report must include:

- implemented app slice
- each committed FC with visible entry and user path
- checks run
- runtime/preview result
- any undelivered committed FC at the top, not as a casual future suggestion
