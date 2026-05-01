#!/usr/bin/env bash
# shellcheck disable=SC2310
set -uo pipefail

# ============================================
# bloat-be-gone (team-safe CLI tool)
# ============================================

readonly VERSION="1.3.0" # x-release-please-version

# --- OS detection ---
_os() {
  case "$(uname -s)" in
    Darwin) echo "macos" ;;
    Linux)
      if grep -qi microsoft /proc/version 2>/dev/null; then
        echo "wsl"
      else
        echo "linux"
      fi
      ;;
    *) echo "other" ;;
  esac
}

_fzf_install_hint() {
  case "$(_os)" in
    macos)     echo "brew install fzf" ;;
    linux|wsl) echo "sudo apt install fzf  # or: sudo dnf install fzf" ;;
    *)         echo "see https://github.com/junegunn/fzf#installation" ;;
  esac
}

_shellcheck_install_hint() {
  case "$(_os)" in
    macos)     echo "brew install shellcheck" ;;
    linux|wsl) echo "sudo apt install shellcheck  # or: sudo dnf install shellcheck" ;;
    *)         echo "see https://github.com/koalaman/shellcheck#installing" ;;
  esac
}

# --- Flags ---
KEEP_OVERRIDE_ARGS=()
DRY_RUN=false
CLEAN_ALL=false
SHOW_VERSION=false
NO_DIST=false
WORKSPACE_ARG=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --keep)
      if [[ $# -lt 2 ]]; then
        echo "❌ --keep requires a value"
        exit 1
      fi
      # Accept comma-separated list: --keep api,web,mobile
      IFS=',' read -ra KEEP_OVERRIDE_ARGS <<< "$2"
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
      if [[ $# -lt 2 ]]; then
        echo "❌ --workspace requires a value"
        exit 1
      fi
      WORKSPACE_ARG="$2"
      shift 2
      ;;
    --version)
      SHOW_VERSION=true
      shift
      ;;
    --help|-h)
      echo "Usage: bloat-be-gone [options]"
      echo ""
      echo "Options:"
      echo "  --keep <project(s)>   Keep specific projects (comma-separated: api,web)"
      echo "  --all                 Clean all projects (no exclusions)"
      echo "  --dry-run             Preview only — nothing is deleted"
      echo "  --no-dist             Skip dist/ and build/ directories"
      echo "  --workspace <path>    Set workspace root (skips interactive prompt)"
      echo "  --version             Show current version"
      echo "  --help                Show this help"
      echo ""
      echo "Examples:"
      echo "  bloat-be-gone"
      echo "  bloat-be-gone --keep api-project"
      echo "  bloat-be-gone --all --dry-run"
      echo "  bloat-be-gone --workspace ~/projects --keep api-project"
      echo ""
      echo "Tip: use 'bgb' for a friendlier interface — run 'bgb help'"
      exit 0
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

  if command -v fzf >/dev/null 2>&1 && [ -t 0 ]; then
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

KEEP_DIRS=()

# --- KEEP logic ---
if [ ${#KEEP_OVERRIDE_ARGS[@]} -gt 0 ]; then
  for _k in "${KEEP_OVERRIDE_ARGS[@]}"; do
    _kdir="$BASE_DIR/$_k"
    if [ ! -d "$_kdir" ]; then
      echo "❌ --keep target does not exist: $_kdir"
      echo "   Available projects:"
      for p in "${PROJECTS[@]}"; do echo "     - $(basename "$p")"; done
      exit 1
    fi
    KEEP_DIRS+=("$_kdir")
  done
  echo "🎯 Keeping (override): ${KEEP_OVERRIDE_ARGS[*]}"

elif [ "$CLEAN_ALL" = true ]; then
  echo "⚠️ --all mode enabled — all projects will be cleaned"

else
  # Offer to install fzf if missing, a supported package manager is available, and we're in a terminal
  if ! command -v fzf >/dev/null 2>&1 && [ -t 0 ]; then
    _PKG_MGR=""
    command -v brew >/dev/null 2>&1 && _PKG_MGR="brew"
    command -v apt  >/dev/null 2>&1 && [ -z "$_PKG_MGR" ] && _PKG_MGR="apt"
    command -v dnf  >/dev/null 2>&1 && [ -z "$_PKG_MGR" ] && _PKG_MGR="dnf"

    if [ -n "$_PKG_MGR" ]; then
      echo "💡 fzf is not installed — it gives you a much nicer project selector."
      read -r -p "   Install fzf now? (y/N): " INSTALL_FZF
      if [[ "$INSTALL_FZF" == "y" || "$INSTALL_FZF" == "Y" ]]; then
        case "$_PKG_MGR" in
          brew) brew install fzf ;;
          apt)  sudo apt install -y fzf ;;
          dnf)  sudo dnf install -y fzf ;;
        esac
        hash -r 2>/dev/null || true
        echo ""
      fi
    fi
  fi

  if command -v fzf >/dev/null 2>&1 && [ -t 0 ]; then

    mapfile -t KEEP_DIRS < <(
      for dir in "${PROJECTS[@]}"; do
        size=$(du -sh "$dir" 2>/dev/null | cut -f1)
        printf "%s | %s\n" "$dir" "$size"
      done |
      fzf --prompt="Select projects to KEEP: " \
          --multi \
          --header="Tab=select/deselect  Enter=confirm  Ctrl-C=abort" \
          --bind='tab:toggle+down' |
      cut -d'|' -f1 |
      sed 's/[[:space:]]*$//'
    )

  else
    [ -t 0 ] && echo "⚠️ fzf not available — using fallback selector ($(_fzf_install_hint))"
    echo ""

    PROJECT_NAMES=()
    for p in "${PROJECTS[@]}"; do
      PROJECT_NAMES+=("$(basename "$p")")
    done

    echo "Select projects to KEEP (enter number, blank line when done):"
    select KEEP_NAME in "${PROJECT_NAMES[@]}"; do
      if [ -n "$KEEP_NAME" ]; then
        KEEP_DIRS+=("$BASE_DIR/$KEEP_NAME")
        echo "  ✅ Added: $KEEP_NAME (enter another number, or blank to finish)"
      else
        break
      fi
    done
  fi
fi

# --- SAFETY GUARD ---
if [ "$CLEAN_ALL" != true ] && [ "${#KEEP_DIRS[@]}" -eq 0 ]; then
  echo "❌ Safety abort: no project selected to keep"
  exit 1
fi

echo "📦 Base: $BASE_DIR"
if [ "${#KEEP_DIRS[@]}" -gt 0 ]; then
  for _kd in "${KEEP_DIRS[@]}"; do echo "✅ Keep: $(basename "$_kd")"; done
else
  echo "✅ Keep: NONE"
fi

[ "$NO_DIST" = true ] && echo "ℹ️  --no-dist: skipping dist/ and build/"

# --- Preview ---
echo ""
echo "🧾 Will clean:"

for dir in "${PROJECTS[@]}"; do
  _skip=false
  for _kd in "${KEEP_DIRS[@]:-}"; do
    [ -z "$_kd" ] && break
    [ "$dir" = "$_kd" ] && _skip=true && break
  done
  if [ "$_skip" = false ]; then
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

rm -rf "$HOME/.npm" "$HOME/.pnpm-store" "$HOME/.cache/yarn" "$HOME/.yarn"

# --- Cleanup ---
for dir in "${PROJECTS[@]}"; do

  _skip=false
  for _kd in "${KEEP_DIRS[@]:-}"; do
    [ -z "$_kd" ] && break
    [ "$dir" = "$_kd" ] && _skip=true && break
  done
  if [ "$_skip" = true ]; then
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
