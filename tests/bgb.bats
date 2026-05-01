#!/usr/bin/env bats

BGG="$BATS_TEST_DIRNAME/../bin/bgb"

@test "bgb help exits 0 and shows usage" {
  run bash "$BGG" help
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Usage:" ]]
}

@test "bgb --help exits 0" {
  run bash "$BGG" --help
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Usage:" ]]
}

@test "bgb with no args shows help" {
  run bash "$BGG"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Usage:" ]]
}

@test "bgb unknown command exits 1" {
  run bash "$BGG" not-a-command
  [ "$status" -eq 1 ]
}

@test "bgb unknown command prints helpful message" {
  run bash "$BGG" not-a-command
  [ "$status" -eq 1 ]
  [[ "$output" =~ "bgb help" ]]
}

@test "bgb doctor exits 0" {
  run bash "$BGG" doctor
  [ "$status" -eq 0 ]
}

@test "bgb doctor reports install dir" {
  run bash "$BGG" doctor
  [ "$status" -eq 0 ]
  [[ "$output" =~ ".local/bin" ]]
}

@test "bgb doctor reports PATH status" {
  run bash "$BGG" doctor
  [ "$status" -eq 0 ]
  [[ "$output" =~ "PATH" ]]
}

@test "bgb version exits 0 and prints version" {
  run bash "$BGG" version
  [ "$status" -eq 0 ]
  [[ "$output" =~ "bloat-be-gone v" ]]
}

@test "bgb help lists all commands" {
  run bash "$BGG" help
  [ "$status" -eq 0 ]
  [[ "$output" =~ "clean" ]]
  [[ "$output" =~ "update" ]]
  [[ "$output" =~ "uninstall" ]]
  [[ "$output" =~ "doctor" ]]
  [[ "$output" =~ "version" ]]
}

@test "bgb clean passes --dry-run --all through to bloat-be-gone" {
  WORKSPACE="$(mktemp -d)"
  mkdir -p "$WORKSPACE/project-x"
  run bash "$BGG" clean --workspace "$WORKSPACE" --all --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" =~ "DRY RUN" ]]
  rm -rf "$WORKSPACE"
}

@test "bgb clean passes --mobile through to bloat-be-gone" {
  WORKSPACE="$(mktemp -d)"
  mkdir -p "$WORKSPACE/project-x"
  TMPBIN="$(mktemp -d)"
  ln -s "$BATS_TEST_DIRNAME/../bloat-be-gone.sh" "$TMPBIN/bloat-be-gone"
  PATH="$TMPBIN:$PATH" run bash "$BGG" clean --workspace "$WORKSPACE" --all --dry-run --mobile
  [ "$status" -eq 0 ]
  [[ "$output" =~ "DRY RUN" ]]
  rm -rf "$WORKSPACE" "$TMPBIN"
}

@test "bgb help lists --mobile option" {
  run bash "$BGG" help
  [ "$status" -eq 0 ]
  [[ "$output" =~ "--mobile" ]]
}
