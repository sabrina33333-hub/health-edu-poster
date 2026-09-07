#!/bin/bash
# 反向：把 GitHub repo 最新版本拉下來，同步回本機 iCloud 那份 skill。
# 用途：如果在網頁版 Claude Code（連這個 repo）改了 skill 內容並 push 了，
# 用這支腳本把改動同步回本機 CLI 用的那份。
#
# 用法：./pull-and-sync.sh
#
# 來源（這個 git repo，網頁版改完 push 後會在這裡）：
#   /Users/new/dev/health-edu-poster/.claude/skills/health-edu-poster/
# 目的地（本機 CLI 用，Claude Code 在「工作用/衛教產圖」專案目錄下會自動發現）：
#   claudeAgen/工作用/衛教產圖/.claude/skills/health-edu-poster/
#
# 會覆蓋 iCloud 那份跟 repo 不一樣的地方（含刪除 iCloud 有但 repo 沒有的檔案），
# 執行前會先列出「即將變更的項目」讓妳確認，輸入 y 才會真的動手。
# .venv（本機 Python 環境的符號連結）不受影響，repo 本來就沒有這個東西。

set -euo pipefail

REPO_DIR="/Users/new/dev/health-edu-poster"
SRC="$REPO_DIR/.claude/skills/health-edu-poster"
DEST="/Users/new/Library/Mobile Documents/com~apple~CloudDocs/claudeAgen/工作用/衛教產圖/.claude/skills/health-edu-poster"

if [ ! -d "$DEST" ]; then
  echo "找不到本機目的地資料夾：$DEST"
  exit 1
fi

echo "== 1. 從 GitHub 拉最新版本 =="
cd "$REPO_DIR"
git pull --ff-only origin main

RSYNC_OPTS=(-a --delete --exclude='.venv' --exclude='.venv/' --exclude='.DS_Store' --exclude='__pycache__')

echo "== 2. 預覽會有哪些變更（repo → 本機 iCloud） =="
CHANGES="$(rsync -an --delete --itemize-changes \
  --exclude='.venv' --exclude='.venv/' --exclude='.DS_Store' --exclude='__pycache__' \
  "$SRC/" "$DEST/")"

if [ -z "$CHANGES" ]; then
  echo "沒有變更，本機已經是最新的。"
  exit 0
fi

echo "$CHANGES"
echo ""
read -p "以上是即將對本機 iCloud 那份做的變更，確定要套用嗎？(y/N) " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  echo "取消，沒有做任何變更。"
  exit 0
fi

echo "== 3. 套用同步 =="
rsync "${RSYNC_OPTS[@]}" "$SRC/" "$DEST/"

echo "完成。本機 iCloud 那份已同步為 repo 最新版本。"
