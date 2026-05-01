# zsh completion for bgb
# Install: place in a directory on your $fpath, e.g. ~/.zsh/completions/_bgb
#          then run: autoload -Uz compinit && compinit

_bgb() {
  local -a commands
  commands=(
    'clean:Clean node_modules, lockfiles, and caches'
    'update:Update bloat-be-gone to the latest version'
    'uninstall:Remove bloat-be-gone and bgb from your system'
    'doctor:Check dependencies and installation health'
    'version:Show current version'
    'help:Show help'
  )

  local -a clean_flags
  clean_flags=(
    '--keep[Keep specific projects to exclude from cleaning (comma-separated)]:project:_directories'
    '--all[Clean all projects, no exclusions]'
    '--dry-run[Preview only — nothing is deleted]'
    '--no-dist[Skip dist/ and build/ directories]'
    '--workspace[Set workspace root]:directory:_directories'
  )

  if (( CURRENT == 2 )); then
    _describe 'bgb commands' commands
    return
  fi

  case "${words[2]}" in
    clean)
      _arguments $clean_flags
      ;;
  esac
}

compdef _bgb bgb
