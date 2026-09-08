#!/bin/bash
# 把本機 iCloud 那份 health-edu-poster skill 同步進這個 git repo，然後推上 GitHub。
# 用法：./sync-and-push.sh ["commit 訊息（選填）"]
#
# 來源（本機 CLI 用，Claude Code 在「工作用/衛教產圖」專案目錄下會自動發現）：
#   claudeAgen/工作用/衛教產圖/.claude/skills/health-edu-poster/
# 目的地（這個 git repo，網頁版 Claude Code 連這個 repo 才會發現）：
#   /Users/new/dev/health-edu-poster/.claude/skills/health-edu-poster/
#
# 同步方向固定是「iCloud → repo」單向，因為平常改 skill 內容是在本機 CLI 做。
# 如果哪天改成先在網頁版改、想反過來同步回 iCloud，跟 Claude 說一聲，另外寫一支反向腳本。

set -euo pipefail

SRC="/Users/new/Library/Mobile Documents/com~apple~CloudDocs/claudeAgen/工作用/衛教產圖/.claude/skills/health-edu-poster"
REPO_DIR="/Users/new/dev/health-edu-poster"
DEST="$REPO_DIR/.claude/skills/health-edu-poster"

if [ ! -d "$SRC" ]; then
  echo "找不到來源資料夾：$SRC"
  exit 1
fi

echo "== 1. 同步檔案（iCloud → git repo） =="
rsync -a --delete \
  --exclude='.venv' \
  --exclude='.venv/' \
  --exclude='.DS_Store' \
  --exclude='__pycache__' \
  "$SRC/" "$DEST/"

cd "$REPO_DIR"

echo "== 2. 檢查有沒有變更 =="
if git diff --quiet && git diff --cached --quiet && [ -z "$(git status --porcelain)" ]; then
  echo "沒有變更，不用 commit/push。"
  exit 0
fi

git add -A
git status --short

MSG="${1:-Sync from local iCloud copy - $(date '+%Y-%m-%d %H:%M')}"

echo "== 3. Commit =="
git commit -q -m "$MSG

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01SLuzuRRBa6WLbxDHxwx5fQ"

echo "== 4. Push 到 GitHub =="
git push

echo "完成。repo: https://github.com/sabrina33333-hub/health-edu-poster"
