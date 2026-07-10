---
name: app-srs
description: Use when first generating an industrial-enterprise business or operations app, or when generating, normalizing, converting, revising, or saving a spec/SRS from natural-language requirements, PRD, feature brief, enterprise workflow, WMS, SRM, CRM, ERP, MES, QMS, EAM, order, asset, supplier, customer, resource, scheduling, compliance, exception, reporting, or operational process needs.
---

# App SRS

## Purpose

Transform vague or concrete industrial-enterprise software requests into
bounded, operationally executable requirements specifications. Support three
stable scenarios: creating an SRS from an initial request, converting an
existing PRD or requirements draft into the required SRS format, and revising
an existing SRS after the user adds or changes requirements. Produce documents
that are suitable as the preferred source input for `$app-builder`, while
keeping the SRS itself technology-neutral. Focus on enterprise workflows,
process closure, roles, exchanged data, status changes, validations,
exceptions, records, and user interactions.

Act like a professional industrial-enterprise business consultant before
writing execution details: infer the user's domain language, identify the core
workflow map, surface the checkpoints that make the workflow safe and useful,
and then define a balanced first-release slice for implementation. The first
release should feel functionally complete across the user's main business map:
core workflows go deep enough to operate, supporting workflows stay lighter but
usable, and unimplemented future details stay out of the visible app. Do not
hard-code one module such as WMS or MES as the default. Horizontal systems such
as SRM, CRM, ERP, EAM, project, order, supplier, customer, service, resource,
and reporting apps still belong to the industrial enterprise context when they
serve industrial companies. Domain-specific knowledge belongs in optional
reference packs; this skill's core method must apply across industrial
enterprise functions, not consumer or lifestyle app domains by default.

For first-time app generation, treat this skill as the requirements compiler
step before implementation, not as a confirmation gate. Save `specs/spec.md`,
then continue to `$app-builder` by default in the same task flow unless
the user explicitly asked for requirements only or clarification is required.

## Workflow

1. Classify the request as one of these scenarios: new SRS generation, PRD-to-SRS conversion, existing SRS revision, or follow-up product-memory update.
2. Determine whether the operational scope and requested change are sufficiently clear.
3. If clarification is needed, ask concise clarification questions before drafting.
4. If the scope is clear, read `references/process-consulting-lens.md` and
   `references/spec-template.md` before drafting or revising the SRS. Do not
   draft from memory.
5. Use the available file write/edit tool to save the complete SRS as Markdown.
6. Default output path is `specs/spec.md` relative to the current workspace or user-specified output directory; create `specs/` if it does not exist.
7. When revising an existing SRS, update the target `spec.md` with the complete revised document, not a partial patch.
8. When the user intends to build an app, make the SRS implementation-ready enough for `$app-builder` to consume without requiring raw PRD context.
9. For first-time app generation, hand off to `$app-builder` immediately after saving the SRS. Do not ask for confirmation first.
10. If the user explicitly asked for requirements only and an `unsswe_notify_card` MCP tool is available, call it exactly once after the completed SRS file is saved and make that call the final action.

## Scenario Rules

Treat source documents titled "Spec", "App Spec", "PRD", "Feature Brief", "Requirements", or similar as source material. Convert them into the required SRS template instead of preserving their original structure.

### New SRS Generation

- Use the user's request as the source of scope, roles, workflows, data, validation rules, and UI flows.
- Before writing, identify the workflow closure: trigger, responsible actor,
  required inputs, checkpoints, state changes, records produced, downstream
  effects, and exception paths.
- Identify lifecycle coverage for the main operating objects. If the request
  is about resources, inventory, orders, assets, tasks, cases, suppliers,
  customers, projects, or similar objects, check whether the first release
  needs intake/create, current-state management, downstream use/issue/dispatch/
  fulfillment or closure, and exception/alert/recommendation handling.
- Identify the user's expected business map for the first release: primary
  modules, supporting modules, key states, and visible entry points that would
  make the app feel like a coherent working product instead of one isolated
  workflow.
- Ask clarification questions only when the requested operational scope is too vague, broad, or ambiguous to produce an implementation-ready SRS.
- Do not invent unrelated modules or platform capabilities to make the document look complete.
- For short first-time app requests, generate a light SRS that captures the
  balanced first release plus the relevant workflow checkpoints. Do not expand
  a simple request into a full enterprise program.

### Category Archetype Expansion

When the user names a recognized application category (WMS, CRM, MES, QMS,
EAM, SRM, ERP, ...) — especially with phrasing like "based on standard
<category> knowledge" — the category itself is a scope commitment. Domain
users judge the product against the category's canonical shape: an app
missing its master-data and core-flow modules reads as incomplete no matter
how well the named special features work.

- Expand the category's canonical module set into named modules in the SRS
  as First-Version Commitments, and present them in the blueprint for
  confirmation. The user trims the archetype; the system never silently trims
  it. This is not "inventing unrelated modules": category-implied modules are
  related by definition — the no-invention rule applies to capabilities
  outside the named category.
- User-named special requirements (e.g. pre-receipt, expiry alerts, FIFO) are
  additive to the archetype, never a substitute for it.
- Load the matching category reference from `references/categories/` when one
  exists (currently: `wms.md`). When none exists, expand from general category
  knowledge and note in the SRS that no category reference was available.
- Record a depth tier per module in the SRS so the builder inherits the
  calibration instead of re-deciding scope:
  - **core-flow**: the workflows the user emphasized plus the category's
    primary loop — fully operable end to end;
  - **master-data**: standard CRUD with realistic seeds;
  - **supporting**: minimal but real and operable — never a stub, never fake.
- Use the category's standard terminology, entities, field sets, and status
  taxonomies from the reference. Industry-standard vocabulary and status
  models are part of looking professional; generic names ("items", "records")
  read as amateur to domain users.

### PRD-to-SRS Conversion

- Treat the provided PRD, requirements draft, notes, or pasted source material as the source of truth.
- Preserve stated business facts, operational rules, terms, roles, constraints, and workflow intent.
- Convert the source material into the required SRS structure from `references/spec-template.md`; do not preserve the PRD's original section structure unless it matches the template.
- Fill obvious structural gaps only when directly inferable from the source material and domain context.
- Ask clarification questions when missing information blocks an implementation-ready SRS, especially missing scope boundaries, direct operator roles, workflow triggers, validation rules, or required outputs.
- Do not silently add business rules that are not stated or strongly implied.
- For long or detailed PRDs, normalize the PRD into a bounded first-version SRS instead of trying to implement the entire PRD at once. Preserve important later-phase requirements as concise notes inside the relevant business logic or UI sections only when they affect first-version boundaries.

### Existing SRS Revision

- Treat the existing SRS as the current baseline and the user's new instruction as a change request.
- Save a complete revised SRS document, not a partial patch or diff.
- Preserve the required structure, existing IDs, naming style, and unaffected content where still valid.
- Update all impacted sections consistently, including roles, permissions, user stories, data models, business logic, UI flows, and validation rules.
- Add new IDs sequentially when new roles, stories, models, workflows, or screens are needed.
- Remove or rewrite obsolete content only when the user's change clearly supersedes it.
- Ask clarification questions only when the requested change cannot be applied without choosing between materially different business meanings.

### Follow-Up Product-Memory Update

- Use this mode when implementation already exists and the user asks for a
  small product change whose business meaning should be remembered, such as a
  field, table column, validation rule, status, permission, action, workflow
  wording, or domain term.
- Do not expand a small edit into a full SRS redesign. Update only the affected
  SRS sections while preserving existing IDs and structure.
- Do not trigger Builder just to record product memory. The implementation can
  stay lightweight; the SRS update exists to prevent drift during later work.
- Skip SRS updates for purely visual repairs, formatting tweaks, and copy edits
  that do not change domain meaning.

## Scope Rules

- Define the scope as a module, subsystem, bounded industrial-enterprise
  business application, or related multi-module scope according to the user's
  request.
- Do not force a valid multi-domain request into a single object or module.
- Do not expand beyond the expressed business need.
- For first-time generation, balance breadth and depth: cover the main business
  areas the user would expect to see in the first product version, deepen the
  core operating loop, and keep supporting loops lighter but operable.
- State an explicit, bounded app or module name in the document.
- Keep all content business-logic focused: input, processing, output, roles,
  validations, status changes, exceptions, records, and operational workflow.
- Avoid platform-level, architecture, scalability, future extensibility, and technology-stack claims unless the user explicitly requests them.
- Never use generic roles such as "User", "Viewer", "Read-only", or "Business User".

## Clarification Decision

Generate the SRS when the requested operational scope is sufficiently clear, including bounded multi-domain requests.

Stop and ask clarification questions only when:

- The request is too vague or broad to identify an operational workflow.
- The scope boundary could reasonably mean different applications or execution contexts.
- The actor groups, operational concerns, or intended workflow are unclear.
- The user explicitly asks to stop after requirements and not build.
- The requested work implies destructive actions against real production or external systems.

When clarification is needed:

- Ask only the questions needed to unblock an implementation-ready SRS.
- Prefer concrete options when the user needs to choose between meaningful application boundaries or workflow choices.
- Free-text questions are allowed when a constrained option set would distort the business meaning.
- Keep questions concise and avoid drafting the SRS in the same response.

## File Output

Before generating any SRS document, read `references/process-consulting-lens.md`
and `references/spec-template.md`, then follow the required structure and
section constraints.

When the SRS can be generated, save it to a Markdown file:

- Default path: `specs/spec.md`.
- If the user specifies a path, use that path instead.
- Create the parent directory if it does not exist.
- Write the complete requirements document body only; do not wrap file contents in `=====doc:start=====` or `=====doc:end=====` markers.
- Do not split the SRS across multiple files unless the user explicitly asks.
- After saving, respond with a concise confirmation and the saved path unless a required final MCP card call must be the last action.

File content rules:

- Do not wrap the document body in a markdown code block.
- Never place clarification questions inside the saved SRS file.
- Do not save a partial document.
- Do not include assistant commentary in the saved file.

## Builder Handoff

The completed SRS file is the default input for `$app-builder`.

- Preserve operational details that affect implementation: roles, permissions, user stories, data fields, business logic, UI flows, validation rules, and system outputs.
- Section 2.3 First-Version Commitments is the balanced first-release delivery
  contract. The Builder must deliver the committed business map with enough
  depth that each visible capability is usable, not merely present. It may not
  silently downgrade a commitment to future work. If the user later narrows
  scope, revise the SRS so the commitments table stays truthful.
- Each first-version commitment should have a discoverable product entry point
  in the SRS UI flows: sidebar module, first-screen action, dashboard queue, or
  visible in-page module link. The Builder must not satisfy a commitment only
  with a hidden route or a final-report URL.
- For lifecycle-oriented apps, section 2.3 should make the upstream,
  current-state, downstream, and exception/recommendation stages visible when
  they are part of the requested business meaning. The Builder should not
  interpret a compact first release as permission to omit a committed
  downstream operation such as use, issue, dispatch, fulfillment, closure, or
  exception recording.
- Avoid technology-stack choices in the SRS; let the Builder infer stack from the target project or user instruction.
- For first-time app generation, continue directly to `$app-builder` after saving `specs/spec.md`.
- Do not create `handoff.json` or any other sidecar handoff file. The handoff is the saved SRS plus the same-turn instruction to build the first version.
- If the source was a long PRD, the Builder should implement the balanced
  first release represented by the SRS: roughly the main user-perceived product
  surface and core operating depth, not every PRD detail at once.
- If the user explicitly requested SRS-only work, stop after saving the SRS and report the path.

## Requirements Card

If an `unsswe_notify_card` MCP tool is available during SRS-only work, call it exactly once after every completed requirements document file is saved. Make the card call the final action of the response and do not output assistant text afterward.

For first-time app generation, Builder handoff takes precedence over a waiting
confirmation card. Do not emit a card that blocks implementation unless the
user explicitly requested requirements-only output.

For the first completed draft, call:

```json
{
  "card_type": "requirements_doc_ready",
  "data": {
    "card_id": "requirements_v1",
    "status": "idle",
    "hint": "The requirements document is complete."
  }
}
```

For revised completed drafts after a previous requirements card exists:

- First update the old card with the same `card_id` and `status: "ignored"`.
- Then output the new full document.
- Then call a new card with the next versioned `card_id` and `status: "idle"`.

Use only these statuses for SRS-only review cards:

- `idle`: current requirements-only draft is available for user review.
- `ignored`: older card superseded by a newer draft.
- `confirmed`: use only when the platform explicitly records user approval.

If the tool is unavailable, still follow all file output rules and do not invent a substitute tool call.
