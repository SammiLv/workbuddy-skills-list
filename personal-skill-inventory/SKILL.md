---
name: personal-skill-inventory
description: 当用户想列出、审计、总结、记录或更新当前 AI 工具的个人 skills 清单时使用，包括每个 skill 的名称、位置、概述和触发条件。触发请求包括：“我有哪些个人 skill”、“记录我创建的 skills”、“列出每个 skill 的概述和触发器”、“整理 skill 清单”、“更新个人 skill 目录”，或要求整理当前 AI 工具的 skills。
---

# 个人 Skill 清单

## 概述

为当前执行该 skill 的 AI 工具整理一份用户个人 skills 清单。清单应说明当前有哪些 skills、每个 skill 做什么、位于哪里，以及什么用户请求应触发它。

## 工作流程

1. 识别当前 AI 工具并定位个人 skills。
   - 默认使用当前 AI 工具的个人 skills 目录。
   - 在 Codex 中运行时，默认使用 `${CODEX_HOME:-~/.codex}/skills`。
   - 当该 skill 被复用到其它 AI 工具时，使用该工具运行时上下文、本地约定或用户明确提供的路径来定位 active skills 目录。
   - 如果运行时无法推断当前工具的 skills 目录，应询问用户路径，不要静默扫描其它工具的目录。
   - 可复用脚本支持这些覆盖项：`AI_TOOL_NAME` 用于显示工具名称，`AI_SKILLS_DIR` 或 `SKILLS_DIR` 用于指定扫描目录。
   - 只整理自建 skills：将当前工具个人 skills 根目录下、由用户创建或个人维护的一级 `SKILL.md` 目录纳入清单。
   - 不整理系统、内置、插件、市场安装、缓存、隐藏目录或由外部工具托管的 skills，除非用户明确要求包含。
   - 为适配 WorkBuddy 等工具环境，如果 skill frontmatter 中存在 `agent_created: false`，将其视为非自建 skill，并从清单中排除。
   - 在任何 AI 工具环境下，名为 `dws` 的 skill 都从清单中排除；可按目录名或 frontmatter `name: dws` 识别。
   - 如果某个工具无法通过元数据可靠区分“自建”和“外部提供”，默认只纳入当前个人 skills 根目录中的非系统、非插件、非缓存目录，并在结果中说明该判断依据。

2. 生成清单。
   - 当自动化任务或手动请求需要刷新已保存的索引文件时，运行 `scripts/generate_local_skills_index.sh`。
   - 该脚本是刷新保存文件的可重复入口；如果当前 AI 工具可以直接检查并总结 skills，交互式回答不必依赖脚本。
   - 该脚本适用于将 skills 存为“一级子目录 + `SKILL.md`”的工具。如果其它 AI 工具使用不同格式，应直接检查该工具的原生 skill 注册表；只有确有需要时才添加小型适配器。
   - 脚本会扫描已解析的当前工具 skills 目录，只整理自建 skills，排除系统、插件、市场安装和缓存目录，打印可见进度，并将 Markdown 固定写入本 skill 目录下的 `LOCAL_SKILLS_INDEX.md`。
   - 在 Codex 中运行且用户要求生成或保存清单文件时，只写入 `${CODEX_HOME:-~/.codex}/skills/personal-skill-inventory/LOCAL_SKILLS_INDEX.md`。
   - 在其它 AI 工具中运行时，默认将 `LOCAL_SKILLS_INDEX.md` 保存到该工具的 `personal-skill-inventory` skill 目录，除非用户要求修改脚本以支持其它固定输出位置。
   - 除非单个 shell 脚本无法支持请求的变更，否则不要创建额外辅助脚本。
   - 当用户偏好中文时，保存的索引应优先使用中文 Markdown 格式。

3. 总结字段。
   - `Skill`：优先使用 frontmatter 中的 `name` 字段；没有时使用文件夹名。
   - `概述`：从每个 skill 的 frontmatter `description` 获取，并再精简成一句话。优先保留“这个 skill 做什么”，去掉触发词示例、适用请求清单、实现细节和冗长限定。
   - `触发器`：遵循本地索引约定，使用由 frontmatter `name` 字段派生的 `$skill-name` 显式调用形式。保持简短，不要把冗长的 frontmatter `description` 原文粘贴到这一栏。
   - `路径`：维护时有用的情况下，包含绝对 `SKILL.md` 路径。

4. 默认用中文呈现结果。
   - 保存 `LOCAL_SKILLS_INDEX.md` 时，在文件顶部附近加入 `最后更新时间`，使用 `Asia/Shanghai` 时间，方便确认手动或自动化任务确实运行过。
   - 使用分章节 Markdown，不使用表格：先写 `## Skill 列表`，然后每个 skill 一个 `### skill-name` 小节。
   - 每个 skill 小节中用项目符号列出 `触发器`、`路径` 和 `概述`。
   - 将英文来源内容翻译成简洁中文；规范 skill 名称和直接触发器保持原样。
   - 当用户语言偏好为中文时，保存的 `LOCAL_SKILLS_INDEX.md` 应为中文格式 Markdown。只有 skill 名称、`$skill-name` 触发器和文件系统路径可以不翻译。
   - 在清单范围说明中明确写出“仅整理自建 skills”，避免把系统、插件或市场来源 skills 混入。
   - 清单之后，指出触发描述缺失或过弱的 skills。
   - 回答应聚焦清单本身；除非用户要求，不要改写其它 skills。

## 维护说明

- 如果某个 skill 的触发条件过宽或过模糊，建议收紧 frontmatter 中的 `description`。
- 如果某个 skill 缺少清晰的 `Overview`、`Purpose` 或 `概述` 章节，建议补充，以便后续清单总结更有用。
- 更新本清单 skill 自身时，脚本只保留为可重复刷新保存索引的辅助入口。可移植行为应写在本 `SKILL.md` 中，确保其它 AI 工具即使不运行 shell 脚本也能复用该 skill。

## 资源

- `scripts/generate_local_skills_index.sh`：手动和自动化运行的单一 shell 入口；扫描当前 AI 工具的个人 skills，固定写入本 skill 目录下的 `LOCAL_SKILLS_INDEX.md`，并打印可见进度。
