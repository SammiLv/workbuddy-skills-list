# AI 工具一周使用总结｜2026-05-15 至 2026-05-21

涉及AI工具：Cursor、WorkBuddy

1. AI 工具一周总结 Skill 搭建与迭代
   - 涉及工具：Cursor
   - 概要：新建 all-ai-tools-weekly-summary，支持单工具/多工具/all 三种模式，多轮迭代格式与执行流程。
   - 产出：SKILL.md、SKILL完整版.md、macOS/Windows 安装包、缩进子列表格式模板
   - 验证：多次跨工具测试；格式渲染问题通过缩进子列表解决。

2. Skill 体系迁移与规范化
   - 涉及工具：WorkBuddy、Cursor
   - 概要：3 个 skill 从 Codex 迁移到 WorkBuddy，7 个 skill 统一改为中文显示名。
   - 产出：daily/weekly-workbuddy-work-summary、skill 中文名定稿、LOCAL_SKILLS_INDEX.md
   - 验证：个人技能清单自动化 18:45 扫描验证，8 个 skill 全部入账。

3. 自动化任务体系建设
   - 涉及工具：WorkBuddy
   - 概要：新建并调整 7 个定时自动化任务，覆盖日报/周报/技能清单/周工作总结/GitHub同步。
   - 产出：工作日报（仅工作日 9:30）、技能清单（每日 18:45）、钉钉周工作总结（每周五 17:30）、产品部周报汇总（每周五 18:00）等
   - 验证：7 个 ACTIVE 任务已稳定执行；GitHub 推送 SSL 问题已重试解决。

4. 产品部周报汇总 Skill 重构
   - 涉及工具：WorkBuddy
   - 概要：全面重构 weekly-report-summary，中文化、12 步执行流程、新增删除重建规则与 Computer Use 聊天证据采集。
   - 产出：SKILL.md 重构版、部门汇总文档（nodeId: mExel2BLV54XNY35HmEdmOovWgk9rpMq）
   - 验证：续跑验证通过；样式限制（合并单元格/红字）需手动补回。

5. 钉钉周工作总结 Skill 优化
   - 涉及工具：WorkBuddy
   - 概要：新增强制写文档步骤、删除重建规则、folderId 指定、Computer Use 群消息采集能力。
   - 产出：dingtalk-lxm-weekly-work-summary SKILL.md 更新、吕夏苗钉钉周工作总结（mcp-wb）文档
   - 验证：文档成功写入目标文件夹；初次漏写文档问题已修正并入规则。

6. MCP 服务稳定性排查
   - 涉及工具：Cursor
   - 概要：排查 Codex MCP 莫名丢失、API Key 登录后 MCP 不可见、Claude Code 全局 MCP 配置问题。
   - 产出：config.toml 登录方式切换结论、Claude Code 全局 MCP 配置方案
   - 验证：API Key 模式下 MCP 连通性问题部分缓解，仍有限制。

## 本周重点产出
- all-ai-tools-weekly-summary Skill（SKILL.md + 安装包）
- 产品部周报汇总 Skill 重构版
- 7 个 WorkBuddy 自动化任务体系
- 钉钉周工作总结 Computer Use 聊天证据采集能力
- Skill 中文名规范定稿（7 个）

## 按工具概览
- Cursor：AI工具周总结 Skill 搭建与格式优化、MCP 排查、Token 优化
- WorkBuddy：Skill 迁移与规范化、自动化体系建设、产品部周报汇总重构、钉钉文档输出优化

## 待跟进
- 新缩进子列表格式在 WorkBuddy 等其他工具的渲染效果需重新测试
- Codex API Key 模式下 MCP 连通性问题未完全解决
- 产品部周报汇总合并单元格/红字样式需手动补回（API 限制）
