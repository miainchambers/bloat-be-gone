# 🧹 bloat-be-gone

A fast, interactive CLI tool for cleaning up Node.js workspace bloat across multiple projects.

It safely removes `node_modules`, lockfiles, and build caches — while letting you keep one project untouched.

> **Platform:** macOS, Linux, and Windows (via WSL). Native Windows (cmd/PowerShell) is not supported.

---

## 🚀 What it does

- 🧽 Removes `node_modules` from all projects (except the selected one)
- 🔒 Deletes lockfiles (`package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`)
- 🧼 Cleans build/framework caches (`.next`, `.nuxt`, `.turbo`, `.vite`, etc.)
- 📦 Clears global npm/yarn/pnpm caches
- 🧠 Interactive TUI project selection
- ⚡ Optional `fzf` support (recommended)
- 🧪 Dry-run mode for safe previews

---

## 📦 Installation

One command — installs `bloat-be-gone` and the `bgb` wrapper to `~/.local/bin`:

```bash
curl -fsSL https://raw.githubusercontent.com/miainchambers/bloat-be-gone/main/install.sh | bash
```

Then reload your shell:

```bash
source ~/.zshrc   # or ~/.bashrc
```

> **Note:** The installer automatically adds `~/.local/bin` to your `$PATH` if it isn't already there.

### Windows (WSL)

bloat-be-gone runs inside [WSL](https://learn.microsoft.com/en-us/windows/wsl/install) (Windows Subsystem for Linux). Native cmd/PowerShell are not supported.

1. Open your WSL terminal (Ubuntu, Debian, etc.)
2. Run the same install command above
3. The tool auto-detects WSL and uses `apt`/`dnf` for any dependency installs

> Your Windows filesystem is accessible at `/mnt/c/...` — you can point `--workspace` there:
> ```bash
> bgb clean --workspace /mnt/c/Users/yourname/projects
> ```

---

## 🧑‍💻 Usage

> **Before running:** `cd` into the folder that **contains** your projects — `bgb clean` treats your current directory as the workspace root, with each subdirectory treated as a separate project.
>
> For example, if your projects live at `~/projects/api`, `~/projects/web`, `~/projects/mobile` — run `cd ~/projects` first.
>
> Or skip the `cd` entirely with `--workspace`:
>
> ```bash
> bgb clean --workspace ~/projects
> ```

Use the `bgb` command wrapper for the cleanest experience:

```bash
bgb clean               # interactive cleanup
bgb clean --keep api-project    # keep a specific project
bgb clean --dry-run     # preview only — nothing deleted
bgb clean --all         # clean everything, no exclusions
bgb clean --no-dist     # skip dist/ and build/ (safe for committed outputs)
bgb update              # update to latest version
bgb uninstall           # remove bloat-be-gone from your system
bgb doctor              # check dependencies and install health
bgb version             # show current version
bgb help                # show all commands
```

Or use `bloat-be-gone` directly:

```bash
bloat-be-gone                        # run in current directory
bloat-be-gone /path/to/workspace     # specify workspace root
bloat-be-gone --keep api-project             # keep a specific project
bloat-be-gone --all                  # clean everything
bloat-be-gone --no-dist              # skip dist/ and build/
bloat-be-gone --dry-run              # preview only
```

---

## 🎮 Interactive mode

If no flags are provided:

- You'll be prompted to select a project to keep
- If `fzf` is installed → full TUI selector (recommended)
- If not → fallback terminal selector

Install fzf:

```bash
# macOS
brew install fzf

# Ubuntu / Debian
sudo apt install fzf

# Fedora / RHEL
sudo dnf install fzf
```

> If fzf isn't installed, `bgb` will offer to install it automatically when you first run it (on supported systems), then fall back to a simple numbered selector.

---

## 🧠 Example workflow

```bash
# cd into the folder that CONTAINS your projects (not into a project itself)
cd ~/Documents/workspaces
bgb clean
```

Then:

1. Select `api` (the project you're actively working on)
2. Everything else is cleaned
3. `node_modules`, caches, and lockfiles are removed elsewhere

---

## ⚠️ Safety features

- Requires confirmation before deletion
- Supports dry-run mode
- Never deletes selected "keep" project
- Home directory requires typing `yes` (not just `y`) to proceed
- `--keep` validates the target exists before running
- Safe fallback if no directories found
- Graceful handling of missing tools

---

## 🧰 What gets cleaned

**Dependencies**

- `node_modules`
- `package-lock.json`
- `yarn.lock`
- `pnpm-lock.yaml`

**Yarn / PNPM artifacts**

- `.yarn`
- `.pnp.cjs`
- `.pnp.loader.mjs`
- `.yarnrc.yml`

**Build outputs** _(use `--no-dist` to skip these)_

- `.next`
- `.nuxt`
- `.turbo`
- `.vite`
- `.parcel-cache`
- `dist`
- `build`

> ⚠️ **Note:** `dist/` and `build/` are deleted by default. If your team commits these directories (e.g. serverless functions, static sites), use `--no-dist`.

**Misc**

- `.eslintcache`
- `*.tsbuildinfo`

---

## ⚡ Why this exists

Modern JS/TS workspaces accumulate:

- huge `node_modules`
- duplicated dependencies
- stale build caches
- slow installs and disk bloat

This tool acts as a fast reset button for local development environments.

---

## 🗑️ Uninstall

```bash
bgb uninstall
```

Or manually:

```bash
rm ~/.local/bin/bloat-be-gone ~/.local/bin/bgb
```

---

## � Contributing

### Setup

```bash
git clone https://github.com/miainchambers/bloat-be-gone.git
cd bloat-be-gone
bash hooks/install.sh
```

This installs pre-commit (ShellCheck) and pre-push (BATS tests) hooks automatically.

### Requirements

```bash
# macOS
brew install shellcheck fzf

# Ubuntu / Debian
sudo apt install shellcheck fzf

# Fedora / RHEL
sudo dnf install ShellCheck fzf
```

### Running tests manually

```bash
bats tests/
```

### Branch protection

All PRs targeting `main` require:

- ✅ Approval from the repo owner
- ✅ ShellCheck lint passing
- ✅ BATS tests passing

---

## �🪤 License

MIT — use freely, modify, improve, break, rebuild.
