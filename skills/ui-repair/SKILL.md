---
name: ui-repair
description: "Use when debugging, repairing, or polishing frontend UI quality problems in generated apps: form misalignment, required marker issues, dialog/drawer overflow, accidental horizontal scroll, cramped serial form rows, select/dropdown clipping, responsive/mobile breakage, table or chart layout defects, flat all-white pages, weak visual center, visual hierarchy problems, clipped controls, text overlap, route shell inconsistency, or mixed product copy. Do not use for first-time app generation, requirements work, backend-only changes, small copy edits, or simple field changes unless the issue is UI quality."
---

# UI Repair

## Purpose

Repair production UI defects without importing a new component library. Use
the current app, `DESIGN.md`, existing route/component code, scaffold tokens,
and the scaffold's shared form/overlay/action primitives as the source of
truth, then make the smallest change that fixes the visible problem.

This skill protects UI quality after generation. It should not handle first-time
app builds, business requirement interpretation, ordinary copy edits, or simple
field additions unless the requested change is fundamentally a UI quality
problem.

## Non-Negotiables

- No broken layout: no accidental horizontal page/dialog overflow, clipped
  controls, text overlap, zero-height charts, or action bars covering content.
- Dialogs, drawers, selects, comboboxes, dropdowns, and editable line-item
  forms must show critical content without clipping, accidental horizontal
  scroll, or squeezed multi-column rows.
- Forms must align labels, required markers, controls, helper text, and errors
  inside one stable field group.
- Dialogs and drawers must keep header/footer stable and scroll only the body.
- Date-only fields use `type="date"`; use `datetime-local` only when time is
  truly required.
- The default product language follows the explicit user request, otherwise
  the current conversation language. Do not ship mixed Chinese/English UI
  unless the user explicitly asks for bilingual output.
- Read the current `DESIGN.md`, `src/styles/globals.css`, and relevant shared
  primitives before changing UI. Preserve their colors, typography, radii,
  shadows, and base control appearance. A request for a more modern, polished,
  or attractive UI stays within that system unless the user explicitly asks
  to change it.
- Match layout, density, and interaction size to the work environment using
  the current design system's supported treatments. Workspace, station,
  review, and monitor contexts do not by themselves authorize a new theme.
- Give each primary page a clear main work area through position, size,
  typography, spacing, and density. Avoid meaningless equal-weight card grids;
  plain sections and dividers can establish hierarchy without new colors.
- When the page feels too plain, flat, white, or unfocused, improve grouping,
  proportions, text hierarchy, and existing active/selected states first.
  Use semantic accents only for their defined meaning. A visual center does
  not require a colored panel, softer corners, or decorative effects.
- Composition freedom does not include restyling shared primitives. Use
  existing variants for appearance and page-level classes for layout; build
  missing components from existing semantic tokens. Preserve the current
  design system's identity accent rather than inventing a brand palette.
- Visible UI actions must connect to real state, route navigation, API/service
  logic, or mutation feedback.
- Do not run `npx shadcn`, add `components.json`, or copy a bundled
  `@/components/mes` or generic UI library into the app.
- Do not render design-system notes, color-token explanations, TODOs, or
  implementation guidance as product UI copy.

## Reference Routing

Read only the references needed for the current UI task:

- Forms, dialogs, drawers, required markers, date fields, line-item editors, or
  overflow issues: `references/form-layout-quality.md`.
- Choosing route/layout shells, sidebar vs no-sidebar, station/review/monitor,
  PDA, kiosk, or wallboard behavior: `references/layout-patterns.md`.
- Manufacturing, warehouse, MES, WMS, quality, scheduling, equipment, trace,
  alert, Gantt, SPC, Pareto, timeline, or operational dashboard patterns:
  `references/industrial-ui-patterns.md`.
- Product language, translation, copy consistency, or mixed Chinese/English UI:
  `references/i18n-copy.md`.
- Dedicated multi-breakpoint audits, complex sticky/scroll behavior, or a user
  request specifically about responsive testing: use `$responsive-craft` when
  available. Ordinary app layout sanity stays in this skill.

## Workflow

1. Identify the exact UI defect from the user report, screenshot, route, or
   visible page state.
2. Read the root `DESIGN.md`, `src/styles/globals.css`, the target
   route/component, and existing helpers before editing UI.
3. Classify the defect: form alignment, required marker, overflow, accidental
   horizontal scroll, select/dropdown clipping, cramped form rows,
   responsive, flat/all-white hierarchy, weak visual center, route shell,
   dialog/drawer, table/chart, or copy consistency.
4. Load only the matching reference from the Reference Routing section.
5. Fix the smallest owning component or route. Do not restyle unrelated pages,
   rebuild the app, or change business logic unless it directly causes the UI
   defect.
6. Preserve the app's existing product language and visual tone.
7. Check the affected UI at the relevant viewport widths. Use 375px, 768px, and
   desktop for general app pages; use 360-480px portrait for PDA/scanner flows.
8. Run available lint/build/preview checks, or state why they could not run.

These design instructions do not add UI acceptance gates. Cosmetic deviations
alone must not block delivery or trigger whole-page regeneration; preserve
usable work and keep the requested repair scoped.

## Practical UI Rules

- When the scaffold ships shared form/overlay/action primitives (field groups,
  form grids, line-item sections, record pickers, impact-preview actions),
  repair the defect by converting the broken markup to those primitives instead
  of patching hand-rolled label spans, ad hoc grids, or opaque action buttons.
- Keep components app-specific. Put reusable pieces under
  `src/components/<domain>/`; keep one-off pieces next to the owning route.
- Use `cn()` from `@/lib/utils` for conditional classes.
- Use `apiUrl()` from `@/lib/utils` for browser fetches to app APIs.
- Use `toast.success()` and `toast.error()` for mutation feedback when `sonner`
  is available.
- Use `ClientOnly` around Recharts, dnd-kit, motion layout features, and other
  browser-only render paths.
- Use lucide-react icons for recognizable actions and statuses. Icon-only
  buttons need accessible `aria-label` or `title`.
- Use existing Tier0 CSS variables and Tailwind aliases such as
  `bg-highlight-bg-accent`, `border-highlight-bg-primary`,
  `text-highlight-text`, `bg-button-highlight`, `bg-button-primary`,
  `border-border`, `bg-card`, and `bg-surface-inset`. Do not hardcode new
  brand hex values or fork the palette locally.
- Prefer compact enterprise controls for workspace pages, larger 44-48px
  controls for station, kiosk, PDA, and scan/tap flows.
- Establish modern enterprise hierarchy through a dominant work area,
  readable tables, grouping, and the current system's typography and surface
  styles. Do not introduce dark mode or dark panels merely to add focus;
  use them only where the current design specification supports them or the
  user explicitly requests a design-system change.
- Page title rows contain title, short description/breadcrumb/status text, and
  compact actions only. Put KPI cards, filters, charts, boards, tables, forms,
  and detail panels in sections below.
- Empty states should provide the next meaningful action, not describe future
  functionality.

## TanStack Start Notes

- This is not Next.js. Use `@tanstack/react-router` `Link`, `useNavigate`,
  `Route.useParams()`, and `Route.useSearch()`.
- Pages SSR by default. Guard browser-only code with `useEffect` or
  `ClientOnly`.
- Do not import `next/*`, use App Router conventions, or add `"use client"` as
  a boundary mechanism.
