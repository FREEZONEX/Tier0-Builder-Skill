# First Ensure and Runtime Blockers

Read this when importing a SQL-era app, when `app/context` returns 403, or when
platform access prevents runtime verification. A failed context read is not a
prerequisite failure for all source reconstruction.

## Distinguish Context from Initialization

`POST /openapi/v2/uns/app/context` reads an already active App data policy; it
does not initialize one. `403 active hosted App data policy required` can mean
**no policy yet** or **an existing policy is disabled**. The text alone cannot
distinguish them and does not establish a missing user role or platform outage.
Do not require context to succeed before attempting the first ensure diagnostic.

1. Record the operation, status and structured error (`code`, `reason`,
   `execution`, `retry`, request ID when available), without recording credentials.
   Verify the intended App/workspace and caller through available identity tools.
   App-scoped operations need the platform-issued App credential or an App-bound
   platform system-key path. An unbound Agent session, personal/OAuth key, or
   external App key is not interchangeable with the App runtime identity.
2. Prepare the actual intended declarations in `src/data/collections.ts` and
   obtain their ensure payload with `npm run data:schema`. Use those declarations
   for `POST /openapi/v2/uns/app/collections/ensure` with `dryRun: true` through
   the available platform tool. Do not create a throwaway collection just to
   test access. If the command is unavailable until code/dependencies are
   upgraded, complete that work first; do not ask for the old database.
3. Interpret the result using the table below. A successful dry-run is a plan,
   not collection creation, grant creation, seed completion or runtime acceptance.
   It leaves `app/context` returning 403 when no policy exists yet.
4. For missing-policy initialization, proceed with the authorized reconstruction
   and let the target SDK perform the actual first ensure on data access. If the
   task needs an explicit worker-side ensure before runtime, use the same reviewed
   declarations and intended App; this is a real mutation and follows the task's
   existing authorization. Do not add manual ensure calls or initialization
   flags to App services. Once actual ensure succeeds, re-read context and verify
   the intended App, collection grants, and runtime operations.

| Evidence | Interpretation and next action |
| --- | --- |
| Context 403, ensure dry-run succeeds with creation plan | Compatible with first initialization; continue. Do not demand an administrator create a policy first. |
| Ensure `APP_GRANT_REVOKED`, reason `POLICY_DISABLED` or `GRANT_REVOKED` | Explicit disabled policy or revoked grant; do not reactivate, grant broad access, or use another identity to bypass it. Report the administrative action required; continue independent source work. |
| Credential/identity rejection or no bound App | Verify the App binding and credential route, not the browser's selected role. Report the specific binding/injection gap without asking for secrets. |
| `APP_NOT_READY`, dependency failure, timeout, unreachable host | Runtime/environment issue. Follow structured retry advice with bounded attempts; then retain runtime checks as pending and continue source work. |
| `SCHEMA_CONFLICT`, invalid declaration/index/seed | Correct the declaration or resolve the concrete schema decision. Do not reset/recreate collections or weaken gates. |
| Generic 403 from ensure too, or unknown code | Keep the cause unconfirmed. Preserve the envelope and request ID, check backend version/binding with available evidence; do not label it “no policy” or “platform broken” without further evidence. |

Source basis verified on 2026-10-27: Tier0-Backend commit
`886de710c132d8e06e874927b2d3df358982956c`,
`service/unssvr/internal/domain/unsv2/hosted_app_access.go` (`hostedAppData`),
`app_collections.go` (`planAppEnsure`), and
`service/unssvr/internal/svc/app_ensure_bootstrap_postgres_test.go`
(`TestAppEnsureBootstrapThroughExecutePostgres`). The test explicitly covers
context 403 with no policy, successful non-writing dry-run, first actual ensure,
and disabled-policy rejection. This source evidence does not prove the target
runtime has deployed that version; unexpected results need environment evidence.

## Continue Work While Runtime Is Blocked

Separate **source reconstruction** and **runtime acceptance**. Report each
status independently.

A platform/API failure blocks only operations that depend on that platform
response. Continue authorized collection modeling, service/API conversion,
SDK/runtime and dependency alignment, UI adapters/subscriptions, retirement of
SQL imports/configuration, and local type/lint/build/contract checks. Do not
finish with only a migration plan while executable source work remains possible.
Use source definitions and business rules to model data, not a live old database.
If a domain choice genuinely blocks one slice, identify it and work on the rest.

Preserve a recoverable source baseline while editing the target app. Keep old
production deployment and old data untouched; source edits do not authorize
publication or deleting old data. Switching this App's source to collections is
not a destructive cutover: do not keep the imported app's active SQL runtime or
old data client to protect historical records, or because context returns 403
or target API acceptance is pending.

| Symptom | Next action |
| --- | --- |
| Connection error to the old database, or a request for `DATABASE_URL`, `DB_SCHEMA` or `PG*` | App-owned SQL code is still loaded. Convert that caller to collections and remove its connection setup; do not restore old SQL credentials or claim the cloud code failed. |
| A failing route changes from 500 to 503 or another handled error | Only the error presentation changed. The route is fixed when it reads and writes collections. |
| `/api/health` or the page HTML returns 200 while business APIs fail | That proves readiness only. Verify the affected business APIs before runtime acceptance. |

Run every check that can execute in the available environment. Isolated tests
or mocks may verify code behavior, but cannot stand in for real platform data
access. Record exact blocked checks and resume conditions. Never fabricate a
build pass, downgrade the target, bypass permissions, or mark full alignment
complete while required target-runtime checks remain pending. Write the target
`tier0Scaffold` only after full alignment verification; historical data is
outside alignment and never affects the marker.

## Historical Data Stays Outside Alignment

Do not connect to the original App database, request its host/port/schema,
connection string, account or password, or require database access before
reconstructing the app. Do not add a database extraction/synchronization tool,
restore `DATABASE_URL` / `DB_SCHEMA`, or dual-write old and new storage. Not
carrying the old records is not data loss and needs no user decision.

Historical data does not migrate with alignment. If the user needs it, they
import it separately on the UNS side; that is outside Builder. Do not guide an
export from the original application, describe import or manual-entry steps,
build an import feature, or import records yourself, and never load historical
rows as startup seed. Leave the original application and records untouched.
Do not describe missing historical records as a platform blocker or claim they
were preserved in the new app. Full alignment finishes on source and runtime
evidence alone.
