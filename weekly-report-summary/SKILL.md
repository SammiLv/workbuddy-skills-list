---
name: 产品部周报汇总
description: Use when the user invokes $产品部周报汇总 to archive received weekly reports into DingTalk docs first, then summarize them into a department weekly report using the fixed 产品部周报汇总 template.
---

# 产品部周报汇总

## Canonical Invocation

The canonical way to invoke this skill is:

`$产品部周报汇总`

For this workflow, the default fixed template is:

`产品部周报汇总`

Unless the user explicitly asks for another template, treat `$产品部周报汇总` as:

`$产品部周报汇总，按“产品部周报汇总”模板执行`

## Purpose

Use this skill to process multiple received work reports and produce:

1. archived individual DingTalk docs for each received report
2. a department summary doc based on a designated supervisor weekly report template

This skill is designed for workflows like:

- query received weekly reports for a specific day or range
- archive each report as a DingTalk doc
- exclude a specified person's report from summary inputs
- use a supervisor report as the structural template
- extract, clean, count, and summarize the rest into one department report

## Inputs

For ad-hoc workflows, confirm these inputs before running if they are not already supplied by a preset:

- the date range to query
- the target DingTalk folder for archived reports and summary output
- the supervisor weekly report or finalized summary template to use
- any people to exclude from summary inputs
- any tables that must be shown as totals only
- any custom filtering rules for demand-detail tables

For the fixed preset `产品部周报汇总`, do not pause to reconfirm these inputs. Use the Fixed Defaults below and continue execution unless a required DingTalk report, folder, or template is inaccessible after lookup.

If the user has already confirmed a finalized department-summary template doc for this workflow, prefer that finalized DingTalk doc as the template source instead of regenerating the template structure from a supervisor weekly report each run.

## Timezone Rule

All date and day-boundary logic in this skill must use Beijing time: `Asia/Shanghai` (`UTC+08:00`).

This applies to:

- deciding what counts as `today`, `yesterday`, and the current target day
- converting DingTalk millisecond timestamps into calendar dates
- choosing the fallback date
- displaying the final `汇总日期` in the generated department weekly report
- displaying the final `源周报日期` in the generated department weekly report

`汇总日期` is not the report send date and not the content coverage date.

`源周报日期` is the Beijing-calendar date of the actual selected source reports after converting each selected DingTalk timestamp to `Asia/Shanghai`.

Hard rule for `源周报日期`:

- always derive it from the selected source reports' actual timestamps in `Asia/Shanghai`
- never derive it from the fallback search anchor date, query window start date, report week label, or UTC date
- if all selected in-scope received reports fall on the same Beijing calendar date, display that exact date as `源周报日期`
- if selected source reports span multiple Beijing dates, display an explicit range in Beijing dates

Hard rule for this workflow:

- `汇总日期` must always be the current execution date in Beijing time
- even if received reports and the supervisor weekly report were sent on an earlier date, keep `汇总日期` as today's Beijing-time calendar date
- when needed, separately explain the actual send date of the source reports and the coverage date of the reported work

Never derive report dates from UTC day boundaries when the source timestamps are intended for China Standard Time.

## Hard Rules

### 0. Full-summary execution rule

For this skill, copying or recreating the template document alone is never sufficient.

Every execution must produce a real department summary derived from the selected personal weekly reports.

Mandatory execution baseline:

- first identify the in-scope personal weekly reports
- then fetch and read each in-scope report in full
- then extract the actual paragraphs, lists, and table data from each source report
- then compute the department-level summary from those extracted source reports
- then write the computed result back into the summary doc while preserving the approved template structure and presentation where required

Do not claim that a department summary has been completed unless the summary content has actually been derived from the selected source reports.

Forbidden shortcut:

- do not copy `产品部部门周报汇总（模板）` or any prior summary doc and present it as finished unless its content has been revalidated and updated against the current selected source reports

### 1. Archive first

After identifying the in-scope reports for the workflow and fetching their details, archive those in-scope reports into DingTalk docs before doing any summary work. Do not archive every report from the same day by default.

Default archive behavior:

- archive only the reports selected into the workflow's in-scope personal-report set
- supervisor reports, template-source reports, and explicitly excluded reports must not be archived as personal report docs
- for the fixed preset `产品部周报汇总`, Lu Xiamiao's weekly report must not be archived and must not be counted as a summary input
- one report per DingTalk doc
- doc name = report name
- content must be copied in full
- do not summarize, compress, or rewrite archived personal report content
- before creating a personal report doc, if a same-name doc already exists in the target folder, delete the old doc first and then create a new one
- use delete-then-create instead of overwrite when the user needs fresh create timestamps for archived personal report docs
- before creating the department summary doc, if a same-name summary doc already exists in the target folder, delete the old doc first and then create a new one

### 1.1 Fallback date rule

If there are no received reports for the current target day, and there is also no outgoing supervisor weekly report for that same day, do not stop immediately.

Use this fallback:

1. find the most recent date with in-scope received reports for the current preset or workflow
2. find the most recent outgoing supervisor weekly report that matches that same workflow scope
3. run the workflow using those most recent scoped inputs

If only one side is missing, fall back only for the missing side.

Always make the fallback date explicit in the response so the user knows which source-report date was actually used. This fallback date is for source selection only. Do not replace `汇总日期` with the fallback date. `汇总日期` must still use the current Beijing-time calendar date.
Also do not blindly copy the fallback anchor date into `源周报日期`. `源周报日期` must still be derived from the selected reports' actual Beijing timestamps.

### 2. Template source

The department weekly report format must follow the designated template source.

In this workflow, the template source is:

- either a designated finalized department-summary template doc
- or, if no finalized template doc has been designated yet, the designated supervisor weekly report

That means:

- keep its major section structure
- keep its sub-section hierarchy where possible
- map other received reports into the supervisor report structure
- do not invent a new department report outline unless the user explicitly asks

If a finalized template doc exists for the current preset, it has higher priority than the supervisor weekly report and should be treated as the canonical structural template for subsequent runs.

This skill is global and reusable.

Do not hardcode Lu Xiamiao unless the current task explicitly uses Lu Xiamiao's supervisor report as the template.
Always treat the template source as a variable input unless the preset defines a fixed finalized template doc.

### 2.1 Template fidelity for fixed tables

For any table that already exists in the designated supervisor weekly report template:

- keep the table as a real table in the department summary
- do not collapse a template table into plain text, bullets, or a prose summary
- if the template has multiple sibling tables under the same parent section, keep all of them unless the user explicitly asks to remove one

For the default preset `产品部周报汇总`, the following tables are mandatory and must not be omitted when they exist in the supervisor report template:

- `部门业绩指标总览`
- `创新ToB增收明细`
- `创新ToC用户增量明细`

If the preset has already been stabilized into a finalized department-summary template doc, interpret "template" in all table-fidelity rules as that finalized template doc rather than the historical supervisor weekly report.

If there is no source data for a retained template table:

- keep the table structure
- leave rows blank, zero-filled, or template-consistent as appropriate
- do not delete the table just because some values are empty

### 2.2 Confirmed cell-merge rules for summary tables

When the department summary is rendered into DingTalk docs, the following confirmed merged-cell presentation rules must be applied when the user is using the fixed preset `产品部周报汇总`.

These are presentation rules for the summary doc and should be preserved even if the underlying source values are sparse.

#### A. `创新ToB增收明细`

- keep the table as a real table
- include the rows:
  - `伏羲慧眼`
  - `AI电子相册`
  - `统战系统`
  - `ALLiN1`
  - `其他`
- in the confirmed display variant:
  - `指标` should be vertically merged starting from `AI电子相册` down through `其他`
  - `完成度` should be vertically merged starting from `AI电子相册` down through `其他`
- if the confirmed merged block carries one shared displayed value, place that value in the top cell of the merged block and leave the covered rows as part of the merge instead of repeating the value

#### B. `创新ToC用户增量明细`

- keep the table as a real table
- in the confirmed display variant:
  - first merged block:
    - `指标` merges `学术名片` + `学术主页&文献管理`
    - `完成度` merges `学术名片` + `学术主页&文献管理`
  - second merged block:
    - `指标` merges `ALLiN1` + `公共平台` + `移动商城店铺`
    - `完成度` merges `ALLiN1` + `公共平台` + `移动商城店铺`
- do not split the second merged block into smaller segments unless the user explicitly overrides this layout
- if the displayed shared value belongs to the merged block, place it in the first row of that merged block and render the remaining covered rows as merged cells rather than duplicated values

### 2.3 Confirmed red-text rendering rules for summary tables

When the department summary is rendered into DingTalk docs for the fixed preset `产品部周报汇总`, the following cell values must be rendered in red text.

These are presentation rules and should be applied without changing table structure, merge structure, or source semantics.

#### A. `采购平台` 实施概况表

- render `本周新增` as red
- render `本周已完成` as red

#### B. `科管系统` 明细表

- render all displayed values under these columns as red:
  - `需求成本`
  - `ROI`
  - `单位阶段`

#### C. `创新ToB推广&增收`

- in the non-total data rows, render these columns as red when populated:
  - `启动时间`
  - `进度`

#### D. `C端产品渠道获客概况`

- render the entire `总计` row as red

#### E. `产品投广成本`

- render all displayed values under these columns as red:
  - `本周总计`
  - `本年总计`

#### F. `需求开发概况`

- render `本周新增` as red

#### G. Rendering safety rule

- do not inject raw HTML such as `<span style=...>` into DingTalk table-block cell strings
- if DingTalk table-block APIs would render style markup as literal text, do not use block delete-and-reinsert as the final rendering path for red-text styling
- for tables that already rely on template-native merge or styling behavior, prefer preserving the original template-rendered table presentation
- for the fixed preset `产品部周报汇总`, Markdown whole-document regeneration is not considered presentation-safe for the merged/red-text summary tables if it would flatten template-native merged cells or lose native red-text rendering
- when a finalized template doc already contains the correct native merged-cell and red-text presentation, prefer copying that template doc and editing only non-style-sensitive text blocks instead of recreating the styled tables from Markdown
- if a styling requirement cannot be applied without degrading table rendering, stop and surface the limitation instead of shipping literal HTML text in cells

#### H. Generation-path rule for styled summary tables

- for the fixed preset `产品部周报汇总`, the summary doc's styled tables must be produced through the same whole-document generation path that already yields correct native DingTalk rendering
- do not treat block-level table delete/insert as equivalent to whole-document generation for styled tables
- if a prior generated department-summary doc already demonstrates the correct native rendering for merged cells or red text, use that successful generation path as the reference implementation
- when a table depends on native DingTalk rendering behavior, prefer recreating the whole summary doc over patching individual styled table blocks
- for the finalized template doc `产品部部门周报汇总（模板）`, the preferred reference implementation is: copy the template doc itself, keep the template-native styled tables intact, then update only plain-text metadata or other non-style-sensitive blocks
- do not rebuild `创新ToB增收明细` or `创新ToC用户增量明细` from Markdown when the goal is to preserve the template's native merged-cell presentation and red-text rendering
- block-level patching may still be used for plain-text paragraphs or structurally simple tables that do not depend on native color or merge presentation

### 3. Personal summary section boundary

`二、本周个人工作总结` belongs to the supervisor personally.

Rules:

- do not summarize other received reports into this section
- when producing the department summary from other people's reports, leave this section empty unless the user provides the supervisor's own content
- keep the sub-headings under this section if the template contains them
- if a draft already contains merged content here, remove it

### 4. Promotion data classification

Promotion-related content belongs under product promotion, not under other key projects.

Specifically:

- `科研管理系统投广`
- channel acquisition tables
- promotion cost tables

must stay in:

- `产品推广`
- `创新ToB推广&增收`
- `C端产品渠道获客概况`
- `产品投广成本`

and must not be duplicated under `其他重点项目`.

### 5. Totals-only tables

If the user requests totals only, replace grouped rows with one aggregated totals row or totals table.

For this workflow, confirmed totals-only behavior includes:

- `采购平台实施概况`
- `需求开发概况`

### 6. Table update fallback

When DingTalk block-level table update fails, use this fallback:

1. locate the existing block
2. delete the old block
3. insert a new block in the correct position
4. re-read nearby blocks to verify placement

### 6.1 Source-traceability rule

The generated department summary must be source-traceable.

That means:

- every populated paragraph, list item, and table row in the department summary must come from one or more selected in-scope personal weekly reports unless it is explicitly template metadata
- every aggregated numeric table must be reproducible from the selected source reports
- if a value cannot be traced back to the selected source reports, do not keep it as a claimed summary result

Required execution behavior:

- keep a working mapping between each summary section and the source report(s) that fed it
- treat the selected personal reports as the ground-truth input set for the current run
- when reusing a copied template doc, verify each non-style-sensitive summary block against the current source reports before leaving it in place

### 6.2 Source conflict resolution rule

Sometimes different selected source reports may contain overlapping summary data with inconsistent values.

When this happens:

1. prefer the most specific table or section that is clearly acting as the authoritative source for that metric
2. prefer internally self-consistent source tables that include matching detail rows and totals
3. do not silently merge contradictory numeric values into a fabricated compromise
4. if one source is chosen over another for a conflicting metric, record that choice in the final response
5. if the conflict cannot be resolved confidently, stop and surface the ambiguity instead of pretending the data is settled

### 7. Group leader summary table fidelity

`7. 组长工作总结` must follow the supervisor weekly report's table format exactly.

Rules:

- keep it as a table, not as an overall narrative summary
- keep the original template columns and order
- for the current confirmed format, use:
  - `负责人`
  - `类型`
  - `任务名称`
  - `本周进度`
- merge source rows from in-scope reports into this table row by row
- do not compress multiple rows into one synthesized management summary
- preserve the original wording of each source row as much as possible
- if a source row already fits the target columns, copy it directly instead of rewriting it

## Standard Workflow

1. Query candidate received reports in the specified date range, using Beijing-time day boundaries.
2. Identify which reports are in scope for the current workflow or preset before any archiving.
3. If no in-scope reports are found, apply the fallback date rule against the scoped workflow, not against every received report.
4. Fetch report details for each in-scope result, and normalize all timestamps to `Asia/Shanghai` before comparing dates.
5. Archive each in-scope report into DingTalk docs.
6. Identify which in-scope reports are content sources for summary.
7. Use the finalized department-summary template doc first, or else use the supervisor weekly report as the structure template.
8. Read each selected source report in full and extract its actual paragraphs, lists, and tables.
9. Build a source-to-summary mapping for all major sections and summary tables.
10. Normalize duplicated categories, overlapping rows, and table totals across the selected source reports.
11. Recompute the department summary content from the extracted source reports instead of trusting prior summary output by default.
12. Generate or update the department summary doc while preserving template-native presentation for style-sensitive tables.
13. Verify that each updated summary block is traceable to the selected source reports.
14. After generating the archive docs and department summary doc, report the result for user review and apply any follow-up structural corrections if requested.
15. Do not stop before creating the initial deliverables solely to ask for review or approval when the fixed preset defaults are available.

When generating the summary doc:

- set `汇总日期` to the current execution date in `Asia/Shanghai`
- if source reports come from an earlier day because of fallback, mention that separately in a note or explanation instead of changing `汇总日期`
- do not treat a copied template doc as complete until the summary content has been recomputed or revalidated against the selected source reports

## Summary Mapping Rules

When summarizing into the supervisor report template:

- preserve the supervisor report's main headings
- preserve meaningful sub-headings under business, promotion, AI, demand development, design work, and next-week planning
- preserve required template tables such as `创新ToB增收明细` and `创新ToC用户增量明细`
- preserve the sub-headings under `二、本周个人工作总结`, but do not fill them with content from other people's reports
- if a section exists in the template but no source content exists, keep the section and leave it blank or mark it as none only if the user wants that
- do not replace a table section like `7. 组长工作总结` with a paragraph-style synthesis
- when a section or table is populated, ensure the filled content can be traced back to the selected source reports for the current run

## Confirmed Table Rules

### A. Procurement platform implementation overview

When the user requests totals only:

- sum each numeric column across source groups
- show only the aggregated result

### B. Demand development overview

When the user requests totals only:

- sum each numeric column across source groups
- show only the aggregated result

### C. Key and C-end demand detail table

This table may follow task-specific filtering rules below.

Use these rules in order:

1. If the demand name contains `对接`, include it regardless of workload.
2. Otherwise, if the product name contains any of:
   - `采购平台`
   - `供应商`
   - `科管系统`
   - `科研管理系统`
   and the demand is not a `对接` demand, include it only when workload is `>= 20`.
3. Otherwise, if the owner is either:
   - `张永翔`
   - `梁益双`
   include it regardless of workload.
4. Otherwise, include all remaining product demands regardless of workload.

Additional confirmed notes for the confirmed variant:

- `对接` is the fixed keyword for identifying system-integration-type demands
- product keywords are not merged beyond the exact keyword matching above
- the old title `工作量30及以上...` is not accurate for this rule set
- prefer a title like `重点以及C端产品需求明细（包括所有产品设计需求以及单位实施需求）`

## Output Expectations

The skill should usually produce:

1. archived personal report docs
2. one department weekly summary doc
3. corrections after user review

The completion standard for the summary doc is:

- it is structurally based on the approved template
- it is substantively derived from the selected source reports
- its numeric totals can be explained from the selected source tables
- any material source conflict has either been resolved explicitly or surfaced to the user

## Suggested Prompt Pattern

Use this pattern when executing the skill:

```text
请处理指定日期内收到的周报，并生成部门周报。

要求：
1. 先查询周报列表并获取详情。
2. 查询完成后，先把收到的每份周报生成钉钉文档，作为原始归档。
3. 个人周报文档以周报名称命名，内容完整复制，不做摘要。
4. 根据用户要求排除指定人员周报。
5. 以吕夏苗发出的主管周报作为部门周报模板。
6. 从其他收到的几份周报中提取内容，按主管周报的栏目结构进行整理、统计和汇总。
7. 严格保留主管周报模板里已有的关键表格，尤其是“部门业绩指标总览”“创新ToB增收明细”“创新ToC用户增量明细”。
8. 对指定统计表按列汇总，只展示总数，不展示分组明细。
9. 对“重点以及C端产品需求明细”按既定规则筛选入表。
10. `7.组长工作总结` 必须按原表格列逐行汇总，不要改写成概述。
11. 不要把其他人的内容汇总到“二、本周个人工作总结”。
12. 输出到指定钉钉文件夹。
13. 若文档块级更新失败，采用删除旧块并插入新块的方式修复。
```

## Global Preset Template

This skill supports reusable named presets. For normal use, `$产品部周报汇总` should default to the preset below.

### Default Template Binding

`$产品部周报汇总` defaults to this preset unless the user explicitly names another template.

### Preset Name

`产品部周报汇总`

### Trigger Phrases

`【产品部周报汇总】`

`产品部周报汇总`

### Preset Behavior

When the user sends exactly or primarily:

`$产品部周报汇总`

or

`【产品部周报汇总】`

or

`产品部周报汇总`

run this skill immediately with the following defaults, without asking for additional parameters, and treat the template as fixed to `产品部周报汇总` unless something essential is missing from upstream data or the user explicitly overrides the template. Reading the skill file, querying reports, or copying the template is not a completed run; continue through archive creation, source extraction, summary recomputation, and summary doc creation before returning a final response.

#### Fixed Defaults

- query range: the current conversation date in Beijing time (`Asia/Shanghai`), meaning today's received weekly reports by China Standard Time day boundaries
- target DingTalk folder:
  `https://alidocs.dingtalk.com/i/nodes/D1YKdxGX7EqVQZe2y71ZJe4QrZk95AzP`
- finalized summary template doc:
  `产品部部门周报汇总（模板）`
- Lu Xiamiao exclusion: do not archive Lu Xiamiao's weekly report, and do not use it as a department-summary input
- Lu Xiamiao's weekly report is no longer the first-choice structural template once `产品部部门周报汇总（模板）` has been confirmed by the user
- Lu Xiamiao's weekly report may only be used as a fallback template or reference source when the finalized template doc is unavailable, inaccessible, or explicitly requested by the user
- allowed senders for `产品部周报汇总`: `孙圣宇`, `张永翔`, `邓智泳`, `王俊秀`

#### Fixed Execution Rules

- first query the candidate received reports
- then determine which reports belong to the preset scope before any archiving
- for `产品部周报汇总`, only reports sent by `孙圣宇`, `张永翔`, `邓智泳`, or `王俊秀` are in scope
- if today's in-scope reports are empty and today's in-scope supervisor weekly report is also missing, fall back to the most recent available in-scope reports and the most recent available in-scope supervisor weekly report
- all fallback comparisons and the final displayed summary date must use Beijing-time calendar dates, even if source timestamps are stored or returned in another timezone representation
- then fetch report details
- then archive each in-scope report into DingTalk docs
- for `产品部周报汇总`, do not archive Lu Xiamiao's weekly report as a personal report doc
- for `产品部周报汇总`, never bulk-archive every report from the same day just because it was received
- for `产品部周报汇总`, sender whitelist has higher priority than date-based fallback or mailbox co-receipt
- for `产品部周报汇总`, title matching is only a secondary check; if sender is outside the whitelist, exclude the report by default
- for `产品部周报汇总`, exclude unrelated departments such as reports titled with `（科研服务部）` unless the user explicitly asks for cross-department processing
- if the fallback date contains a mixed mailbox day, archive only the reports that were selected into the preset scope
- if a same-name personal report doc already exists in the target folder, delete the old doc first and then create a new one
- if a same-name department summary doc already exists in the target folder, delete the old doc first and then create a new one
- copy personal report content in full
- summarize the department report using the finalized template doc `产品部部门周报汇总（模板）` as the first-choice structure source
- for `产品部周报汇总`, the department summary must be recomputed from the four selected personal weekly reports for the current run; copying the template without re-deriving the content is not allowed
- for `产品部周报汇总`, read all four selected personal weekly reports in full before claiming the summary is complete
- for `产品部周报汇总`, recompute totals-only tables from source reports instead of inheriting old values from a previous summary doc
- for `产品部周报汇总`, re-screen the demand-detail table from source reports on every run using the confirmed filtering rules instead of trusting a prior summary table by default
- for `产品部周报汇总`, verify `其他重点项目` and `7. 组长工作总结` row by row against the selected source reports so source rows are not silently dropped
- for the department summary doc, if merged cells or red-text styling must match the finalized template, prefer copying `产品部部门周报汇总（模板）` into a new same-folder doc and then editing only the non-style-sensitive text blocks
- do not regenerate the full department summary from Markdown when doing so would break the template-native merge presentation or red-text rendering
- only fall back to a supervisor weekly report as a structure source if the finalized template doc is missing, inaccessible, or explicitly overridden by the user
- keep `二、本周个人工作总结` with sub-headings only, without merging content from other people's reports
- keep promotion-related content under product-promotion sections, not under other key projects
- show totals only for the confirmed totals-only tables
- use the confirmed demand-detail filtering rules for the key and C-end demand table

#### Confirmed Demand-Detail Rules For This Preset

1. if the demand name contains `对接`, include it regardless of workload
2. otherwise, if the product name contains any of:
   - `采购平台`
   - `供应商`
   - `科管系统`
   - `科研管理系统`
   and the demand is not a `对接` demand, include it when workload is `>= 20`
3. otherwise, if the owner is:
   - `张永翔`
   - `梁益双`
   include it regardless of workload
4. otherwise, include all remaining product demands regardless of workload

#### Confirmed Sender Scope For This Preset

Only these senders are allowed into `产品部周报汇总` by default:

- `孙圣宇`
- `张永翔`
- `邓智泳`
- `王俊秀`

If a report comes from any other sender, exclude it from both archive generation and department-summary inputs unless the user explicitly expands the scope.
Lu Xiamiao's weekly report is a special exception: it may still be used as a fallback template source when the finalized template doc is unavailable, but it must not be archived as a personal weekly report doc and must not be counted as a department-summary input.

## Deliverables

When done, report back with:

- which reports were queried
- which reports were selected into scope
- which Beijing-calendar source-report date was actually used
- whether fallback was triggered
- which summary tables or sections were recomputed from source data
- any source conflicts or judgment calls made during aggregation
- the final department summary doc link
- which reports were archived
- which reports were used as summary inputs
- which supervisor report was used as the template
- which totals-only tables were applied
- which custom filtering rules were applied
