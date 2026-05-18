---
name: WorkBuddy工作周报
description: Generate a Chinese weekly work summary from the user's WorkBuddy activity, defaulting to the current week, and display it in the current conversation. Use when the user asks to summarize what they did in WorkBuddy this week, last week, over a date range, or asks for a WorkBuddy weekly report, weekly review, work log, or recap based on WorkBuddy sessions.
---

# Weekly WorkBuddy Work Summary

## Overview

Create a concise, useful Chinese weekly report from WorkBuddy memory files. Focus on the user's actual work themes, completed outcomes, created or changed artifacts, verification, and follow-ups.

## Workflow

1. Resolve the target week or date range.
   - Default to the current local week, Monday through today.
   - Respect explicit requests such as "本周", "上周", "这周", "最近一周", or "2026-05-11 到 2026-05-15".
   - Clarify with absolute dates when relative dates could be confusing.

2. Gather local WorkBuddy activity.
   - Read daily memory files at `~/.workbuddy/memory/YYYY-MM-DD.md` for each day in the target range.
   - Also read `~/.workbuddy/memory/MEMORY.md` for long-term context and preferences relevant to the week's work.
   - Workspace-specific memory may also exist at `{workspace}/.workbuddy/memory/YYYY-MM-DD.md` if the user works across multiple projects.
   - For each day in the range, check whether the file exists; skip missing dates silently.
   - Do not use network access.

3. Read only relevant evidence.
   - Prioritize task descriptions, completed work items, file paths, artifacts created or modified, and key decisions.
   - Skip transient information: intermediate search results, temporary file paths, tool errors.
   - If a daily file is large, focus on completed tasks and key decisions.

4. Summarize by workstream, not by day.
   - Merge multiple daily notes about the same project or task into one weekly item.
   - Prefer concrete outcomes over process details.
   - Distinguish completed work, partial work, blocked work, and investigation-only work.
   - Keep dates as supporting context, not the main structure, unless the user asks for a day-by-day report.

5. Write the final summary to DingTalk Docs.
   - Default target folder: `https://alidocs.dingtalk.com/i/nodes/D1YKdxGX7EqVQZe2y71ZJe4QrZk95AzP`
   - Default document title: `吕夏苗workbuddy周工作总结`
   - Before creating, search the target folder for a document with the same title and delete it first, then create a new one.
   - If the user explicitly provides another folder or title, follow the user's override.
   - After writing, display a brief confirmation and the document link in the current conversation.

6. Output in Chinese unless the user asks otherwise.

## Report Format

Use this format by default:

```markdown
**吕夏苗workbuddy周工作总结｜YYYY-MM-DD 至 YYYY-MM-DD**

本周主要完成了：

1. 项目/主题：一句话说明做了什么。
   产出：列出关键文件、文档、skill、脚本、页面或结论。
   验证：列出运行过的检查；如果没有验证，写"未单独验证"。

2. ...

**本周重点产出**
- 可交付文件、页面、脚本、skill、文档或明确结论。

**待跟进**
- 明确的下一步、风险或需要用户确认的事项；没有就写"暂无明确待跟进项"。
```

For a shorter user request, return a compact paragraph plus bullets. For a detailed request, include sections for "完成事项", "产出物", "验证情况", and "待跟进".

## Quality Bar

- Be specific enough that the user can remember the week's work without reopening every thread.
- Mention paths only when they are useful deliverables or changed files.
- Preserve privacy: do not quote secrets, tokens, private config values, or long message bodies.
- Keep speculation out of the report. Use "看起来" or "可能" only when the memory evidence is incomplete.
- If no WorkBuddy memory files with concrete work are found for the target range, say that clearly and mention the exact dates checked.

## Resources

- `~/.workbuddy/memory/YYYY-MM-DD.md`: Daily memory files written by WorkBuddy after completing substantive work each session.
- `~/.workbuddy/memory/MEMORY.md`: Long-term curated memory with user preferences and project conventions.
- `references/source-notes.md`: Notes about the local WorkBuddy memory files this skill expects.
