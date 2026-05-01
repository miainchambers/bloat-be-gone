#!/usr/bin/env bash
set -euo pipefail

readonly INSTALL_DIR="$HOME/.local/bin"
readonly GITHUB_REPO="miainchambers/bloat-be-gone"

# Get current installed version
if command -v bloat-be-gone >/dev/null 2>&1; then
  CURRENT_VERSION=$(bloat-be-gone --version | grep -o '[0-9][0-9.]*' | head -1)
else
  CURRENT_VERSION="0.0.0"
fi

echo "🔄 Checking for updates..."

# Resolve latest release tag
LATEST_TAG=$(curl -fsSL "https://api.github.com/repos/$GITHUB_REPO/releases/latest" \
  | grep '"tag_name"' | cut -d'"' -f4)

if [ -z "$LATEST_TAG" ]; then
  echo "❌ Could not fetch latest release from GitHub."
  exit 1
fi

LATEST_VERSION="${LATEST_TAG#v}"

if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
  echo "✅ Already up to date (v$CURRENT_VERSION)"
  exit 0
fi

echo "⬆️  Updating v$CURRENT_VERSION → v$LATEST_VERSION..."

readonly REPO="https://raw.githubusercontent.com/$GITHUB_REPO/$LATEST_TAG"

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

echo "✅ Updated to v$LATEST_VERSION"
echo "   Release notes: https://github.com/$GITHUB_REPO/releases/tag/$LATEST_TAG"