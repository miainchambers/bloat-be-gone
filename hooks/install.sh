#!/usr/bin/env bash

# Installs git hooks from hooks/ into .git/hooks/
# Run once after cloning: bash hooks/install.sh

set -e

REPO_ROOT="$(git rev-parse --show-toplevel)"
HOOKS_SRC="$REPO_ROOT/hooks"
HOOKS_DIR="$REPO_ROOT/.git/hooks"

echo "🔧 Installing git hooks..."

for hook in pre-commit pre-push; do
  src="$HOOKS_SRC/$hook"
  dest="$HOOKS_DIR/$hook"

  if [ ! -f "$src" ]; then
    echo "  ⚠️  Not found: $src"
    continue
  fi

  cp "$src" "$dest"
  chmod +x "$dest"
  echo "  ✅ Installed: $hook"
done

echo ""
echo "✅ Git hooks installed."
echo "   pre-commit: ShellCheck on all shell files"
echo "   pre-push:   BATS test suite"
