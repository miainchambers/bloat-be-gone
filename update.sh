#!/usr/bin/env bash

set -e

REPO="https://raw.githubusercontent.com/miainchambers/bloat-be-gone/main"
INSTALL_DIR="$HOME/.local/bin"

echo "🔄 Updating bloat-be-gone..."

TMP_MAIN="/tmp/bloat-be-gone"
TMP_BGB="/tmp/bgb"

if ! curl -fsSL "$REPO/bloat-be-gone.sh" -o "$TMP_MAIN"; then
  echo "❌ Update failed: could not fetch bloat-be-gone.sh"
  exit 1
fi

if ! curl -fsSL "$REPO/bin/bgb" -o "$TMP_BGB"; then
  echo "❌ Update failed: could not fetch bin/bgb"
  exit 1
fi

chmod +x "$TMP_MAIN" "$TMP_BGB"
cat "$TMP_MAIN" > "$INSTALL_DIR/bloat-be-gone"
cat "$TMP_BGB"  > "$INSTALL_DIR/bgb"
rm -f "$TMP_MAIN" "$TMP_BGB"

echo "✅ Updated: bloat-be-gone + bgb"
bloat-be-gone --version