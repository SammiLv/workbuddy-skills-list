# 个人 Skills 清单（WorkBuddy）

> **范围说明**：仅整理自建 skills，不含系统、插件或市场来源 skills。
> **最后更新时间**：2026-06-02 14:55（Asia/Shanghai）

---

## Skill 列表

### AI工具一周使用总结

- **触发器**：`$AI工具一周使用总结`
- **路径**：`/Users/sammilv/.workbuddy/skills/all-ai-tools-weekly-summary/SKILL.md`
- **概述**：从本地 AI 工具会话记录生成一周工作总结，支持单工具、多工具或全量汇总。

### cross-ai-skill-sync

- **触发器**：`$cross-ai-skill-sync`
- **路径**：`/Users/sammilv/.workbuddy/skills/cross-ai-skill-sync/SKILL.md`
- **概述**：跨 AI 工具同步 skill，支持在 Codex、Cursor、WorkBuddy、OpenCode、Claude、Trae 等工具间同步同名 skill 或根目录配置文件。

### WorkBuddy工作日报

- **触发器**：`$WorkBuddy工作日报`
- **路径**：`/Users/sammilv/.workbuddy/skills/daily-workbuddy-work-summary/SKILL.md`
- **概述**：根据 WorkBuddy 每日活动记录生成中文工作日报，默认汇总最近一个有实际工作的前一天。

### dingtalk-leader-meeting-topics

- **触发器**：`$dingtalk-leader-meeting-topics`
- **路径**：`/Users/sammilv/.workbuddy/skills/dingtalk-leader-meeting-topics/SKILL.md`
- **概述**：使用 dws skill 回顾本周钉钉群沟通和个人聊天记录，整理需与组长沟通的议题，并通过钉钉单聊发送给当前用户本人。

### dingtalk-personal-weekly-report

- **触发器**：`$dingtalk-personal-weekly-report`
- **路径**：`/Users/sammilv/.workbuddy/skills/dingtalk-personal-weekly-report/SKILL.md`
- **概述**：基于钉钉数据生成当前用户一周工作总结，通过 dws 采集日程、会议纪要、文档、表格、群聊等工作证据。

### 个人技能清单

- **触发器**：`$个人技能清单`
- **路径**：`/Users/sammilv/.workbuddy/skills/personal-skill-inventory/SKILL.md`
- **概述**：整理当前 AI 工具的个人 skills 清单，记录每个 skill 的名称、概述和触发条件。

### 预约钉钉会议

- **触发器**：`$预约会议`
- **路径**：`/Users/sammilv/.workbuddy/skills/reserve-dingtalk-meeting/SKILL.md`
- **概述**：自动创建钉钉会议，支持查询会议室可用性、按参会人数选择会议室、邀请参会人并返回会议详情。

### 同步C端注册数

- **触发器**：`$同步C端注册数`
- **路径**：`/Users/sammilv/.workbuddy/skills/toc-registration-sync/SKILL.md`
- **概述**：将钉钉文档「产品部部门周报汇总」中的 ToC 用户增量数据同步更新到「产品部项目管理」AI 表格。

### 组长例会议题整理

- **触发器**：`$组长例会议题`
- **路径**：`/Users/sammilv/.workbuddy/skills/weekly-leader-meeting-agenda/SKILL.md`
- **概述**：根据本周钉钉间接证据整理需跟组长沟通的议题，并写入每周一下午组长例会的会议纪要文档。

### 产品部周报汇总

- **触发器**：`$weekly-report-summary`
- **路径**：`/Users/sammilv/.workbuddy/skills/weekly-report-summary/SKILL.md`
- **概述**：将收到的产品部个人周报归档为钉钉文档，并按模板生成部门周报汇总。

### WorkBuddy工作周报

- **触发器**：`$WorkBuddy工作周报`
- **路径**：`/Users/sammilv/.workbuddy/skills/weekly-workbuddy-work-summary/SKILL.md`
- **概述**：从 WorkBuddy 本地记忆文件生成中文周工作总结，默认汇总当前周的工作活动。

---

## 外部 Skills（未纳入清单）

以下 skills 为系统、插件或市场来源，不在自建清单范围内：

- `computer-use` — 系统内置 skill
- `processon-diagram-generator` — 外部市场 skill
- `dws` — 钉钉全产品 skill（按规则排除）

---

## 质量提示

| Skill | 状态 |
|-------|------|
| `all-ai-tools-weekly-summary` | frontmatter 缺少 `agent_created: true` 标记，建议补充 |
| `cross-ai-skill-sync` | frontmatter 缺少 `agent_created: true` 标记，建议补充 |
| `daily-workbuddy-work-summary` | frontmatter 缺少 `agent_created: true` 标记，建议补充 |
| `dingtalk-leader-meeting-topics` | frontmatter 缺少 `agent_created: true` 标记，建议补充 |
| `dingtalk-personal-weekly-report` | frontmatter 缺少 `agent_created: true` 标记，建议补充 |
| `personal-skill-inventory` | frontmatter 缺少 `agent_created: true` 标记，建议补充 |
| `reserve-dingtalk-meeting` | frontmatter 缺少 `agent_created: true` 标记，建议补充 |
| `weekly-workbuddy-work-summary` | frontmatter 缺少 `agent_created: true` 标记，建议补充 |

> 建议为以上未标记 `agent_created: true` 的 skill 补充该字段，以便更准确地识别自建 skills。
