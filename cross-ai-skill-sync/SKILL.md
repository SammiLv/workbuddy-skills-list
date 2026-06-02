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
   - 如果用户要求同步根目录文件，例如 `.gitignore`，使用 `-file` 模式。
   - 如果用户指定源路径或目标路径，优先使用用户指定内容。

2. 执行同步。

   脚本默认在以下个人 skills 目录之间同步：Codex、Cursor、WorkBuddy、OpenCode、Claude、Trae、Trae CN、Cline、Gemini。自动跳过源目录和不存在的目标目录。向其它工具推送时，脚本会先检查所有工具中的同名 skill；如果当前源不是最新版本，会询问是否继续，避免旧版本误覆盖新版本。如果已经明确确认要用当前源覆盖更新版本，可追加 `-force` 跳过询问。

   各 AI 工具的默认 skills 路径如下：
   - Codex：`${HOME}/.codex/skills`
   - Cursor：`${HOME}/.cursor/skills`
   - WorkBuddy：`${HOME}/.workbuddy/skills`
   - OpenCode：`${HOME}/.config/opencode/skills`
   - Claude：`${HOME}/.claude/skills`
   - Trae：`${HOME}/.trae/skills`
   - Trae CN：`${HOME}/.trae-cn/memory/skills`
   - Cline：`${HOME}/.cline/skills`
   - Gemini：`${HOME}/.gemini/skills`

   | 参数 | 说明 |
   |------|------|
   | `-to <工具名\|all>` | 推送模式：将当前工具的 skill/文件同步到指定工具或全部工具 |
   | `-from <工具名\|all>` | 拉取模式：从指定工具或全部工具中选择最新版本拉取到当前工具 |
   | `-skill <名称>` | 指定要同步的 skill 名称，不加则默认为当前所在 skill |
   | `-file <文件名>` | 同步 skills 根目录下的指定文件（如 `.gitignore`），不可与 `-skill` 同时使用 |
   | `-force` | 跳过版本确认，强制用当前源覆盖（谨慎使用） |
   | `-diff` | 对所有 AI 工具中的同名 skill 进行版本对比（含份数统计），不执行同步 |
   | `-help, -h` | 查看脚本完整用法说明 |

   ---

   | 使用场景 | 执行示例 |
   |---------|---------|
   | 从其它 AI 工具拉取当前目录 skill 到当前工具(自己更新自己) | `sync_skill_to_ai_tools.sh -from all` |
   | 从其它 AI 工具拉取指定 skill 到当前工具 | `sync_skill_to_ai_tools.sh -from all -skill personal-skill-inventory` |
   | 从其它 AI 工具拉取根目录文件到当前工具 | `sync_skill_to_ai_tools.sh -from all -file .gitignore` |
   | 从指定 AI 工具拉取当前目录 skill 到当前工具 | `sync_skill_to_ai_tools.sh -from cursor` |
   | 从指定 AI 工具拉取指定 skill 到当前工具 | `sync_skill_to_ai_tools.sh -from cursor -skill personal-skill-inventory` |
   | 从指定 AI 工具拉取其根目录指定文件到当前工具 | `sync_skill_to_ai_tools.sh -from cursor -file .gitignore` |
   | 将当前目录 skill 同步到所有其它 AI 工具 | `sync_skill_to_ai_tools.sh -to all` |
   | 将当前目录 skill 只同步到指定 AI 工具 | `sync_skill_to_ai_tools.sh -to cursor` |
   | 同步指定 skill 到所有其它 AI 工具 | `sync_skill_to_ai_tools.sh -to all -skill personal-skill-inventory` |
   | 同步指定 skill 到指定 AI 工具 | `sync_skill_to_ai_tools.sh -to trae -skill personal-skill-inventory` |
   | 同步根目录指定文件到所有其它 AI 工具 | `sync_skill_to_ai_tools.sh -to all -file .gitignore` |
   | 同步根目录指定文件到指定 AI 工具 | `sync_skill_to_ai_tools.sh -to cursor -file .gitignore` |
   | 强制用旧版本覆盖新版本 | `sync_skill_to_ai_tools.sh -to all -skill weekly-report-summary -force` |
   | 对所有 AI 工具中的 skill 进行版本对比 | `sync_skill_to_ai_tools.sh -diff` |

   ---

   - **在终端执行**：`cd ~/.workbuddy/skills/cross-ai-skill-sync/scripts && bash sync_skill_to_ai_tools.sh -to all`
   - **在 AI 工具中执行**：直接在对话中描述需求，工具会自动调用本 skill 并执行对应命令，无需手动 `cd`。

   - 使用 `rsync -a --delete` 保持目标同名 skill 与源目录一致。同步根目录文件时，只覆盖目标根目录下的同名文件，不删除目标目录中的其它内容。
   - 排除 `.DS_Store` 和 `LOCAL_SKILLS_INDEX.md`，避免把某个工具的本地生成索引覆盖到其它工具。
   - 可通过 `AI_SKILLS_DIR` 指定源 skills 根目录。
   - 支持的工具名：`codex`、`cursor`、`workbuddy`、`opencode`、`claude`、`trae`、`trae-cn`、`cline`、`gemini`。


3. 验证结果。
   - 同步后用 `diff -qr --exclude LOCAL_SKILLS_INDEX.md --exclude .DS_Store` 比对源和目标同名 skill。
   - 如果目标工具目录需要额外生成本地索引，应在对应工具中运行它自己的索引生成脚本，而不是复制其它工具生成的索引文件。

## 资源

- `scripts/sync_skill_to_ai_tools.sh`：跨 AI 工具同步指定同名 skill 或 skills 根目录文件的可复用脚本。
