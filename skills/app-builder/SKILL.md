---
name: app-builder
description: "Use when the user asks to create, build, generate, implement, or substantially expand a runnable industrial-enterprise app, especially from specs/spec.md. Applies to internal tools, dashboards, CRUD workspaces, management platforms, WMS, MES, QMS, ERP, CRM, OA, inventory, warehouse, factory, approval, reporting, admin, and operations apps. Do not use for requirements-only drafting, small copy/field/style edits, UI-only debugging, backend-only fixes, SDK-only scripts, or pure research."
---

# App Builder

## Purpose

Act as the lightweight Builder orchestrator. Turn the user's request, prior
conversation, or `specs/spec.md` into a runnable app while preserving product
intent, user language, and the existing project conventions.

This is the V6 Builder profile: preserve the stronger V4-style product
completeness, while retaining the runtime, table, form, action, and preview
guardrails added later. It includes the UI quality baseline needed for
generation, but it should not become a visual template, a generic CRUD recipe,
or a large implementation manual. Small follow-up edits should remain
lightweight and should update `specs/spec.md` only as product memory when the
business meaning changes.

## Core Principle

Product fit comes before scaffolding completeness.

The model should keep enough freedom to design the right application for the
current business. The hard constraints are only the constraints that protect
user experience and correctness:

- Preserve the user's business intent and domain language.
- Preserve the default app language from the conversation or explicit request.
- Do not ship broken layout, clipped controls, overflow, or misaligned forms.
- Do not flatten business apps into all-white, equal-weight admin screens.
- Connect visible actions to real routes, state, services, APIs, or mutations.
- Verify the generated app slice before reporting completion.

## Workflow

1. Inspect the current working directory before creating files.
2. Detect the existing stack, routes, components, data layer, package manager,
   and project conventions. Build on the project in front of you.
3. Check for `specs/spec.md`. If it exists, read it first and treat it as the
   primary implementation source.
4. If this is first-time app generation and no SRS exists, use
   `$app-srs` first. That skill should save `specs/spec.md`
   and return to this Builder flow automatically unless clarification is
   required.
5. Infer the default product language: explicit user language request wins,
   otherwise use the current conversation language, then the dominant language
   in the SRS or existing app.
6. Classify the work mode before planning:
   - First Release Mode: first-time generation after SRS; deliver a balanced
     first release with broad-enough business coverage and deep-enough core
     workflows.
   - Delta Feature Mode: substantial new module or core workflow expansion;
     preserve existing behavior, update the relevant SRS sections, then build
     the increment.
   - Light Edit Mode: small copy, field, table-column, validation, style, or
     localized behavior edits; do not run the heavy first-release flow. Apply
     the change directly and update `specs/spec.md` only when the business
     meaning should be remembered.
7. Plan three tracks before editing: product experience, domain data/API, and
   verification. For First Release Mode, build a delivery map from
   `specs/spec.md`: every First-Version Commitment (SRS section 2.3) -> visible
   surfaces -> required first-release depth -> lifecycle states/example data.
   Budget implementation around that map; commitments are the first-release
   delivery contract, not optional future work.
8. Apply the built-in UI baseline in this skill for first-version generation.
   Do not require a separate UI Skill during normal app generation.
9. If the app needs Tier0 UNS, Flow, OpenAPI, MQTT, MQ, or platform data
   integration, use `$tier0-sdk`.
10. For substantial implementation work, read
   `references/implementation-checklist.md` as a review checklist.
11. Before finishing, read `references/verification-checklist.md` and run the
    available checks or preview workflow. If preview startup, port reuse, or
    health checks fail, use `$preview-runtime-stability`.

## Delivery Discipline

- Keep planning proportional to the request, but do not trade away the user's
  expected business map to save implementation time.
- Prefer direct implementation after the necessary context is understood.
  Reread reference files when a concrete error, missing API, unfamiliar local
  pattern, or verification failure requires it.
- Build the first release as an integrated product slice: routes/navigation,
  core data/service/API, realistic records, primary write paths, supporting
  operational pages, lifecycle status surfaces, and verification all need to
  line up before reporting completion.
- Avoid unrelated scope, but do not omit requested or implied lifecycle stages.
  Resource, inventory, order, task, asset, case, supplier, customer, or project
  apps should not stop at intake/listing when downstream use, issue, dispatch,
  fulfillment, closure, or exception handling is part of the business meaning.

## Product Experience Rules

- Do not downgrade a specific operational request into a generic dashboard.
- The first screen should feel like the user's actual workbench: priority work,
  exceptions, risks, next actions, and domain language from the request or SRS.
- Build the main business map, then deepen the core loop. Do not collapse the
  first release into one narrow workflow when the user's request implies
  neighboring modules, states, or exception paths that make the app feel whole.
- For apps that manage resources, inventory, orders, assets, tasks, cases,
  suppliers, customers, projects, or similar operating objects, include the
  relevant lifecycle coverage in the first release: intake/create, current
  state management, downstream use/issue/dispatch/fulfillment or closure, and
  exception/alert/recommendation handling when requested or implied. For
  inventory/resource systems, receiving plus listing stock is not enough when
  the request also implies issuing, consumption, allocation, dispatch, or FIFO
  use.
- Build fewer meaningful workflows instead of many shallow modules when forced
  to choose, but do not use that rule to omit explicitly requested first-release
  capabilities.
- Management apps must not be delivered as read-only skeletons. If the
  requested workflow includes create, edit, delete, manage, receive, issue,
  publish, approve, configure, or similar actions, deliver at least one
  connected write path: command button -> form/dialog/drawer/page ->
  validation -> state/API mutation -> visible feedback.
- Recommended, automatic, optimized, or rule-based primary actions must not be
  opaque one-click buttons. Before mutation, show the affected records,
  quantities, statuses, dates, owners, or assignments and let the user confirm,
  adjust, or take an exception path when the workflow implies a material
  business change. Use the scaffold's action-transparency primitives when it
  provides them instead of building this flow by hand.
- If a recommendation suggests a concrete operation, the operation itself must
  be executable in the first release or the recommendation should not be shown
  as a primary capability. For example, a rule can recommend which record to
  issue, dispatch, release, assign, or close only when the user can inspect and
  execute that target operation.
- When adding navigation links, create and wire the matching route files in the
  same implementation slice. Do not expose sidebar, tab, card, or action links
  to routes that do not exist yet.
- Do not invent unrelated modules just to make the app look complete.
- Do not leave required actions as fake buttons, TODOs, placeholder cards, or
  disconnected views.
- Every capability named in navigation, tabs, page titles, dashboard cards,
  primary actions, or row actions must have an executable user path in the
  delivered version. For committed capabilities, implement the first-release
  path; removal is not an option. For uncommitted, speculative surface, either
  implement it or remove it from the visible UI. Exposing a capability the
  user cannot act on is a defect, not a preview.
- The first version must feel like a running business system, not an empty
  shell: example records cover the lifecycle states declared in the SRS data
  models, overview surfaces aggregate real module data, and primary lists open
  populated. Realistic example records are required product surface — the ban
  on placeholder copy does not ban them.
- Preserve existing technology choices unless the user explicitly asks to
  change them.
- For Tier0 platform integrations, use the installed `@tier0/sdk`; do not
  hand-write platform clients or user-facing credential pages for injected
  platform auth/connectivity unless explicitly requested.
- Do not duplicate the platform default Skills. Requirements belong to
  `$app-srs`, Tier0 integration belongs to `$tier0-sdk`,
  preview/runtime stability belongs to `$preview-runtime-stability`, and
  dedicated UI repair belongs to `$ui-repair`.

## Generation Scope

- First-time app generation implements a balanced first release, not a bare
  minimum demo and not the full future product implied by a long PRD.
- The SRS First-Version Commitments table is the delivery contract: every
  committed capability ships with enough breadth and depth to be usable in the
  delivered version. Never silently downgrade a committed capability to future
  work; if one genuinely cannot be delivered, state that explicitly at the top
  of the completion report as an open decision for the user.
- Balance breadth and depth. Cover the main user-perceived business map, deepen
  the core operating loop, and keep supporting loops lighter but operable.
  Avoid both extremes: many shallow pages with fake actions, or one deep
  workflow that leaves expected neighboring modules invisible.
- Lifecycle coverage is part of first-release breadth. When the domain object
  naturally moves from request/intake to current state to downstream use,
  fulfillment, dispatch, consumption, closure, or exception handling, represent
  that map with lightweight but operable paths before spending time on deep
  configuration detail.
- When `specs/spec.md` came from a detailed PRD, implement the primary product
  surface and core operating depth that represent roughly the first 70-80% of
  user-perceived completeness. This is not a PRD percentage or code-volume
  target. Leave lower-priority PRD details out unless they are necessary for
  that first version to make business sense.
- For small follow-up edits such as copy changes, one table column, minor
  styling, a small field adjustment, or a local validation tweak, do not use
  the heavy first-release flow unless the user is expanding core functionality.
  If the edit changes product meaning and `specs/spec.md` exists, update only
  the affected spec lines as product memory after or alongside the code change.

## Capability Archetypes

When a committed capability matches one of these archetypes, its first-release
path must include at least the listed loop: one entry point, one form, one
service action, one status change, one visible record. Core capabilities should
also include the adjacent list/detail/summary surface that lets users inspect
the result. These archetypes are
domain-neutral — apply them with the domain's own objects across MES, EMS,
QMS, EAM, SRM, CRM, WMS, ERP, project, order, supplier, service, compliance,
and reporting apps alike.

| Archetype | First-release path |
|---|---|
| Exception / deviation | entry point -> reason form -> saved record -> status change -> visible history |
| Approval / review | submit -> approve or reject with reason -> status transition -> record |
| Alert / event handling | acknowledge -> assign or escalate -> close with note, each recorded |
| Adjustment / correction | form -> validation -> audit record -> visible before/after delta |
| Hold / freeze / release | impact preview -> confirm -> status transition -> record |
| Assignment / dispatch | select target -> preview affected work -> confirm -> owner/status change |
| Resource use / fulfillment | select demand or target -> choose available resource -> confirm use/issue/dispatch -> quantity/status change -> record |
| Recommendation / automation | basis -> affected records -> confirm or adjust -> execute -> record |

Do not expose an archetype word in the UI (exception, approval, alert,
adjustment, hold, freeze, release, dispatch, recommended, automatic, or their
domain-language equivalents) unless its loop is operable. Each loop is cheap
to build with the scaffold's form, overlay, and action-transparency
primitives; the cost of implementing the loop is always lower than the trust
cost of a dead click.

## Built-In UI Baseline

Apply these rules during Builder generation:

- Use `DESIGN.md`, existing tokens, and scaffold layout primitives as the UI
  source of truth.
- Make `/` own the selected app experience. Do not leave the scaffold blank
  route or a generic home page in a finished first version.
- Pick the shell that matches the workflow: workspace, station, review,
  monitor, or a justified custom layout.
- Establish one visual center on each primary page: work queue, editable table,
  exception list, decision panel, chart, or current task card.
- Business operations apps such as WMS, QMS, CRM, inventory, approval,
  analytics, R&D warehouse, and management workspaces should feel like modern
  enterprise software, not a plain white scaffold or a severe MES terminal by
  default. Use layered surfaces, active navigation, semantic accents, focused
  section headers, selected/priority rows, and one dominant work surface.
- Reserve heavy industrial, dark, terminal-like, or highly restrained visual
  treatment for shop-floor execution, station, monitor, safety-critical, or
  equipment-terminal contexts, or when the user asks for it.
- Do not make every card, table, filter, and panel pure white with identical
  borders. The first viewport should make the next action or highest-priority
  operational surface obvious within a few seconds.
- Use Tier0 highlight green as an identity accent for active navigation,
  selected states, progress, optimistic actions, FIFO/recommended markers, and
  focal highlights. Pair it with neutral and semantic warning/error/success
  states instead of turning the page into a one-color theme.
- When the scaffold ships shared form-layout, record-selection, overlay, and
  action-transparency primitives, compose forms, business-object pickers, and
  risky actions from those primitives instead of hand-rolling equivalents; the
  scaffold's contract tests enforce the structural rules behind them.
- With or without such primitives, these outcomes are mandatory: labels,
  required markers, controls, helper text, and errors stay in stable field
  groups; dialogs and drawers keep header/footer fixed, scroll only the body,
  and never scroll horizontally (one column on narrow overlays, at most two in
  ordinary desktop dialogs, line-item editors stacked or given an internal
  scroll viewport); selects, dropdowns, and editable line items never clip the
  values users need to choose the correct record.
- Dense business tables use the scaffold's data-table primitives or an
  intentional internal horizontal viewport. Do not squeeze status pills,
  actions, IDs, quantities, locations, or dates into narrow columns that wrap
  into unreadable fragments. Status/action cells stay nowrap; long names and
  IDs wrap, clamp, or truncate intentionally inside their own cells.
- Date-only fields use `type="date"`; use `datetime-local` only when time is
  truly required.
- Visible UI actions must connect to real state, route navigation,
  API/service logic, or mutation feedback.
- Product copy uses one language unless bilingual output was explicitly
  requested.
- Do not render design-system notes, token explanations, TODOs, or
  implementation guidance as product UI copy.
- Keep responsive sanity at 375px, 768px, and desktop widths; avoid accidental
  horizontal overflow, clipped controls, and text overlap.

## Completion Gate

Before reporting completion, enumerate every capability named in navigation,
tabs, page titles, dashboard cards, primary actions, and row actions, and
verify each one against this gate:

- The main user workflow is reachable.
- The visible app covers the main business map implied by the SRS: primary
  modules, key supporting modules, status surfaces, and entry actions work
  together as a coherent first release rather than one isolated demo flow.
- The visible app covers the committed lifecycle stages implied by its primary
  operating objects. Resource, inventory, order, task, asset, case, supplier,
  customer, or project apps must not stop at intake/listing when downstream
  use, fulfillment, dispatch, closure, or exception handling is part of the
  user's requested workflow.
- Every First-Version Commitment from `specs/spec.md` has an operable
  first-release path. The completion report describes what the user can do now
  as concrete click-paths (e.g. "open queue -> pick record -> record exception
  with reason -> see status change and history"), and never lists a committed
  capability under next steps or future work. An undeliverable commitment is
  stated explicitly at the top of the report as an open decision, not buried.
- Example data demonstrates the lifecycle states declared in the SRS data
  models: primary lists, filters, status panels, and dashboards open populated
  and show real state variety.
- Required UI actions are connected to real behavior.
- At least one requested create/edit/delete/manage/receive/issue/publish/
  approve/configure workflow has a complete write path when the requested app
  is a management or operations workspace.
- Recommended or automatic actions expose what will change before executing;
  no primary action mutates hidden records without a visible preview,
  confirmation, or business-appropriate exception path.
- Raw SQL `db.execute()` / `tx.execute()` results are normalized before array
  operations. In the TanStack/Drizzle scaffold, use `rowsOf()` from the service
  layer before `.map()`, `.filter()`, `.length`, or index access.
- Every visible navigation item, sidebar link, tab, dashboard card link, and
  primary action target resolves to an implemented route or intentional
  in-page behavior; no exposed link lands on a 404.
- Visible copy follows one chosen app language unless bilingual output was
  explicitly requested.
- Each primary page has a clear visual center and is not an all-white,
  equal-weight collection of cards, filters, and tables.
- Business/management apps use enough hierarchy, accent, and surface layering
  to feel designed, while MES/station/monitor pages remain appropriately
  serious and task-first.
- Forms, dialogs, drawers, tables, and page shells do not have accidental
  horizontal overflow, clipped controls, overlapping text, or misaligned
  required markers.
- Dense tables have an intentional internal scroll viewport or responsive
  layout; status badges, row actions, and compact metrics do not wrap into
  broken fragments.
- Dialogs, drawers, select menus, and editable line-item controls show their
  critical content without clipping, unintended horizontal scroll, or squeezed
  multi-column layouts.
- Placeholder copy, unused TODOs, dead screens, and disconnected buttons are
  removed.
- Available build, lint, test, and preview checks have run, or the reason they
  could not run is stated clearly. Typecheck and lint are not enough for a
  first release: if a preview/runtime surface is available, restart it and
  confirm the entry page loads without "Page failed to load" or route-level
  runtime errors before reporting completion. In this scaffold, use
  `npm run smoke:routes -- <preview-url> [/optional-route ...]` when a preview
  URL is available.
- When a follow-up implementation changed durable product meaning and
  `specs/spec.md` exists, the affected SRS roles, user stories, commitments,
  data fields, workflows, UI flows, or validation rules were updated without
  rewriting unrelated sections.
