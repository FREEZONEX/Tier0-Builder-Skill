# Preview Process Lifecycle

Use only for an authorized, isolated preview process whose ownership is verified.
Use the managed runtime control interface when the platform owns the process.
The scripts do not establish ownership merely by finding a listener.

## Required Runtime Behavior

Before every preview start:

1. Ensure dependency restoration succeeded. In managed preview, wait for the
   managed install and inspect its failure log; do not run a concurrent install.
   In local/unmanaged preview, restore with the project's package manager and
   authoritative lockfile before build or preview.
2. Check whether the declared preview port is already listening.
3. If occupied, probe `http://127.0.0.1:${PREVIEW_PORT}/api/health`.
4. If health is 2xx, reuse the running preview and return ready instead of starting a second process.
5. If occupied but unhealthy, kill the old preview process group, wait for the port to free, then start the new preview.
6. If the port is free, start preview normally.

When preview stop/restart runs:

1. Stop by process group, not only by parent PID.
2. Send SIGTERM first.
3. Wait a few seconds.
4. If the process group or port is still alive, send SIGKILL.
5. Verify the declared port is free, unless the preview was intentionally reused because it is healthy.

For each session:

- Allow only one preview supervisor/task at a time.
- A new start request should reuse a healthy running preview, or replace an unhealthy one under a session-level lock.
- Do not allow Vite to silently drift from `5173` to `5174/5175`; use strict port behavior or treat drift as failure.

## Bundled Scripts

Use these scripts as reference implementations or direct smoke tests in the sandbox:

- `scripts/preview_preflight.sh` checks the port, probes health, and optionally cleans unhealthy listeners.
- `scripts/preview_stop_process_group.sh` stops a preview by PID/PGID or by the listener on the preview port.
- `scripts/test_preview_port_lifecycle.sh` verifies healthy reuse and unhealthy cleanup behavior with temporary Node test servers.

## Suggested Commands

Run preflight before starting preview:

```bash
PREVIEW_PORT=5173 HEALTH_PATH=/api/health ./.agents/skills/preview-runtime-stability/scripts/preview_preflight.sh --cleanup
```

Stop preview robustly:

```bash
PREVIEW_PORT=5173 ./.agents/skills/preview-runtime-stability/scripts/preview_stop_process_group.sh
```

Run the lifecycle test:

```bash
./.agents/skills/preview-runtime-stability/scripts/test_preview_port_lifecycle.sh
```

## Implementation Notes

- Prefer `127.0.0.1` for in-Pod health checks.
- Record `pid`, `pgid`, `session_id`, `task_id`, `port`, and `health_url` for every preview start.
- Add logs for `port_occupied`, `health_status`, `reuse_existing_preview`, `cleanup_unhealthy_preview`, `sigterm_sent`, `sigkill_sent`, and `port_free_after_stop`.
- If `lsof` is unavailable in the image, install it or provide an equivalent port-to-PID resolver. The bundled scripts can also use `fuser` or `ss` when available.
