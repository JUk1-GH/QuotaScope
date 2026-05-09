#!/bin/zsh
set -e

cd "$(dirname "$0")"
if [ ! -f index.html ]; then
  cd ..
fi

if [ -f ./codexscope-darwin-arm64 ]; then
  chmod +x ./codexscope-darwin-arm64 2>/dev/null || true
fi

if [ -x ./codexscope-darwin-arm64 ] \
  && { [ ! -f generate_codex_data.go ] || { [ ./codexscope-darwin-arm64 -nt generate_codex_data.go ] && [ ./codexscope-darwin-arm64 -nt go.mod ] && [ ./codexscope-darwin-arm64 -nt go.sum ]; }; } \
  && ./codexscope-darwin-arm64; then
  open index.html
  exit 0
fi

if [ -x ./codexscope-generator ] \
  && [ ./codexscope-generator -nt generate_codex_data.go ] \
  && [ ./codexscope-generator -nt go.mod ] \
  && [ ./codexscope-generator -nt go.sum ] \
  && ./codexscope-generator; then
  open index.html
  exit 0
fi

if command -v go >/dev/null 2>&1; then
  go build -trimpath -ldflags="-s -w" -o ./codexscope-generator generate_codex_data.go
  ./codexscope-generator
else
  echo "No prebuilt generator was found, and Go is not installed."
  echo "Please download CodexScope-mac.zip from the GitHub Releases page."
  exit 1
fi

open index.html
