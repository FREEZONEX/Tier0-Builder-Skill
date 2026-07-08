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
- Match visual tone to the use environment, not to industrial keywords alone.
  Production execution, station, andon, monitor, equipment terminal, and
  safety-critical screens may use heavier industrial treatment. EMS, WMS, QMS,
  CRM, inventory, approval, analytics, R&D, office, and management workspaces
  default to a modern enterprise software style: lighter surfaces, softer
  corners, clear hierarchy, and practical operational layouts.
- Every primary page must have a clear visual center. Do not make all panels,
  cards, filters, and tables share the same weight. Establish a focal working
  area through hierarchy, contrast, density, active state, or a dominant queue,
  table, chart, or decision panel.
- When the user says the page is too plain, too flat, too white, lacks focus,
  or has no visual center, treat it as a hierarchy repair task. Keep the
  existing app structure and business logic, but add clearer active states,
  layered surfaces, semantic accents, selected/priority rows, stronger section
  headers, or a dominant work area.
- Preserve the Tier0 theme tokens. The scaffold's `DESIGN.md` and
  `src/styles/globals.css` own color, radius, typography, and spacing. Tier0
  signal green remains the identity accent for active, selected, progress,
  optimistic, and highlight states; do not replace it with a new brand color.
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
2. Read `DESIGN.md`, the target route/component, and existing helpers before
   editing UI.
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
- Do not make dark, high-contrast, machine-terminal UI the default for every
  industrial-related app. Use it only when the workflow environment justifies
  it. Management and analysis apps should feel like modern software, not a
  factory terminal.
- Modern enterprise style must not become flat or empty. Use layered surfaces,
  stronger section headers, active navigation, semantic accents, dense but
  readable tables, and one dominant work area so the page has a readable path.
- Dark mode or dark panels are acceptable when the user asks for them, when the
  app is for monitors/stations, or when stronger readability/focus is needed.
  Keep contrast accessible, preserve Tier0 green as the identity accent, and
  avoid turning dark styling into the default for all management apps.
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
