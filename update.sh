#!/usr/bin/env bash
set -euo pipefail

readonly REPO="https://raw.githubusercontent.com/miainchambers/bloat-be-gone/main"
readonly INSTALL_DIR="$HOME/.local/bin"

echo "🔄 Updating bloat-be-gone..."

TMP_MAIN="$(mktemp)"
TMP_BGB="$(mktemp)"

cleanup() { rm -f "$TMP_MAIN" "$TMP_BGB"; }
trap cleanup EXIT

if ! curl -fsSL "$REPO/bloat-be-gone.sh" -o "$TMP_MAIN"; then
  echo "❌ Update failed: could not fetch bloat-be-gone.sh"
  exit 1
fi

if ! curl -fsSL "$REPO/bin/bgb" -o "$TMP_BGB"; then
  echo "❌ Update failed: could not fetch bin/bgb"
  exit 1
fi

chmod +x "$TMP_MAIN" "$TMP_BGB"
mkdir -p "$INSTALL_DIR"
cat "$TMP_MAIN" > "$INSTALL_DIR/bloat-be-gone"
cat "$TMP_BGB"  > "$INSTALL_DIR/bgb"

echo "✅ Updated: bloat-be-gone + bgb"
bloat-be-gone --version