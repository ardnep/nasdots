# Avoid duplicate PATH entries.
typeset -U path PATH

export EDITOR=nvim
export VISUAL=nvim

# Aliases
alias f="yazi"
alias ls="eza"
alias t="tmux"
alias ta="tmux attach"

# Keybindings; OMZ's vi-mode is initialized by NixOS.
bindkey -s '\es' '^asudo ^e'
bindkey -s '\eg' '^agit ^e'
bindkey -s '\ec' '^asource ^e'
bindkey -M viins jj vi-cmd-mode
bindkey -M vicmd 'k' up-line-or-beginning-search
bindkey -M vicmd 'j' down-line-or-beginning-search

# Change the shell's directory when leaving Yazi.
function y() {
  local tmp cwd
  tmp="$(mktemp -t yazi-cwd.XXXXXX)" || return

  yazi "$@" --cwd-file="$tmp"
  cwd="$(cat -- "$tmp")"
  rm -f -- "$tmp"

  if [[ -n "$cwd" && "$cwd" != "$PWD" ]]; then
    builtin cd -- "$cwd"
  fi
}

# Launch Yazi with Ctrl+F and refresh the prompt afterward.
function _yazi_widget() {
  y
  zle reset-prompt
}
zle -N _yazi_widget
bindkey -M viins '^F' _yazi_widget

# Shell integrations
eval "$(direnv hook zsh)"

if [[ "$CLAUDECODE" != "1" ]]; then
  eval "$(zoxide init --cmd cd zsh)"
fi
