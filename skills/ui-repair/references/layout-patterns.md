# App Layout Patterns

Use this reference when choosing route groups, sidebar behavior, or device
posture for an app screen.

Layout is an interaction contract. Choose it by workflow, physical device,
environment, and navigation needs. Do not choose layout by user title alone;
the page frame should follow the actual work surface.

## Selection Questions

1. What is the primary job: navigate/manage, execute, decide, monitor, guide, or
   edit?
2. What device is used: desktop, tablet, PDA/handheld scanner, kiosk,
   wallboard, or large TV?
3. Does the workflow need persistent navigation, or should navigation be
   removed to reduce operator load?
4. Does the surface scroll, or must it fit a fixed viewport?

## Layout Matrix

| Layout | Route group | Use when | Navigation |
|---|---|---|---|
| Workspace | `_app.*` | planning, admin, analytics, master data, multi-module operations | Shell sidebar |
| Station | `station.*` | scan/tap/confirm, receiving, picking, reporting, point inspection | no sidebar |
| Review | `review.*` | queue + evidence + decision, approval, disposition, quality review | no sidebar by default |
| Monitor | `monitor.*` | passive wallboard, andon, live production TV, fixed operational display | no navigation, no page scroll |
| Custom | `<intent>.*` | wizard, dispatch, editor, portal, kiosk queue, canvas | minimal shell |

## Invariants

- Every authenticated layout exposes a visible logout action.
- One app keeps one app-level chrome. Do not mix Shell-sidebar pages with
  no-sidebar task pages inside the same app experience.
- Sidebar module links stay inside `_app.*` workspace routes.
- Station, review, monitor, and no-sidebar custom routes should not be placed
  in the workspace sidebar.
- Setup-only pages such as system configuration, role/permission setup, tenant
  settings, and audit settings belong under a parent item unless the whole app
  is a configuration console.
- Do not generate Tier0 SDK authentication, API key, token, OpenAPI host, MQTT
  host, workspace binding, or integration credential configuration pages unless
  the user explicitly asks for a credential administration console.
- A finished app must replace the scaffold blank route. If the app has one
  primary screen, `/` should own that screen directly.

## Device Notes

- PDA/handheld scanner is a Station-like industrial device profile, not just a
  mobile breakpoint. Design portrait-first at 360-480px, with one task path,
  visible scanner/manual input, larger operational text, and 44-48px controls.
- Station/kiosk pages emphasize the current task, scan/manual entry, exception
  handling, and one or two dominant actions.
- Review pages expose queue state, evidence, reason capture, decisions, and
  handoff status.
- Monitor pages are passive wallboard/TV surfaces. Use fixed composition,
  stable grid tracks, large readable labels, no forms, no drawers, no dense
  interaction, and no page-level scroll.

## Responsive Checklist

- Add `min-h-0` to flex children that should scroll.
- Add `min-w-0` to grid/flex children with long text or controls.
- Use `minmax(0, 1fr)` grid tracks instead of fixed widths where possible.
- Wrap header/toolbar actions into sensible rows.
- Use horizontal scroll only for intentional wide data tables, Gantt boards, or
  timelines, and isolate it inside the data viewport.
- Keep icon buttons at stable square sizes.
- Validate general interactive pages at 375px, 768px, and desktop widths.
- Validate PDA/scanner flows at 360-480px portrait.
- Validate monitor pages at their intended fixed viewport.
