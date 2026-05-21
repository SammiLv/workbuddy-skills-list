# Cursor 一周工作总结｜2026-05-15 至 2026-05-21

涉及AI工具：Cursor

1. AI 工具一周总结 Skill 搭建
   - 概要：从 Claude Code 复制 weekly-work-summary-on-AItools，新建 all-ai-tools-weekly-summary，支持单工具/多工具/all 三种模式。
   - 产出：`~/.cursor/skills/all-ai-tools-weekly-summary/SKILL.md`、`SKILL完整版.md`、macOS/Windows 安装包
   - 验证：多次跨工具触发测试；同名文档删除重建规则已验证可用。

2. Skill 输出格式多轮迭代
   - 概要：针对格式揉成一团、字段不分行、内容臃肿等问题持续优化。
   - 产出：缩进子列表格式模板、格式规则章节合并、Quality Bar 精简要求
   - 验证：Markdown 渲染分行问题通过缩进子列表格式解决；跨工具测试仍需再次确认。

3. Skill Token 消耗优化
   - 概要：引入 Shell grep 预筛机制，避免直接读取完整 jsonl 文件。
   - 产出：硬性读取上限规则（30 文件 / 150 行 / 300 行 grep）、按工具分级抓取策略
   - 验证：原理可行；实测 token 对比未单独验证。

4. Skill 文件结构整理
   - 概要：调整章节顺序（使用说明→输出格式→Quality Bar→Workflow），合并格式规则与模板为单一章节。
   - 产出：SKILL.md、SKILL完整版.md 结构同步更新
   - 验证：未单独验证。

5. MCP 服务稳定性排查（Codex / Claude Code）
   - 概要：排查 Codex MCP 莫名丢失、API Key 登录后 MCP 不可见、Claude Code 全局 MCP 配置等问题。
   - 产出：config.toml 登录方式切换结论、Claude Code 全局 MCP 配置方案
   - 验证：API Key 模式下 MCP 连通性问题部分缓解，仍有限制。

6. 环境与工具配置
   - 概要：修正 GitHub remote 链接、设置 Skill 文件默认用 Cursor 打开、排查 Claude Code global rule 旧版本问题。
   - 产出：GitHub remote 修正、文件打开应用设置
   - 验证：未单独验证。

## 本周重点产出
- `all-ai-tools-weekly-summary` Skill（SKILL.md + SKILL完整版.md）
- Skill macOS/Windows 安装包
- 缩进子列表格式模板（解决跨渲染器分行问题）
- Codex/Claude Code MCP 排查结论

## 待跟进
- 新缩进子列表格式在其他 AI 工具（WorkBuddy 等）的实际渲染效果需重新测试
- Codex API Key 模式下 MCP 连通性问题未完全解决
