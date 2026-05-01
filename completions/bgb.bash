# bash completion for bgb
# Install: source this file from ~/.bashrc, or copy to /etc/bash_completion.d/bgb

_bgb_completions() {
  local cur prev
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  local commands="clean update uninstall doctor version help"
  local clean_flags="--keep --all --dry-run --no-dist --workspace"

  if [[ $COMP_CWORD -eq 1 ]]; then
    # shellcheck disable=SC2207
    COMPREPLY=( $(compgen -W "$commands" -- "$cur") )
    return
  fi

  case "$prev" in
    clean|bgb)
      # shellcheck disable=SC2207
      COMPREPLY=( $(compgen -W "$clean_flags" -- "$cur") )
      ;;
    --workspace)
      # complete with directories
      # shellcheck disable=SC2207
      COMPREPLY=( $(compgen -d -- "$cur") )
      ;;
    --keep)
      # complete with subdirectory names of current dir
      # shellcheck disable=SC2207
      COMPREPLY=( $(compgen -W "$(ls -d */ 2>/dev/null | tr -d /)" -- "$cur") )
      ;;
  esac
}

complete -F _bgb_completions bgb
