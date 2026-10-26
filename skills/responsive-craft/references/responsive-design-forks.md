# Responsive Design Forks

Patterns with multiple responsive presentations. Apply an explicit user choice first. In Adaptive mode, when the task clearly supports an approach, state the decision and proceed. Present options and ask only when a material tradeoff remains unresolved; preserve requested Guided review.

---

## How to Use This Reference

When auditing existing code or planning new responsive layouts, scan for the patterns below. Each fork includes:
- **The desktop pattern** — what exists or is planned
- **Mobile options** — 2-3 approaches with tradeoffs
- **The question to ask** — what the user needs to decide
- **Signals** — what in the codebase hints at which option is best

---

## Fork 1: Sidebar with Mixed Content

**Desktop pattern:** Sidebar with navigation + filters + summary/stats + secondary actions.

### Option A: Bottom Sheet Drawer
- Content stays grouped in a single drawer
- Triggered by a hamburger/menu button
- Good when sidebar content is secondary and rarely accessed
- **Tradeoff:** Hidden by default — users may not discover it

### Option B: Tab Bar with Sections
- Each sidebar section becomes a tab or bottom nav item
- Content is accessible simultaneously without opening a drawer
- Good when sidebar sections are equally important
- **Tradeoff:** Takes permanent screen space; limited to 3-5 sections

### Option C: Collapsible Accordion Inline
- Sidebar content collapses into an accordion above or below main content
- Everything is visible in the page flow
- Good when sidebar content is a reference that users scan
- **Tradeoff:** Lengthens the page; may push main content too far down

### The Question
> "This sidebar has [N] distinct content types: [list them]. On mobile, do you want them (a) hidden in a drawer and opened on demand, (b) accessible as permanent tabs, or (c) collapsed inline above the main content?"

### Signals
- If sidebar has 5+ sections → drawer is likely best (too many for tabs)
- If sidebar has navigation → tabs or bottom nav
- If sidebar has filters → floating action button that opens a filter sheet
- If sidebar has stats/summary → inline above main content

---

## Fork 2: Record Lists and Data Tables

**Desktop pattern:** Records shown in a table, with or without row actions. Inspect the mobile task regardless of column count, even when horizontal scrolling and sticky columns already work correctly.

### Choose by task

| Primary mobile task | Preferred presentation | Tradeoff |
|---------------------|------------------------|----------|
| Find one record, read its context, approve/edit/process it | Card list | More vertical space; weaker cross-record column comparison |
| Compare values across records, inspect a matrix, or edit spreadsheet-like data | Table with a contained horizontal scroll region | Requires horizontal navigation; preserve row identity and clear scroll affordance |
| Scan a few comparable fields, occasionally inspect other fields | Priority columns with explicit details access | Secondary fields take another action to reach |

An operator role or a narrow width alone does not require cards. Use the actual task, existing behavior, and user preference. When the user asks for cards, implement that choice without reopening the fork. When the task is unclear, ask whether users primarily process individual records or compare values across records.

### Design the card, not a vertical dump of every cell

- Put the record's primary identifier/title first, keeping its detail link. Show relevant status alongside it when the data provides one; do not invent a status from a disabled action.
- Choose the few labeled fields needed to recognize and act on the record. Preserve full identifiers through wrapping or an accessible detail path. Keep secondary fields reachable in details/expansion rather than silently dropping them.
- Place the main permitted row action in a clear action area. Keep secondary actions accessible, with the same permission, disabled-state, confirmation, and pending-state rules as the table. Avoid a fixed action column consuming the mobile card width.
- Preserve selection when supported: a labeled checkbox per record, selected count, select-all scope, and existing bulk actions. Tapping an action or checkbox must not accidentally open the record.
- Keep existing search, filters, reset, sort, pagination/load-more, refresh, create, and export capabilities reachable. Table-header sorting needs an equivalent control when the header is absent. Adapt crowded toolbars only within the requested scope; show active filter state when filters collapse.

**Example — equipment archive processing:** At phone width, render each archive as a card headed by its document number/link, followed by labeled equipment code and location when available, then approval/edit actions using existing availability rules. Keep selection and bulk controls. At a wider width that supports readable columns and actions, retain the desktop table. Operators should be able to identify and process a record without sideways scrolling. A working horizontal table alone does not satisfy this task.

### Implementation contract

Use the project's existing card/list or responsive collection component when available. Cards and table are two presentations of the same records, query, selected IDs, and action handlers—not independent workflows or data fetches. Preserve filters, sort, pagination, selection, and action results across resizing or rotation; retain existing rules for selection when the query changes.

Choose the switch from available content width and readable fields/actions, using existing design-system breakpoints where suitable. Do not blindly convert every table below a fixed phone breakpoint. Scope styles to the affected collection, not global `table`, `tr`, or `td` selectors.

Use semantic list items with real headings and field labels (for example, `dl`/`dt`/`dd`) for cards and retain table/header semantics on desktop. Do not rely solely on CSS-generated `data-label` text for accessible labels. If both presentations exist in the DOM, expose only the active one to focus and assistive technology, avoid duplicate IDs, and do not trigger duplicate requests or actions. Keep keyboard focus usable when switching presentations.

For comparison tables that remain scrollable, use the dual-axis sticky patterns in `sticky-scroll-patterns.md`. For both choices, verify task completion and state continuity using the record-list checks in `testing-checklist.md`.

---

## Fork 3: Multi-Panel Dashboard

**Desktop pattern:** Header + sidebar nav + main content area + optional detail panel. Multiple information-dense regions visible simultaneously.

### Option A: Tab-Based Single View
- Each panel becomes a tab or screen
- Cleanest mobile experience; one thing at a time
- Good for dashboards where users work in one section at a time
- **Tradeoff:** Loses the at-a-glance overview that makes dashboards valuable

### Option B: Stacked with Anchored Navigation
- Panels stack vertically; sticky anchor nav at top for jumping between sections
- Everything is in the page flow, accessible by scrolling
- Good when all panels need to be scannable in sequence
- **Tradeoff:** Very long page; context switching requires scrolling

### Option C: Collapsible Regions + Scroll
- Each panel collapses to a summary/header with expand capability
- Shows overview of all panels; user expands what they need
- Good when the summary is useful without the detail
- **Tradeoff:** Requires designing meaningful collapsed states

### The Question
> "This dashboard has [N] panels visible simultaneously on desktop. How much information density matters on mobile? (a) One panel at a time (tabs), (b) all panels stacked and scannable, or (c) collapsed summaries that expand on demand?"

### Signals
- If dashboard is monitoring/status → collapsed summaries (C) — users scan for anomalies
- If dashboard is workflow → tabs (A) — users focus on one task
- If panels have sequential relationships → stacked (B)

---

## Fork 4: Hero with Complex Visual Content

**Desktop pattern:** Large hero with background video/image, overlay text, CTA, secondary elements (stats, testimonials, animated graphics).

### Option A: Simplified Adaptation
- Keep the same structure but simplify: static image replaces video, stacked layout, smaller text
- Good when the hero's message works at any size
- **Tradeoff:** May feel like a "shrunk desktop" — not designed for mobile

### Option B: Different Mobile Hero
- Completely different mobile hero designed for the mobile context
- Smaller, faster, thumb-friendly
- Good when the desktop hero relies on visual impact that doesn't scale down
- **Tradeoff:** Two things to maintain; content can drift out of sync

### Option C: Progressive Disclosure
- Mobile shows headline + CTA only; stats/testimonials/video are below the fold or behind a "learn more" interaction
- Good when the CTA is the primary goal and surrounding content is supporting
- **Tradeoff:** Supporting content may never be seen

### The Question
> "The desktop hero relies on [visual element] for impact that won't translate to 375px. Do you want to (a) adapt it (simpler version, same structure), (b) design a different mobile hero, or (c) reduce to headline + CTA with the rest below the fold?"

### Signals
- If hero has background video → Option A with static image fallback, or C
- If hero has complex animations/graphics → Option B (they'll be janky on mobile)
- If the CTA is the whole point → Option C (strip everything else)

---

## Fork 5: Multiple Sticky Elements

**Desktop pattern:** Sticky header (60px) + sticky subnav (40px) + sticky filters (48px). Total: ~148px of stuck content.

### Option A: Keep All (Cascading Sticky)
- All three remain sticky with stacked `top` offsets
- Good on large tablets and desktops
- **Tradeoff:** 148px is ~20% of a mobile screen. Content area becomes too small.

### Option B: Collapse Subnav into Header
- Header absorbs subnav functionality (tabs, dropdown)
- Reduces sticky stack to ~70px
- Good when subnav items are few (3-5)
- **Tradeoff:** Header becomes more complex and may need its own responsive states

### Option C: Filters Become Floating Button + Sheet
- Header stays sticky, subnav optionally sticky, filters open from a floating action button
- Reduces permanent sticky space to 60-100px
- Good when filters are used intermittently, not constantly
- **Tradeoff:** Filters are no longer visible; users may forget active filter state

### The Question
> "[N] sticky elements stack to ~[X]px on mobile — that's [Y]% of the screen. Which ones truly need to stay visible while scrolling?"

### Signals
- If subnav has 3-5 items → collapse into header (B)
- If filters are applied rarely → floating button + sheet (C)
- If user constantly references all three → keep cascading but reduce heights (A with smaller mobile variants)

---

## Fork 6: Complex Navigation

**Desktop pattern:** Mega menu, multi-level dropdowns, or navigation with 15+ items across 3+ categories.

### Option A: Hamburger with Accordion Categories
- Single hamburger → full-screen overlay → category accordions
- The standard approach for deep navigation
- **Tradeoff:** Adds taps to reach any destination; deep nesting is confusing

### Option B: Bottom Tab Bar + Category Pages
- Primary sections as bottom tabs; sub-navigation within each tab's page
- Good for app-like experiences with 3-5 top-level sections
- **Tradeoff:** Only works for 3-5 sections; more requires overflow handling

### Option C: Search-First Navigation
- De-emphasize browse navigation; prominently feature search
- Good when users know what they're looking for
- **Tradeoff:** New users who don't know the content can't browse effectively

### The Question
> "This navigation has [N] items across [M] categories. On mobile, is the primary user behavior browsing/exploring or searching for something specific?"

### Signals
- If content-heavy site with defined categories (e-commerce, docs) → hamburger + accordion (A)
- If app with 3-5 core flows (dashboard, messages, settings, profile) → bottom tabs (B)
- If content is highly searchable and users have intent (knowledge base, marketplace) → search-first (C)
- If navigation has 3+ nesting levels → hamburger (A) — bottom tabs can't handle depth
- If navigation items have icons → bottom tabs (B) — icon + label fits the tab bar pattern

---

## Fork 7: Form Layout with Complex Fields

**Desktop pattern:** Multi-column form, inline validation, conditional fields, field groups side by side.

### Option A: Single Column Stack
- Every field goes full-width, stacked vertically
- Simplest and most reliable on mobile
- **Tradeoff:** Long forms become very long; user may lose context of where they are

### Option B: Stepped/Wizard
- Break form into steps; one group of fields per screen
- Good for forms with 10+ fields or natural groupings
- **Tradeoff:** Users can't scan the whole form; progress indicator needed

### Option C: Accordion Sections
- Logical field groups collapse into sections; user expands one at a time
- Good for reference/settings forms where users edit specific sections
- **Tradeoff:** Users may miss required fields in collapsed sections

### The Question
> "This form has [N] fields in [M] groups. Is this a fill-once form (registration, checkout) or an edit-many-times form (settings, profile)?"

### Signals
- Fill-once → stepped wizard (B) for 10+ fields, single column (A) for fewer
- Edit-many-times → accordion (C)
- Mix of required/optional fields → step through required, accordion for optional

---

## Fork 8: Content Grid with Varying Card Types

**Desktop pattern:** Bento grid or masonry layout with hero cards, standard cards, and wide cards.

### Option A: Linear Stack (All Same Width)
- Every card becomes full-width, stacked vertically
- Hero card can be taller or have a different layout to maintain hierarchy
- **Tradeoff:** Loses the visual rhythm and hierarchy of the bento grid

### Option B: Horizontal Scroll Sections
- Group cards by type; each group scrolls horizontally
- Preserves some visual variety
- **Tradeoff:** Less discoverable; users may miss cards off-screen

### Option C: Two-Column Mini Grid
- Standard cards go 2-up; hero card spans full width
- Preserves some grid feel on mobile
- **Tradeoff:** Cards may be too narrow on phones under 375px

### The Question
> "The desktop grid uses varying card sizes for visual hierarchy. On mobile, do you want to (a) stack everything full-width (simplest), (b) group into horizontal scroll sections (preserves variety), or (c) keep a 2-column mini-grid (preserves density)?"

### Signals
- If hierarchy matters (featured vs. regular) → Option C with hero card full-width
- If all cards are equal → Option A
- If cards are grouped by category → Option B
