---
name: WorkBuddy工作日报
description: Generate a daily Chinese work summary from the user's WorkBuddy activity, defaulting to the most recent prior day with concrete work (starting from yesterday), and display the summary in the current conversation. Use when the user asks to summarize what they did in WorkBuddy yesterday, today, on a specific date, or asks for a daily WorkBuddy work report, WorkBuddy daily review, work log, or end-of-day recap based on WorkBuddy sessions.
---

# Daily WorkBuddy Work Summary

## Overview

Create a concise, useful Chinese daily report from WorkBuddy memory files and display it in the current conversation. Focus on what the user asked WorkBuddy to do, what was completed, what files or artifacts were created or changed, what was verified, and what follow-ups remain.

## Workflow

1. Resolve the target date.
   - Default to yesterday's local date from the active environment context.
   - If yesterday has no concrete WorkBuddy work, keep moving backward one local day at a time until you find the most recent date with concrete work, and summarize that day instead.
   - Respect explicit dates such as "今天", "上周五", or "2026-05-15"; clarify with absolute dates when there is ambiguity.

2. Gather local WorkBuddy activity.
   - Primary source: read the daily memory file at `~/.workbuddy/memory/YYYY-MM-DD.md` (or the workspace-specific path if applicable, e.g. `{workspace}/.workbuddy/memory/YYYY-MM-DD.md`).
   - Also check `~/.workbuddy/memory/MEMORY.md` for long-term context and preferences relevant to the day's work.
   - For the default summary flow, if the first checked date has no concrete work, continue checking earlier dates until you find one with concrete work.
   - Do not use network access.

3. Read only the relevant parts of memory files.
   - Prioritize task descriptions, completed work items, file paths, artifacts created, and verification results.
   - Skip transient information, intermediate search results, and temporary file paths.
   - If a memory file is large, focus on completed tasks and key decisions.

4. Summarize by work, not by raw notes.
   - Merge multiple notes about the same task into one item.
   - Prefer concrete outcomes over process details.
   - Distinguish completed work, partial work, blocked work, and investigation only.

5. Display the final summary directly in the current conversation.

6. Output in Chinese unless the user asks otherwise.

## Report Format

Use this format by default:

```markdown
## YYYY-MM-DD

**WorkBuddy 工作日报｜YYYY-MM-DD**

昨天主要完成了：

1. 项目/主题：一句话说明做了什么。
   产出：列出关键文件、文档、skill、脚本、页面或结论。
   验证：列出运行过的检查；如果没有验证，写"未单独验证"。

2. ...

**待跟进**
- 明确的下一步、风险或需要用户确认的事项；没有就写"暂无明确待跟进项"。
```

For a shorter user request, return a compact paragraph plus bullets. For a detailed request, include sections for "完成事项", "产出物", "验证情况", and "待跟进".

## Quality Bar

- Be specific enough that the user can remember the day's work without reopening every thread.
- Mention paths only when they are useful deliverables or changed files.
- Keep speculation out of the report. Use "看起来" or "可能" only when the memory evidence is incomplete.
- Preserve privacy: do not quote secrets, tokens, private config values, or long message bodies.
- For the default summary flow, clearly state the final summarized date if it was backtracked from yesterday because intermediate dates had no concrete work.
- If no WorkBuddy memory files with concrete work are found after backtracking, say that clearly and mention the checked date range.

## Resources

- `~/.workbuddy/memory/YYYY-MM-DD.md`: Daily memory files written by WorkBuddy after completing substantive work.
- `~/.workbuddy/memory/MEMORY.md`: Long-term curated memory with user preferences and project conventions.
- `references/source-notes.md`: Notes about the local WorkBuddy memory files this skill expects.
