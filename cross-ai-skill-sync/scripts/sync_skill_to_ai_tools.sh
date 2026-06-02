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
DIFF_MODE=0
FROM_SELECTOR=""

usage() {
  cat <<'USAGE'
用法：
  sync_skill_to_ai_tools.sh -from all
      从其它 AI 工具中选择同名 skill 最新的一份，同步到当前工具。

  sync_skill_to_ai_tools.sh -from all -skill personal-skill-inventory
      从其它 AI 工具中选择指定 skill 最新的一份，同步到当前工具。

  sync_skill_to_ai_tools.sh -from all -file .gitignore
      从其它 AI 工具中选择指定根目录文件最新的一份，同步到当前工具。

  sync_skill_to_ai_tools.sh -from cursor
      从指定 AI 工具拉取当前目录 skill 到当前工具。

  sync_skill_to_ai_tools.sh -from cursor -skill personal-skill-inventory
      从指定 AI 工具拉取指定 skill 到当前工具。

  sync_skill_to_ai_tools.sh -from cursor -file .gitignore
      从指定 AI 工具拉取根目录文件到当前工具。

  sync_skill_to_ai_tools.sh -to all
      将当前 skill 同步到所有其它 AI 工具。

  sync_skill_to_ai_tools.sh -to cursor
      将当前 skill 只同步到指定 AI 工具。

  sync_skill_to_ai_tools.sh -to all -skill personal-skill-inventory
      将指定 skill 同步到所有其它 AI 工具。

  sync_skill_to_ai_tools.sh -to trae -skill personal-skill-inventory
      将指定 skill 只同步到 Trae。

  sync_skill_to_ai_tools.sh -to all -file .gitignore
      将 skills 根目录下的指定文件同步到所有其它 AI 工具。

  sync_skill_to_ai_tools.sh -to cursor -file .gitignore
      将 skills 根目录下的指定文件同步到指定 AI 工具。

  sync_skill_to_ai_tools.sh -to all -skill weekly-report-summary -force
      源不是所有工具中的最新版本时，跳过确认并继续推送。谨慎使用。

  sync_skill_to_ai_tools.sh -diff
      对所有 AI 工具中的 skill 进行版本对比。
      输出格式：skill | 同步状态 | 份数 | 最新版本工具
      同步状态：同步、不同步
      份数：该 skill 在多少个 AI 工具中存在
      最新版本工具：记录最新版本所在的工具名

支持的工具名：
  codex cursor workbuddy opencode claude trae trae-cn cline gemini

其它选项：
  -help, -h  查看用法说明。
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

# 差异对比函数
run_diff_mode() {
  printf '\n=== AI 工具 Skill 版本对比 ===\n'
  printf '%-40s | %-10s | %-8s | %s\n' "Skill" "同步状态" "份数" "最新版本工具"
  printf '%-40s-|-%-10s-|-%-8s-|-%s\n' "----------------------------------------" "----------" "--------" "--------------"

  # 收集所有工具中的所有 skill 名称（使用临时文件存储唯一名称）
  temp_file=$(mktemp)

  for ((i = 0; i < ${#TOOL_DIRS[@]}; i++)); do
    root="${TOOL_DIRS[$i]}"
    [ -d "$root" ] || continue

    if [ -d "$root" ]; then
      for skill_dir in "$root"/*/; do
        [ -d "$skill_dir" ] || continue
        skill_name="$(basename "$skill_dir")"
        echo "$skill_name" >> "$temp_file"
      done
    fi
  done

  # 排序并去重
  sort -u "$temp_file" > "${temp_file}.sorted"

  # 对每个 skill 进行版本对比
  while IFS= read -r skill_name; do
    [ -z "$skill_name" ] && continue

    newest_mtime=0
    newest_tool=""
    sync_status="同步"
    tool_count=0

    # 统计该 skill 在多少个工具中存在
    for ((i = 0; i < ${#TOOL_DIRS[@]}; i++)); do
      root="${TOOL_DIRS[$i]}"
      [ -d "$root" ] || continue
      skill_path="$root/$skill_name"
      [ -d "$skill_path" ] && tool_count=$((tool_count + 1))
    done

    # 第一遍：找出最新版本的工具
    for ((i = 0; i < ${#TOOL_DIRS[@]}; i++)); do
      root="${TOOL_DIRS[$i]}"
      [ -d "$root" ] || continue

      skill_path="$root/$skill_name"
      [ -d "$skill_path" ] || continue

      # 获取该 skill 的最新修改时间
      skill_mtime="$(mtime_for "$skill_path")"
      if [ "$skill_mtime" -gt "$newest_mtime" ]; then
        newest_mtime="$skill_mtime"
        newest_tool="${TOOL_NAMES[$i]}"
      fi
    done

    # 第二遍：检查是否所有工具中的版本都一致
    if [ -n "$newest_tool" ]; then
      # 找到最新版本的工具路径
      newest_path=""
      for ((j = 0; j < ${#TOOL_NAMES[@]}; j++)); do
        if [ "${TOOL_NAMES[$j]}" = "$newest_tool" ]; then
          newest_path="${TOOL_DIRS[$j]}/$skill_name"
          break
        fi
      done

      # 对比所有工具中的该 skill 是否与最新版本一致
      for ((i = 0; i < ${#TOOL_DIRS[@]}; i++)); do
        root="${TOOL_DIRS[$i]}"
        [ -d "$root" ] || continue

        skill_path="$root/$skill_name"
        [ -d "$skill_path" ] || continue

        # 使用 diff 检查是否与最新版本一致
        if [ -d "$newest_path" ] && [ -d "$skill_path" ]; then
          diff_result="$(diff -qr --exclude '.DS_Store' --exclude 'LOCAL_SKILLS_INDEX.md' "$newest_path" "$skill_path" 2>/dev/null || true)"
          if [ -n "$diff_result" ]; then
            sync_status="不同步"
            break
          fi
        fi
      done
    fi

    # 如果同步状态为"同步"，则不显示最新版本工具名称
    if [ "$sync_status" = "同步" ]; then
      newest_tool=""
    fi

    printf '%-40s | %-10s | %-8s | %s\n' "$skill_name" "$sync_status" "$tool_count" "$newest_tool"
  done < "${temp_file}.sorted"

  # 清理临时文件
  rm -f "$temp_file" "${temp_file}.sorted"

  printf '=== 对比完成 ===\n'
  exit 0
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

# 解析参数
while [ $# -gt 0 ]; do
  case "$1" in
    -help|-h)
      usage
      exit 0
      ;;
    -force)
      FORCE=1
      ;;
    -diff)
      DIFF_MODE=1
      ;;
    -to)
      shift
      if [ $# -eq 0 ]; then
        printf '错误：请在 -to 后指定目标工具名或 all。\n' >&2
        exit 1
      fi
      TARGET_SELECTOR="$1"
      ;;
    -from)
      shift
      if [ $# -eq 0 ]; then
        printf '错误：请在 -from 后指定来源工具名或 all。\n' >&2
        exit 1
      fi
      FROM_SELECTOR="$1"
      ;;
    -file)
      MODE="file"
      shift
      if [ $# -eq 0 ]; then
        printf '错误：请在 -file 后指定要同步的根目录文件名。\n' >&2
        exit 1
      fi
      SYNC_NAME="$1"
      ;;
    -skill)
      MODE="skill"
      shift
      if [ $# -eq 0 ]; then
        printf '错误：请在 -skill 后指定 skill 名称。\n' >&2
        exit 1
      fi
      SYNC_NAME="$1"
      ;;
    *)
      if [ -z "$SYNC_NAME" ]; then
        SYNC_NAME="$1"
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

# 如果指定了 -from 模式，从指定工具拉取到当前工具
if [ -n "$FROM_SELECTOR" ]; then
  # 校验来源工具是否合法
  case "$FROM_SELECTOR" in
    all|codex|cursor|workbuddy|opencode|claude|trae|trae-cn|traecn|cline|gemini)
      ;;
    *)
      printf '错误：无法识别来源工具：%s\n' "$FROM_SELECTOR" >&2
      usage >&2
      exit 1
      ;;
  esac

  if [ -z "$SYNC_NAME" ]; then
    SYNC_NAME="$(basename "$CURRENT_SKILL_DIR")"
  fi

  # -from all：从所有工具中找出最新版本拉取到当前
  if [ "$FROM_SELECTOR" = "all" ]; then
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
    # 如果同时指定了 -to，继续执行推送；否则退出
    if [ -z "$TARGET_SELECTOR" ]; then
      exit 0
    fi
  fi

  # -from <工具名>：从指定工具拉取
  from_root="$(tool_dir_for "$FROM_SELECTOR")"
  if [ ! -d "$from_root" ]; then
    printf '错误：来源工具目录不存在：%s\n' "$from_root" >&2
    exit 1
  fi

  from_path="$(source_path_for_root "$from_root" "$SYNC_NAME")"
  validate_source "$from_path" || {
    printf '错误：来源工具（%s）中不存在：%s\n' "$FROM_SELECTOR" "$SYNC_NAME" >&2
    exit 1
  }

  # 检查来源是否是所有工具中的最新版本
  find_newest_source
  from_mtime="$(mtime_for "$from_path")"
  if [ "$FORCE" -ne 1 ] && [ -n "$newest_source" ] && [ "$newest_mtime" -gt "$from_mtime" ]; then
    printf '警告：指定的来源（%s）不是所有工具中的最新版本。\n' "$FROM_SELECTOR" >&2
    printf '指定来源路径：%s\n' "$from_path" >&2
    printf '指定来源最新文件时间戳：%s\n' "$from_mtime" >&2
    printf '检测到更新来源：%s\n' "$newest_source" >&2
    printf '更新来源最新文件时间戳：%s\n' "$newest_mtime" >&2
    if [ ! -t 0 ]; then
      printf '非交互环境无法确认，已停止同步。如确认要用指定来源覆盖，请追加 -force。\n' >&2
      exit 1
    fi
    printf '是否继续用指定来源（%s）覆盖当前工具？输入 yes 确认：' "$FROM_SELECTOR" >&2
    read -r confirm_from
    case "$confirm_from" in
      yes|YES|y|Y)
        printf '已确认：继续使用指定来源同步。\n' >&2
        ;;
      *)
        printf '已取消同步。\n' >&2
        exit 1
        ;;
    esac
  fi

  printf '开始从 %s 拉取%s到当前工具：%s\n' "$FROM_SELECTOR" "$([ "$MODE" = "file" ] && printf '根目录文件' || printf ' skill')" "$SYNC_NAME"
  printf '来源路径：%s\n' "$from_path"
  printf '当前工具 skills 根目录：%s\n' "$CURRENT_SKILLS_DIR"

  copy_to_target "$from_path" "$CURRENT_SKILLS_DIR" "$SYNC_NAME"
  printf '拉取完成：已从 %s 同步到当前工具。\n' "$FROM_SELECTOR"
  # 如果同时指定了 -to，继续执行推送；否则退出
  if [ -z "$TARGET_SELECTOR" ]; then
    exit 0
  fi
fi

# 如果指定了 -diff 模式，运行差异对比并退出
if [ "$DIFF_MODE" -eq 1 ]; then
  run_diff_mode
fi

if [ -z "$TARGET_SELECTOR" ]; then
  printf '错误：未指定目标。推送请用 -to all 或 -to <工具名>；拉取请用 -from all 或 -from <工具名>。\n' >&2
  usage >&2
  exit 1
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
    printf '非交互环境无法确认，已停止同步。如确认要覆盖，请追加 -force。\n' >&2
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
