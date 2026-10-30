# Issue 30：首次 align 前后 AGENTS.md 对照

测试日期：2026-10-29，阿里云 test，Builder Skill + Scaffold v18；旧设备维修中心源码包 v6/cd71421，首次 align 产物 v18/f5fe69d。

## 旧包根目录 AGENTS.md（节选）

原文件有 `## Equipment Repair Application` 章节，其中：

> The registered `equipment_repair_center_technician` (维修员-328e0892) role can view, create, and edit repairs; `equipment_repair_center_viewer` (查看者-328e0892) can only view, search, filter, and view/download attachments. Viewer-only access hides the entire write form and row mutation controls, leaving a full-width list.

> Repairs include editable priority `low` / `medium` / `high` (低、中、高), default `medium`.

## 首次 align 后根目录 AGENTS.md 标题

```text
# Tier0 Industrial App Scaffold
## Delivery Floor: Complete the Legal Lifecycle
## Managed Preview Workflow
## Sources of Truth
## Scaffold Map
## Architecture and Domain Rules
## App Data
## Routing and Server Boundaries
## Gateway Authentication and Roles
## UI and Client Runtime
## Tier0 SDK and Platform
## App Identity and Product Copy
## Build, Gates, and Deployment
## Completion Check
```

首次产物不存在 `App-Specific Rules` 标题，未找到上述 App 角色及优先级业务约定。新规则中的 SQL / DATABASE_URL 字样是禁止或门禁说明，不能据此判为旧数据库连接配置残留。旧包涉及历史数据库的约定不应照搬。
