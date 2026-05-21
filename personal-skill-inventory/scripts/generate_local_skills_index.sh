#!/usr/bin/env bash
set -euo pipefail

SKILLS_DIR="${HOME}/.workbuddy/skills"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
OUTPUT_FILE="${SKILL_DIR}/LOCAL_SKILLS_INDEX.md"
TIMESTAMP="$(TZ=Asia/Shanghai date '+%Y-%m-%d %H:%M:%S %Z')"
TMP_FILE="$(mktemp)"

# 外部安装的 skill 文件夹名列表（不纳入自建清单）
EXTERNAL_SKILLS=(
  "computer-use"
  "processon-diagram-generator"
  "processon-diagramgen"
)

cleanup() {
  rm -f "$TMP_FILE"
}

trap cleanup EXIT

overview_for() {
  case "$1" in
    WorkBuddy工作日报)
      printf '根据本地 WorkBuddy 会话记录生成中文工作日报，汇总指定日期完成的任务、产出物、验证情况和待跟进事项。'
      ;;
    WorkBuddy工作周报)
      printf '根据本地 WorkBuddy 会话记录生成中文工作周报，聚焦工作主题、完成成果、产出物和待跟进事项。'
      ;;
    钉钉周工作总结（mcp）)
      printf '基于钉钉 MCP 数据（聊天、@消息、OA审批、待办、日程、文档等）生成吕夏苗的周工作总结，默认范围最近 7 天。'
      ;;
    钉钉周工作总结（cu）)
      printf '基于钉钉聊天、群聊、@消息、日程和相关文档生成个人周报，按发现与解决问题、业务与培训、管理与协作、学习与创新四部分组织。'
      ;;
    个人技能清单)
      printf '扫描个人本地 skills 目录，生成中文技能清单索引，记录每个 skill 的名称、概述、触发器和文件路径。'
      ;;
    预约钉钉会议)
      printf '根据会议时间与参会人自动创建钉钉会议：查询会议室空闲、选择合适房间、完成预订与邀请。'
      ;;
    同步C端注册数)
      printf '将产品部周报汇总中创新ToC用户增量明细表的本周新增和总完成量数据，同步到产品部项目管理 AI 表格的 C 端注册数表。'
      ;;
    产品部周报汇总)
      printf '将收集到的周报先归档为钉钉文档，再按固定模板汇总生成产品部部门周报。'
      ;;
    AI工具一周使用总结)
      printf '从本地 AI 工具会话记录生成一周工作总结，支持单工具、多工具或全量汇总，可选择性写入钉钉文档。'
      ;;
    组长例会议题整理)
      printf '从钉钉日程、待办、审批、日志等间接证据中提炼需要跟组长沟通的议题，查找或创建每周一下午组长例会纪要文档，并将议题写入文档。'
      ;;
    *)
      printf '该 skill 已被识别，但尚未配置中文概述；请根据对应 SKILL.md 补充。'
      ;;
  esac
}

is_external() {
  local dir_name="$1"
  for ext in "${EXTERNAL_SKILLS[@]}"; do
    if [ "$dir_name" = "$ext" ]; then
      return 0
    fi
  done
  return 1
}

markdown_escape() {
  printf '%s' "$1" | sed 's/|/\\|/g'
}

inline_code_escape() {
  printf '%s' "$1" | sed 's/`/\\`/g'
}

printf '开始执行本地 Skills 清单自动化任务\n'
printf '扫描目录：%s\n' "$SKILLS_DIR"
printf '目标文件：%s\n' "$OUTPUT_FILE"

{
  printf '# 个人本地 Skills 清单\n\n'
  printf '最后更新时间：%s\n\n' "$TIMESTAMP"
  printf '本文件记录当前个人自建的 WorkBuddy skills。范围为 `%s` 下的自建 skills，不包含外部安装、系统内置和插件 skills。\n\n' "$SKILLS_DIR"
  printf -- '- 触发器约定：使用 `$skill-name` 显式调用本地 skill。\n'
  printf -- '- 范围：仅个人自建 skills。\n'
  printf -- '- 排除：外部安装、系统内置、插件 skills。\n\n'
  printf '## Skill 列表\n\n'

  found_count=0

  while IFS= read -r skill_dir; do
    dir_name="$(basename "$skill_dir")"
    if is_external "$dir_name"; then
      continue
    fi

    skill_file="${skill_dir}/SKILL.md"
    [ -f "$skill_file" ] || continue

    name="$(sed -n 's/^name:[[:space:]]*//p' "$skill_file" | head -n 1)"
    if [ -z "$name" ]; then
      name="$dir_name"
    fi

    overview="$(overview_for "$name")"
    trigger="\$${name}"

    printf '### %s\n\n' "$name"
    printf -- '- 触发器：`%s`\n' "$(inline_code_escape "$trigger")"
    printf -- '- 路径：`%s`\n' "$(inline_code_escape "$skill_file")"
    printf -- '- 概述：%s\n\n' "$(markdown_escape "$overview")"

    found_count=$((found_count + 1))
  done < <(find "$SKILLS_DIR" -mindepth 1 -maxdepth 1 -type d ! -name '.system' | sort)
} > "$TMP_FILE"

mv "$TMP_FILE" "$OUTPUT_FILE"

printf '识别到个人自建 skills 数量：%s\n' "$found_count"
printf '生成中文索引内容\n'
printf '保存目标文件：%s\n' "$OUTPUT_FILE"
printf '刷新最后更新时间：%s\n' "$TIMESTAMP"
printf '校验结果：已生成中文格式 Markdown\n'
printf '本地 Skills 清单自动化任务执行完成\n'
