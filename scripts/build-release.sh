#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"
MAC_DIR="$DIST_DIR/CodexScope-mac"
WIN_DIR="$DIST_DIR/CodexScope-windows"

cd "$ROOT_DIR"

npm run build:frontend

rm -rf "$DIST_DIR"
mkdir -p "$MAC_DIR" "$WIN_DIR"

common_files=(
  "index.html"
  "styles.css"
  "app.js"
  "data.sample.js"
  "README.md"
  "README.zh-CN.md"
  "LICENSE"
)

for file in "${common_files[@]}"; do
  cp "$file" "$MAC_DIR/$file"
  cp "$file" "$WIN_DIR/$file"
done

printf 'window.CODEXSCOPE_DATA = window.CODEXSCOPE_DATA || null;\n' > "$MAC_DIR/data.js"
printf 'window.CODEXSCOPE_DATA = window.CODEXSCOPE_DATA || null;\n' > "$WIN_DIR/data.js"

cp "macos/open-dashboard.command" "$MAC_DIR/open-dashboard.command"
cp "windows/open-dashboard.cmd" "$WIN_DIR/open-dashboard.cmd"

cat > "$MAC_DIR/START-HERE.txt" <<'TXT'
CodexScope macOS 用户先看

1. 双击 open-dashboard.command。
2. 如果 macOS 拦截，打开 系统设置 > 隐私与安全性，点击 仍要打开。
3. 这个包已经内置编译好的 codexscope-darwin-arm64，不需要安装 Go。

如果你下载的是 GitHub 自动生成的 Source code (zip)，那是给开发者看的源码包，不是普通用户推荐下载。

1. Double-click open-dashboard.command.
2. If macOS blocks it, open System Settings > Privacy & Security, then click Open Anyway.
3. This package already includes the compiled codexscope-darwin-arm64 generator. You do not need Go.
TXT

cat > "$WIN_DIR/START-HERE.txt" <<'TXT'
CodexScope Windows 用户先看

1. 双击 open-dashboard.cmd。
2. 这个包已经内置编译好的 codexscope-windows-amd64.exe，不需要安装 Go。

如果你下载的是 GitHub 自动生成的 Source code (zip)，那是给开发者看的源码包，不是普通用户推荐下载。

1. Double-click open-dashboard.cmd.
2. This package already includes the compiled codexscope-windows-amd64.exe generator. You do not need Go.
TXT

GOOS=darwin GOARCH=arm64 go build -trimpath -ldflags="-s -w" -o "$MAC_DIR/codexscope-darwin-arm64" generate_codex_data.go
GOOS=windows GOARCH=amd64 go build -trimpath -ldflags="-s -w" -o "$WIN_DIR/codexscope-windows-amd64.exe" generate_codex_data.go

chmod +x "$MAC_DIR/open-dashboard.command" "$MAC_DIR/codexscope-darwin-arm64"

(
  cd "$DIST_DIR"
  zip -qr "CodexScope-mac.zip" "CodexScope-mac"
  zip -qr "CodexScope-windows.zip" "CodexScope-windows"
)

printf 'Built release packages:\n  %s\n  %s\n' \
  "$DIST_DIR/CodexScope-mac.zip" \
  "$DIST_DIR/CodexScope-windows.zip"
