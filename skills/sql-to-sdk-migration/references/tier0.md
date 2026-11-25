# Tier0 迁移要点

以 App 实际安装的 SDK 类型和后端当前契约为准；合并源码不代表环境已支持。优先查随包 data/uns 指南，MCP search 用于确认目标接口 schema。

## 查询与范围

- 业务字段使用模型路径；系统字段使用 `_id`、`_meta.revision`，不要带入底层存储的 `data.` 前缀。
- 集合访问授权不代替 App 访问者角色和站点范围过滤；关联查询也必须保持原数据归属约束。
- get 的遗漏通过 missing 判断；分页按 pageInfo 继续，queryBatch 不会自动取得全部页。
- `$in` 值数、逻辑分支数、表达式节点/深度和页大小分别判断。把 OR 嵌套更深不会减少节点预算；优先用关系查询简化条件。
- 能力字段的 `0` 仅在契约明确时表示该维度无固定上限，不能当作分批步长。不要把旧 get100/queryBatch20 上限写进 App。
- capped 总数不能当作精确总数；JSON 字符串提取不能默认替代原有类型转换和规范化规则。

## 写入

单记录编辑用 expectedRevision 或预期状态条件；多步动作需要原子性时用 transact。不能把一个原子动作拆成多次请求来适应批量限制。

按错误中的 execution 和 retry.safe 判断重试。unknown 先确认结果；允许重放时复用原幂等键。SDK 已有重试时，不再外包无条件重试。

## 慢查询

目标版本支持时，用 `records:explain` 的 `op:"aggregate"` 提交原 pipeline 和分页参数。它只生成计划，成本和行数是估计值；不拿简化 find 的计划解释另一条聚合。

已安装 SDK 支持时，用 `createDataClient({ onRequest })` 获取 requestId、本地排队、请求耗时和重试次数。用 requestId 关联后端证据，不能从 SDK 总耗时推算数据库执行耗时。

`OVERLOADED` 查并发占用和连接等待；`LOOKUP_BUDGET_EXCEEDED` 查中间结果膨胀；响应过大先缩字段和结果页。不要静默截断或无限重试。

业务无法合理表达时，补已有 SDK/后端查询能力。月报算法、汇总分片和失效策略留在 App，不做成所有 App 必须使用的框架。
