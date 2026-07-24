# Builder Verification Checklist

Use this before reporting a generated app or substantial change as complete.

## Product

- `/` or the intended entry route opens the actual app experience.
- Every SRS First-Version Commitment has:
  - visible primary entry
  - executable user path
  - real service/API/state behavior
  - example record or visible status proof
- Hidden routes do not count unless linked from the primary workspace.
- The app covers the main business map, not one isolated happy path.
- Primary navigation pages have distinct page purpose, primary object view,
  information hierarchy, and primary action; they are not shallow variants of
  one reused full-page workspace.
- Core workflows are operable; supporting workflows may be lighter but usable.
- Lifecycle coverage is present for the domain object: intake/create, current
  state, downstream use/issue/dispatch/fulfillment or closure, and
  exception/alert/recommendation when requested or necessary.
- Required create/edit/receive/issue/approve/configure/resolve flows validate,
  mutate state, and show success/error feedback.
- Recommendations, automatic actions, rule-based actions, and bulk actions
  show basis and affected records before mutation.
- Example data covers the statuses users need to inspect.
- When the SRS carries a category archetype, the full confirmed module
  surface is in navigation and each module meets its SRS depth tier
  (core-flow operable end to end; master-data CRUD with seeds; supporting
  minimal but real).
- List/ledger pages meet the professional density baseline: search, status
  filter chips with live counts, status badges, remaining-days annotations on
  risk-carrying dates, and a risk banner when the data contains risk states.
- No committed capability is listed as "next step" or future work.

## UI

- One product language unless bilingual output was requested.
- For first release/rebrand, the final app name and icon are set in the app
  shell, and the icon points to the same PNG/JPEG file prepared for the
  platform project.
- Main pages have a clear visual center and enough hierarchy/accent to avoid a
  flat all-white admin surface.
- Business workspaces feel like modern enterprise software; station/monitor
  severity is reserved for task-first or safety-critical contexts.
- Forms keep labels, required marks, controls, helper text, and errors aligned.
- Dialogs/drawers have fixed header/footer, vertical body scroll, and no
  accidental horizontal scroll.
- Selects and dropdowns show enough metadata to pick the correct record.
- Dense tables use internal viewport/responsive layout; status/action cells
  remain readable.
- No overlapping text, clipped controls, broken status wrapping, or page-level
  horizontal overflow.

- Design-system primitives used where the scaffold provides them (buttons,
  status badges, page headers, filter chips, risk banner, empty states); no
  hand-styled primary buttons or ad hoc badge shapes.
- Entity lists are tables/compact rows, not sparse card grids; identifiers in
  mono; one language everywhere including eyebrows/kickers; the scaffold's
  locale constant is set so native date inputs localize.

## Code And Runtime

- TypeScript, lint, tests, build, and postbuild verification pass when
  available.
- Preview or route smoke confirms the entry route loads without "Page failed
  to load" or equivalent route-level runtime errors when a preview URL exists.
- Visible links/actions resolve to implemented routes or in-page behavior.
- Raw SQL results are normalized before array operations.
- No unsafe HTML, hardcoded secrets, user-facing platform credential pages, or
  unbounded client trust are introduced.
- Polling/timers/subscriptions use shared patterns or clean up correctly.

## App Identity

- `update_app_info` succeeded with the final `name`, `description`, and the
  same `icon_path` used by the generated app.
- A designed `cover_path` was included when available; otherwise the ready live
  preview was captured for the cover.
- The completion report does not infer platform synchronization from
  `APP_NAME` / `APP_ICON` source changes alone.
- Any unavailable or failed App Info tool call is listed as an undelivered item
  at the top instead of being deferred until the user notices.

## Roles

- Real business roles from the SRS are registered across every role surface
  the scaffold contract lists (permission matrix, role metadata, platform
  role mirror) in one pass.
- Template/demo/test roles are replaced, not shipped.
- The scaffold's built-in admin role keeps full access and reaches every FC.
- Walk the Delivery Map once per defined role: each business role reaches the
  workflows the SRS assigns to it; no role lands on an empty workspace unless
  the SRS says so.
- Permission differences appear as real effects (menu visibility, action
  availability, data scope), never as explanatory role copy in page bodies.

## Report

Report in this shape:

| FC | Visible entry | User path | Status |
|---|---|---|---|

Then list checks run and preview/runtime result. Put any undelivered committed
FC at the top as an explicit open decision, not in casual future suggestions.
Include the App Identity synchronization result.
