#!/usr/bin/env bash

set -e

INSTALL_DIR="$HOME/.local/bin"

echo "🗑️  Uninstalling bloat-be-gone..."

removed=0
for bin in bloat-be-gone bgb; do
  if [ -f "$INSTALL_DIR/$bin" ]; then
    rm -f "$INSTALL_DIR/$bin"
    echo "  ✅ Removed $INSTALL_DIR/$bin"
    removed=$((removed + 1))
  else
    echo "  ⚠️  Not found: $INSTALL_DIR/$bin"
  fi
done

if [ $removed -gt 0 ]; then
  echo ""
  echo "✅ Uninstalled successfully."
  echo ""
  echo "You may also remove the PATH entry from your shell rc if desired:"
  echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
else
  echo "⚠️  Nothing was removed — is bloat-be-gone installed?"
fi
