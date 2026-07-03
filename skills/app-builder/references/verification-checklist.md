# Builder Verification Checklist

Use this checklist before reporting a generated app or substantial change as
complete.

## Product Verification

- The app's main workflow is reachable from `/` or the intended entry route.
- For first release work, the visible app covers the user's main business map:
  primary modules, key supporting modules, status surfaces, realistic records,
  and entry actions form a coherent product slice rather than one isolated
  happy path.
- The first release feels substantially complete to the user: the main
  business map is visible, core workflows are operable, supporting workflows
  are lighter but usable, and realistic records make the system feel alive.
- Required lifecycle coverage is present. When the app manages resources,
  inventory, orders, assets, tasks, cases, suppliers, customers, projects, or
  similar objects, the relevant intake/create, current-state, downstream
  use/issue/dispatch/fulfillment or closure, and exception/recommendation paths
  are visible and operable when requested or necessary for first-version
  coherence.
- Implementation produced visible product surface proportional to the time
  spent: routes, data, services, actions, example records, and verification all
  line up as a working app rather than a narrow demo plus hidden plumbing.
- The first screen reflects the user's domain and business, not a generic KPI
  dashboard.
- The first screen has one clear visual center. It is not an all-white,
  equal-weight set of cards, filters, and tables.
- Required actions are connected to real state, service logic, API handlers, or
  route navigation.
- Core workflows have enough depth to operate; supporting workflows may be
  simpler but remain usable and do not appear as dead tabs, fake actions, or
  future-promise copy.
- Recommended, automatic, optimized, or rule-based actions show what records,
  quantities, statuses, dates, owners, or assignments will change before the
  user confirms execution.
- Required create/edit flows have validation, pending, success, and error
  states.
- Placeholder copy, TODOs, dead screens, and disconnected buttons are removed.

## UI Verification

- Visible copy follows one product language unless bilingual output was
  explicitly requested.
- Business/management workspaces use visible hierarchy, layered surfaces,
  active navigation, semantic accents, and focal contrast. Shop-floor,
  station, monitor, and safety-critical pages may stay more severe or
  high-contrast when the context justifies it.
- Page shells, dialogs, drawers, and forms have no accidental horizontal
  overflow.
- Dialog bodies use vertical scroll, not page/dialog horizontal scroll, unless
  an explicit internal data viewport is intentionally wide.
- Labels, required markers, controls, helper text, and errors align as a stable
  field group.
- Form grids do not squeeze three intrinsic-width controls into a narrow
  overlay row; controls wrap or stack before clipping.
- Selects, comboboxes, and dropdown options do not hide critical identifiers,
  units, quantities, or statuses needed to make the choice.
- Text does not overlap controls, counters, cards, table cells, or footer
  actions.
- Tables, Gantt boards, and timelines use intentional internal scroll when
  wide; the page/dialog shell itself does not become the scroll surface.
- Dense business tables keep status badges, row actions, quantities, and dates
  readable. Long object names and identifiers wrap, clamp, or truncate
  intentionally inside their cells instead of forcing adjacent columns to break.
- Charts have explicit height and are not blank.
- Responsive behavior is checked at 375px, 768px, and desktop. PDA/scanner
  flows are also checked at 360-480px portrait.

## Code Verification

- Build output exists when a build was run.
- TypeScript, lint, tests, or project-specific checks pass when available.
- No unsafe HTML rendering, hardcoded secrets, or user-facing credential pages
  are added without an explicit requirement.
- Runtime effects avoid render-created request dependencies that can cause
  fetch loops.
- Raw SQL `db.execute()` / `tx.execute()` results are not treated as arrays
  directly; generated service code uses the scaffold normalizer before array
  operations.
- Repeated polling uses a shared/single-flight pattern when available.
- Event listeners, timers, and subscriptions have cleanup where needed.

## Reporting

Report:

- what app slice was implemented
- for first release work, how the main business map and core workflow depth are
  covered
- what checks were run
- what could not be verified, if anything
- whether the preview or entry route loaded successfully; do not report
  completion if the visible app still shows "Page failed to load" or an
  equivalent runtime error. In this scaffold, run
  `npm run smoke:routes -- <preview-url>` when a preview URL is available
- whether `specs/spec.md` was updated for durable follow-up product changes,
  or why no product-memory update was needed

If preview startup, port reuse, process cleanup, or health checks fail, use
`$preview-runtime-stability` when it is available.
