---
name: cross-ai-skill-sync
description: 当用户需要把某个本地 skill 的变更或 skills 根目录文件同步到其它 AI 工具的 skills 目录时使用。适用于 Codex、Cursor、WorkBuddy、OpenCode、Claude、Trae、Trae CN、Cline、Gemini 等本地工具之间同步同名 skill、同步 .gitignore 等根目录文件，或建立经常性的跨工具 skill 维护流程。
---

# 跨 AI 工具 Skill 同步

## 概述

把当前 AI 工具中的一个本地 skill，或 skills 根目录下的单个配置文件，同步到其它 AI 工具的个人 skills 目录。用于维护一份主版本，并让其它工具获得相同的 `SKILL.md`、脚本、资源和必要根目录配置。

## 工作流程

1. 确认源内容。
   - 默认源 skills 根目录为当前工具的 skills 目录。
   - 在 Codex 中通常是 `${CODEX_HOME:-~/.codex}/skills`。
   - 如果用户指定 skill 名称，使用该名称；否则可从当前 skill 目录推断。
   - 如果用户要求同步根目录文件，例如 `.gitignore`，使用 `--file` 模式。
   - 如果用户指定源路径或目标路径，优先使用用户指定内容。

2. 执行同步。
   - 不带参数运行 `scripts/sync_skill_to_ai_tools.sh` 时，从其它 AI 工具中选择同名 skill 最新的一份，同步回当前工具。
   - 带 `all` 运行 `scripts/sync_skill_to_ai_tools.sh all` 时，将当前 skill 同步到所有其它 AI 工具。
   - 带工具名运行 `scripts/sync_skill_to_ai_tools.sh cursor`、`scripts/sync_skill_to_ai_tools.sh trae` 等时，只同步到指定 AI 工具。
   - 同步指定 skill 时，运行 `scripts/sync_skill_to_ai_tools.sh personal-skill-inventory all` 或 `scripts/sync_skill_to_ai_tools.sh --skill personal-skill-inventory trae`。
   - 同步根目录文件时，运行 `scripts/sync_skill_to_ai_tools.sh --file .gitignore all` 或 `scripts/sync_skill_to_ai_tools.sh --file .gitignore cursor`。
   - 向其它工具推送时，脚本会先检查所有工具中的同名 skill；如果当前源不是最新版本，会询问是否继续，避免旧版本误覆盖新版本。
   - 如果已经明确确认要用当前源覆盖更新版本，可追加 `--force` 跳过询问。
   - 脚本默认在现有个人 skills 目录之间同步：Codex、Cursor、WorkBuddy、OpenCode、Claude、Trae、Trae CN、Cline、Gemini。
   - 自动跳过源目录和不存在的目标目录。
   - 使用 `rsync -a --delete` 保持目标同名 skill 与源目录一致。
   - 同步根目录文件时，只覆盖目标根目录下的同名文件，不删除目标目录中的其它内容。
   - 排除 `.DS_Store` 和 `LOCAL_SKILLS_INDEX.md`，避免把某个工具的本地生成索引覆盖到其它工具。
   - 可通过 `AI_SKILLS_DIR` 指定源 skills 根目录。
   - 支持的工具名：`codex`、`cursor`、`workbuddy`、`opencode`、`claude`、`trae`、`trae-cn`、`cline`、`gemini`。

3. 验证结果。
   - 同步后用 `diff -qr --exclude LOCAL_SKILLS_INDEX.md --exclude .DS_Store` 比对源和目标同名 skill。
   - 如果目标工具目录需要额外生成本地索引，应在对应工具中运行它自己的索引生成脚本，而不是复制其它工具生成的索引文件。

## 资源

- `scripts/sync_skill_to_ai_tools.sh`：跨 AI 工具同步指定同名 skill 或 skills 根目录文件的可复用脚本。
