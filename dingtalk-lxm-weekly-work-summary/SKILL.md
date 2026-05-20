---
name: 钉钉周工作总结（mcp）
description: Use when the user wants a weekly work summary for Lu Xiamiao (吕夏苗) based on all available DingTalk MCP evidence, including chats and @mentions when accessible, OA approvals, todos, calendar events, logs, documents, spreadsheets, contacts, and group metadata. Default range is the 7-day period ending on the current date.
---

# DingTalk Lu Xiamiao Weekly Work Summary

## Purpose

Use this skill to summarize `吕夏苗`'s weekly work from DingTalk evidence. The report owner is fixed as `吕夏苗` unless the user explicitly names another subject.

Default period: the 7 calendar days ending on the current date in `Asia/Shanghai`. If the user says `本周`, `上周`, or gives explicit dates, use that range instead and state exact start/end dates in the result.

## Evidence Scope

Use every available DingTalk MCP source that can provide relevant evidence. Prefer read-only tools. Do not create, update, send, approve, revoke, delete, or modify DingTalk data unless the user explicitly asks.

Collect from these sources when the corresponding MCP tools are available:

1. `contacts`: identify the current user and relevant people by searching `吕夏苗`, known aliases, and names found in evidence.
2. `calendar`: query all calendar events in the date range; inspect details and participants for meetings, reviews, trainings, project discussions, and coordination work.
3. `ToDo`: query current-user todos; use completed, pending, high-priority, and overdue todos as work evidence when they fall in or clearly relate to the range.
4. `OAapproval`: query submitted, pending, processed, and copied approvals; fetch details for relevant instances and summarize only business-relevant approval actions.
5. `log`: query sent and received logs in the range; inspect details where titles or summaries suggest weekly reports, project progress, blockers, or decisions.
6. `doc`, `excel`, and `AIexcel`: search or inspect DingTalk documents, spreadsheets, and AI tables only when project names, meeting titles, approval titles, or todo titles suggest relevant work details.
7. `robotmessage` and `groupchat`: use group search and group metadata to locate likely work groups or project groups. Do not send robot messages or create groups.
8. Chat records and `@我`: **使用 Computer Use 采集聊天证据，详见下方"Computer Use 聊天证据采集"章节。**

## Collection Workflow

1. Compute the exact range in Beijing time and keep millisecond timestamps for MCP calls.
2. Establish identity:
   - default owner name: `吕夏苗`
   - if available, find the corresponding DingTalk userId through contacts or evidence details
   - do not infer another report owner from frequent names in groups
3. Query core sources first:
   - calendar events in the range
   - todos
   - OA approvals: submitted, pending/todo, processed/done, copied/notified
   - logs sent and received
4. Search communication evidence via Computer Use:
   - execute the full Computer Use chat evidence workflow (see dedicated section below)
5. Expand by keywords from the evidence:
   - project names, customer names, system names, requirement names, approval titles, meeting titles, todo subjects
   - inspect related docs/spreadsheets only when they can clarify work content, status, metrics, decisions, or blockers
6. Build an evidence ledger before writing the summary.

## Evidence Ledger

Track every usable item in this shape:

`日期｜事项｜来源｜证据类型｜归属判断｜状态/结果`

Rules:

- Use compact source names such as `钉钉日程 / 会议标题`, `OA审批 / 审批标题`, `待办 / 任务标题`, `群聊 / 群名`, `单聊 / 人名`, `日志 / 日志标题`, `文档 / 文档名`.
- Do not overquote private chat text. Paraphrase decisions, blockers, commitments, and outcomes.
- Keep only work attributable to `吕夏苗`: messages she sent, items assigned to her, approvals she submitted/handled, meetings she organized or attended, todos she owns or executes, and work where she is explicitly mentioned as responsible.
- Ignore pure notifications, system messages, step counts, and generic reminders unless they directly explain a work item.
- When evidence conflicts, prefer primary structured records in this order: approval/detail records, calendar/detail records, todo/detail records, logs/docs, then chat summaries. Note unresolved uncertainty briefly.

## Computer Use 聊天证据采集

**DingTalk MCP 不提供聊天消息历史读取接口，因此必须通过 Computer Use 操作钉钉桌面客户端来采集聊天证据。** 这是本 skill 的必执行步骤，与 calendar、ToDo、OA 等数据源同等重要，不可省略。

### 前置：通过 MCP 发现群组

在启动 Computer Use 之前，先用 MCP 工具发现相关群组，确定要检查的聊天范围：

1. 调用 `search_groups_by_keyword`（robotmessage MCP），用以下关键词逐一搜索：
   - `产品部`、`组长`、`项目`、`AI`、`数字化`、`周报`
   - 以及从 calendar/ToDo/OA 证据中提取的项目名、会议名
2. 记录所有搜到的群名和 openConversationId，按工作相关性排序
3. 优先检查与吕夏苗工作直接相关的群（如产品部组长群、项目群等）

### Computer Use 操作流程

调用 `$computer-use` skill 加载 Computer Use 工具集，然后按以下流程操作钉钉桌面客户端：

#### 第一步：打开钉钉

1. 截图确认当前桌面状态
2. 打开钉钉客户端（macOS: 打开 /Applications/DingTalk.app；Linux: 对应的启动命令）
3. 等待钉钉窗口加载，截图确认

#### 第二步：采集"@我"消息

1. 在钉钉主界面，找到并点击左侧导航栏的"消息"图标
2. 找到"@我"入口（通常在消息列表顶部或搜索栏附近），点击进入
3. 截图查看 @我 消息列表
4. 向下滚动，覆盖本周日期范围的所有 @我 消息
5. 对每条 @我 消息：点击进入查看上下文，截图记录关键讨论内容
6. 提取工作相关信息：决策、任务分配、问题反馈、进度更新等

#### 第三步：逐群检查消息

按前置步骤发现的群组列表，依次检查每个重要群聊：

1. 在钉钉搜索栏输入群名，定位目标群
2. 点击进入群聊
3. 滚动浏览本周日期范围内的消息
4. 重点关注：
   - 吕夏苗自己发送的消息（反映她主动推进的工作）
   - @吕夏苗 的消息（反映需要她关注/决策的事项）
   - 与已知工作项目相关的讨论（从 calendar/ToDo/OA 证据中交叉验证）
5. 对关键讨论截图留证
6. 提取工作要点，忽略纯闲聊、表情、系统通知

#### 第四步：检查重要单聊

1. 在消息列表中查找与工作相关的人员单聊（优先从 calendar 参会人、OA 审批相关人中找）
2. 进入单聊，浏览本周消息
3. 截图记录关键工作沟通
4. 注意：不要逐个检查所有单聊，只检查与本周已知工作直接相关的

### 证据提取规则

- **只记录工作相关信息**：决策、任务分配、问题反馈、进度更新、会议结论、承诺事项
- **忽略**：纯闲聊、表情包、系统通知、打卡、广告
- **归属判断**：只归入吕夏苗的工作——她发的消息、@她的消息、与她负责项目直接相关的讨论
- **隐私边界**：不要逐字引用聊天原文，用自己话概括工作要点；不暴露与他人无关的私人对话
- **证据来源标注**：在证据台账中使用 `群聊 / 群名` 或 `单聊 / 人名` 标注

### 异常处理

- 如果钉钉客户端未登录或无法打开，在"未覆盖/受限来源"中说明，继续完成其余步骤
- 如果 Computer Use 工具不可用（如环境不支持），在"未覆盖/受限来源"中说明，不阻塞整个 skill 执行
- 如果某些群聊因权限原因无法查看，跳过并记录

## Classification

Group atomic work items into these sections unless the user asks for another format:

- `发现与解决问题`: issue discovery, diagnosis, troubleshooting, risk handling, process correction, optimization.
- `业务与培训`: requirements, launches, project delivery, customer/business support, content/material work, training participation.
- `管理与协作`: cross-team alignment, meetings, reviews, scheduling, follow-ups, resource coordination, approval coordination.
- `学习与创新`: tool exploration, AI use, reusable workflows, process automation, new methods.

Avoid duplicating the same item across sections. Put it in the best-fit section and reference supporting sources in the ledger.

## Output

Default response in Chinese:

1. Title: `吕夏苗钉钉周工作总结（mcp-wb）`
2. `本周概览`: 3-5 sentences summarizing the main work themes and outcomes.
3. Four fixed sections:
   - one concise paragraph
   - numbered points using `1、2、3、`
4. `证据台账`: include when the user asks for traceability, when evidence is mixed across many MCP services, or when confidence would benefit from source visibility.
5. `未覆盖/受限来源`: list MCP services or chat sources that were unavailable, inaccessible, or returned no relevant data.

Write formally enough to paste into a weekly report. Be concrete: include project names, meeting titles, approval/todo/log titles, deliverables, decisions, and follow-up status when available.

## 输出到钉钉文档

**必须将总结结果输出到指定的钉钉文档。** 这是 skill 的必执行步骤，不可省略。

### 文档名称

`吕夏苗钉钉周工作总结（mcp-wb）`

### 目标文件夹

文档必须创建在指定的文件夹下，**folderId 固定为 `D1YKdxGX7EqVQZe2y71ZJe4QrZk95AzP`**（即 https://alidocs.dingtalk.com/i/nodes/D1YKdxGX7EqVQZe2y71ZJe4QrZk95AzP ）。

### 写入流程

1. 搜索是否已存在同名文档（通过 `search_documents` 按关键词 `吕夏苗钉钉周工作总结（mcp-wb）` 查找）。
2. 如果存在同名文档，先调用 `delete_document` 将其移入回收站。
3. 调用 `create_document` 创建新文档，参数如下：
   - `name`: `吕夏苗钉钉周工作总结（mcp-wb）`
   - `folderId`: `D1YKdxGX7EqVQZe2y71ZJe4QrZk95AzP`（**必传**，确保文档创建在指定文件夹下）
   - `markdown`: 完整总结内容
4. 记录新建文档的 `nodeId`，在回复中告知用户文档已生成并提供访问链接（格式：`https://alidocs.dingtalk.com/i/nodes/{nodeId}`）。

### 注意事项

- 不使用 `update_document` 的 overwrite 模式在旧文档上覆盖，而是删除旧文档后重建，确保文档内容干净无残留。
- 创建文档时**必须传 `folderId`**，否则文档会创建在"我的文档"根目录下而非指定文件夹。
- 创建文档后需确认返回的 `success` 字段为 `true`。
- 如果删除或创建失败，需在回复中明确报告错误信息。

## Safety

- 输出到钉钉文档是本 skill 的规定动作，不算"修改文档"，无需额外授权。
- 通过 Computer Use 操作钉钉客户端采集聊天证据是本 skill 的规定动作（只读浏览 + 截图），不算"修改数据"，无需额外授权。
- Computer Use 过程中只允许浏览和截图，**禁止**：发送消息、修改群设置、转发内容、撤回消息、进行任何写操作。
- Do not send DingTalk messages, create robots, create groups, change todos, modify approvals, create logs, or edit other documents unless explicitly requested.
- Do not expose unnecessary personal or sensitive chat content. Summarize only work-relevant facts.
- If a tool needs a `processCode` or similar schema identifier that is not known, first call the corresponding list/visible-process tool, then query likely forms.
