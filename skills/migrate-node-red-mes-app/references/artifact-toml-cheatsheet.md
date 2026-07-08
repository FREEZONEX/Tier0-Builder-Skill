# artifact.toml Public-Safe Cheatsheet

Use this reference when preparing a Tier0 platform app package for import or
deployment. Treat the latest Tier0 scaffold as authoritative when it differs
from this guidance.

## Important Fields

| TOML path | Purpose | Notes |
|-----------|---------|-------|
| `name` | Default app name | User or platform may override display name |
| `services[0].localPort` | App port inside preview/runtime | Match the dev server and production server |
| `services[0].production.run.image` | Runtime image | Required for production import |
| `services[0].production.run.args` | Runtime command | Should start the built app |
| `services[0].production.run.env` | Runtime environment | Platform-injected variables override same names |
| `services[0].production.health.startup.path` | Startup health path | Must return success after container start |
| `services.preview.args` | Preview command | Should bind to `0.0.0.0` |
| `services.preview.health.path` | Preview health path | Prefer `/api/health` when available |

## Generic TanStack Start Example

```toml
name = "tier0-platform-app"

[deployment]
deploymentTarget = "autoscale"

[deployment.postBuild]
args = ["npm", "prune", "--omit=dev"]

[[services]]
name = "web"
paths = ["/"]
localPort = 5173

[services.production]
serve = "dynamic"

[services.production.build]
args = ["npm", "ci", "&&", "npm", "run", "build"]
outputDir = "."

[services.production.run]
args = ["node", "server.mjs"]
image = "node:22-alpine"

[services.production.run.env]
NODE_ENV = "production"
HOST = "0.0.0.0"

[services.production.health.startup]
path = "/api/health"
timeout = 120

[services.preview]
install = ["npm", "install"]
args = ["npm", "run", "dev", "--", "--host", "0.0.0.0", "--port", "5173"]
port = 5173

[services.preview.health]
path = "/api/health"
timeout = 180

[services.preview.env]
NODE_ENV = "development"
HOST = "0.0.0.0"
BROWSER = "none"
VITE_ALLOWED_HOSTS = "all"
```

## Checks

1. ZIP root directly contains `package.json`, `server.mjs`, and
   `artifact.toml`; do not wrap the app in an extra folder.
2. Keep `dist` in the import package after build.
3. Preserve the platform health route and point health checks to it.
4. Bind preview and production servers to `0.0.0.0`.
5. If Drizzle is used, keep `drizzle.config.ts` compatible with injected
   `DATABASE_URL`; do not require local `.env` loading in deployed runtime.
6. Do not put Tier0 SDK credentials or platform-injected environment values in
   user-editable settings pages or committed examples.
