# Industrial UI Patterns

Use this reference for MES, WMS, QMS, warehouse, factory, scheduling, quality,
equipment, traceability, and operational dashboard screens.

The goal is not to copy a component library. Create small app-local snippets
that fit the current domain, data shape, and workflow.

## Visual Tone Matrix

Choose tone by use environment, not by the word "industrial" or by an acronym
alone. Industrial-related business apps can still feel like modern software.

| Context | Default tone |
|---|---|
| EMS, WMS, QMS, CRM, inventory, planning, approval, analytics, reporting, master data, R&D warehouse | Modern enterprise workspace: light or soft-neutral canvas, rounded but controlled surfaces, clear tables, restrained cards, practical status color |
| Office approval, planning, reporting, master data | Modern management console: quiet navigation, readable density, low visual drama |
| MES shop-floor execution, station, scanner, kiosk | Task-first operational UI: larger controls, stronger state color, reduced navigation |
| Andon, monitor, line status wallboard, safety-critical alerts | High-contrast industrial display is acceptable; dark surfaces may help distance reading |
| Equipment/fleet maintenance or harsh factory terminal | Heavier industrial treatment is acceptable when the task context justifies it |

For EMS/WMS/QMS/CRM and similar management apps, do not default to black
backgrounds, orange hazard accents, terminal-like typography, or
military/mechanical styling. Use urgency only for real exceptions such as
expiry, quarantine, shortage, blocked stock, abnormal energy use, open quality
issues, overdue approvals, or high-risk customers.

Keep the Tier0 signal green identity across all visual tones. Use the scaffold
tokens, not new brand colors:

- `--tier0-highlight`
- `--tier0-highlight-bg-primary`
- `--tier0-highlight-bg-accent`
- `--tier0-highlight-text`
- Tailwind aliases such as `bg-highlight-bg-accent`,
  `border-highlight-bg-primary`, `text-highlight-text`, and
  `bg-button-highlight`

For modern enterprise workspaces, use green as active navigation, selected row,
progress, optimistic action, or focused highlight. Do not turn the whole page
green, and do not replace it with blue/orange/purple as the default brand
accent.

## Visual Center and Readability

A modern operational app still needs a strong reading path. Avoid "flat admin"
screens where the title, filters, KPI cards, empty panels, and tables all have
the same weight. Each primary page should make one work surface visually
dominant:

- Inventory and WMS pages: dominant inventory table, exception queue, risk
  band, or reservation/issue panel.
- Planning and approval pages: dominant queue, calendar, board, or decision
  split view.
- Quality and traceability pages: dominant evidence timeline, sample result
  table, genealogy graph, or disposition panel.
- Analytics pages: dominant chart or metric story with secondary drill-down
  tables.

Use supporting elements to lead into the focal surface:

- Put alert/risk banners above the main surface only when the issue changes
  priority or action.
- Let filters visually attach to the table/board they control.
- Use one primary action near the title or focal section, then secondary
  actions in the local panel.
- Give the focal section more width, richer header treatment, denser data, or
  stronger border/background contrast than supporting cards.
- Avoid leaving large blank framed areas in the first viewport. If data is
  sparse, show meaningful empty states, suggested next actions, or condensed
  explanatory metrics.

Dark industrial examples often feel more readable because they create clear
contrast between shell, alert, controls, and table. Recreate that hierarchy in
light themes with surface layering, semantic tint, section contrast, typography
scale, and spacing. Use dark mode or dark panels when requested, for
station/monitor contexts, or when the product needs stronger focus, but do not
make darkness the only way to achieve hierarchy.

## Pattern Map

| Need | Prefer |
|---|---|
| Dense operational counts | summary strip or compact KPI tiles |
| Individual metric emphasis | metric card with label, value, state, optional trend |
| Status display | icon + text status badge, not color alone |
| Audit, genealogy, approvals, exceptions | timeline |
| Queue grouped by state | kanban-style board or grouped list |
| Manufacturing route or stage progression | process flow |
| Short local task phase | step indicator |
| Actual-versus-target progress | target bar |
| Shift coverage or occupancy band | shift bar |
| Resource-by-time scheduling | Gantt-style board with internal horizontal scroll |
| Control limits and stability | SPC chart |
| Ranked defects, downtime, loss causes | Pareto chart |
| Equipment/workstation status | fleet grid |
| Matrix intensity by shift/resource/line | heatmap grid |
| Critical operational alert | alarm banner |

## Selection Rules

- Use a workbench for the first screen: current work, exceptions, risks, and
  next actions. Do not default to a generic KPI-only dashboard.
- Preserve the strong layout ideas from modern app builders: clear left or top
  navigation, a focused workbench, compact summary cards, actionable exception
  lists, readable tables, and obvious primary actions. Treat color and tone as
  variables; do not let a dark industrial palette be the only way to make the
  app feel operational.
- Prefer "one strong work surface plus supporting context" over several
  equally weighted white cards. A page should reveal what the user should read
  or act on first within three seconds.
- Use timeline when order over time is the point; use grouped columns when
  status grouping is the point.
- Use a Gantt board for many resources over time; use a shift bar for one
  continuous time band.
- Use summary strips for 4-8 small counts above a board/table; use metric cards
  when each KPI needs individual emphasis.
- Use SPC for stability against limits; use Pareto for ranked causes and
  cumulative share.
- Use alert banners only for issues that must be seen before deeper content.

## Visual Defaults

- Prefer compact enterprise surfaces: crisp borders, small radius, quiet
  panels, restrained shadows, and clear status color.
- For EMS/WMS/QMS/CRM/inventory/R&D/approval/analytics workspaces, prefer
  modern enterprise surfaces: light or soft-neutral backgrounds, white or
  lightly tinted cards, 6-8px radius, readable tables, subtle accents, and
  clear exception states.
- Strengthen light themes with tonal layers: app background, raised card,
  inset/filter band, focal data surface, and active/selected state should not
  all be pure white with identical borders.
- Preserve Tier0 green as the product accent even when the rest of the visual
  tone becomes more rounded, light, or modern.
- Reserve dark, rugged, high-contrast industrial styling for shop-floor,
  station, monitor, and safety-critical contexts, or when the user asks for it.
- Pair color with readable labels or icons.
- Avoid large decorative hero sections, blobs, glass effects, or marketing
  composition for operational tools.
- Adjacent KPI tiles should not all look identical when their states differ:
  use subtle semantic variety for active, healthy, warning, and blocker states.
- Charts need explicit height and decision value: units, thresholds, time range,
  legends, or annotations should be visible.
- Gantt/timeline/table horizontal width must scroll inside the board viewport,
  not the page or dialog shell.

## Adaptation Checklist

- Rename generic entities to domain names.
- Replace placeholder actions with real routes, mutations, or state changes.
- Surface event time, actor, state, and next action for traceability views.
- Keep browser-only chart, drag, and motion subtrees inside `ClientOnly`.
- Add loading, empty, error, pending, and success states where the workflow
  needs them.
- Use the selected product language consistently across labels, statuses,
  actions, tooltips, and empty/error text.
