---
name: 同步C端注册数
description: 将钉钉文档「产品部部门周报汇总」中【创新ToC用户增量明细】表格的「本周新增」和「总完成量」数据同步到「产品部项目管理」AI表格「2026年C端注册数」表的「本周新增注册数」和「累计注册数」字段。当用户说"同步C端注册数"、"更新注册数据"、"把周报里的注册数更新到项目管理表"时触发此 skill。
agent_created: true
---

# ToC 注册数同步

## 前置条件

**必须先加载 `dws` skill**：本 skill 所有钉钉操作均通过 `dws` 命令执行（非 MCP 工具），执行前必须 `Skill(skill="dws")` 加载 dws 技能。

## 概述

从钉钉文档「产品部部门周报汇总」读取【创新ToC用户增量明细】表格数据，按产品名称匹配，将「本周新增」→「本周新增注册数」、「总完成量」→「累计注册数」写入「产品部项目管理」AI表格的「2026年C端注册数」数据表。

## 文档信息

| 角色 | 文档名 | 类型 | 说明 |
|------|--------|------|------|
| 数据来源（文档1） | 产品部部门周报汇总 | adoc（钉钉在线文档） | 动态查找，见下方说明 |
| 数据目标（文档2） | 产品部项目管理 | able（钉钉AI表格） | baseId: `Y1OQX0akWm3g7G1DIozPoRl3JGlDd3mE` |

**文档1 动态查找规则：**

每次执行时，先调用 `dws doc list --folder D1YKdxGX7EqVQZe2y71ZJe4QrZk95AzP --format json`，在返回的 `nodes` 列表中找到 `name` 为 `产品部部门周报汇总` 的文件，取其 `nodeId` 作为文档1的读取目标。

若目录下存在多个同名文件，取 `updateTime` 最新的一个。若未找到，停止执行并告知用户。

**文档2 目标表格信息：**
- 表名：2026年C端注册数
- tableId：`kWZxlii`
- 视图：全部数据（viewId: `nzu9MbN`）
- 字段：
  - 产品（primaryDoc，fieldId: `8yVHZqg`）
  - 本周新增注册数（number，fieldId: `kd4WMay`）
  - 累计注册数（number，fieldId: `5iILIri`）

## 已知 RecordId 映射（重要！）

> ⚠️ **已知 Bug**：`query_records` 对「2026年C端注册数」表始终返回 0 条记录，但表中实际有数据。
> **解决方案**：维护下方的产品→recordId 映射表，直接用 recordId 执行 update，完全绕开 query_records。

当前各产品的 recordId（首次创建后记录，后续直接使用）：

| 产品 | recordId |
|------|----------|
| 学术名片 | `L9objPDHi6` |
| 学术主页&文献管理 | `wZoMPECqQI` |
| ALLiN1 | `UPbtPpjDN1` |
| 公共平台 | `OhA7D1N2QI` |
| 移动商城店铺 | `hH0svKGCj1` |

> **注意**：每次成功创建记录后，必须立即将返回的 recordId 更新到上方映射表中，并更新 skill.md 文件。

## 执行流程

### 第一步：查找文档1

执行 `dws doc list --folder D1YKdxGX7EqVQZe2y71ZJe4QrZk95AzP --format json`，从返回的 `nodes` 数组中找到 `name` 为 `产品部部门周报汇总` 的文件，取其 `nodeId`。若有多个同名文件，取 `updateTime` 最新的。

### 第二步：读取文档1内容

执行 `dws doc read --node <NODE_ID> --format json`，从返回的 `markdown` 字段中获取文档正文。

### 第三步：解析【创新ToC用户增量明细】表格

在返回的 Markdown 中，定位标题 `**创新ToC用户增量明细**` 下方的表格，提取每行的：
- 产品名称（第1列）
- 本周新增（第4列）
- 总完成量（第5列）

示例表格结构：
```
| 产品 | 单位 | 指标 | 本周新增 | 总完成量 | 完成度 |
|------|------|------|----------|----------|--------|
| 学术名片 | 人 | 30000 | 26 | 796 | 8.91% |
| 学术主页&文献管理 | 人 |  | 40 | 1807 |  |
| ALLiN1 | 人 |  | 6 | 69 |  |
| 公共平台 | 人 | 5000 | 107 | 1495 | 45.04% |
| 移动商城店铺 | 个 |  | 64 | 757 |  |
```

提取后得到产品→数值的映射，空值视为 0。

### 第四步：判断执行模式（update 还是 create）

**优先使用 update 模式**：检查上方「已知 RecordId 映射」表，若所有产品都有 recordId，直接跳到第四步执行 update。

**仅在以下情况使用 create 模式**：
- 映射表中某产品的 recordId 为 `_(待首次创建后填入)_`
- 说明该产品记录尚未创建，需要新建

> ⚠️ **严禁**：不得调用 `query_records` 来判断记录是否存在（该 API 对此表有 bug，始终返回 0 条）。

### 第五步：执行 update（有 recordId 时）

对映射表中有 recordId 的产品，使用 `dws aitable record update` 批量更新：
```bash
dws aitable record update --base-id Y1OQX0akWm3g7G1DIozPoRl3JGlDd3mE --table-id kWZxlii \
  --records '[{"recordId":"<recordId>","cells":{"kd4WMay":<本周新增>,"5iILIri":<总完成量>}}]' --format json
```

> ⚠️ CLI 只接受 `--records` 一个 JSON 数组参数，不存在 `--record-id` / `--cells` 独立 flag。所有记录合并到一个 `--records` 数组一次性提交，单次最多 100 条。

### 第六步：执行 create（无 recordId 时）

对映射表中 recordId 为空的产品，使用 `dws aitable record create` 新建：
```bash
dws aitable record create --base-id Y1OQX0akWm3g7G1DIozPoRl3JGlDd3mE --table-id kWZxlii \
  --records '[{"cells":{"8yVHZqg":"<产品名称>","kd4WMay":<本周新增>,"5iILIri":<总完成量>}}]' --format json
```

**创建成功后，立即将返回的 recordId 写入 skill.md 的映射表中**（使用 Edit 工具更新 skill.md 文件）。

### 第七步：汇报结果

执行完成后，向用户汇报：
- 成功更新的产品列表及写入的数值
- 新建的产品记录（如有）
- 跳过或失败的条目（如有）

## 注意事项

- 数值字段若为空字符串或"-"，写入时跳过该字段（不覆盖为 0），除非用户明确要求清零。
- 产品名称匹配区分全角/半角，建议先做 trim 处理。
- 若文档1中同一产品出现多行，取最后一行数据。
- 执行前无需用户二次确认，直接执行并汇报结果。
