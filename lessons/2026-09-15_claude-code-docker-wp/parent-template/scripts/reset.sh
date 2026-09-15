#!/usr/bin/env bash
# 指定した子環境を「CLAUDE.md だけがある状態」に戻す。
# 使い方: ./scripts/reset.sh <子ディレクトリ名> [-y]
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NAME="${1:-}"
YES="${2:-}"

if [ -z "$NAME" ]; then
  echo "使い方: ./scripts/reset.sh <子ディレクトリ名> [-y]" >&2
  exit 1
fi

TARGET="$ROOT/$NAME"
if [ ! -d "$TARGET" ]; then
  echo "子ディレクトリが見つかりません: $TARGET" >&2
  exit 1
fi

echo "対象: $TARGET"
echo "コンテナとボリュームを削除し、CLAUDE.md 以外のファイルを消します。"
if [ "$YES" != "-y" ]; then
  read -r -p "続けますか? [y/N] " ans
  [ "$ans" = "y" ] || [ "$ans" = "Y" ] || { echo "中止しました"; exit 0; }
fi

cd "$TARGET"

if [ -f compose.yml ] || [ -f compose.yaml ] || [ -f docker-compose.yml ]; then
  echo "--- docker compose down -v"
  docker compose down -v --remove-orphans || true
fi

# CLAUDE.md だけ退避して、中身を空にしてから戻す
TMP="$(mktemp -d)"
[ -f CLAUDE.md ] && cp CLAUDE.md "$TMP/CLAUDE.md"

shopt -s dotglob nullglob
rm -rf -- ./*
shopt -u dotglob nullglob

if [ -f "$TMP/CLAUDE.md" ]; then
  cp "$TMP/CLAUDE.md" ./CLAUDE.md
else
  cp "$ROOT/templates/CLAUDE.md" ./CLAUDE.md
fi
rm -rf "$TMP"

echo "--- 残っているファイル"
ls -a
echo "リセット完了: $NAME"
