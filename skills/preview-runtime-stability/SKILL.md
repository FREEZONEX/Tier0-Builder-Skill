---
name: preview-runtime-stability
description: >-
  Use when managed preview startup fails for TanStack Start or Vite apps,
  including install failures, ERESOLVE or lockfile errors, "Failed to load
  preview", preview timeouts, "dev server exited: exit status 1", port 5173
  conflicts, /api/health failures, missing dependencies, stale npm/node
  processes, broken HMR, Vite reload issues, or preview pages showing no
  permission / 403 / missing menus for the selected preview roles (one or
  several view-as roles).
---

# Preview Runtime Stability

## Purpose

Use this skill when the user says `Failed to load preview`, `Preview loading timed out`, or when a managed preview is stuck, repeatedly times out, or reports port conflicts such as `Port 5173 is already in use`. The goal is to make preview start/stop idempotent inside one executor Pod.

This skill also covers dependency-install diagnosis and frequent full page
reloads during development. Read the install or preview logs before retrying;
do not treat every exit status as a port or Vite startup problem.

## Diagnose and Route

Read the first relevant error and identify the failing layer before retrying.

| Evidence | Read |
| --- | --- |
| Missing dependency, ERESOLVE, unavailable package, install failure | [Error playbooks](references/error-playbooks.md), dependency sections |
| Dev process exit, SSR/auth error, artifact mismatch, readiness timeout | [Error playbooks](references/error-playbooks.md), matching error section |
| Frequent full reloads or HMR failures | [Error playbooks](references/error-playbooks.md), HMR section |
| No permission, `403`, empty pages or missing menus for the selected preview roles | [Error playbooks](references/error-playbooks.md), preview role section |
| Confirmed stale owned preview process or lifecycle implementation | [Process lifecycle](references/process-lifecycle.md) |

Do not run a second install while managed dependency restoration is active.
Fix the evidenced cause before repeating a preview restart. Preserve the
current managed port contract (5173 for this scaffold); do not silently move
to another port or bypass the normal completion build.

## Responsibility Boundary

Application dependency, route, and configuration defects can be fixed in the
app. Managed process creation and termination belong to the platform runtime;
prefer its control interface. Before using cleanup scripts, verify the process
belongs to this app and the task authorizes its lifecycle management. A busy
port or failed health check alone is insufficient evidence to kill a process.
Do not run process-lifecycle tests against a shared or production listener.

## Verification

Check the original failure after the targeted repair. Port availability and
HTTP health prove transport/readiness only; use the app's normal build and
interactive route checks where relevant. Report the layer, evidence, action,
and result, distinguishing app changes from platform runtime work.
