# Template

Use this structure when the user wants one document that supports both direct submission and event traceability.

When the final output is written to DingTalk Docs:
- default to the fixed target folder `https://alidocs.dingtalk.com/i/nodes/D1YKdxGX7EqVQZe2y71ZJe4QrZk95AzP` unless the user explicitly overrides it
- delete any same-name document in the same target folder before creating the new one

## Document skeleton

```md
# 吕夏苗钉钉周工作总结（cu）

**时间范围：YYYY年M月D日-YYYY年M月D日**

## 本周小结

一段 2-3 句的总述，概括本周重点。

## 1. 发现与解决问题

本周在问题发现与处理方面，……
1、……
2、……

【台账】

1. 时间：5月6日｜事项：……｜来源：群名 / 人名 / 事项关键词。

## 2. 业务与培训

本周在业务与培训方面，……
1、……
2、……

【台账】

1. 时间：5月8日｜事项：……｜来源：群名 / 人名 / 事项关键词。

## 3. 管理与协作

本周在管理与协作方面，……
1、……
2、……

【台账】

1. 时间：5月8日｜事项：……｜来源：群名 / 人名 / 事项关键词。

## 4. 学习与创新

本周在学习与创新方面，……
1、……
2、……

【台账】

1. 时间：5月9日｜事项：……｜来源：群名 / 人名 / 事项关键词。
```

## Item writing rules

- Summary list items should be short enough to paste into a weekly report directly.
- Ledger items should be more exact than summary items.
- Use Chinese punctuation consistently.
- If a source mixes two events, split them before writing.
- Unless the user explicitly gives another range, compute the report range as the 7-day window ending on the current date.
- The report title must use the confirmed report owner's name. Do not replace it with names that appear in the evidence.

## Common corrections

- Split `上线` and `收录` into separate items when they come from different people or groups.
- Move purely exploratory AI tooling content into `学习与创新` unless it directly solved a production issue.
- Put coordination-only work into `管理与协作`, not `发现与解决问题`.
- If a draft title accidentally uses another colleague's name, correct the title first, then re-check whether any items were also wrongly attributed.
