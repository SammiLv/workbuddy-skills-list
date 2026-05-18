---
name: 个人技能清单
description: Use when the user wants to list, audit, summarize, document, or update a registry of their personal Codex skills, including each skill's name, location, overview, and trigger conditions. Trigger this skill for requests such as "我有哪些个人 skill", "记录我创建的 skills", "列出每个 skill 的概述和触发器", "整理 skill 清单", or "更新个人 skill 目录".
---

# Personal Skill Inventory

## Overview

Create a current inventory of the user's personal Codex skills. The inventory should show which skills exist, what each skill does, where it lives, and what user requests should trigger it.

## Workflow

1. Locate personal skills.
   - Default to `${CODEX_HOME:-~/.codex}/skills`.
   - Treat immediate child folders with a `SKILL.md` file as personal skills.
   - Exclude `.system` and plugin cache folders unless the user explicitly asks to include system or plugin-provided skills.

2. Generate the inventory.
   - Run `scripts/generate_local_skills_index.sh` when updating the saved index file from an automation or manual request.
   - The script scans `${CODEX_HOME:-~/.codex}/skills`, excludes `.system`, prints visible progress, and writes Chinese-format Markdown to `LOCAL_SKILLS_INDEX.md`.
   - When the user asks to generate or save the inventory file, write it to `LOCAL_SKILLS_INDEX.md` in this skill's current directory: `/Users/sammilv/.codex/skills/personal-skill-inventory/LOCAL_SKILLS_INDEX.md`.
   - Do not create extra helper scripts unless the single shell script cannot support the requested change.
   - Do not write raw English script output directly into `LOCAL_SKILLS_INDEX.md`.

3. Summarize fields.
   - `Skill`: use the frontmatter `name` field when present; otherwise use the folder name.
   - `概述`: prefer the first useful paragraph under `## Overview` or `## Purpose`; otherwise summarize from the frontmatter `description`.
   - `触发器`: follow the local index convention and use the direct explicit invocation form `$skill-name`, derived from the frontmatter `name` field. Keep it short; do not paste the long frontmatter `description` into this column.
   - `路径`: include the absolute `SKILL.md` path when useful for maintenance.

4. Present results in Chinese by default.
   - When saving `LOCAL_SKILLS_INDEX.md`, include a `最后更新时间` line near the top using `Asia/Shanghai` time so manual automation runs are visible.
   - Use section-based Markdown rather than a table: `## Skill 列表`, then one `### skill-name` section per skill.
   - In each skill section, list `触发器`, `路径`, and `概述` as bullets.
   - Translate English source text into concise Chinese; preserve canonical skill names and direct triggers exactly.
   - The saved `LOCAL_SKILLS_INDEX.md` content must be Chinese-format Markdown. Only skill names, `$skill-name` triggers, and filesystem paths may remain untranslated.
   - After the table, mention any skills with missing or weak trigger descriptions.
   - Keep the answer focused on the inventory; do not rewrite skills unless the user asks.

## Maintenance Notes

- If a skill's trigger is too broad or too vague, recommend tightening the `description` frontmatter.
- If a skill lacks a clear Overview/Purpose section, recommend adding one so future inventory summaries are more useful.
- When updating this inventory skill itself, keep the script as the source of repeatable scanning logic and keep this `SKILL.md` short.

## Resources

- `scripts/generate_local_skills_index.sh`: single shell entrypoint for manual and automation runs; scans personal skills, writes `LOCAL_SKILLS_INDEX.md` in Chinese, and prints visible progress.
