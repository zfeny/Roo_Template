# Worktree Policy

## Objective
并行 WO 默认启用 worktree，降低上下文互相污染和切分支开销。

## Default Rule
1. 同时处理两个及以上 WO 时，优先为每个 WO 分配独立 worktree。
2. 子任务进入 worktree 前，必须复制对应上下文：
   - `.roo_process/work_orders/<WO_ID>/`
   - `.roo_process/context_packs/<WO_ID>/`
   - `.roo_process/evidence/<WO_ID>/`

## Guardrails
1. 不在错误 WO 的 worktree 内写入证据。
2. 跨 WO 引用时必须显式标注来源 WO。
3. 合并前逐个 WO 执行 `validate-delivery` 与独立 Reviewer 验收。
