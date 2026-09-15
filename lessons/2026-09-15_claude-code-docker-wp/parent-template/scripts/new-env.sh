#!/usr/bin/env bash
# 子フォルダの雛形を作る。
# 使い方: ./scripts/new-env.sh <子ディレクトリ名> <ホストポート>
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NAME="${1:-}"
PORT="${2:-}"

if [ -z "$NAME" ] || [ -z "$PORT" ]; then
  echo "使い方: ./scripts/new-env.sh <子ディレクトリ名> <ホストポート>" >&2
  exit 1
fi

TARGET="$ROOT/$NAME"
if [ -d "$TARGET" ]; then
  echo "すでに存在します: $TARGET" >&2
  exit 1
fi

if lsof -nP -iTCP:"$PORT" -sTCP:LISTEN >/dev/null 2>&1; then
  echo "警告: ポート $PORT は使用中です。別のポートを指定してください。" >&2
  exit 1
fi

mkdir -p "$TARGET"
sed -e "s/<案件名>/$NAME/g" -e "s/<割当ポート>/$PORT/g" \
  "$ROOT/templates/CLAUDE.md" > "$TARGET/CLAUDE.md"

echo "作成しました: $TARGET"
echo "projects.md にポート $PORT を追記してください。"
echo
echo "  cd $TARGET && claude"
