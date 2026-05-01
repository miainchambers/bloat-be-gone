# Changelog

All notable changes to this project will be documented in this file.

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

---

## [1.0.0] - 2026-05-01

### Added
- `bgb` wrapper command with `clean`, `update`, `uninstall`, `doctor`, `version`, `help` subcommands
- Interactive fzf project selector with fallback `select` menu
- `--keep`, `--all`, `--dry-run`, `--no-dist`, `--workspace` flags
- Cross-platform support: macOS, Linux, WSL — OS-aware fzf/shellcheck install hints
- Auto-detects and offers to install fzf via brew/apt/dnf
- `install.sh` and `update.sh` pin to latest GitHub release tag
- `bgb update` shows current → latest version diff and links to release notes
- CI matrix: ShellCheck lint + BATS tests on Ubuntu and macOS
- Git hooks: pre-commit (ShellCheck) and pre-push (BATS)
- Safety guard: home directory requires `yes` to confirm
- `--keep` validates target project exists before running
- `set -euo pipefail` and `readonly` constants across all scripts
- `mktemp` for secure temp files in `update.sh`
