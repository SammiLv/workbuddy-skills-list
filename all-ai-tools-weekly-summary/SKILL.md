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
- `trae` / `trae cn` → Trae（**统一显示名，见下方 Trae 专规**）
- `workbuddy` / `work buddy` → WorkBuddy

**Trae 专规（触发词含 trae 时强制）：**
- 数据扫描**必须同时覆盖** Trae 国际版与 Trae CN 两个安装路径（见第 2、3 步）。
- 输出中**统一称「Trae」**：禁止将「Trae CN」「Trae 国际版」用作工具名、报告标题或「涉及AI工具」字段值。
- 单工具标题必须是 `# Trae 一周工作总结｜...`，禁止 `# Trae CN 一周工作总结`。
- 工作主题中的「涉及工具」字段写 `Trae`；若需区分来源，仅在概要/产出路径中注明配置文件路径，不把安装包名当作工具名。

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

### 第 3 步：精准收集会话记录（Shell 预筛，严控读取量）

> **⚠️ 严禁使用文件系统时间（mtime/ctime）筛选会话文件。** 必须解析文件内部的时间戳字段；没有内部时间戳的文件直接跳过，不做猜测。
>
> **核心原则：先用 Shell / 辅助脚本提取关键字段，禁止直接读取完整 jsonl 文件。**
>
> **辅助脚本**：复杂扫描逻辑放在本 SKILL.md 同目录的 `scripts/` 下。执行前确认 `SKILL_DIR` = SKILL.md 所在目录，运行 `python3 "$SKILL_DIR/scripts/xxx.py"`。**禁止在 Skill 正文里自行重写或改用其他数据源。**

**硬性读取上限（所有工具通用，如有冲突以本表为准）：**

| 限制项 | 上限 |
|---|---|
| 每个工具最多处理的会话文件数 | 30 个 |
| 每个会话文件最多读取的行数 | 150 行 |
| 单次 grep 输出最多使用的行数 | 300 行 |

超出上限的部分直接跳过，不影响已提取内容的汇总。

**范围校验（汇总前必做）：**
统计每个工具命中的有效记录条数，打印简明清单（`工具名 → N 条`）。Claude Code 以 history.jsonl 去重 sessionId 数为准；OpenCode 以 session 表命中数为准；Trae 以 memento session 去重数为准（须执行 Trae 脚本；输出 `BY_INSTALL` 行确认两个安装路径均已扫描，`TOTAL_SESSIONS=0` 时检查是否误读了 ChatStore）；WorkBuddy 以 sessions 表命中数为准；其他工具以 user_query / 用户消息为准。命中数为 0 的工具排除，不纳入报告。全部为 0 时直接报告"目标日期范围内未找到有效会话"并列出已检查路径。

只读取第 2 步确认纳入的工具，按工具逐一处理：

- **Cursor**
  - 只取父会话：`agent-transcripts/<sessionId>/<sessionId>.jsonl`；跳过 `subagents/*.jsonl`。
  - **时间过滤**：解析 user 消息内 `<timestamp>` 标签（格式含 UTC 偏移），只保留落在目标范围内的 `<user_query>`。
  - **不读取 assistant 消息**，除非 user_query 结论不可判断时，才读相邻 assistant 摘要（最多 30 行）。
  - 命令：
    ```bash
    find ~/.cursor/projects/*/agent-transcripts -maxdepth 2 -name "*.jsonl" \
      | grep -v '/subagents/' | grep -E '/([0-9a-f-]+)/\1\.jsonl$' | head -30
    grep -h '<timestamp>\|<user_query>' <文件路径列表> | head -300
    ```
  - **⚠️ grep 污染（2026-10-16 实测）**：直接 `grep '<timestamp>\|<user_query>'` 会被**会话正文里出现的这两个字面量**污染（例如某次会话让 AI 写过解析 `<timestamp>` 的脚本，脚本源码整段进入 jsonl，grep 会把整行回吐成几十 KB，并可能让真正的 user_query 被淹没或被误判为命中）。判断本周是否有记录、以及统计命中数时，**优先用 Python 逐行读取、只解析 `<user_query>...</user_query>` 块并正则提取时间戳**，不要依赖裸 grep。
  - Cursor 时间戳格式为 `Friday, Aug 7, 2026, 4:19 PM (UTC+8)`（月名英文 + 12 小时制 + UTC 偏移），必须按此格式解析，不要按 GMT+8 或 24 小时制处理。

- **Claude Code**
  - **`history.jsonl` 的 `timestamp` 是毫秒整数，禁止用 `grep '2026-05-xx'` 过滤，否则会命中 0 条。**
  - 第一步：执行 `python3 "$SKILL_DIR/scripts/scan-claude-code-sessions.py"`，输出 `sessionId \t 时间 \t display \t project`。
  - 第二步：`find ~/.claude/projects -name '<sessionId>.jsonl'`，再 `grep -m 80 '"role":"user"\|"type":"result"\|"summary"' <session.jsonl> | head -150`。
  - 第三步：`python3 "$SKILL_DIR/scripts/scan-claude-code-memory.py"`。记忆文件为强制校验步骤，必须执行。

- **Codex**
  - **数据源优先级（2026-09-18 实测更新，务必按此顺序）：**
    1. **首选 `~/.codex/thread_history_1.sqlite` 的 `thread_items` 表**（真实会话正文所在）：
       - `item_type='userMessage'` → 用户请求；`item_type='agentMessage'` → 助手结论/产出
       - 时间字段 `created_at_ms`（毫秒），先算好 `START_MS`/`END_MS` 再筛选，禁止 grep 日期字符串
       - `substr(item_json,1,300)` 控制读取量
    2. 线程元信息取 `~/.codex/state_5.sqlite` 的 `threads` 表：`id` / `title` / `cwd` / `updated_at`（秒）
    3. `~/.codex/session_index.jsonl` **已停更**（实测最后条目为 2026-09-09），仅在 sqlite 无数据时降级使用
  - **禁止把 `~/.codex/sessions/<YYYY>/<MM>/<DD>/*.jsonl` 当作真实会话来源**：该目录可能只留下 `thread_source=guardian_review` 的审查子会话（`session_meta.payload.source.subagent.other == 'guardian'`），其 `event_msg.user_message` 是喂给审查器的转写文本，不是用户原始请求。只读该目录会得到"看起来有记录但内容是审查提示"的假阳性。
  - 命令（`d` 为日期，按第 1 步范围替换）：
    ```bash
    sqlite3 ~/.codex/thread_history_1.sqlite "SELECT datetime(created_at_ms/1000,'unixepoch','+8 hours'), substr(item_json,1,300) FROM thread_items WHERE item_type='userMessage' AND created_at_ms >= START_MS AND created_at_ms <= END_MS ORDER BY created_at_ms LIMIT 60;"
    sqlite3 ~/.codex/state_5.sqlite "SELECT id, title, cwd FROM threads WHERE updated_at >= START_S ORDER BY updated_at DESC LIMIT 20;"
    ```
  - **必须排除的两类假阳性（2026-10-10 实测）**：
    1. **批量导入的 Claude Code 会话**：`thread_history_1.sqlite` 里存在大量 `item_type='userMessage'` 记录，其 `created_at_ms` 全部落在**同一个毫秒值**（如某次导入时刻），且对应 `state_5.sqlite` 中 threads 的 `cwd` 指向 `ClaudeCode工作区/...`、标题形如 `<command-name>/model</command-name>`、`Imported session`。这些是历史 Claude Code 会话被导入的记录，不是本周 Codex 使用。判定法：按 `created_at_ms` 分组，某毫秒值的条数远大于 1（如 >10）即视为导入批次，剔除。
    2. **Guardian 审查子会话**：标题为 `Guardian review` 的线程，其 `userMessage` 文本以 `The following is the Codex agent history added since your last a...` 开头，是喂给审查器的转写文本，不是用户请求，一律剔除。
  - **真实会话判定**：保留 `created_at_ms` 时间戳分散（每条不同毫秒）且 `item_json` 中带 `clientId` 非 null 的线程，即真实人机对话。
  - **记录数口径**：Codex 以剔除上述两类后、`thread_items` 命中时间范围的 `userMessage` 条数为准；同一 `thread_id` 的多轮对话合并为 1 个工作线（多日连续推进的主题合并为同一工作主题）。
  - **关键词扩展搜索**：对提取到的用户消息做一次概念关键词二次扫描（DWS\|CLI\|dws\|升级\|迁移\|替换\|权限\|授权\|改用\|API），命中内容分配更多关注，避免重要工作因措辞不同而被遗漏。

- **OpenCode**
  - **优先查 `~/.local/share/opencode/opencode.db` 的 `session` 表**；`time_created` 为毫秒时间戳，禁止 grep 日期字符串。
  - 第一步：按 `time_created` 筛选，取 `id`、`title`、`directory`（`START_MS`/`END_MS` 替换为第 1 步毫秒范围）。
  - 第二步（可选）：从 `message`/`part` 表提取 `role=user` 且 `type=text` 的用户文本。
  - 命令：
    ```bash
    sqlite3 ~/.local/share/opencode/opencode.db \
      "SELECT id, title, directory FROM session WHERE time_created >= START_MS AND time_created <= END_MS ORDER BY time_created DESC LIMIT 30;"
    ```

- **Trae**
  - **Trae 与 Trae CN 需同时扫描**；对话在各工作区 `state.vscdb`（SQLite）。
  - **唯一 session 来源：`memento/icube-ai-agent-storage`**；用户请求来源：`icube-ai-agent-storage-input-history` 的 `inputText`。
  - **禁止读 `ChatStore`**（仅 UI 布局，会误报 0 条）；**禁止读 `ModularData/ai-agent/database.db`**。
  - **必须**执行 `python3 "$SKILL_DIR/scripts/scan-trae-sessions.py"`；禁止只扫 `Trae CN` 路径或自行改写逻辑。
  - 脚本输出含 `BY_INSTALL` 行，确认 Trae / Trae CN 两个安装均已扫描；合并去重后**输出统一称「Trae」**，禁止称「Trae CN」。

- **WorkBuddy**
  - **优先查 `~/.workbuddy/workbuddy.db` 的 sessions 表**，不要只扫 jsonl；跨工作区会话标题在 DB 中。
  - 第一步：按 `created_at`（毫秒）筛选，取 `id`、`title`、`cwd`；命中数为 0 再降级查 jsonl。
  - 第二步：`find ~/.workbuddy/projects -name '<sessionId>.jsonl'`，再 `grep -m 40 '"role":"user"\|"input_text"\|"output_text"' <session.jsonl> | head -150`。
  - 第三步：读取目标日期范围内的 `~/.workbuddy/projects/*/.workbuddy/memory/*.md`。记忆文件为强制校验步骤，必须执行。
  - 命令：
    ```bash
    sqlite3 ~/.workbuddy/workbuddy.db \
      "SELECT id, title, cwd FROM sessions WHERE created_at >= START_MS AND created_at <= END_MS ORDER BY created_at DESC LIMIT 30;"
    ```
  - **命中数可能极少是正常的**：WorkBuddy 的记录基本由自动化任务产生，若本周只跑了本 skill 的定时任务，`sessions` 表可能只有 1 条（即本次自动化会话本身）。该条仍算有效记录，不要把工具判定为"无有效记录"。
  - **补充判据**：除 `created_at` 外可用 `updated_at` / `last_activity_at` 交叉核对，避免把跨周启动、本周仍在活跃的长会话漏掉。
  - **环境限制（2026-10-10 实测）**：`~/.workbuddy/projects/**` 在本沙盒内被拒绝访问（`find` / `ls` / glob 均不可用），因此 WorkBuddy 只能取 `workbuddy.db` 的 `sessions` 表 + 各工作区 `.workbuddy/memory/*.md`；jsonl 兜底步骤在本环境无法执行，不要因失败而重试。

- **其他 AI 工具**
  - 先抽样读 1 个文件前 30 行确认字段格式，再用 grep 按内部时间戳过滤；遵守硬性读取上限。

### 第 4 步：提取有效信息

- 从 grep 已抽取的内容中归纳：用户任务、完成事项、关键产出、关键文件、验证结果、受阻原因。
- 跳过：重复追问、纯闲聊、tool_call / tool_result 细节、临时日志、报错堆栈、token 或密钥。
- 同一任务跨多个工具或多次会话出现时，合并为同一个工作主题，并标注涉及工具。
- 同一数据源（同一 jsonl/DB 表）不重复读取；信息不足时用"看起来""可能"表述，不做无依据推断。不同数据源之间必须通过第 4.5 步交叉验证补齐。

### 第 4.5 步：完整性交叉验证

> **目的**：第 4 步从会话内容提取的工作主题，可能因会话标题措辞不精确或关键词缺失而遗漏重要工作。本步骤用不同数据源做补全校验。

**方法（按顺序执行）：**

1. **读记忆文件（按工具能力）**
   - 读取已开通每日记忆的工具：WorkBuddy 和 Claude Code 目标日期范围内的所有 `YYYY-MM-DD.md`，提取工作主题记录。
   - 其余工具（Cursor/Codex/OpenCode/Trae）无独立 markdown 记忆文件，直接使用第 3 步已提取的会话内容作为校验依据，无需额外读文件。

2. **概念关键词扩展**
   - 对全部工具的已提取内容（含记忆文件 + 第 3 步会话提取），搜索以下概念关键词，检查是否有未被归纳为独立主题的重要工作：
     - 技术名词：`dws`、`DWS`、`CLI`、`MCP`、`API`、`token`、`沙盒`
     - 动作词：`升级`、`迁移`、`替换`、`改为`、`改用`、`对比`、`复制`、`同步`
     - 领域词：`权限`、`授权`、`数据源`、`数据采集`

3. **与第 4 步结果比对**
   - 若以下任一情况成立，补充或拆分主题：
     - 某工作线在记忆文件或关键词扫描中出现，但未在第 4 步主题中体现 → **新增主题**
     - 某概念关键词高频出现（≥3 条会话）但未对应任何独立主题 → **检查是否需拆分**
     - 同一工作涉及的工具数与第 4 步列表不符 → **更新「涉及工具」字段**
   - 补充内容需标注证据来源（如「依据 05-28 WorkBuddy 记忆文件」或「依据 Codex 会话关键词扫描」）。

**约束**：
- 不因本步骤回头重新读 jsonl 文件；仅使用已提取内容 + 记忆文件。
- 比对发现的补充工作中，对信息不足的部分用"看起来""可能"表述。

### 第 5 步：汇总

- 先按工具整理证据，再按**工作主题**合并，不按日期逐条罗列。
- **主题粒度 = 项目维度（2026-10-10 用户明确要求）**：同一项目/仓库（如 depot-clean、operapage-web）下的多个工作项必须合并为 1 个主题，主题命名体现项目名，格式如「产品管理平台（depot-clean）迭代优化」「商城活动页搭建器（operapage-web）联调与发布流程建设」；禁止把同一项目的 KPI 修复、白屏修复、接口联调等拆成多个并列主题。合并后「概要」内用分号串联各工作项，「产出」「验证」内逐项列举。
- 纯自动化任务（无项目归属，如本 skill 自身的定时执行）可单独作为 1 个主题放在最后。
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
    - 单工具：`{工具名}一周工作总结`，例如 `cursor一周工作总结`、**`Trae一周工作总结`**（禁止 `Trae CN一周工作总结`）。
    - 多工具 / all：`AI工具一周使用总结`。
  - **同名文件删除后重建规则（强制）**：
    - 创建前必须先使用 dingtalk-doc-mcp 在目标文件夹下搜索标题与目标标题完全匹配的文档。
    - 若找到同名文档，必须先调用删除接口删除该文档，再创建新文档。
    - 若未找到同名文档，直接创建新文档。
    - 不要在旧文档上追加、覆盖局部内容或改名保留旧版本。
  - 完成后在当前会话返回文档链接。

