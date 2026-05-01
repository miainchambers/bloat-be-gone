# Changelog

All notable changes to this project will be documented in this file.

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

---

## [2.0.0](https://github.com/miainchambers/bloat-be-gone/compare/v1.4.1...v2.0.0) (2026-05-01)


### ⚠ BREAKING CHANGES

* --mobile permanently deletes Xcode DerivedData, iOS Simulator caches, and Gradle daemon/cache directories with no recovery path

### ### Added

* add --mobile flag to clean Xcode, iOS Simulator, and Gradle caches ([ee47d45](https://github.com/miainchambers/bloat-be-gone/commit/ee47d45d9581bab567c3f4efca4985dc4def0985))

## [1.4.1](https://github.com/miainchambers/bloat-be-gone/compare/v1.4.0...v1.4.1) (2026-05-01)


### ### Fixed

* replace mapfile with bash 3.2-compatible while-read loop ([a0e5938](https://github.com/miainchambers/bloat-be-gone/commit/a0e59385ecce44d2761f1cb974970a146314771f))

## [1.4.0](https://github.com/miainchambers/bloat-be-gone/compare/v1.3.0...v1.4.0) (2026-05-01)


### ### Added

* add the ability to select multiple projects to keep ([309d59a](https://github.com/miainchambers/bloat-be-gone/commit/309d59a77868a1e4218411f317b40b9c4e5d27f3))

## [1.3.0](https://github.com/miainchambers/bloat-be-gone/compare/v1.2.2...v1.3.0) (2026-05-01)


### ### Added

* remove separate tap update action ([a3fdd1a](https://github.com/miainchambers/bloat-be-gone/commit/a3fdd1a8a4cac6c3bba664607a3f713622a7bfdb))

## [1.2.2](https://github.com/miainchambers/bloat-be-gone/compare/v1.2.1...v1.2.2) (2026-05-01)


### ### Fixed

* fix update tap to run on release created and published ([0d03954](https://github.com/miainchambers/bloat-be-gone/commit/0d03954365d8a721cd8d3c11c6e8f99ec5aeb161))

## [1.2.1](https://github.com/miainchambers/bloat-be-gone/compare/v1.2.0...v1.2.1) (2026-05-01)


### ### Fixed

* fixed shasum on Linux ([b19407a](https://github.com/miainchambers/bloat-be-gone/commit/b19407a027ae86c0b1f1d5de4087969661e10975))
* fixed shasum on Linux ([b19407a](https://github.com/miainchambers/bloat-be-gone/commit/b19407a027ae86c0b1f1d5de4087969661e10975))
* fixed shasum on Linux ([097ba31](https://github.com/miainchambers/bloat-be-gone/commit/097ba31cec60e670de64dc9d2bafff8bf8cc9e72))

## [1.2.0](https://github.com/miainchambers/bloat-be-gone/compare/v1.1.0...v1.2.0) (2026-05-01)


### ### Added

* add shell completions and homebrew tap support ([b2972a9](https://github.com/miainchambers/bloat-be-gone/commit/b2972a911cc01d6a0354f7e296a3401db71370cc))

## [1.1.0](https://github.com/miainchambers/bloat-be-gone/compare/v1.0.0...v1.1.0) (2026-05-01)


### ### Added

* add homebrew tap and cross-platform support ([364f521](https://github.com/miainchambers/bloat-be-gone/commit/364f521c16edd3f36d31ee4075644fcee2d026d7))
* add homebrew tap and cross-platform support ([364f521](https://github.com/miainchambers/bloat-be-gone/commit/364f521c16edd3f36d31ee4075644fcee2d026d7))
* add homebrew tap and cross-platform support ([6ef1831](https://github.com/miainchambers/bloat-be-gone/commit/6ef18319dd8ff3c693b95a97ac6e936d5ee9bc22))
* Added Homebrew support for Mac OS ([c2863e9](https://github.com/miainchambers/bloat-be-gone/commit/c2863e902af833174391da72eb181632f3e672b0))
* Automated releases and changelog ([c434547](https://github.com/miainchambers/bloat-be-gone/commit/c434547eed26d6c94709277d67c9ea3fe0601e71))
* Enforcing PRs into main from dev branch only ([cfbbda6](https://github.com/miainchambers/bloat-be-gone/commit/cfbbda6a428d76850e18db20f798d1689c30cdca))
* homebrew and branch protection ([8a6bb99](https://github.com/miainchambers/bloat-be-gone/commit/8a6bb99034c0abffb48358c9a448992a3b923f17))
* homebrew tap ([8645faf](https://github.com/miainchambers/bloat-be-gone/commit/8645faf5e4b478a9d576b5a68c0aa61b43c07b91))
* homebrew tap ([8645faf](https://github.com/miainchambers/bloat-be-gone/commit/8645faf5e4b478a9d576b5a68c0aa61b43c07b91))


### ### Fixed

* use packages format in release-please config ([4db1d86](https://github.com/miainchambers/bloat-be-gone/commit/4db1d86c6a3493103df4f0ca8eb1faab310b3051))

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
