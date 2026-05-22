---
name: AI工具一周使用总结
description: 从本地 AI 工具会话记录生成一周工作总结，支持单工具、多工具或全量汇总。触发词：帮我总结AI工具一周的工作。可在触发词后附加工具名（如 cursor、codex）指定单个或多个工具，附加 all 表示全量扫描所有本地工具，不附加任何参数则默认总结当前使用的 AI 工具。适用于 Claude Code、Codex、Cursor、OpenCode、Trae、WorkBuddy 等 AI 工具。如需写入钉钉文档，在触发词后附上【钉钉文件夹链接】。总结内容的输出格式按指定模板要求输出。
---

# AI 工具一周使用总结

## 使用说明

**触发方式：**

| 触发词示例 | 行为 |
|---|---|
| `帮我总结AI工具一周的工作` | 总结**当前使用的** AI 工具 |
| `帮我总结AI工具一周的工作 cursor` | 只总结 Cursor |
| `帮我总结AI工具一周的工作 cursor codex` | 只总结 Cursor 和 Codex |
| `帮我总结AI工具一周的工作 all` | 扫描并总结**所有本地** AI 工具 |
| 以上任意 + `【钉钉文件夹链接】` | 额外写入钉钉文档 |

**统计周期：** 以当前日期往回 7 天（含今天），不使用自然周。

**注意事项：**

- 本 Skill 的总结目的在于为每周工作周报提供 AI 工具使用情况相关的数据源。
- 本 Skill 查询文件较多，token 消耗也较多。`SKILL.md` 是精简版，资源消耗相对良好；`SKILL完整版.md` 是完整版，资源消耗较大，对模型稳定性的要求也相对较高。
- 会话输出的格式可能存在不按模板执行的情况，不影响使用。

## 输出格式

> **以下规则优先级最高，生成内容时必须严格遵守，不得以任何形式绕过。**
### 输出模板（强制参考外部文件）

> **输出时必须严格对照以下两个模板文件的结构和字段格式，不得自行改变章节顺序或字段名称。**
> **严禁会话输出不按模板格式输出。**

- **单工具**（只有 1 个工具有有效记录）：参考 `单个AI工具的输出格式模板.md`
- **多工具 / all**（2 个及以上工具有有效记录）：参考 `多个AI工具的输出格式模板.md`

两个模板文件与本 SKILL.md 位于同一目录下。生成输出前必须先读取对应模板文件（路径 = 本 SKILL.md 所在目录 + 模板文件名），以模板的章节结构、字段名称、缩进格式为准，用本次实际内容填充。


## Quality Bar

- 按 5-15 个工作主题合并，不逐日展开每条会话。
- 每个字段用短语或短句，不写超过 30 字的长句。
- 产出物列举用顿号或分点，不堆砌成一段。
- 清楚区分"已完成""部分完成""受阻""仅调研"。
- 只在路径是有价值的产出物或变更文件时才提及路径。
- 不引用 token、密钥、私有配置值或完整消息体。
- 若没有找到任何有效会话记录，说明已检查的工具、目录和日期范围。

## Workflow

### 第 0 步：解析模式

读取触发词之后、钉钉链接之前的参数，判断进入哪种模式：

- **当前工具模式**（默认）：用户未附加任何工具参数。根据当前运行环境自动判断工具名（如在 Cursor 中即为 cursor），只总结该工具，报告标题使用单工具格式。
- **单/多工具模式**：用户指定了一个或多个工具名（不区分大小写）。只处理指定工具，跳过其他工具。
- **all 模式**：用户指定 `all`。扫描所有已知本地目录，有会话记录的工具全部纳入，无记录的标注"已检查但无有效记录"。

**工具名别名映射（不区分大小写）：**
- `cursor` → Cursor
- `claudecode` / `claude` / `claude code` → Claude Code
- `codex` → Codex
- `opencode` / `open code` → OpenCode
- `trae` / `trae cn` → Trae（统一显示名；扫描两个安装，输出禁止称 Trae CN）
- `workbuddy` / `work buddy` → WorkBuddy

### 第 1 步：确定时间范围

- 固定为当前日期往回 7 天（含今天）。
- 示例：当前日期为 2026-05-21 时，范围为 2026-05-15 至 2026-05-21。
- 后续所有会话筛选都必须落在该时间范围内。

### 第 2 步：确定待处理工具列表

- **当前工具模式 / 单/多工具模式**：直接使用解析到的工具列表，不扫描其他工具。
- **all 模式**：依次检查以下本地目录，有可读记录则纳入：
  - Cursor：`~/.cursor/projects/*/agent-transcripts/**/*.jsonl`
  - Claude Code：`~/.claude/history.jsonl`、`~/.claude/projects/*/*.jsonl`、`~/.claude/projects/*/memory/YYYY-MM-DD.md`
  - Codex：`~/.codex/sessions/**/*.jsonl`、`~/.codex/history.jsonl`
  - OpenCode：`~/.local/share/opencode/opencode.db`（session 表）
  - Trae：`~/Library/Application Support/Trae/User/workspaceStorage/*/state.vscdb`、`~/Library/Application Support/Trae CN/User/workspaceStorage/*/state.vscdb`
  - WorkBuddy：`~/.workbuddy/workbuddy.db`（sessions 表）、`~/.workbuddy/projects/*/*.jsonl`
- 不使用网络访问，不扫描无关大目录。

### 第 3 步：收集各工具会话记录

> **⚠️ 严禁使用文件系统时间（mtime/ctime）筛选会话文件。**
> 文件的修改时间可能因同步、索引等原因被意外更新，与会话实际发生时间无关。必须解析文件内部的时间戳字段来判断该文件是否在目标日期范围内。
>
> **正确流程：先扫描发现候选文件 → 逐文件解析内部时间戳 → 只保留有消息落在目标范围内的文件 → 再提取内容。**
> 没有内部时间戳的文件直接跳过，不做猜测。

**范围校验（在生成摘要之前必做）：**
统计每个工具命中的有效记录条数，打印简明清单（`工具名 → N 条`）。Claude Code 以 history.jsonl 去重 sessionId 数为准；OpenCode 以 session 表命中数为准；Trae 以 memento session 去重数为准（须执行 Trae 专节脚本，禁止误读 ChatStore）；WorkBuddy 以 sessions 表命中数为准；其他工具以 user_query / 用户消息为准。命中数为 0 的工具排除，不纳入报告。全部为 0 时直接报告"目标日期范围内未找到有效会话"并列出已检查路径。

只读取第 2 步确认纳入的工具，按工具逐一处理：

- **Cursor**
  - 遍历 `~/.cursor/projects/*/agent-transcripts/**/*.jsonl`。
  - 只读取父会话文件：路径形如 `agent-transcripts/<sessionId>/<sessionId>.jsonl`；跳过 `subagents/*.jsonl`。
  - **时间过滤**：解析每行 JSON 中 `role: "user"` 消息里 `message.content[].text` 内的 `<timestamp>...</timestamp>` 标签。时间戳格式为 `"Thursday, May 21, 2026, 2:06 PM (UTC+8)"`，必须解析 UTC 偏移量后与目标范围比较，只保留落在范围内的消息。
  - 提取对应的 `<user_query>...</user_query>` 作为任务描述，必要时读取相邻 assistant 消息确认结果。

- **Claude Code**
  - **`history.jsonl` 的 `timestamp` 是毫秒整数，不是日期字符串；禁止用 grep 匹配 `2026-05-xx`，否则会命中 0 条。**
  - 第一步：执行 `<SKILL_DIR>/scripts/scan-claude-code-sessions.py`，按毫秒时间戳筛选 session。
  - 第二步：用 `find ~/.claude/projects -name '<sessionId>.jsonl'` 定位会话文件，只提取用户请求、完成摘要、关键文件和验证信息，跳过 tool_result 与长日志。
  - 第三步（可选）：执行 `<SKILL_DIR>/scripts/scan-claude-code-memory.py` 读取 memory 文件；memory 已覆盖时可不再读 jsonl。

- **Codex**
  - 读取 `~/.codex/session_index.jsonl`，按每行的 `updated_at` 字段（ISO 8601 时间戳）筛选目标日期范围内的 session id，再在 `~/.codex/sessions/` 目录下读取对应 session 文件内容。
  - `session_index.jsonl` 每行格式为 `{"id":"uuid","thread_name":"...","updated_at":"2026-05-21T05:10:15Z"}`，按 `updated_at` 过滤是合法且准确的（该字段由 Codex 写入，反映会话最后活跃时间）。
  - 如存在 `~/.codex/history.jsonl`，用它辅助定位 session。

- **OpenCode**
  - **优先查 `~/.local/share/opencode/opencode.db` 的 `session` 表**；`time_created` / `time_updated` 为毫秒时间戳，禁止用 grep 匹配日期字符串。
  - 第一步：按 `time_created` 筛选目标日期范围，取 `id`、`title`、`directory`。
  - 第二步（可选）：从 `message` / `part` 表提取 `role=user` 且 `type=text` 的用户文本。

- **Trae**
  - **Trae 与 Trae CN 需同时扫描**；对话存在各工作区 `state.vscdb`（SQLite）。
  - **唯一有效 session 来源：`memento/icube-ai-agent-storage`**；用户请求来源：`icube-ai-agent-storage-input-history` 的 `inputText`。
  - **禁止读 `ChatStore`**（仅 UI 布局，会导致误报 0 条或错误日期）；**禁止读 `ModularData/ai-agent/database.db`**。
  - **必须**执行 `<SKILL_DIR>/scripts/scan-trae-sessions.py`；禁止只扫 Trae CN 或自行改写逻辑；脚本 `BY_INSTALL` 行确认两个安装均已扫描。
  - **输出统一称「Trae」**：禁止「Trae CN」出现在标题、「涉及AI工具」或工作主题的「涉及工具」字段；单工具标题为 `# Trae 一周工作总结｜...`。

- **WorkBuddy**
  - **优先查 sessions 表**，不要只扫 jsonl；跨工作区会话（如 C端产品规范、KPI指标制定）的标题在 DB 中，jsonl 路径分散易漏。
  - 第一步：用 `sqlite3 ~/.workbuddy/workbuddy.db` 查询 `sessions` 表，按 `created_at`（毫秒时间戳）筛选目标日期范围，取 `id`、`title`、`cwd`；`title` 即会话主题，`cwd` 标识工作区文件夹。
  - 命中数为 0 时再降级查 jsonl，不得跳过 DB 直接扫 jsonl。
  - 第二步：按 sessionId 在 `~/.workbuddy/projects/` 下定位对应 `.jsonl`，只提取用户请求与 assistant 摘要，跳过 tool_call / tool_result 细节。
  - 第三步：如有 `~/.workbuddy/projects/*/.workbuddy/memory/YYYY-MM-DD.md`，直接读取目标日期范围内的 memory 文件补充摘要。

- **其他 AI 工具**
  - 只读取明确属于该工具的本地会话、日志、history 或 transcript。
  - 如格式不清楚，先抽样读取少量文件确认字段，再筛选目标日期范围。

### 第 4 步：提取有效信息

- 优先提取：用户任务、完成事项、关键产出、创建或修改的文件、验证结果、受阻原因。
- 跳过：重复追问、纯闲聊、工具调用细节、临时日志、无结论的报错堆栈、token 或密钥。
- 同一任务跨多个工具或多次会话出现时，合并为同一个工作主题，并标注涉及工具。

### 第 5 步：汇总

- 先按工具整理证据，再按工作主题合并，不按日期逐条罗列。
- **单工具报告**：省略"按工具概览"，直接输出主题列表。
- **多工具 / all 报告**：保留"按工具概览"；若某工具目录存在但无有效记录，仅在输出末尾附注"已检查但无有效记录的工具：{列表}"，不写入正文。
- 对证据不足的结论使用"看起来""可能"等表述，不做无依据推断。

### 第 6 步：输出

**输出前必须先执行：读取模板文件**

根据有效工具数量选择模板，两个文件均与本 SKILL.md 位于同一目录：
- 单工具（1 个工具有有效记录）→ 读取 `单个AI工具的输出格式模板.md`
- 多工具 / all（2 个及以上）→ 读取 `多个AI工具的输出格式模板.md`

输出内容的结构、章节顺序、字段名称、缩进格式必须与所读模板完全一致，不得自行调整。

**格式适用范围（强制）：**
- **当前会话输出**与**钉钉文档输出**必须使用同一套模板格式，禁止不按模板输出，章节结构、字段名称、缩进子列表格式不得改变。

若某工具目录存在但无有效记录，不纳入「涉及AI工具」字段，仅在输出末尾附注"已检查但无有效记录的工具：{列表}"。

**输出目标：**

- 默认直接在当前会话输出（严格按模板格式）。
- 若用户附带钉钉文件夹链接，则额外写入钉钉文档（严格按同一模板格式）：
  - **文档标题规则**：
    - 单工具：`{工具名}一周工作总结`，例如 `cursor一周工作总结`。
    - 多工具 / all：`AI工具一周使用总结`。
  - **同名文件删除后重建规则（强制）**：
    - 创建前必须先使用 dingtalk-doc-mcp 在目标文件夹下搜索标题与目标标题完全匹配的文档。
    - 若找到同名文档，必须先调用删除接口删除该文档，再创建新文档。
    - 若未找到同名文档，直接创建新文档。
    - 不要在旧文档上追加、覆盖局部内容或改名保留旧版本。
  - 完成后在当前会话返回文档链接。

