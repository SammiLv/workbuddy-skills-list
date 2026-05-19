# 个人本地 Skills 清单

最后更新时间：2026-05-19 18:45:37 CST

本文件记录当前个人创建或安装在本地的 WorkBuddy skills。范围为 `/Users/sammilv/.workbuddy/skills` 下的个人 skills，不包含系统内置 skills 和插件 skills。

- 触发器约定：使用 `$skill-name` 显式调用本地 skill。
- 范围：仅个人本地 skills。
- 排除：系统内置 skills 和插件 skills。

## Skill 列表

### WorkBuddy工作日报

- 触发器：`$WorkBuddy工作日报`
- 路径：`/Users/sammilv/.workbuddy/skills/daily-workbuddy-work-summary/SKILL.md`
- 概述：根据本地 WorkBuddy 会话记录生成中文工作日报，汇总指定日期完成的任务、产出物、验证情况和待跟进事项。

### 钉钉周工作总结（mcp）

- 触发器：`$钉钉周工作总结（mcp）`
- 路径：`/Users/sammilv/.workbuddy/skills/dingtalk-lxm-weekly-work-summary/SKILL.md`
- 概述：基于钉钉 MCP 数据（聊天、@消息、OA审批、待办、日程、文档等）生成吕夏苗的周工作总结，默认范围最近 7 天。

### 钉钉周工作总结（cu）

- 触发器：`$钉钉周工作总结（cu）`
- 路径：`/Users/sammilv/.workbuddy/skills/dingtalk-personal-weekly-report/SKILL.md`
- 概述：基于钉钉聊天、群聊、@消息、日程和相关文档生成个人周报，按发现与解决问题、业务与培训、管理与协作、学习与创新四部分组织。

### 个人技能清单

- 触发器：`$个人技能清单`
- 路径：`/Users/sammilv/.workbuddy/skills/personal-skill-inventory/SKILL.md`
- 概述：扫描个人本地 skills 目录，生成中文技能清单索引，记录每个 skill 的名称、概述、触发器和文件路径。

### 预约钉钉会议

- 触发器：`$预约钉钉会议`
- 路径：`/Users/sammilv/.workbuddy/skills/reserve-dingtalk-meeting/SKILL.md`
- 概述：根据会议时间与参会人自动创建钉钉会议：查询会议室空闲、选择合适房间、完成预订与邀请。

### 同步C端注册数

- 触发器：`$同步C端注册数`
- 路径：`/Users/sammilv/.workbuddy/skills/toc-registration-sync/SKILL.md`
- 概述：将产品部周报汇总中创新ToC用户增量明细表的本周新增和总完成量数据，同步到产品部项目管理 AI 表格的 C 端注册数表。

### 产品部周报汇总

- 触发器：`$产品部周报汇总`
- 路径：`/Users/sammilv/.workbuddy/skills/weekly-report-summary/SKILL.md`
- 概述：将收集到的周报先归档为钉钉文档，再按固定模板汇总生成产品部部门周报。

### WorkBuddy工作周报

- 触发器：`$WorkBuddy工作周报`
- 路径：`/Users/sammilv/.workbuddy/skills/weekly-workbuddy-work-summary/SKILL.md`
- 概述：根据本地 WorkBuddy 会话记录生成中文工作周报，聚焦工作主题、完成成果、产出物和待跟进事项。

