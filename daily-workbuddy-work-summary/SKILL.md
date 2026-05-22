---
name: WorkBuddy工作日报
description: 根据 WorkBuddy 每日活动记录生成中文工作日报，默认汇总最近一个有实际工作的前一天（从昨天开始回溯）。触发场景：用户要求总结昨天/今天/某日在 WorkBuddy 中完成的工作、生成工作日报、工作日志或每日回顾。
---

# WorkBuddy 工作日报

## 概述

从 WorkBuddy 本地数据源中提取当日工作内容，生成简洁、有用的中文日报，展示在当前会话中。关注用户让 WorkBuddy 做了什么、完成了什么、创建或修改了哪些文件/产物、验证结果如何、以及剩余待跟进事项。

## 执行流程

1. 确定目标日期。
   - 默认取当前环境上下文中昨天的本地日期。
   - 若昨天无实际工作记录，则逐日向前回溯，直到找到最近一个有实际工作的日期为止。
   - 支持显式日期指定，如"今天"、"上周五"、"2026-05-15"；如有歧义需明确为绝对日期。
   - 不使用网络访问。

2. 采集 WorkBuddy 本地活动（三层数据源，由粗到细）。
   - **第一层（主数据源，必做）**：查询 sqlite3 sessions 表，获取目标日期所有会话清单。
     ```bash
     # 将 START_MS / END_MS 替换为目标日期 00:00:00 ~ 23:59:59 的毫秒时间戳
     # 先获取时间戳（示例为 2026-05-21）：
     START_MS=$(date -j -f "%Y-%m-%d %H:%M:%S" "2026-05-21 00:00:00" "+%s"000)
     END_MS=$(date -j -f "%Y-%m-%d %H:%M:%S" "2026-05-21 23:59:59" "+%s"000)
     sqlite3 ~/.workbuddy/workbuddy.db \
       "SELECT id, title, cwd, datetime(created_at/1000,'unixepoch','localtime')
        FROM sessions
        WHERE created_at >= START_MS AND created_at <= END_MS
        ORDER BY created_at DESC
        LIMIT 50;"
     ```
     - `title` 即会话主题，直接作为工作线索；`cwd` 标识工作区。
     - 命中数为 0 时说明当天无 WorkBuddy 会话，继续向前回溯。
   - **第二层（细节补充）**：读取目标日期的 daily memory 文件（优先工作区路径 `{workspace}/.workbuddy/memory/YYYY-MM-DD.md`），获取已完成任务的详细描述、文件路径、验证结果。
   - **第三层（辅助上下文）**：读取 `MEMORY.md`，获取与当日工作相关的长期偏好和项目约定。

3. 交叉验证：检测 sessions 表 / memory 未覆盖的工作（防遗漏）。
   - **对话搜索**：调用 `conversation_search`，`start_date` 和 `end_date` 均设为目标日期，查询 WorkBuddy 相关对话。将返回的对话主题与 sessions 表 / memory 已覆盖的主题做对比。
   - **Skill 文件时间戳**：执行 `ls -laR ~/.workbuddy/skills/*/`，检查哪些 skill 目录或 SKILL.md 文件在目标日期被创建或修改。skill 的创建或修改在任何情况下都属于实际工作。
   - **sessions 表 vs memory 对比**：sessions 表中存在但 memory 未记录的主题，说明有遗漏；此类会话的 `title` 可直接作为工作线索纳入汇总。
   - 若任一数据源发现未涵盖的工作主题，将其合并进最终汇总。
   - 交叉验证为强制执行步骤，即使 memory 看起来完整也不得跳过。

4. 提取有效信息。
   - 优先提取：任务描述、完成事项、文件路径、产出的产物、验证结果。
   - 跳过：临时信息、中间搜索结果、临时文件路径。
   - 若 memory 文件较大，聚焦于已完成任务和关键决策。
   - sessions 表的 `title` 字段可直接作为「概要」线索；细节从 memory 和 conversation_search 中补充。

5. 按工作主题汇总，不按原始笔记罗列。
   - 同一任务的多个来源记录合并为一条。
   - 优先呈现具体成果，弱化过程细节。
   - 明确区分：已完成、部分完成、受阻、仅调研。

6. 在当前会话中直接展示最终汇总结果。

7. 默认使用中文输出。

## 输出格式

每一项工作按 **概要 / 产出 / 验证** 三个字段分行输出，三个字段左对齐、无缩进：

```markdown
## YYYY-MM-DD

**WorkBuddy 工作日报｜YYYY-MM-DD**

昨天主要完成了：

1. 概要：一句话说明做了什么。
   产出：列出关键文件、文档、skill、脚本、页面或结论。
   验证：列出运行过的检查；如果没有验证，写"未单独验证"。

2. 概要：……
   产出：……
   验证：……

**待跟进**
- 明确的下一步、风险或需要用户确认的事项；没有就写"暂无明确待跟进项"。
```

> 注意：字段名「概要」「产出」「验证」必须严格使用中文，不得替换为英文或缩写。

若用户要求简短版，输出精简段落加要点。若要求详细版，增加"完成事项""产出物""验证情况""待跟进"等小节。

## 自动化输出规则（关键）

当本 skill 被自动化任务执行时（非交互式用户请求），**只输出最终的日报内容**。不得输出以下任何内容：
- 思考过程、推理步骤或执行规划
- 工具调用描述或中间结果
- 如"让我先……""首先我要……"之类的叙述
- 英文过程叙述
- 除格式化日报本身以外的任何内容

自动化任务会将输出推送到手机端，用户只需要看到结果。

## 质量标准

- 足够具体，让用户无需重新打开每个对话就能回忆起当天的工作。
- 仅在路径是有价值的产物或变更文件时才提及路径。
- 避免猜测。证据不完整时用"看起来""可能"表述。
- 保护隐私：不引用 token、密钥、私有配置值或完整消息体。
- 若回溯了日期，在汇总中明确最终汇总的日期。
- 若回溯后仍未找到有实际工作的 memory 文件，明确说明并列出检查的日期范围。
- **三层数据源为强制执行**：sessions 表查询 → memory 文件 → conversation_search + skill 时间戳，缺一不可。sessions 表和 skill 时间戳是防遗漏的最后防线。

## 数据源

- `~/.workbuddy/workbuddy.db` → `sessions` 表：**主数据源**，包含所有 WorkBuddy 会话的 id、title、cwd、created_at。优先查询此表获取当日会话清单。
- `{workspace}/.workbuddy/memory/YYYY-MM-DD.md`：工作区每日 memory 文件，提供已完成任务的详细描述。
- `~/.workbuddy/memory/YYYY-MM-DD.md`：全局每日 memory 文件。
- `~/.workbuddy/memory/MEMORY.md`：长期记忆，记录用户偏好和项目约定。
- `conversation_search`：辅助数据源，与 sessions 表 / memory 交叉验证，捕获遗漏的对话。
- `~/.workbuddy/skills/*/`：检查文件修改时间戳，发现目标日期创建或编辑的 skill。
- `references/source-notes.md`：关于本地 WorkBuddy memory 文件的补充说明。
