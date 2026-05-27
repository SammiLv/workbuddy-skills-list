#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
cd "$REPO_DIR"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Error: current directory is not a Git repository."
  exit 1
fi

if ! git remote get-url origin >/dev/null 2>&1; then
  echo "Error: Git remote 'origin' is not configured."
  exit 1
fi

branch="$(git branch --show-current)"
if [[ -z "$branch" ]]; then
  echo "Error: not on a branch. Please switch to a branch before syncing."
  exit 1
fi

remote_url="$(git remote get-url origin)"
timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
commit_message="${1:-Auto update skills: $timestamp}"

echo "Repository: $(pwd)"
echo "Remote: $remote_url"
echo "Branch: $branch"
echo

echo "Fetching latest remote state..."
git fetch origin "$branch"

if git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
  echo "Rebasing local changes onto origin/$branch..."
  git pull --rebase --autostash origin "$branch"
fi

echo "Staging changes according to Git ignore rules..."
git add -A -- .

if git diff --cached --quiet; then
  echo "No changes to commit. Ignored files stayed ignored according to .gitignore."
  exit 0
fi

echo "Files to be committed:"
git diff --cached --name-status
echo

git commit -m "$commit_message"

echo "Pushing to GitHub..."
git push origin "$branch"

echo
echo "Done. Current directory has been synced to GitHub."
