---
name: 钉钉周工作总结（cu）
description: Use when the user wants a personal weekly report generated from DingTalk communication records and calendar events, especially chat/group-chat based work summaries that need to be organized into the four sections 发现与解决问题、业务与培训、管理与协作、学习与创新, with optional traceable ledger items and DingTalk Docs output.
---

# DingTalk Personal Weekly Report

## Overview

Use this skill to turn a user's DingTalk communication and calendar activity into a reusable weekly report workflow. It is designed for cases where the evidence comes from chat records, group discussions, @mentions, message timelines, calendar events, and relevant DingTalk documents rather than a prewritten worklog.

Default output should support both:
- a direct weekly report summary under four fixed sections
- an optional traceable ledger with `时间｜事项｜来源`

## Workflow

1. Confirm the reporting range.
   - Default rule: summarize the 7-day period ending on the current date.
   - In practice, when the user asks for a weekly summary near the end of the current week, treat the current date as the end date and trace back 7 calendar days inclusively for evidence collection.
   - If the user explicitly says `上周`, `本周`, or gives a custom date range, follow the user's range instead.
   - In China-locale threads, prefer explicit dates like `2026年5月5日-2026年5月11日`.

2. Confirm the report subject.
   - Fixed rule for this skill: the report owner is `吕夏苗`, and the weekly report must summarize `吕夏苗`'s work unless the user explicitly overrides it.
   - Default rule: the report subject is the current user themself, not the most frequently mentioned person in DingTalk chats.
   - In this workflow, never infer the report owner from arbitrary names that appear in group messages, @mentions, or copied chat snippets.
   - If the user has already established their name in the thread, use that name consistently in the title and summary.
   - If the user explicitly asks for another person's weekly report, switch to that named subject.
   - If the subject is genuinely unclear and no prior identity is established, ask before generating the final report title.

3. Collect DingTalk evidence.
   - Prefer the DingTalk desktop app via `computer-use` when the source is chat history or group discussion.
   - Always include DingTalk calendar events for the reporting range when calendar MCP access is available. Meeting-driven work is part of the weekly report evidence, not optional background.
   - Prioritize:
     - `@我`
     - recent one-to-one chats
     - recent group chats tied to work
     - threads where the user clearly spoke or was explicitly mentioned
     - calendar events where the report owner is organizer or attendee
     - meetings whose title, description, participants, or room booking indicate product, project, management, review, or training work
   - For each calendar event used, record the meeting title and date as a source such as `钉钉日程 / 伏羲慧眼2.0迭代需求讨论会`.
   - Treat project-specific meeting titles as concrete work evidence. For example, if the range contains `伏羲慧眼2.0迭代需求讨论会`, include it under the most relevant section instead of omitting it because it was found in calendar rather than chat.
   - Search DingTalk Docs or existing department summary materials for project keywords that appear in calendar or chats, especially strategic product names and ToB projects such as `伏羲慧眼`, `伏羲慧心`, `科管系统`, `采购平台`, `锐竞学术`, and `AI开发应用平台`.
   - When a project appears across multiple sources, combine evidence carefully:
     - use calendar events for participation and meeting-driven work
     - use chat/group records for decisions, follow-ups, blockers, or direct communication
     - use documents or department summaries for project status, design handoff, metrics, and official wording
   - Ignore generic noise such as approvals, step counts, and pure notification traffic unless the user says otherwise.

4. Separate evidence into concrete items.
   - Do not merge unrelated threads into one item.
   - A message about `百度SEO收录` and a message about `采购平台产品页上线` are two items, even if they happened on the same day.
   - A meeting about `伏羲慧眼2.0迭代需求讨论会` and a design status item about `伏羲慧心+联盟介绍优化需求` are separate items unless the sources show they are the same follow-up.
   - Prefer short, decision-oriented item wording.

5. Classify items into the fixed four sections.
   - `发现与解决问题`: issues, diagnosis, troubleshooting, correction, optimization direction
   - `业务与培训`: launches, requirements, content/material work, business support, training participation
   - `管理与协作`: coordination, alignment, scheduling, internal review, cross-team follow-up, personnel/group management
   - `学习与创新`: tool exploration, new methods, reusable patterns, workflow innovation

6. Produce the summary layer first.
   - For each section, write:
     - one concise overview paragraph
     - a numbered `1、2、3、` summary list that can be copied directly into a weekly report

7. Produce the ledger layer when needed.
   - Put `【台账】` under the section summary.
   - Use the exact format:
     - `时间：5月9日｜事项：……｜来源：群名 / 人名 / 事项关键词。`
   - Keep source compact: usually `群名 / 人名 / 事项关键词`; for meetings, use `钉钉日程 / 会议标题`; for document-derived project status, use `文档名 / 章节或事项关键词`.

8. Write to DingTalk Docs when requested.
   - Unless the user explicitly overrides the destination, write the final document under the fixed DingTalk folder `https://alidocs.dingtalk.com/i/nodes/D1YKdxGX7EqVQZe2y71ZJe4QrZk95AzP`.
   - If the user explicitly gives another DingTalk folder or node, follow the user's override instead of the default folder above.
   - Before creating a new DingTalk document, search the target folder for a document with the same final title and delete that same-name document first, then create the new one. Do not reuse, update, or overwrite the old same-name document in place.
   - Prefer a deterministic title such as `吕夏苗钉钉周工作总结（cu）` or `吕夏苗钉钉周工作总结（cu）（YYYY年M月D日-YYYY年M月D日）` so same-name cleanup is reliable.
   - If the user wants both traceability and direct weekly report use, keep them in the same document:
     - top: `本周小结`
     - then each section:
       - summary paragraph
       - numbered summary list
       - blank line
       - `【台账】`
       - ledger entries

## Output Rules

- Keep wording formal and reusable.
- Prefer management-facing prose over chatty narration.
- Do not overquote chat messages.
- Do not rely only on chat history when calendar access is available. Before finalizing, check whether the date range contains meetings, reviews, training sessions, project discussions, or leave/status events that should appear in the summary or ledger.
- Do not omit important project communication just because it appears in calendar or department materials rather than direct chat messages.
- For recurring or strategic projects, actively check obvious project keywords from the evidence. If a key project appears in the user's correction, add that keyword to future evidence collection heuristics.
- Keep each item atomic.
- Unless the user explicitly overrides it, treat `吕夏苗` as the fixed report owner, and summarize only work attributable to `吕夏苗`.
- Remove duplicates across sections. One event should live in the best-fit section only.
- If the same event appears in both summary and ledger, that is expected; avoid repeating it in multiple sections.
- The document title must use `吕夏苗钉钉周工作总结（cu）` (with optional date range suffix), not a guessed name from chat participants.
- When writing to DingTalk Docs, if a same-name document already exists in the target folder, delete it first and then create a brand-new document for the new summary; do not overwrite the old document in place.
- When writing to DingTalk Docs, default to the fixed target folder `https://alidocs.dingtalk.com/i/nodes/D1YKdxGX7EqVQZe2y71ZJe4QrZk95AzP` unless the user explicitly overrides it.
- When writing to DingTalk Docs, delete same-name documents in the target folder before creating the new final document.

## Template

Read [references/template.md](references/template.md) when you need the exact document structure, section pattern, or ledger format.
