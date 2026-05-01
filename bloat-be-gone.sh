#!/usr/bin/env bash

# ============================================
# bloat-be-gone (team-safe CLI tool)
# ============================================

VERSION="1.0.0"

# --- Flags ---
KEEP_OVERRIDE=""
DRY_RUN=false
CLEAN_ALL=false
SHOW_VERSION=false
NO_DIST=false
WORKSPACE_ARG=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --keep)
      KEEP_OVERRIDE="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --all)
      CLEAN_ALL=true
      shift
      ;;
    --no-dist)
      NO_DIST=true
      shift
      ;;
    --workspace)
      WORKSPACE_ARG="$2"
      shift 2
      ;;
    --version)
      SHOW_VERSION=true
      shift
      ;;
    *)
      echo "❌ Unknown flag: $1"
      exit 1
      ;;
  esac
done

# --- Version ---
if [ "$SHOW_VERSION" = true ]; then
  echo "bloat-be-gone v$VERSION"
  exit 0
fi

# --- Workspace ---
if [ -n "$WORKSPACE_ARG" ]; then
  BASE_DIR="$WORKSPACE_ARG"
else
  BASE_DIR="$(pwd)"

  if command -v fzf >/dev/null 2>&1; then
    read -r -p "Select workspace root? (y/N): " PICK_WS

    if [[ "$PICK_WS" == "y" || "$PICK_WS" == "Y" ]]; then
      BASE_DIR=$(
        find "$HOME" -maxdepth 3 -type d 2>/dev/null |
        fzf --prompt="Select workspace root: "
      )

      if [ -z "$BASE_DIR" ]; then
        echo "❌ No workspace selected"
        exit 1
      fi
    fi
  fi
fi

if [ ! -d "$BASE_DIR" ]; then
  echo "❌ Directory does not exist: $BASE_DIR"
  exit 1
fi

# --- Home dir warning ---
REAL_BASE=$(cd "$BASE_DIR" && pwd)
REAL_HOME=$(cd "$HOME" && pwd)

if [ "$REAL_BASE" = "$REAL_HOME" ]; then
  echo ""
  echo "⚠️  WARNING: You are about to clean your home directory ($HOME)."
  echo "   This will affect ALL top-level folders."
  read -r -p "   Are you sure? Type yes to continue: " HOME_CONFIRM
  if [[ "$HOME_CONFIRM" != "yes" ]]; then
    echo "❌ Aborted"
    exit 0
  fi
fi

echo "📁 Using base directory: $BASE_DIR"

# --- Project list (array - safe for paths with spaces) ---
PROJECTS=()
while IFS= read -r dir; do
  [[ -n "$dir" ]] && PROJECTS+=("$dir")
done < <(find "$BASE_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null || true)

if [ ${#PROJECTS[@]} -eq 0 ]; then
  echo "⚠️ No projects found — exiting safely."
  exit 0
fi

KEEP_DIR=""

# --- KEEP logic ---
if [ -n "$KEEP_OVERRIDE" ]; then
  KEEP_DIR="$BASE_DIR/$KEEP_OVERRIDE"

  if [ ! -d "$KEEP_DIR" ]; then
    echo "❌ --keep target does not exist: $KEEP_DIR"
    echo "   Available projects:"
    for p in "${PROJECTS[@]}"; do echo "     - $(basename "$p")"; done
    exit 1
  fi

  echo "🎯 Keeping (override): $KEEP_DIR"

elif [ "$CLEAN_ALL" = true ]; then
  echo "⚠️ --all mode enabled — all projects will be cleaned"

else
  if command -v fzf >/dev/null 2>&1; then
    echo "🔍 Using fzf selection"

    KEEP_DIR=$(
      for dir in "${PROJECTS[@]}"; do
        size=$(du -sh "$dir" 2>/dev/null | cut -f1)
        printf "%s | %s\n" "$dir" "$size"
      done |
      fzf --prompt="Select project to KEEP: " |
      cut -d'|' -f1 |
      xargs
    )

  else
    echo "⚠️ fzf not installed — fallback selector"

    PROJECT_NAMES=()
    for p in "${PROJECTS[@]}"; do
      PROJECT_NAMES+=("$(basename "$p")")
    done

    select KEEP_NAME in "${PROJECT_NAMES[@]}"; do
      if [ -n "$KEEP_NAME" ]; then
        KEEP_DIR="$BASE_DIR/$KEEP_NAME"
        break
      fi
    done
  fi
fi

# --- SAFETY GUARD ---
if [ "$CLEAN_ALL" != true ] && [ -z "$KEEP_DIR" ]; then
  echo "❌ Safety abort: no project selected to keep"
  exit 1
fi

echo "📦 Base: $BASE_DIR"
echo "✅ Keep: ${KEEP_DIR:-NONE}"

[ "$NO_DIST" = true ] && echo "ℹ️  --no-dist: skipping dist/ and build/"

# --- Preview ---
echo ""
echo "🧾 Will clean:"

for dir in "${PROJECTS[@]}"; do
  if [ -z "$KEEP_DIR" ] || [ "$dir" != "$KEEP_DIR" ]; then
    echo "  - $(basename "$dir")"
  fi
done

echo ""

# --- Dry run ---
if [ "$DRY_RUN" = true ]; then
  echo "🧪 DRY RUN — nothing was deleted"
  exit 0
fi

# --- Confirm ---
read -r -p "⚠️ Proceed? (y/N): " CONFIRM

if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
  echo "❌ Aborted"
  exit 0
fi

# --- Global caches ---
echo "🗑 npm cache..."
npm cache clean --force 2>/dev/null || true

echo "🗑 yarn cache..."
yarn cache clean 2>/dev/null || true

echo "🗑 pnpm store..."
pnpm store prune 2>/dev/null || true

rm -rf ~/.npm ~/.pnpm-store ~/.cache/yarn ~/.yarn

# --- Cleanup ---
for dir in "${PROJECTS[@]}"; do

  if [ -n "$KEEP_DIR" ] && [ "$dir" = "$KEEP_DIR" ]; then
    echo "⏭ Skipping $(basename "$dir")"
    continue
  fi

  echo "🧹 Cleaning $(basename "$dir")..."

  find "$dir" -type d -name "node_modules" -prune -exec rm -rf {} +

  find "$dir" -type f \( \
    -name "package-lock.json" -o \
    -name "yarn.lock" -o \
    -name "pnpm-lock.yaml" \
  \) -delete

  rm -rf "$dir/.yarn" \
         "$dir/.pnp.cjs" \
         "$dir/.pnp.loader.mjs" \
         "$dir/.yarnrc.yml"

  rm -rf "$dir/.next" \
         "$dir/.nuxt" \
         "$dir/.turbo" \
         "$dir/.cache" \
         "$dir/.vite" \
         "$dir/.parcel-cache"

  if [ "$NO_DIST" != true ]; then
    rm -rf "$dir/dist" "$dir/build"
  fi

  rm -rf "$dir/.eslintcache"
  find "$dir" -name "*.tsbuildinfo" -delete

done

echo "🎉 Cleanup complete!"
