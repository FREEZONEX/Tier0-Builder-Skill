# Workflow: Transform Existing Site/App

Audit an existing codebase's responsive behavior, identify problems and design forks, then fix them in priority order.

## Required Reading

Read only the references needed for the affected layout:
- `references/ai-failure-patterns.md` — pre-flight scan for quick wins
- `references/responsive-design-forks.md` — Fork 2 for any record list/table; other forks when ambiguous patterns are found
- `references/sticky-scroll-patterns.md` — loaded when sticky/scroll issues are found
- `references/modern-css-patterns.md` — loaded when implementing fixes

---

## Step 1: Audit Current State

### Scope the audit

If the user pointed at a specific component, page, or problem ("fix the mobile nav", "the sidebar breaks on tablet"), scope the audit to that area. Don't run a full-codebase audit for a targeted request — read the relevant component, check its responsive behavior and primary mobile task, then fix it. For record lists/tables, read Fork 2 before Step 3, including when the user says the layout already fits. Apply their chosen presentation without another design-choice gate.

If the user asked for a general responsive review ("make this responsive", "audit the responsive design"), proceed with the full audit below.

### Assess codebase complexity first

Before diving into responsive specifics, understand what you're working with:

| Signal | Implication |
|--------|-------------|
| Single CSS approach (all Tailwind, or all vanilla CSS) | Straightforward — apply patterns directly |
| Mixed styling (Tailwind + inline styles + CSS modules) | Target the dominant approach; flag conflicts between systems |
| Third-party component library (MUI, Chakra, shadcn, Radix) | Check the library's responsive defaults before overriding — work WITH it, not against it |
| `!important` scattered throughout | Specificity wars — consider `@layer` to establish cascade order before fixing responsive issues |
| CSS-in-JS (styled-components, Emotion) | Responsive patterns are the same but expressed differently — use the library's responsive API (theme breakpoints, responsive props) |
| Legacy code (floats, table layout, fixed widths in HTML) | Full retrofit needed — follow the 6-step order below; don't try to incrementally patch |

**If the codebase is a mess:** Don't try to fix everything at once. Identify the 2-3 pages or components with the worst responsive behavior, fix those first, and establish patterns that can spread. Present this triage to the user.

**If using a component library:** Read the library's responsive documentation first. Many libraries (Chakra's responsive props, MUI's `sx` breakpoint syntax, Tailwind's responsive modifiers) have built-in responsive systems. Use them instead of writing raw media queries around the library's components.

### What to check

1. **Viewport meta tag** — Does `<meta name="viewport" ...>` exist? Does it include `viewport-fit=cover` if safe areas are used?

2. **Breakpoint strategy** — How are breakpoints defined? Mobile-first (`min-width`) or desktop-first (`max-width`)? How many breakpoints? Are they consistent or ad-hoc?

3. **Layout approach** — CSS Grid, Flexbox, or older techniques (floats, fixed widths)? Intrinsic patterns (`auto-fit`, `flex-wrap`, `clamp()`) or breakpoint-dependent?

4. **Container queries** — Are components adapting to their container or the viewport? Would container queries improve reusability?

5. **Sticky/scroll patterns** — Any `position: sticky` or `position: fixed`? Check for the common failures (overflow ancestors, missing align-self, z-index issues).

6. **Typography** — Fluid (`clamp()`) or stepped (different px at each breakpoint)? Minimum body text 16px on mobile?

7. **Images** — `width`/`height` attributes? `max-width: 100%`? `object-fit` where needed? Responsive loading (`srcset`, `<picture>`) for large images?

8. **Touch targets** — Interactive elements at least 44x44px on mobile?

9. **Task suitability** — Can mobile users identify and process a record comfortably? For every affected list/table, choose cards, a comparison table, or priority columns using Fork 2; passing overflow checks alone is insufficient.

### Present findings

After auditing, present a structured summary:

```
RESPONSIVE AUDIT

Current approach: [mobile-first/desktop-first/mixed]
Breakpoints found: [list them]
Layout system: [Grid/Flexbox/mixed/legacy]

Issues found:
1. [Critical] [description]
2. [Important] [description]
3. [Minor] [description]

Design forks identified:
- [Pattern] → needs a decision (see Step 2)
```

**Wait gate:** Present the audit and wait for the user to confirm before proceeding.

---

## Step 2: Surface Design Forks

For each ambiguous responsive translation found in the audit, load `references/responsive-design-forks.md` and present the relevant fork with options and tradeoffs.

### How to identify forks

Scan for these patterns in the existing code:
- Sidebar with mixed content types
- Record lists/tables of any column count, including those that already fit or scroll correctly
- Multi-panel layouts (dashboard-style)
- Complex hero sections with video/animation
- Multiple sticky elements stacking
- Deep navigation (15+ items, 3+ levels)
- Multi-column forms
- Bento/masonry grids

For each fork found, apply an explicit user choice first. In Adaptive mode, state and implement a task-supported choice; present 2-3 approaches and ask only if a material tradeoff remains unresolved.

If AskUserQuestion is available, present forks as tappable options. Otherwise, describe the options and ask the user to choose by number.

**Don't batch all forks at once** — present them one at a time or in groups of 2-3 max. Let the user make each decision before moving on.

---

## Step 3: Prioritize and Fix

### Fix order (highest impact first)

1. **Foundation fixes** — viewport meta, box-sizing reset, image max-width, missing `min-width: 0` on flex children
2. **Structural fixes** — convert desktop-first to mobile-first if needed, establish consistent breakpoints, add container queries where components are viewport-dependent
3. **Layout fixes** — implement the design fork decisions from Step 2
4. **Detail fixes** — touch targets, safe areas, fluid typography, sticky coordination
5. **Polish** — scroll-snap, scroll-driven animations, reduced motion queries

### For each fix

Run the pre-flight scan (ai-failure-patterns.md) against the change before presenting it. Don't introduce new responsive bugs while fixing old ones.

### Adaptive vs Guided mode

**Adaptive mode:** Fix foundation issues directly (they're unambiguous), surface forks inline as they come up, move quickly. Present a brief summary of what was changed after each fix category.

**Guided mode:** Before fixing anything, write behavior specs for the components being changed — documenting their current behavior AND the target behavior. Present each fix category with the spec for approval before implementing. The specs serve as a record of what was decided and why.

---

## Step 4: Verify

Load `references/testing-checklist.md` for the 10-point check and priority viewport list.

**Snapshot comparison (optional):** For before/after documentation, use `node ${CLAUDE_SKILL_DIR}/scripts/snapshot.js <url> --before` before fixing, then `node ${CLAUDE_SKILL_DIR}/scripts/snapshot.js <url>` after fixing to generate a visual comparison.

After implementing fixes:

1. Run the pre-flight scan (ai-failure-patterns.md checklist) against all changes
2. Run through the 10-point check at 375px, 768px, and 1440px
3. Check the edge cases most relevant to this specific site
4. Confirm all design fork decisions were implemented as agreed
5. Check that no new responsive issues were introduced
6. For list/table transformations, run the record-list task and state checks in `references/testing-checklist.md`; report static review separately from browser-tested behavior

Present the verification summary:

```
VERIFICATION

Tested at: 375px, 768px, 1440px
Issues fixed: [N]
Design forks resolved: [N]
Remaining concerns: [list any, or "none"]
```

**Offer live preview:** After presenting the summary, offer to launch the multi-breakpoint preview so the user can see the results across all viewports at once:

> Want me to open a live responsive preview in your browser? You'll see 375px, 768px, 1024px, and 1440px side by side — you can scroll and navigate each one independently.

If they accept, run `node ${CLAUDE_SKILL_DIR}/scripts/preview.js <url>`.

---

## Success Criteria

- [ ] Audit completed and presented
- [ ] Design choices follow user intent and task context; unresolved tradeoffs confirmed
- [ ] Fixes implemented in priority order
- [ ] Pre-flight scan passed
- [ ] Verification completed at key viewports
