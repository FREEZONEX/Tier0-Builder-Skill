# Implementation Checklist

Use this checklist when planning and reviewing a generated application.

## Requirement Analysis

- Identify the application type and intended users.
- Extract required features, workflows, validations, and state transitions.
- Classify the work mode: balanced first release, delta feature expansion, or
  light edit. For first release, plan the main business map plus core workflow
  depth; for light edits, avoid global replanning and update `specs/spec.md`
  only when product meaning changes.
- Treat first-release completeness as user-perceived completeness, not PRD
  percentage or code volume. The target is a coherent first product slice:
  the main business map is visible, core workflows are operable, supporting
  workflows are lighter but usable, and runtime behavior is verified before
  reporting completion.
- Do not translate "compact" into a smaller business lifecycle. For apps that
  manage resources, inventory, orders, assets, tasks, cases, suppliers,
  customers, projects, or similar objects, plan the relevant intake/create,
  current-state, downstream use/issue/dispatch/fulfillment or closure, and
  exception/recommendation paths before choosing which details to omit.
- Avoid repeated broad rereads of the same scaffold files after the stack,
  shell, form primitives, and route conventions are understood, but reread
  references when a concrete local pattern, missing API, or verification
  failure requires it.
- Identify required data models, relationships, and business rules.
- Identify required UI screens, overlay-backed create/edit forms, lists, detail views, dashboards, and operational flows. Treat workspace CRUD forms as `FormDialog` or `Drawer` flows unless the requirements explicitly call for an inline station, filter, scan/manual entry, or review-reason form.
- Identify dense tables early. Plan `TableViewport` or an explicit internal
  horizontal scroll region for wide business tables, with nowrap status/action
  cells and intentional wrapping, clamping, or truncation for long names and
  identifiers.
- Identify any recommended, automatic, optimized, or rule-based actions. Plan
  a visible preview or confirmation surface that shows affected records,
  quantities, statuses, dates, owners, or assignments before mutation.
- Classify each frontend workflow by layout intent: station for scan/tap execution, review for evidence/decision queues, workspace for management/planning/analytics, or a custom layout when the built-ins do not fit.
- Classify the visual tone by use environment. Business operations apps such as WMS, QMS, inventory, R&D warehouse, approval, analytics, CRM, and management workspaces default to modern enterprise hierarchy with a clear focal work surface, not all-white equal-weight admin panels. Reserve severe MES, dark, terminal-like, or highly restrained treatment for shop-floor, station, monitor, safety-critical, or equipment-terminal contexts.
- Identify backend/API requirements, persistence needs, integrations, and error paths.
- Identify whether the app needs Tier0 OpenAPI, UNS, Flow, MQTT, or MQ integration; if yes, plan to use `@tier0/sdk` instead of custom clients.
- Note explicit technology constraints from the requirements or existing project.

## File Organization

- Use a logical project structure appropriate for the selected or existing stack.
- Separate concerns across UI, business logic, data access, utilities, configuration, and tests where applicable.
- Follow conventional naming and directory patterns for the stack.
- Include required configuration files such as `package.json`, framework config, environment examples, or build settings when creating a project from scratch.
- Include setup and usage instructions only when the project format expects them.

## Code Quality Standards

- Generate syntactically valid, complete code.
- Follow language and framework conventions.
- Implement validation and error handling for user input, API calls, and persistence operations.
- When raw SQL `db.execute()` / `tx.execute()` is needed, normalize the result
  with the scaffold's `rowsOf()` helper before array operations. Prefer
  Drizzle `select().from(...)` for normal reads.
- Avoid common security issues, including injection-prone data handling, unsafe HTML rendering, hardcoded secrets, and overbroad trust in client input.
- Optimize for maintainability and performance appropriate to the app's scope.
- Keep comments concise and useful.
- Avoid TODO placeholders, mock-only behavior, and disconnected UI for required features.

## Implementation Order

1. Establish product skeleton: app name, routes, navigation, primary page.
2. Define the smallest coherent data model and baseline example records.
3. Implement the core vertical slice: service/API, one write path or state
   transition, validation, and visible feedback.
4. Run a quick type/runtime check when available; fix blockers before adding
   more breadth.
5. Implement required lifecycle coverage and supporting pages with lightweight
   but operable secondary actions.
6. Add error, empty, loading, and validation states.
7. Run full checks, route smoke when preview URL is available, and fix failures.

For Tier0 platform integrations, use the scaffold's preinstalled `@tier0/sdk`
and use `@tier0/sdk` for endpoint
guidance. Use lazy loaders from `@/lib/tier0`; do not top-level import
`@tier0/sdk/openapi` or `@tier0/sdk/mq` from services, route loaders, pages, or
SSR startup paths. Do not duplicate UNS/Flow REST endpoint wrappers or MQTT
reconnect/resubscribe logic in app code.
Keep `vite.config.ts` `ssr.external: ["pg", "@tier0/sdk", "mqtt"]`; do not put
SDK packages in `ssr.noExternal`. SDK SSR compatibility is scaffold
configuration plus lazy app-code loading, not a reason to add fallback clients.
Do not create pages or forms for users to configure Tier0 SDK authentication,
API keys, tokens, OpenAPI hosts, MQTT hosts, or workspace binding; those are
injected automatically by the platform at deployment. Do not add `TIER0_*` /
`VITE_TIER0_*` placeholders to generated `.env.example` files unless the user
explicitly asks for a platform-external debugging setup.

For this TanStack Start MES scaffold, use the shared service-layer
`bootstrapModule(...)` helper for runtime table/index creation and baseline
seed. Do not hand-roll create/seed sequencing; the helper creates all module
tables/indexes before running any seed callbacks.

When creating baseline seed with related tables, verify the FK graph before
inserting child rows. Parent rows and named IDs must be declared first; child
rows must set every non-null FK explicitly from those IDs. Do not pass
`undefined` or omit required FK properties in Drizzle `.values([...])` objects:
Drizzle compiles those properties to SQL `default`, which produces failures like
`sales_order_items.sales_order_id = default`. Use `requireSeedRef()` or
`requireSeedValue()` from `@/services/seed-utils` for generated interlinked seed
data.

## Self-Review

- Check for syntax errors, missing imports, incorrect paths, and unused exports.
- Verify a first release covers the user's main business map while keeping
  core workflows deeper than supporting workflows. It should not feel like one
  isolated demo flow, and it should not expose a broad set of shallow stubs.
- Verify every required workflow is reachable from the UI or API.
- Verify the first release does not stop at intake/listing when the requested
  business object also needs downstream use, issue, dispatch, fulfillment,
  closure, or exception handling to make the app coherent.
- Verify each frontend route uses the layout group that matches the workflow intent.
- Verify each primary page has one visual center and enough surface layering, active state, semantic accent, or focal contrast to avoid a flat all-white layout.
- Verify recommended or automatic actions are inspectable before execution and
  do not hide the records, quantities, or statuses being changed behind a
  single unexplained button.
- Verify forms enforce required fields and validation rules, use the shared `FieldLabel` / `RequiredMark` or `data-required-marker` convention for required asterisks, and launch workspace CRUD create/edit forms from buttons, row actions, or empty states into `FormDialog`/`Drawer` instead of permanently flattening them on the page.
- Verify dialogs and drawers do not create accidental horizontal scroll, form
  grids collapse cleanly, and selects/comboboxes show enough text for users to
  choose the correct record.
- Verify dense tables use an internal table viewport or equivalent responsive
  layout; status badges, row actions, quantities, and dates remain readable and
  do not wrap into broken fragments.
- Verify status transitions and business rules match the requirements.
- Verify durable product changes are reflected in `specs/spec.md` when that
  file exists, without rewriting unrelated SRS sections for small edits.
- Verify raw SQL result handling is safe: no direct `.map()`, `.filter()`,
  `.length`, or index access on `db.execute()` / `tx.execute()` results.
- Verify errors are surfaced to users or callers clearly.
- Verify no required feature is represented only by placeholder text.
- Verify the app starts, builds, or tests successfully using the available environment.
  For first release work, runtime page load matters: do not stop at
  typecheck/lint when a preview or route smoke check is available. In this
  scaffold, use `npm run smoke:routes -- <preview-url>` when a preview URL is
  available.
