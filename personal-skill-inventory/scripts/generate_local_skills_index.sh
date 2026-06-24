#!/usr/bin/env bash
set -euo pipefail

TOOL_NAME="${AI_TOOL_NAME:-Codex}"
SKILLS_DIR="${AI_SKILLS_DIR:-${SKILLS_DIR:-${CODEX_HOME:-${HOME}/.codex}/skills}}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OUTPUT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
OUTPUT_FILE="${DEFAULT_OUTPUT_DIR}/LOCAL_SKILLS_INDEX.md"
TIMESTAMP="$(TZ=Asia/Shanghai date '+%Y-%m-%d %H:%M:%S %Z')"
TMP_FILE="$(mktemp)"

cleanup() {
  rm -f "$TMP_FILE"
}

trap cleanup EXIT

if [ ! -d "$SKILLS_DIR" ]; then
  printf '错误：skills 目录不存在：%s\n' "$SKILLS_DIR" >&2
  printf '请通过 AI_SKILLS_DIR 或 SKILLS_DIR 指定当前 AI 工具的 skills 目录。\n' >&2
  exit 1
fi

description_for() {
  local skill_file="${1:-}"
  [ -f "$skill_file" ] || return 0

  awk '
    NR == 1 && $0 == "---" { in_frontmatter=1; next; }
    in_frontmatter && $0 == "---" { exit; }
    in_frontmatter && /^description:[[:space:]]*/ {
      sub(/^description:[[:space:]]*/, "");
      gsub(/^["'\'']|["'\'']$/, "");
      print;
      exit;
    }
  ' "$skill_file"
}

is_self_built_skill() {
  local skill_dir="${1:-}"
  local skill_file="${skill_dir}/SKILL.md"
  local base
  base="$(basename "$skill_dir")"

  case "$base" in
    .system|cache|plugins|plugin-cache|node_modules|dws|processon-diagram-generator|processon-diagramgen|.*)
      return 1
      ;;
  esac

  [ -f "$skill_file" ] || return 1

  if awk '
    NR == 1 && $0 == "---" { in_frontmatter=1; next; }
    in_frontmatter && $0 == "---" { exit; }
    in_frontmatter && /^name:[[:space:]]*/ {
      sub(/^name:[[:space:]]*/, "");
      gsub(/^["'\'']|["'\'']$/, "");
      name=tolower($0);
      gsub(/[[:space:]]+$/, "", name);
      exit;
    }
    END { exit(name == "dws" ? 0 : 1); }
  ' "$skill_file"; then
    return 1
  fi

  if awk '
    NR == 1 && $0 == "---" { in_frontmatter=1; next; }
    in_frontmatter && $0 == "---" { exit; }
    in_frontmatter {
      line=tolower($0);
      if (line ~ /^(system|builtin|plugin|marketplace|external)[[:space:]]*:[[:space:]]*true[[:space:]]*$/) found=1;
      if (line ~ /^agent_created[[:space:]]*:[[:space:]]*false[[:space:]]*$/) found=1;
      if (line ~ /^source[[:space:]]*:[[:space:]]*(system|plugin|marketplace|builtin|external)[[:space:]]*$/) found=1;
      if (line ~ /^managed_by[[:space:]]*:[[:space:]]*(system|plugin|marketplace|builtin|external)[[:space:]]*$/) found=1;
    }
    END { exit(found ? 0 : 1); }
  ' "$skill_file"; then
    return 1
  fi

  return 0
}

concise_overview() {
  local description="$1"
  if [ -z "$description" ]; then
    printf '该 skill 已被识别，但尚未配置清晰 description；请根据对应 SKILL.md 补充。'
    return
  fi

  printf '%s' "$description" \
    | tr '\n' ' ' \
    | awk '{
      text=$0;
      gsub(/[[:space:]][[:space:]]*/, " ", text);
      split_markers[1]="触发词：";
      split_markers[2]="触发词:";
      split_markers[3]="触发语包括：";
      split_markers[4]="触发语包括:";
      split_markers[5]="触发请求包括：";
      split_markers[6]="触发请求包括:";
      split_markers[7]="触发语包括";
      split_markers[8]="触发请求包括";
      split_markers[9]="Trigger on requests";
      split_markers[10]="Trigger for requests";
      split_markers[11]="Trigger on ";
      split_markers[12]="Trigger when ";
      split_markers[13]=", defaulting";
      split_markers[14]="; defaulting";
      split_markers[15]="，支持";
      split_markers[16]="，包括";
      split_markers[17]="，并";
      split_markers[18]="。当用户说";
      split_markers[19]=". The skill";
      split_markers[20]=", identify";
      split_markers[21]=", and";
      split_markers[22]=" from a meeting time";
      split_markers[23]="，适用于";
      split_markers[24]="（";
      split_markers[25]="。适用于";
      split_markers[26]="，同步更新到";
      for (i=1; i<=26; i++) {
        if (!(i in split_markers)) continue;
        pos=index(text, split_markers[i]);
        if (pos > 0) {
          text=substr(text, 1, pos - 1);
        }
      }
      sub(/^Use when the user wants to /, "", text);
      sub(/^Use when /, "", text);
      sub(/^the user invokes /, "", text);
      sub(/^\$[^ ]+ or asks to /, "", text);
      sub(/^当用户[^。]*时触发。/, "", text);
      sub(/[[:space:]]+$/, "", text);
      print text;
    }'
}

markdown_escape() {
  local text="$1"
  printf '%s' "${text//|/\\|}"
}

inline_code_escape() {
  local text="$1"
  printf '%s' "${text//\`/\\\`}"
}

printf '开始执行本地 Skills 清单自动化任务\n'
printf '当前 AI 工具：%s\n' "$TOOL_NAME"
printf '扫描目录：%s\n' "$SKILLS_DIR"
printf '目标文件：%s\n' "$OUTPUT_FILE"
mkdir -p "$(dirname "$OUTPUT_FILE")"

{
  printf '# %s 个人本地 Skills 清单\n\n' "$TOOL_NAME"
  printf '最后更新时间：%s\n\n' "$TIMESTAMP"
  printf '本文件仅记录当前由用户自建或个人维护的 %s skills。范围为 `%s` 下的自建 skills，不包含系统内置、插件、市场安装、缓存或外部托管的 skills。\n\n' "$TOOL_NAME" "$SKILLS_DIR"
  printf -- '- 触发器约定：使用 `$skill-name` 显式调用本地 skill。\n'
  printf -- '- 范围：仅自建 skills。\n'
  printf -- '- 排除：系统内置、插件、市场安装、缓存和外部托管 skills。\n\n'
  printf '## Skill 列表\n\n'

  found_count=0

  while IFS= read -r skill_dir; do
    skill_file="${skill_dir}/SKILL.md"
    is_self_built_skill "$skill_dir" || continue

    name="$(sed -n 's/^name:[[:space:]]*//p' "$skill_file" | head -n 1)"
    if [ -z "$name" ]; then
      name="$(basename "$skill_dir")"
    fi

    overview="$(concise_overview "$(description_for "$skill_file")")"
    trigger="\$${name}"

    printf '### %s\n\n' "$name"
    printf -- '- 触发器：`%s`\n' "$(inline_code_escape "$trigger")"
    printf -- '- 路径：`%s`\n' "$(inline_code_escape "$skill_file")"
    printf -- '- 概述：%s\n\n' "$(markdown_escape "$overview")"

    found_count=$((found_count + 1))
  done < <(find "$SKILLS_DIR" -mindepth 1 -maxdepth 1 -type d | sort)
} > "$TMP_FILE"

mv "$TMP_FILE" "$OUTPUT_FILE"

printf '识别到自建 skills 数量：%s\n' "$found_count"
printf '生成中文索引内容\n'
printf '保存目标文件：%s\n' "$OUTPUT_FILE"
printf '刷新最后更新时间：%s\n' "$TIMESTAMP"
printf '校验结果：已生成中文格式 Markdown\n'
printf '本地 Skills 清单自动化任务执行完成\n'
