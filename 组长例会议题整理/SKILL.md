---
name: 组长例会议题整理
description: 当用户希望根据本周钉钉群沟通内容整理需要跟组长沟通的议题，并写入每周一下午组长例会的会议纪要时触发此 skill。该 skill 会搜索用户参与的钉钉工作群（仅能获取群名，无法读取群聊消息历史）、日程、待办、审批等间接证据，提炼出需要与组长沟通的议题清单，然后查找本周一下午的组长例会纪要文档，若不存在则先创建，最后将议题写入文档。触发词包括"整理组长会议题"、"组长例会议题"、"本周跟组长沟通的内容"等。
agent_created: true
---

# 组长例会议题整理

## Purpose

从本周（周一至周五）用户在钉钉的日程、待办、审批、日志等间接证据中，提炼需要跟组长沟通的议题，并写入每周一下午组长例会的会议纪要文档。若该纪要文档尚未创建，则先创建再写入。注意：当前钉钉 MCP 无法读取群聊消息历史，群聊相关议题需用户提供。

## Canonical Invocation

Use this skill when the user writes:

- `$组长例会议题`
- `$整理组长会议题`
- "帮我整理本周跟组长沟通的议题"
- "组长例会要讨论什么"
- 任何表达"从钉钉群聊总结本周跟组长沟通议题并写入例会纪要"的意图

## Defaults

Apply these defaults unless the user says otherwise:

- report owner: `吕夏苗`
- time zone: `Asia/Shanghai`
- 本周范围: 当前自然周的周一 00:00 至当前时刻（若当天为周五后则截至周五 23:59）
- 组长例会时间: 每周一下午（14:00-18:00 区间内搜索）
- 会议纪要文档命名: `组长例会纪要-YYYY年MM月DD日`（日期为该周一的日期）
- 纪要存放位置: 用户钉钉"我的文档"根目录（除非用户指定了知识库或文件夹）

## Required DingTalk MCP Tools

Use MCP tools for this workflow. Do not fall back to operating the DingTalk desktop UI unless the user explicitly asks.

Key MCP tools used:

- `dingtalk-calendar-mcp`: `list_calendar_events` — 查找本周一下午的组长例会日程
- `dingtalk-contacts-mcp`: `get_current_user_profile`, `search_user_by_key_word` — 确认用户身份，查找组长信息
- `dingtalk-robotmessage-mcp`: `search_groups_by_keyword` — 搜索相关群聊（仅返回群名列表，不返回消息内容）
- `dingtalk-ToDo-mcp`: `get_user_todos_in_current_org` — 获取待办
- `dingtalk-OAapproval-mcp`: `list_initiated_instances`, `get_todo_tasks`, `get_done_tasks` — 获取审批记录
- `dingtalk-log-mcp`: `get_send_report_list`, `get_received_report_list` — 获取日志
- `dingtalk-doc-mcp`: `search_documents`, `get_document_content`, `create_document`, `update_document`, `insert_document_block` — 查找/创建/更新会议纪要文档
- `dingtalk-groupchat-mcp`: 如有聊天记录读取工具则使用；否则通过间接证据推断
- Chat history MCP: 当可用时，读取群聊消息作为直接证据

If no DingTalk MCP tools are available, stop and tell the user that the MCP tools need to be reloaded.

## Workflow

### Phase 1: 确定时间范围和身份

1. 计算本周周一和周五的精确日期（北京时间）。
2. 生成毫秒级时间戳用于 MCP 查询。
3. 通过 `get_current_user_profile` 确认当前用户身份；若无法获取则默认为 `吕夏苗`。
4. 若用户提供了组长的姓名，通过 `search_user_by_key_word` 查找组长的 DingTalk userId。

### Phase 2: 收集沟通证据

从以下来源收集本周（周一至当前时刻）的沟通相关证据，按优先级排列：

1. **群聊搜索（仅获取群名，无法读取消息历史）**:
   - 通过 `search_groups_by_keyword` 搜索与工作相关的群（如项目群、部门群、产品群等），仅能返回群名、openConversationId、成员数等元信息。
   - **关键限制**: 当前钉钉 MCP 没有群聊消息历史读取工具，`search_groups_by_keyword` 不返回任何消息内容。搜索到的群名仅作为间接提示（提示用户可能在这些群中有相关讨论），不能从中提炼议题。
   - 若未来有 chat-history MCP 可用，可读取本周群聊消息作为直接证据。届时重点关注：
     - 用户自己发送的消息
     - @用户的消息
     - 涉及问题、阻塞、决策、进度更新的讨论
     - 与组长相关的讨论
   - 执行时必须明确向用户说明此限制，避免用户误以为已读取群聊消息。

2. **日程**:
   - 通过 `list_calendar_events` 查询本周所有日程。
   - 提取会议标题、参与者、时间，识别需要与组长同步的会议结论和待跟进事项。

3. **待办**:
   - 通过 `get_user_todos_in_current_org` 获取当前用户的待办。
   - 识别需要组长支持、审批、决策的待办事项。

4. **审批**:
   - 通过 `list_initiated_instances`, `get_todo_tasks`, `get_done_tasks` 获取本周审批记录。
   - 识别涉及组长审批或需要组长知会的流程。

5. **日志**:
   - 通过 `get_send_report_list`, `get_received_report_list` 获取本周日志。
   - 提取与组长沟通相关的工作进展和问题。

6. **文档间接证据**:
   - 仅当日程标题、审批标题或待办标题提示有相关文档时，通过 `search_documents` 搜索并读取关键内容。

### Phase 3: 提炼议题

从收集的证据中提炼需要与组长沟通的议题，遵循以下规则：

1. **议题筛选标准**:
   - 需要组长决策或审批的事项
   - 工作中遇到的阻塞或风险，需要组长协调资源
   - 项目/业务进展需要向组长同步
   - 跨组协作中需要组长出面协调的事项
   - 组长在群聊中提出但尚未闭环的问题（如群聊消息可获取时）
   - 用户自己发现但需要组长知情的问题

2. **议题格式**:
   每个议题包含：
   - 议题标题（简明扼要）
   - 背景说明（1-2 句）
   - 期望沟通结果（需要组长做什么：决策/审批/协调/知会）
   - 证据来源（群名/日程名/待办名等）

3. **去重和归类**:
   - 同一话题的不同证据合并为一个议题
   - 按重要性和紧迫性排序：阻塞类 > 决策类 > 同步类 > 知会类

4. **隐私保护**:
   - 不直接引用群聊原文，而是提炼为议题描述
   - 不暴露敏感个人信息

### Phase 4: 查找或创建组长例会纪要

1. **查找组长例会日程**:
   - 通过 `list_calendar_events` 查询本周一下午（14:00-18:00）的日程。
   - 识别标题包含"组长"、"例会"、"周会"等关键词的日程。
   - 从日程详情中提取可能的会议纪要文档链接（若有附件）。

2. **查找已有纪要文档**:
   - 通过 `search_documents` 搜索标题包含"组长例会纪要"且创建时间在本周的文档。
   - 若找到，通过 `get_document_content` 读取当前内容。

3. **若未找到纪要文档，则创建**:
   - 通过 `create_document` 创建新文档：
     - name: `组长例会纪要-YYYY年MM月DD日`（使用本周一日期）
     - markdown: 使用下方模板
   - 若用户指定了知识库或文件夹，使用对应的 `workspaceId` 或 `folderId`。

### Phase 5: 写入议题

1. **确定插入位置**:
   - 若文档为新建，模板中已预留"待讨论议题"区块，直接填入。
   - 若文档已存在，读取 `list_document_blocks` 找到"待讨论议题"或"议题"区块，在该区块末尾追加新议题。
   - 若无明确区块，使用 `insert_document_block` 在文档末尾添加。

2. **议题内容格式**（Markdown）:

```markdown
## 待讨论议题（吕夏苗）

### 1. [议题标题]
- **背景**: [1-2句背景说明]
- **期望结果**: [决策/审批/协调/知会]
- **来源**: [群名/日程/待办等]

### 2. [议题标题]
...
```

3. **更新文档**:
   - 使用 `update_document` 或 `insert_document_block` 将议题写入文档。
   - 验证写入结果：通过 `get_document_content` 读取确认。

### Phase 6: 输出结果

输出格式：

```markdown
✅ 组长例会议题整理完成

**本周时间范围**: YYYY-MM-DD 至 YYYY-MM-DD
**组长例会纪要**: [文档标题](文档链接)

**整理的议题共 N 项**:

1. **[议题标题]** — 期望结果: [决策/审批/协调/知会]
2. **[议题标题]** — 期望结果: [决策/审批/协调/知会]
...

**纪要文档已更新**: 已将议题写入"待讨论议题"区块。

**数据来源覆盖情况**:
- ✅ 日程/待办/审批/日志（可直接读取内容）
- ❌ 群聊消息（钉钉 MCP 无群聊消息历史读取工具，`search_groups_by_keyword` 仅返回群名列表，不返回任何消息内容）
```

> ⚠️ **重要限制**: 当前钉钉 MCP 没有群聊消息历史读取接口。`search_groups_by_keyword` 仅能搜索群名列表，无法获取任何群聊消息内容。议题完全基于日程、待办、审批、日志等间接证据提炼。如需基于群聊讨论提炼议题，请在钉钉桌面端查阅群记录后，将关键消息内容粘贴给我补充。

## Meeting Minutes Document Template

新建会议纪要文档时使用以下 Markdown 模板：

```markdown
# 组长例会纪要-YYYY年MM月DD日

## 会议信息
- 时间: YYYY-MM-DD HH:MM ~ HH:MM
- 参会人: [待补充]
- 主持人: [组长姓名]

## 待讨论议题（吕夏苗）

[议题将在运行 skill 时自动填入]

## 会议记录

[待会议后补充]

## 待办事项

[待会议后补充]
```

## Safety

- Read-only 为主，仅在创建或更新会议纪要文档时写入。
- 不发送钉钉消息、不创建机器人、不创建群、不修改审批、不修改待办，除非用户明确要求。
- 不在输出中直接引用群聊原文，仅提炼为议题描述。
- 不暴露敏感个人信息。
- 写入文档前先确认文档不存在相同议题，避免重复。
- 若文档已有"待讨论议题"区块且包含内容，在末尾追加而非覆盖。

## Example Requests

- `$组长例会议题`
- `$整理组长会议题`
- "帮我看看本周群里有什么要跟组长沟通的"
- "组长例会要讨论什么，帮我整理一下"
- "总结本周群沟通里需要跟组长讨论的问题，写到周一例会纪要里"
