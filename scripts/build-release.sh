#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"
MAC_DIR="$DIST_DIR/CodexScope-mac"
WIN_DIR="$DIST_DIR/CodexScope-windows"

cd "$ROOT_DIR"

npm run build:frontend

rm -rf "$DIST_DIR"
mkdir -p "$MAC_DIR/macos" "$WIN_DIR/windows"

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

cp "macos/open-dashboard.command" "$MAC_DIR/macos/open-dashboard.command"
cp "windows/open-dashboard.cmd" "$WIN_DIR/windows/open-dashboard.cmd"

GOOS=darwin GOARCH=arm64 go build -trimpath -ldflags="-s -w" -o "$MAC_DIR/codexscope-darwin-arm64" generate_codex_data.go
GOOS=windows GOARCH=amd64 go build -trimpath -ldflags="-s -w" -o "$WIN_DIR/codexscope-windows-amd64.exe" generate_codex_data.go

chmod +x "$MAC_DIR/macos/open-dashboard.command" "$MAC_DIR/codexscope-darwin-arm64"

(
  cd "$DIST_DIR"
  zip -qr "CodexScope-mac.zip" "CodexScope-mac"
  zip -qr "CodexScope-windows.zip" "CodexScope-windows"
)

printf 'Built release packages:\n  %s\n  %s\n' \
  "$DIST_DIR/CodexScope-mac.zip" \
  "$DIST_DIR/CodexScope-windows.zip"
