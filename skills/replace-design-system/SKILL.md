---
name: replace-design-system
description: Replace the contents of the project's DESIGN.md with a user-supplied design specification, then restyle the existing app to match the new tokens. Use when the user attaches a design document (markdown) and asks to replace the current design system, apply a new design spec, or change the app's overall visual style while keeping its features intact.
---

# Replace Design System

## Purpose

The user has attached a design specification and wants it to become this project's
design system. Two things must happen, in this order: `DESIGN.md` takes on the new
specification, and the app's existing UI is restyled to match it. Doing only the
first leaves the app looking exactly as before, which is not what the user asked for.

## Critical Constraints

- **Replace the file's contents, not the file.** `DESIGN.md` must remain at the
  project root under that exact name. Never delete it, rename it, move it, or create
  a variant alongside it. Overwrite what is inside it.
- **The attachment is the source, not the destination.** The uploaded file lives in
  `tier0_uploads/` with a generated filename. Read it, use its content, and leave it
  untouched. Never treat that path as the design system the app should read from —
  `AGENTS.md` points every UI change at the root `DESIGN.md`, and only that.
- **Never guess the attachment's contents from its filename.** Uploaded names are
  sanitized and carry random suffixes; they mean nothing. Read the file.
- **Preserve behaviour.** Restyling changes appearance only. Do not alter business
  logic, data flow, routing, API calls, or component responsibilities.

## Workflow

1. Read the current root `DESIGN.md`, so you know the schema in use — typically
   YAML frontmatter carrying design tokens (colors, typography, spacing, radii)
   followed by prose guidance. For Tier0 Cloud scaffold apps, start with the project's
   `AGENTS.md`, `DESIGN.md`, and `src/styles/globals.css` together. CSS and the
   component implementations define runtime styling; the DESIGN YAML is their
   compact map.
2. Read the attached design specification referenced in the user's message.
3. Reconcile the two:
   - If the attachment already follows the same schema, use it as the new contents.
   - If it is free-form (a style writeup, a token dump, a brand sheet), translate it
     into the schema the project's `DESIGN.md` uses. Keep every key the existing file
     defines — supply values from the attachment where it speaks to them, and carry
     over the current value where it is silent. A missing key breaks downstream UI work.
   - If the two conflict, the attachment wins; it is the user's new intent.
   - For Tier0 Cloud, retain the existing component-interface, keyboard-operation,
     readability/contrast, and touch-target requirements from both YAML and prose,
     including when the attachment follows the same schema. Apply the attachment's
     visual choices (colors, typography, radii, and other styling) within these
     requirements.
4. Write the reconciled content into the root `DESIGN.md`, replacing its previous
   contents entirely.
5. Restyle the app to match the new tokens: locate where the old values are realised
   (theme config, CSS variables, Tailwind config, shared UI primitives, per-component
   styles) and update them. Prefer changing shared token definitions over patching
   individual components.
   - For Tier0 Cloud, use Tailwind CSS 4 through `src/styles/globals.css`; do not add
     `tailwind.config.js` or a second theme pipeline. Trace actual component token
     references and aliases, including `--tier0-cta` and `--tier0-brand` where
     present, through `:root`, `.dark`, `@theme inline`, and shared components.
     Update existing theme overrides and component-local styles as needed so
     affected surfaces follow the new specification in the app's existing themes.
6. Verify the app still builds and, where a dev/preview workflow is available, that it
   renders. Report which surfaces changed appearance.
   - For Tier0 Cloud, run `npm run build`, including its existing postbuild checks.
     With browser access, inspect affected pages on desktop and at a real 375px
     viewport in the app's existing themes. Check relevant hover, keyboard-focus,
     disabled, and error states, including readability and touch targets. Report
     build results and the themes, viewports, and states checked; if browser
     verification is unavailable, explicitly list the unverified items.

## Reporting

Tell the user, briefly: what the new design system changed at the token level (e.g.
primary colour, type scale, density), which files were restyled, and anything in the
attachment you could not apply — for instance a token the project's schema has no slot
for. Do not claim the restyle is complete if you only rewrote `DESIGN.md`.
