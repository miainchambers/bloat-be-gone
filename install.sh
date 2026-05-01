#!/usr/bin/env bash
set -euo pipefail

readonly INSTALL_DIR="$HOME/.local/bin"
readonly GITHUB_REPO="miainchambers/bloat-be-gone"

echo "📦 Installing bloat-be-gone..."

# Resolve latest release tag
echo "🔍 Fetching latest version..."
LATEST_TAG=$(curl -fsSL "https://api.github.com/repos/$GITHUB_REPO/releases/latest" \
  | grep '"tag_name"' | cut -d'"' -f4)

if [ -z "$LATEST_TAG" ]; then
  echo "❌ Could not fetch latest release from GitHub."
  exit 1
fi

readonly REPO="https://raw.githubusercontent.com/$GITHUB_REPO/$LATEST_TAG"

mkdir -p "$INSTALL_DIR"

# Install main script
curl -fsSL "$REPO/bloat-be-gone.sh" -o "$INSTALL_DIR/bloat-be-gone"
chmod +x "$INSTALL_DIR/bloat-be-gone"

# Install bgb wrapper
curl -fsSL "$REPO/bin/bgb" -o "$INSTALL_DIR/bgb"
chmod +x "$INSTALL_DIR/bgb"

# Auto PATH fix
if ! echo ":$PATH:" | grep -q ":$INSTALL_DIR:"; then
  case "$SHELL" in
    */zsh)  SHELL_RC="$HOME/.zshrc" ;;
    */bash) SHELL_RC="$HOME/.bashrc" ;;
    *)      SHELL_RC="$HOME/.profile" ;;
  esac

  if ! grep -q "$INSTALL_DIR" "$SHELL_RC" 2>/dev/null; then
    # shellcheck disable=SC2016
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_RC"
    echo "🔧 Added $INSTALL_DIR to PATH in $SHELL_RC"
    echo "   Run: source $SHELL_RC"
  fi
fi

echo ""
echo "✅ Installed: bloat-be-gone + bgb ($LATEST_TAG)"
echo ""
echo "👉 Quick start:"
echo "   bgb clean          — interactive cleanup"
echo "   bgb clean --help   — see all options"
echo "   bgb doctor         — check your setup"