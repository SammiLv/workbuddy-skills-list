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
8. Chat records and `@我`: when a chat-history MCP is available, query direct chats, group chats, and messages where `吕夏苗` is mentioned. If MCP chat history is not available, use DingTalk desktop via Computer Use only if the user has asked for a live run and the UI is accessible.

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
4. Search communication evidence:
   - direct chats involving the owner
   - group chats with owner messages or `@吕夏苗` / `@我`
   - project groups discovered through group search
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

## Classification

Group atomic work items into these sections unless the user asks for another format:

- `发现与解决问题`: issue discovery, diagnosis, troubleshooting, risk handling, process correction, optimization.
- `业务与培训`: requirements, launches, project delivery, customer/business support, content/material work, training participation.
- `管理与协作`: cross-team alignment, meetings, reviews, scheduling, follow-ups, resource coordination, approval coordination.
- `学习与创新`: tool exploration, AI use, reusable workflows, process automation, new methods.

Avoid duplicating the same item across sections. Put it in the best-fit section and reference supporting sources in the ledger.

## Output

Default response in Chinese:

1. Title: `吕夏苗钉钉周工作总结（mcp）`
2. `本周概览`: 3-5 sentences summarizing the main work themes and outcomes.
3. Four fixed sections:
   - one concise paragraph
   - numbered points using `1、2、3、`
4. `证据台账`: include when the user asks for traceability, when evidence is mixed across many MCP services, or when confidence would benefit from source visibility.
5. `未覆盖/受限来源`: list MCP services or chat sources that were unavailable, inaccessible, or returned no relevant data.

Write formally enough to paste into a weekly report. Be concrete: include project names, meeting titles, approval/todo/log titles, deliverables, decisions, and follow-up status when available.

## Safety

- Read-only by default.
- Do not send DingTalk messages, create robots, create groups, change todos, modify approvals, create logs, or edit documents unless explicitly requested.
- Do not expose unnecessary personal or sensitive chat content. Summarize only work-relevant facts.
- If a tool needs a `processCode` or similar schema identifier that is not known, first call the corresponding list/visible-process tool, then query likely forms.
