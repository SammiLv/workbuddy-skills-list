#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURRENT_SKILL_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CURRENT_SKILLS_DIR="${AI_SKILLS_DIR:-$(cd "${CURRENT_SKILL_DIR}/.." && pwd)}"

TOOL_NAMES=(codex cursor workbuddy opencode claude trae trae-cn cline gemini)
TOOL_DIRS=(
  "${HOME}/.codex/skills"
  "${HOME}/.cursor/skills"
  "${HOME}/.workbuddy/skills"
  "${HOME}/.config/opencode/skills"
  "${HOME}/.claude/skills"
  "${HOME}/.trae/skills"
  "${HOME}/.trae-cn/memory/skills"
  "${HOME}/.cline/skills"
  "${HOME}/.gemini/skills"
)

MODE="skill"
SYNC_NAME=""
TARGET_SELECTOR=""
FORCE=0

usage() {
  cat <<'USAGE'
用法：
  sync_skill_to_ai_tools.sh
      从其它 AI 工具中选择同名 skill 最新的一份，同步到当前工具。

  sync_skill_to_ai_tools.sh all
      将当前 skill 同步到所有其它 AI 工具。

  sync_skill_to_ai_tools.sh cursor
      将当前 skill 只同步到指定 AI 工具。

  sync_skill_to_ai_tools.sh personal-skill-inventory all
      将指定 skill 同步到所有其它 AI 工具。

  sync_skill_to_ai_tools.sh --skill personal-skill-inventory trae
      将指定 skill 只同步到 Trae。

  sync_skill_to_ai_tools.sh --file .gitignore all
      将 skills 根目录下的指定文件同步到所有其它 AI 工具。

  sync_skill_to_ai_tools.sh --skill weekly-report-summary all --force
      源不是所有工具中的最新版本时，跳过确认并继续推送。谨慎使用。

支持的工具名：
  codex cursor workbuddy opencode claude trae trae-cn cline gemini
USAGE
}

is_target_selector() {
  case "${1:-}" in
    all|codex|cursor|workbuddy|opencode|claude|trae|trae-cn|traecn|cline|gemini)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

tool_dir_for() {
  local selector="$1"
  local i

  [ "$selector" = "traecn" ] && selector="trae-cn"

  for ((i = 0; i < ${#TOOL_NAMES[@]}; i++)); do
    if [ "${TOOL_NAMES[$i]}" = "$selector" ]; then
      printf '%s\n' "${TOOL_DIRS[$i]}"
      return 0
    fi
  done

  return 1
}

mtime_for() {
  if [ -f "$1" ]; then
    stat -f '%m' "$1"
  else
    find "$1" -type f \
      ! -name '.DS_Store' \
      ! -name 'LOCAL_SKILLS_INDEX.md' \
      -exec stat -f '%m' {} + \
      | sort -nr \
      | head -n 1
  fi
}

copy_to_target() {
  local source_path="$1"
  local target_root="$2"
  local sync_name="$3"

  if [ "$MODE" = "file" ]; then
    rsync -a "$source_path" "${target_root}/"
    printf '已同步到：%s\n' "${target_root}/${sync_name}"
  else
    local target_skill_dir="${target_root}/${sync_name}"
    mkdir -p "$target_skill_dir"
    rsync -a --delete \
      --exclude '.DS_Store' \
      --exclude 'LOCAL_SKILLS_INDEX.md' \
      "${source_path}/" \
      "${target_skill_dir}/"
    printf '已同步到：%s\n' "$target_skill_dir"
  fi
}

while [ $# -gt 0 ]; do
  case "$1" in
    --help|-h)
      usage
      exit 0
      ;;
    --force)
      FORCE=1
      ;;
    --file)
      MODE="file"
      shift
      if [ $# -eq 0 ]; then
        printf '错误：请在 --file 后指定要同步的根目录文件名，例如 .gitignore。\n' >&2
        exit 1
      fi
      SYNC_NAME="$1"
      ;;
    --skill)
      MODE="skill"
      shift
      if [ $# -eq 0 ]; then
        printf '错误：请在 --skill 后指定 skill 名称。\n' >&2
        exit 1
      fi
      SYNC_NAME="$1"
      ;;
    all|codex|cursor|workbuddy|opencode|claude|trae|trae-cn|traecn|cline|gemini)
      TARGET_SELECTOR="$1"
      ;;
    *)
      if [ -z "$SYNC_NAME" ]; then
        SYNC_NAME="$1"
      elif [ -z "$TARGET_SELECTOR" ] && is_target_selector "$1"; then
        TARGET_SELECTOR="$1"
      else
        printf '错误：无法识别参数：%s\n' "$1" >&2
        usage >&2
        exit 1
      fi
      ;;
  esac
  shift
done

if [ -z "$SYNC_NAME" ]; then
  SYNC_NAME="$(basename "$CURRENT_SKILL_DIR")"
fi

if [ "$MODE" = "file" ]; then
  case "$SYNC_NAME" in
    */*|.|..|'')
      printf '错误：只能同步 skills 根目录下的单个文件名：%s\n' "$SYNC_NAME" >&2
      exit 1
      ;;
  esac
fi

source_path_for_root() {
  local root="$1"
  local name="$2"
  printf '%s/%s\n' "$root" "$name"
}

validate_source() {
  local source_path="$1"

  if [ "$MODE" = "file" ]; then
    [ -f "$source_path" ] || return 1
  else
    [ -d "$source_path" ] || return 1
    [ -f "${source_path}/SKILL.md" ] || return 1
  fi
}

current_source_path="$(source_path_for_root "$CURRENT_SKILLS_DIR" "$SYNC_NAME")"

find_newest_source() {
  newest_source=""
  newest_root=""
  newest_mtime=0

  for ((i = 0; i < ${#TOOL_DIRS[@]}; i++)); do
    root="${TOOL_DIRS[$i]}"
    [ -d "$root" ] || continue

    candidate="$(source_path_for_root "$root" "$SYNC_NAME")"
    validate_source "$candidate" || continue

    candidate_mtime="$(mtime_for "$candidate")"
    if [ "$candidate_mtime" -gt "$newest_mtime" ]; then
      newest_mtime="$candidate_mtime"
      newest_source="$candidate"
      newest_root="$root"
    fi
  done
}

if [ -z "$TARGET_SELECTOR" ]; then
  find_newest_source

  if [ -z "$newest_source" ] || [ "$newest_root" = "$CURRENT_SKILLS_DIR" ]; then
    printf '错误：其它 AI 工具中没有找到比当前工具更新的%s：%s\n' "$([ "$MODE" = "file" ] && printf '根目录文件' || printf ' skill')" "$SYNC_NAME" >&2
    exit 1
  fi

  printf '开始从其它 AI 工具同步%s到当前工具：%s\n' "$([ "$MODE" = "file" ] && printf '根目录文件' || printf ' skill')" "$SYNC_NAME"
  printf '源路径：%s\n' "$newest_source"
  printf '当前工具 skills 根目录：%s\n' "$CURRENT_SKILLS_DIR"

  copy_to_target "$newest_source" "$CURRENT_SKILLS_DIR" "$SYNC_NAME"
  printf '同步完成：已从 %s 拉取到当前工具。\n' "$newest_root"
  exit 0
fi

validate_source "$current_source_path" || {
  printf '错误：当前工具中不存在可同步的%s：%s\n' "$([ "$MODE" = "file" ] && printf '根目录文件' || printf ' skill')" "$current_source_path" >&2
  exit 1
}

find_newest_source
current_mtime="$(mtime_for "$current_source_path")"
if [ "$FORCE" -ne 1 ] && [ -n "$newest_source" ] && [ "$newest_mtime" -gt "$current_mtime" ]; then
  printf '警告：当前源不是最新版本，继续同步会用旧版本覆盖更新内容。\n' >&2
  printf '当前源：%s\n' "$current_source_path" >&2
  printf '当前源最新文件时间戳：%s\n' "$current_mtime" >&2
  printf '检测到更新来源：%s\n' "$newest_source" >&2
  printf '更新来源最新文件时间戳：%s\n' "$newest_mtime" >&2
  if [ ! -t 0 ]; then
    printf '非交互环境无法确认，已停止同步。如确认要覆盖，请追加 --force。\n' >&2
    exit 1
  fi
  printf '是否继续用当前源覆盖其它工具？输入 yes 确认：' >&2
  read -r confirm_outdated
  case "$confirm_outdated" in
    yes|YES|y|Y)
      printf '已确认：继续使用当前源同步。\n' >&2
      ;;
    *)
      printf '已取消同步。\n' >&2
      exit 1
      ;;
  esac
fi

if [ "$TARGET_SELECTOR" = "all" ]; then
  target_dirs=("${TOOL_DIRS[@]}")
else
  target_dir="$(tool_dir_for "$TARGET_SELECTOR")" || {
    printf '错误：未知目标工具：%s\n' "$TARGET_SELECTOR" >&2
    exit 1
  }
  target_dirs=("$target_dir")
fi

printf '开始同步%s：%s\n' "$([ "$MODE" = "file" ] && printf '根目录文件' || printf ' skill')" "$SYNC_NAME"
printf '源路径：%s\n' "$current_source_path"
printf '目标选择：%s\n' "$TARGET_SELECTOR"

synced_count=0
skipped_count=0

for target_root in "${target_dirs[@]}"; do
  [ -n "$target_root" ] || continue

  if [ "$target_root" = "$CURRENT_SKILLS_DIR" ]; then
    printf '跳过当前工具目录：%s\n' "$target_root"
    skipped_count=$((skipped_count + 1))
    continue
  fi

  if [ ! -d "$target_root" ]; then
    printf '跳过不存在的目标目录：%s\n' "$target_root"
    skipped_count=$((skipped_count + 1))
    continue
  fi

  copy_to_target "$current_source_path" "$target_root" "$SYNC_NAME"
  synced_count=$((synced_count + 1))
done

printf '同步完成：成功 %s 个，跳过 %s 个。\n' "$synced_count" "$skipped_count"
