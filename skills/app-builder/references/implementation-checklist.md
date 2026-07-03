# Implementation Checklist

Use this only as a quick review aid for substantial app generation or module
expansion. Do not turn it into a long planning phase.

## Before Coding

- Identify the work mode: first release, delta feature, or light edit.
- Read `specs/spec.md` first when present.
- For first release, create the FC Delivery Map:

| FC | Visible entry | Executable user path | Data/state proof | Done |
|---|---|---|---|---|

- Treat each SRS First-Version Commitment as required delivery, not future
  work.
- For every FC, choose the primary app entry: sidebar, first-screen action,
  dashboard queue, row action, or visible in-page module link.
- Hidden `/station`, `/review`, `/monitor`, direct URLs, metrics-only cards,
  and final-report route lists do not count as delivery.
- Classify route intent. Normal management, warehouse, R&D, approval,
  inventory, CRM, SRM, QMS, EAM, and operations flows stay in workspace pages
  by default. Use station/review only when the user asked for no-sidebar work
  or the task truly needs it, and link it from the workspace if it fulfills an
  FC.
- Identify data models, statuses, validations, seed records, service actions,
  and API handlers needed to make visible paths real.
- Identify high-risk actions: recommended, automatic, optimized, rule-based,
  bulk, approval, exception, dispatch, issue, freeze, release, or adjustment.
  Plan impact preview/confirmation before mutation.

## Build Order

1. App identity, shell, navigation, and `/` experience.
2. Example records and lifecycle states.
3. Core data/service/API path behind the main workflow.
4. Visible forms, lists, queues, row actions, and dashboard links for every FC.
5. Supporting workflows with lighter but operable paths.
6. UI quality pass: visual center, table layout, overlay/form safety,
   responsive sanity, one product language.
7. Runtime and build verification.

For inventory/resource/order/task/asset/case/supplier/customer/project apps,
do not stop at intake/listing when the SRS or domain implies downstream use,
issue, dispatch, fulfillment, closure, approval, or exception handling.

## Scaffold Notes

- Use existing components and design tokens before inventing new patterns.
- Use form, overlay, record-select, table, and action-transparency primitives
  when the scaffold provides them.
- In the TanStack/Drizzle scaffold, normalize raw `db.execute()` /
  `tx.execute()` results with `rowsOf()` before array operations.
- Use the shared bootstrap helper for runtime table/index creation and seed
  data when available.
- For Tier0 integrations, use installed SDK/scaffold helpers. Do not add custom
  platform clients, credential pages, or `TIER0_*` placeholders unless the user
  explicitly asks for external debugging.

## Self-Review

- Every FC is visible from the primary app surface and has a user path.
- Every visible nav item, tab, card link, primary action, and row action works.
- Core workflow mutates state and shows feedback.
- Example data demonstrates declared statuses.
- Recommendations/actions show affected records before mutation.
- No hidden route is counted as delivered product capability.
- No required feature is placeholder copy, TODO, fake button, or disconnected
  view.
- Forms, overlays, dense tables, and responsive layouts do not clip, overlap,
  or create accidental horizontal page/dialog scroll.
- Durable product changes update only the affected SRS lines.
