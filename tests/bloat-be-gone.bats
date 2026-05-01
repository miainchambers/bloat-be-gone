#!/usr/bin/env bats

SCRIPT="$BATS_TEST_DIRNAME/../bloat-be-gone.sh"

setup() {
  WORKSPACE="$(mktemp -d)"
  mkdir -p "$WORKSPACE/project-alpha/node_modules/some-pkg"
  mkdir -p "$WORKSPACE/project-beta/.next"
  mkdir -p "$WORKSPACE/project-beta/dist"
  touch "$WORKSPACE/project-alpha/package-lock.json"
  touch "$WORKSPACE/project-beta/yarn.lock"
}

teardown() {
  rm -rf "$WORKSPACE"
}

@test "--version prints version string" {
  run bash "$SCRIPT" --version
  [ "$status" -eq 0 ]
  [[ "$output" =~ "bloat-be-gone v" ]]
}

@test "unknown flag exits 1" {
  run bash "$SCRIPT" --not-a-real-flag
  [ "$status" -eq 1 ]
}

@test "--dry-run --all shows DRY RUN message" {
  run bash "$SCRIPT" --workspace "$WORKSPACE" --all --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" =~ "DRY RUN" ]]
}

@test "--dry-run --all lists all projects" {
  run bash "$SCRIPT" --workspace "$WORKSPACE" --all --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" =~ "project-alpha" ]]
  [[ "$output" =~ "project-beta" ]]
}

@test "--dry-run --all does not delete anything" {
  run bash "$SCRIPT" --workspace "$WORKSPACE" --all --dry-run
  [ -d "$WORKSPACE/project-alpha/node_modules" ]
  [ -d "$WORKSPACE/project-beta/.next" ]
}

@test "--keep valid project excludes it from preview" {
  run bash "$SCRIPT" --workspace "$WORKSPACE" --keep project-alpha --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" =~ "project-beta" ]]
  [[ ! "$output" =~ "- project-alpha" ]]
}

@test "--keep nonexistent project exits 1 with error" {
  run bash "$SCRIPT" --workspace "$WORKSPACE" --keep no-such-project --dry-run
  [ "$status" -eq 1 ]
  [[ "$output" =~ "does not exist" ]]
}

@test "--keep nonexistent project lists available projects" {
  run bash "$SCRIPT" --workspace "$WORKSPACE" --keep no-such-project --dry-run
  [ "$status" -eq 1 ]
  [[ "$output" =~ "project-alpha" ]]
}

@test "empty workspace exits 0 safely" {
  EMPTY="$(mktemp -d)"
  run bash "$SCRIPT" --workspace "$EMPTY" --all --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" =~ "No projects found" ]]
  rm -rf "$EMPTY"
}

@test "--all with y confirm cleans node_modules" {
  run bash -c "echo 'y' | bash '$SCRIPT' --workspace '$WORKSPACE' --all"
  [ "$status" -eq 0 ]
  [ ! -d "$WORKSPACE/project-alpha/node_modules" ]
}

@test "--all with N confirm aborts and preserves files" {
  run bash -c "echo 'N' | bash '$SCRIPT' --workspace '$WORKSPACE' --all"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Aborted" ]]
  [ -d "$WORKSPACE/project-alpha/node_modules" ]
}

@test "--all cleans lockfiles" {
  run bash -c "echo 'y' | bash '$SCRIPT' --workspace '$WORKSPACE' --all"
  [ "$status" -eq 0 ]
  [ ! -f "$WORKSPACE/project-alpha/package-lock.json" ]
  [ ! -f "$WORKSPACE/project-beta/yarn.lock" ]
}

@test "--no-dist preserves dist/ directory" {
  run bash -c "echo 'y' | bash '$SCRIPT' --workspace '$WORKSPACE' --all --no-dist"
  [ "$status" -eq 0 ]
  [ -d "$WORKSPACE/project-beta/dist" ]
}

@test "dist/ is removed by default" {
  run bash -c "echo 'y' | bash '$SCRIPT' --workspace '$WORKSPACE' --all"
  [ "$status" -eq 0 ]
  [ ! -d "$WORKSPACE/project-beta/dist" ]
}

@test "--keep with confirm skips kept project" {
  run bash -c "echo 'y' | bash '$SCRIPT' --workspace '$WORKSPACE' --keep project-alpha"
  [ "$status" -eq 0 ]
  [ -d "$WORKSPACE/project-alpha/node_modules" ]
  [ ! -d "$WORKSPACE/project-beta/.next" ]
}

@test "safety guard fires when no project selected and no --all" {
  # Pipe EOF so select gets empty input — KEEP_DIR stays empty, guard fires
  run bash -c "echo '' | bash '$SCRIPT' --workspace '$WORKSPACE'"
  [ "$status" -eq 1 ]
  [ -d "$WORKSPACE/project-alpha/node_modules" ]
}
