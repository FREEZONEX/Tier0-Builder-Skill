---
name: app-builder
description: >-
  Build a runnable industrial-enterprise app or substantially expand an existing
  app from user requirements or specs/spec.md. Use for implementation of business
  workflows and modules, not requirements-only work, ordinary copy or field edits,
  isolated UI repairs, or backend-only fixes.
---

# App Builder

Deliver the agreed business capabilities as visible, executable user paths.
Use the existing stack and preserve the user's domain language. Requirements
come from the user and `specs/spec.md`; platform details come from the target
scaffold's current instructions and implementation.

## Work Modes

- **First release:** if `specs/spec.md` is absent, use `$app-srs` and continue
  implementation unless the user requested requirements only or clarification
  is necessary. Deliver the bounded first-version commitments.
- **Substantial extension:** preserve existing behavior, update affected SRS
  sections, and implement the requested delta.
- Ordinary field, copy, or style edits do not need this workflow or a full
  delivery map. Update affected SRS sections only if business meaning changes.

## Delivery Map

For a first release, map every First-Version Commitment (FC). For a substantial
extension, map only the affected commitments. Keep this as a short working aid:

| FC | Visible entry | Executable user path | Data/state proof | Status |
| --- | --- | --- | --- | --- |

An entry must be discoverable from navigation, a work queue, a primary action,
or an intentional in-page link. A hidden route, standalone URL, or metric
without a path to the work does not fulfill a commitment. If a commitment
cannot be delivered, identify it explicitly; do not silently move it to future
work. Expose speculative capabilities only if implemented.

## Implementation

1. Read the SRS, target scaffold instructions, root `DESIGN.md`,
   `src/styles/globals.css`, and relevant existing routes, services, and
   primitives before implementing UI.
2. Establish the app shell, navigation, and primary business surface. Connect
   the core workflow through validation, service/API mutations, and feedback;
   supporting commitments can be smaller but must remain operable.
3. Use coherent example records across relevant lifecycle states when the
   target environment permits them. Do not substitute fixtures for real writes.
4. Give primary pages distinct purposes and information hierarchies. Share
   primitives and services; merge redundant top-level pages rather than making
   superficial title/filter variants of one full-page workspace.
5. Keep the delivery map current and verify using the single
   [delivery checklist](references/verification-checklist.md).

Use management workspace pages for ordinary business operations. A dedicated
station, review, or monitor surface is appropriate when the requested work
needs it; link any committed workflow from its intended primary experience.
Use [product patterns](references/product-patterns.md) for lifecycle examples
and category-specific density only when relevant to the SRS.

Recommended, automated, rule-based, and bulk actions show their basis and
impact and obtain confirmation before mutation. Use the scaffold's existing
action primitives. Preserve technology choices and use verified SDK/helpers
for Tier0 integration rather than inventing clients or credential screens.

## UI and Platform Boundaries

Use `DESIGN.md`, tokens, and shared form, overlay, table, and action primitives.
Preserve their colors, typography, radii, shadows, and base control appearance.
A request for a more modern, polished, or attractive UI stays within the current
system unless the user explicitly requests a design-system change. Layout,
grouping, proportions, density, and interactions remain workflow-specific;
composition freedom does not include restyling shared primitives. Use existing
variants for appearance and page-level classes for layout. Build missing
components from existing semantic tokens.

For list-type pages (master data, ledgers, documents, tasks, or searchable
record collections), default to the target scaffold's `MetaListPage` from
`@/components/kit/meta/meta-list-page`. Read `docs/component-kit.md` and the
component props; configure metadata and extend its business-action hooks instead
of rebuilding search, views, columns, sorting, and pagination. Wire an
application-scoped `ComponentKitProvider`, a real data adapter, and permissions;
logical resource paths and gallery fixtures are not implemented app services.
Enable only capabilities required by the workflow and backed by real services.
`DataGrid` / `DataTable` are lower-level display tables; `DetailTable` is for
editable line items, not the default list-page shell. An explicit user choice
or a concrete mismatch (chart-first report, Kanban/Gantt, scan-first station,
or embedded detail table) can justify another composition; record the reason.
If the target scaffold lacks this component, report the compatibility gap and
follow the authorized alignment scope rather than inventing the import.

Give each primary page a clear main work area through position, size,
typography, spacing, and density. Avoid meaningless equal-weight card grids;
plain sections and dividers can establish hierarchy. Use existing selected and
semantic states where meaningful; a visual center does not require a colored
panel or decorative effect.

These instructions guide generation, not additional UI acceptance gates.
Cosmetic deviations alone must not block delivery or trigger whole-page
regeneration; preserve usable work and keep any correction scoped.

Keep controls legible, field groups stable, and dense content within intentional
scroll regions. Follow the target scaffold's server/client and data boundaries:
declare collections in `src/data/collections.ts` and access records only from
services through `data` from `@/lib/data`.

Derive business roles from the SRS and register each across the target
scaffold's required surfaces in one pass. Do not assume a reserved admin role
or preview fallback. Verify each defined role's intended permissions and the
current empty-role behavior; preserve roleless scope when appropriate.

## Specialist Routing

- For QR/barcode scanning, photo capture, geolocation, audio recording, file
  reading, or clipboard access, read
  [browser-platform-capabilities](../browser-platform-capabilities/SKILL.md)
  before choosing the browser API.
- For an existing UI defect, use `$ui-repair` when available. Use
  `$responsive-craft` only for complex breakpoint, sticky/scroll, or dedicated
  multi-viewport work.
- For preview install, process, readiness, or HMR failures, use
  `$preview-runtime-stability` when available.

## Completion

Apply the delivery checklist once to the affected scope. Report the delivered
slice, visible paths, checks and roles verified, and preview/runtime evidence.
Put missing commitments or blockers first. A build or HTTP status alone does
not prove the interactive workflow works.
