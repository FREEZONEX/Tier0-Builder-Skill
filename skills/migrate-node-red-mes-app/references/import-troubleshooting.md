# Node-RED WMS/MES App Import Troubleshooting

Use this reference when a migrated Node-RED WMS/MES app fails preview, package
import, health checks, or deployment. Keep project-specific logs and raw
artifacts in the target project, not in this reusable skill.

## Deployment Stays In Progress

Common causes:

1. Dependency install is slow or blocked in the deployment environment.
2. A migration command depends on a dev-only package.
3. `drizzle.config.ts` loads local `.env` files that are not available in the
   container.
4. Generated compose or runtime config is malformed.
5. Health checks point to a route that is missing or not reachable.

Checks:

```bash
docker ps -a --filter 'name=app-'
```

Use the platform's backend logs or deployment logs for the real environment.
Do not hard-code one local container name into the reusable skill.

## Health Check Fails

Check:

- Production command starts the built server, not the dev server.
- Server binds to `0.0.0.0`.
- `services[0].production.health.startup.path` exists.
- `/api/health` is present if the scaffold provides it.
- The package includes `dist` and `server.mjs`.

## Import Cannot Find The App

Check:

- The ZIP root directly contains app files.
- `artifact.toml` is at the ZIP root.
- `package.json` scripts match the scaffold.
- Import tooling points to the correct backend URL or target environment.

## Drizzle Migration Fails

Check:

- `DATABASE_URL` is read from `process.env`.
- `drizzle.config.ts` does not require `dotenv/config` in deployed runtime.
- Migration dependencies are available where the platform runs migration
  commands.
- Schema names and table names match the target database policy.

## Legacy Pages Load Empty Data

Check:

- The legacy store initializer is mounted once in the relevant app layout.
- API wrappers call target `src/routes/api/**` routes.
- Permissions do not short-circuit write calls before the request is sent.
- Browser-only storage fallback is not hiding a failed server call.

## State Changes Do Not Persist

Check:

- Button handlers call the API wrapper rather than only mutating local state.
- Permission/action codes exist for the method and route.
- Services perform the transition and write to the database.
- The UI invalidates or reloads the relevant query after mutation.

## Package Is Too Large

Check:

- Exclude `.git`, local temp folders, preview caches, and editor folders.
- Keep `dist`.
- Include `node_modules` only when the target import flow explicitly supports
  offline/preinstalled dependencies.
- Do not include raw source archives, customer data exports, or private analysis
  files in the import package.
