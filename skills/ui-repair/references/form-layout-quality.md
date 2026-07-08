# Form And Overlay Layout Quality

Use this reference for forms, dialogs, drawers, required markers, date fields,
line-item editors, and any visible alignment or overflow problem.

## Hard Gate

A form or overlay is not acceptable if any of these are true:

- the dialog/page creates accidental horizontal scrolling
- inputs, selects, date fields, or buttons are clipped
- selected values or dropdown options hide critical identifiers, quantities,
  units, statuses, or locations needed to make a business choice
- labels, required markers, controls, helper text, and errors are misaligned
- required asterisks appear below the input or detached from the label
- text overlaps another control or is hidden behind a footer/action bar
- three intrinsic-width controls are squeezed into one narrow row
- footer buttons move into a horizontally scrolling body

## Field Group Pattern

- Treat each field as one group: label row, control, helper/error text.
- Put the required marker in the label row next to the label text.
- If the scaffold has `FieldLabel` / `RequiredMark`, use them. Otherwise create
  one small app-local label primitive instead of hand-writing bare red stars.
- Use `htmlFor` / `id` pairs where practical.
- Keep every grid/flex child that contains a control at `min-w-0`.
- Keep every input/select/textarea at `w-full` or an equivalent stable width.
- Let long labels wrap before they push controls out of the container.
- For selects and comboboxes, make the trigger and option content fit the
  available width. Use wrapping, intentional truncation with the most important
  identifier first, or a two-line option layout rather than clipping the value.

## Dialogs And Drawers

- Header and footer stay fixed in the overlay shell; only the body scrolls.
- Default overlay bodies use vertical scroll and `overflow-x-hidden`.
- Horizontal scroll is allowed only inside an explicit data table, Gantt,
  timeline, or other intentionally wide internal viewport.
- Normal dialog forms use one column on narrow containers and at most two
  columns in ordinary desktop dialogs.
- Use three columns only when the overlay is intentionally wide and each field
  has a stable minimum width.
- Do not place repeated line-item cards inside narrow three-column grids.
  Prefer stacked cards or a full-width editable table with intentional internal
  horizontal scroll.
- If a line item needs material/object, quantity, unit, location, status, or
  reason fields, stack the row into readable groups before allowing the dialog
  itself to scroll horizontally.

## Dates And Quantities

- Use `type="date"` for date-only fields.
- Use `datetime-local` only when the workflow truly needs time capture.
- Do not put multiple `datetime-local` fields side by side in compact dialogs.
- Keep quantity/unit pairs together when they are conceptually one value.
- Use consistent alignment for numeric inputs, units, validation, and totals.

## Responsive Checks

Check the actual overlay max width, not only the viewport:

- 375px mobile
- 768px tablet
- desktop
- 360-480px portrait for PDA/scanner flows

At each width verify:

- critical actions remain visible or reachable
- footer buttons do not cover validation or inputs
- labels and controls remain inside the dialog width
- long identifiers truncate or wrap intentionally
- the page or overlay does not acquire accidental horizontal scroll
