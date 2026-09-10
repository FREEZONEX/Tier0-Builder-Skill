# App SRS Spec Template

Use this template when generating an implementation-ready industrial-enterprise
business or operations software requirements specification.

## Required Document Structure

Use this structure exactly, adapting headings in brackets to the requested scope.

Structural constraints:

- Do not add, remove, rename, or reorder top-level sections.
- For repeated models, workflows, and screens, continue numeric headings sequentially: `3.2`, `3.3`, `4.2`, `4.3`, `5.2`, `5.3`.
- Keep all subsection labels exactly as shown, including `Purpose`, `Key Elements`, `User Interaction Flow`, and `Validation Rules`.
- Do not add extra sections such as Assumptions, Out of Scope, Non-functional Requirements, Architecture, API, Database, or Future Enhancements unless the user explicitly requests them.
- Do not add API Requirements, Seed Requirements, Build Requirements, Verification Requirements, database tool names, framework names, package commands, or implementation-stack sections unless the user explicitly requests implementation constraints in the SRS.
- Use the table column names exactly as shown.
- Save only the requirements document body in the final `spec.md`; do not include response markers or assistant commentary in the file.

```markdown
# 1. Overview

## 1.1 Description

- App name: <bounded scope name>
- Project goals and objectives:

# 2. Requirements

## 2.1 Roles and Permission

| Role ID | Display Name | Description | Permission |
|---|---|---|---|

## 2.2 User Story

| US ID | As a | I want to | So that |
|---|---|---|---|

## 2.3 First-Version Commitments

| FC ID | Capability | Depth Tier | Minimum User Path | Related US |
|---|---|---|---|---|

# 3. Data Models

## 3.1 <Model Name A>

- Description:

| Field Name | Definition | Notes |
|---|---|---|

# 4. Business Logic

## 4.1 <Workflow Name A>

- Related user story: <US IDs>
- Trigger:
- Logic:
- Output:

# 5. UI

## 5.1 <Screen Name A>

- Purpose:
- Key Elements:
- User Interaction Flow:
- Validation Rules:
```

## Section Rules

### 1. Overview

- Name the app, module, subsystem, or bounded industrial-enterprise business
  application according to the user's actual requested scope.
- State goals as operational outcomes, not platform or technology goals.
- Keep the scope explicit and bounded.

### 2.1 Roles and Permission

- Always include `root | Root | Full Access`.
- Use `root` only for application development; never use it in user stories.
- Derive every non-root role from concrete actions in section 2.2.
- Include only direct in-module operators.
- Exclude stakeholders who only consume, approve, reference, or reuse data outside the module.
- Map each non-root role to at least one user story.
- Remove any role that has no direct in-module action.
- Prefer 2 to 4 non-root roles unless the requested scope clearly needs more.
- Describe permissions as operational capabilities, not CRUD labels.
- Use wording like "Can record exception" or "Can approve request" instead of technical CRUD levels.
- Prefer domain-specific role names from the user's context, such as requester,
  processor, reviewer, approver, planner, coordinator, operator, specialist,
  manager, or administrator when those roles match the workflow.
- Never use generic roles such as "User", "Viewer", "Read-only", or "Business User".

### 2.2 User Story

- Break scenarios into concise operational user stories.
- Keep each story to a maximum of 3 lines.
- Avoid fluff and generic value statements.
- Do not create user stories for `root`.
- Ensure every user story uses a role that appears in section 2.1.

### 2.3 First-Version Commitments

- List user-requested capabilities and dependencies necessary for the core
  workflow. Optional category suggestions enter only after acceptance. This is the
  first-release delivery contract for implementation, not a list of optional
  future ideas.
- `Capability` uses the user's domain language (e.g. "FIFO recommendation with
  exception recording", "supplier qualification approval", "equipment alert
  acknowledgement") — never generic labels like "CRUD" or "management".
- `Depth Tier` is one of `core-flow` / `master-data` / `supporting` and is the
  implementation calibration the Builder inherits (see Category Archetype
  Expansion): core-flow is fully operable end to end; master-data is standard
  CRUD with realistic seeds; supporting is minimal but real and operable. For
  apps without a category archetype, assign tiers by the same semantics — the
  workflows the user emphasized are core-flow.
- `Minimum User Path` names the first-release delivery depth in one line:
  entry point -> input/reason -> saved record -> visible state change. For a
  core workflow, include the adjacent list, status, example data, or follow-up
  action needed for the capability to feel usable, not just clickable.
- Every commitment maps to at least one user story ID.
- Do not list capabilities that are intentionally out of the first version;
  simply omit them. Anything named here must be implementable as a minimum
  path, and anything in the app's visible navigation, tabs, or primary actions
  should trace back to a row in this table.
- Cover the user's main business map before optimizing for depth. A normal
  first release should include the primary modules and key supporting flows
  that make the product feel coherent, while avoiding full enterprise detail.
- Cover the lifecycle stages implied by the user's main operating objects. If
  the app manages resources, inventory, orders, assets, tasks, cases,
  suppliers, customers, projects, or similar objects, include first-release
  commitments for intake/create, current-state management, downstream
  use/issue/dispatch/fulfillment or closure, and exception/alert/
  recommendation handling when those stages are requested or necessary for the
  product to make business sense.
- Do not let a recommendation capability stand alone when it implies an
  executable operation. The first release should either include the target
  operation path (for example, issue, dispatch, release, assign, close, or
  fulfill) or keep the recommendation out of visible first-version scope.
- Every first-version commitment should be discoverable from a primary product
  entry point described in section 5: sidebar module, first-screen action,
  dashboard queue, or visible in-page module link. A hidden route, background
  page, or final-report URL is not enough.
- Keep the table between 4 and 10 rows for a normal first version; a short
  request may have fewer and a detailed but bounded request may have slightly
  more. Do not pad it with invented capabilities.

### 3. Data Models

- Define only business-critical fields.
- Describe business meaning, not implementation schema details.
- Include identifiers, status fields, operational quantities, timestamps, references, and validation-relevant values when needed.
- When a model has a status or lifecycle field, enumerate its states explicitly
  in the field's Definition (e.g. draft / pending / in-progress / exception /
  completed, adapted to the domain). These declared states are business facts:
  the implementation is expected to demonstrate each declared state with
  realistic example records.
- Avoid technology-specific schema language unless the user explicitly requests it.

### 4. Business Logic

- Describe the operational workflows implemented by the system.
- Describe how the system processes inputs and produces outputs.
- Reference related user stories by ID.
- State the trigger for each workflow.
- Use numbered steps under `Logic`.
- Include checkpoints, validation, rejection, exception, handoff, record, and
  status-transition rules when they affect operations.
- For recommended, automatic, optimized, or rule-based actions, describe what
  users can inspect before execution and what affected records, quantities,
  statuses, dates, owners, or assignments will change.
- Use mermaid only when it materially clarifies a workflow; mermaid code blocks are allowed inside the document block.

### 5. UI

- Describe how users interact with the system to complete tasks.
- For each first-version commitment, describe where the user starts from:
  primary navigation, first screen, dashboard queue, list row action, or
  in-page module link.
- Focus on interaction flows rather than UI components.
- Describe user actions and system responses.
- Ensure flows are consistent with business scenarios.
- Include validation rules such as required fields, range limits, thresholds,
  duplicate checks, permission checks, status restrictions, and exception
  handling.
- When a UI action applies a recommendation or automatic decision, the
  interaction flow must reveal the recommendation basis and affected objects
  before final confirmation.
- Do not describe UI at component level unless needed for business clarity.

## Quality Bar

- Prefer specific operational rules over generic statements.
- Preserve domain language from the user's request without turning one domain
  into the default for unrelated requests.
- Keep generated content operationally executable, business-logic focused, and implementation-ready.
- Balance first-release breadth and depth: core workflows should be complete
  enough to operate, supporting workflows should be light but usable, and
  anything not intended for implementation should stay out of the visible
  first-release commitments.
- Balanced breadth includes lifecycle coverage, not just page count. Avoid a
  first release that only creates or lists records while omitting the requested
  downstream operation that makes those records useful.
- Do not include vague future extensibility sections.
- Do not include unnecessary scalable architecture claims.
- Do not include platform-level capabilities unless the user explicitly asks for a platform.
- Do not assume React, SQL, Cloud, or any other implementation technology.
- Focus exclusively on business logic: input, processing, output, status,
  exception, record, and handoff.

Bad:

```text
The system should be flexible enough to handle various business checks.
```

Good:

```text
System must reject any request whose Requested_Amount exceeds Available_Balance unless an authorized approver records an override reason.
```
