# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# oh my zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# perf: skip the fpath security audit (single-user machine) and oh-my-zsh's
# background auto-update git-fetch on startup. Run `omz update` manually.
ZSH_DISABLE_COMPFIX="true"
zstyle ':omz:update' mode disabled

# Pin the completion dump to a stable, hostname-independent path. omz's default
# embeds $SHORT_HOST, and macOS intermittently flips this machine's hostname
# between "Roberts-MacBook-Pro" and "...-2", which changed the dump filename
# every session and forced a full compinit rebuild each start.
ZSH_COMPDUMP="$HOME/.cache/zsh/zcompdump-${ZSH_VERSION}"

plugins=(
  git
  zsh-autosuggestions
  )
# NOTE: zsh-syntax-highlighting is intentionally NOT listed here. It must be
# sourced last, after every other ZLE plugin — see the bottom of this file.
# NOTE: zsh-autocomplete is intentionally NOT listed here either. omz adds a
# plugin's top-level dir to fpath and runs compinit *before* it sources the
# plugin file, but zsh-autocomplete keeps its completers in a Completions/
# subdir that only lands on fpath when the plugin file runs. Listed here, that
# dir always misses the compinit scan and every keystroke errors with
# "command not found: _autocomplete__unambiguous". It's sourced by hand below,
# ahead of oh-my-zsh.sh, so the dir is on fpath before compinit.

# zsh-autosuggestions tuning — must be set BEFORE omz sources the plugin.
# Async is already on by default (zsh >= 5.0.8); set explicitly for clarity.
# BUFFER_MAX_SIZE skips suggestion work on long lines (e.g. pasted text).
# NOTE: we don't set ZSH_AUTOSUGGEST_MANUAL_REBIND here — zsh-autocomplete
# manages the autosuggestions/ZLE widget integration itself (on load it sets
# MANUAL_REBIND=1 and ZSH_AUTOSUGGEST_IGNORE_WIDGETS), so setting it is redundant.
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=100

# zsh-autocomplete tuning (loaded via plugins= above). These zstyles debounce it
# so it doesn't recompute completions on every keystroke — that was the lag.
# Tune delay/min-input to taste; higher delay = calmer, lower = snappier menu.
zstyle ':autocomplete:*' delay 0.25   # wait 0.25s after a keypress before computing completions
zstyle ':autocomplete:*' min-input 2  # no menu until 2+ chars typed
zstyle ':autocomplete:*' timeout 1.0  # cap each completion so a slow one can't hang the line
# Don't add `zstyle '*:compinit' arguments -C` here. Only zsh-autocomplete reads
# that style (omz hardcodes its own compinit flags), and -C tells compinit to
# trust the cached dump instead of re-scanning fpath — that scan is what picks
# up Completions/, so -C reintroduces the "command not found" errors above.

# Load zsh-autocomplete before oh-my-zsh.sh, per its install notes: it puts its
# Completions/ dir on fpath, and omz runs compinit as soon as it's sourced.
# Going first also keeps it ahead of zsh-autosuggestions, which it expects — on
# load it sets MANUAL_REBIND and ZSH_AUTOSUGGEST_IGNORE_WIDGETS for it.
for _zsh_ac in \
  "${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh" \
  /opt/homebrew/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh \
  /usr/share/zsh/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh; do
  [[ -f "$_zsh_ac" ]] && source "$_zsh_ac" && break
done
unset _zsh_ac

source $ZSH/oh-my-zsh.sh

## Path
export PATH="$HOME/.cargo/bin":$PATH

# go toolchain. Prefer the copy under ~/.local/go: it installs from the official
# tarball without root, so a new machine needs no sudo to get Go. /usr/local/go
# is the fallback for machines where it went to the system location instead.
# GOPATH stays the default ~/go, whose bin is already on PATH from .zshenv.
for _go_root in "$HOME/.local/go" /usr/local/go; do
  [[ -x "$_go_root/bin/go" ]] && export PATH="$PATH:$_go_root/bin" && break
done
unset _go_root

# set nvim as editor
export EDITOR="nvim"
export VISUAL="nvim"
export SUDO_EDITOR="nvim"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && start_nvm() {
  . "$NVM_DIR/nvm.sh" # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# Removed a second `compinit` here — oh-my-zsh already runs it above, so this
# was doubling ~100ms of startup. The old Docker completions fpath pointed at
# /Users/ebinchanged (a different machine) and no longer exists. To re-enable
# Docker CLI completions, add this BEFORE `source $ZSH/oh-my-zsh.sh`:
#   fpath=($HOME/.docker/completions $fpath)

# pnpm
if [[ "$OSTYPE" == darwin* ]]; then
  export PNPM_HOME="$HOME/Library/pnpm"
else
  export PNPM_HOME="$HOME/.local/share/pnpm"
fi
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# uv shell completion. Suppress stderr: some projects pin `required-version`
# in pyproject.toml/uv.toml, and uv errors out when the shell starts inside
# them. That console output during init breaks p10k's instant prompt.
eval "$(uv generate-shell-completion zsh 2>/dev/null)"

# aliases
alias python='python3'

kcode() {
  if [[ "$OSTYPE" == darwin* ]]; then
    open -na kitty --args \
      --working-directory "$PWD" \
      --session "$HOME/.config/kitty/sessions/code.session"
  else
    kitty --detach \
      --working-directory "$PWD" \
      --session "$HOME/.config/kitty/sessions/code.session"
  fi
}

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
#
# Set up fzf key bindings and fuzzy completion. `fzf --zsh` only exists from
# fzf 0.48; Ubuntu 24.04 ships 0.44, which installs the scripts as files instead.
if fzf --zsh >/dev/null 2>&1; then
  source <(fzf --zsh)
else
  [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]] &&
    source /usr/share/doc/fzf/examples/key-bindings.zsh
  [[ -f /usr/share/doc/fzf/examples/completion.zsh ]] &&
    source /usr/share/doc/fzf/examples/completion.zsh
fi

# zoxide
eval "$(zoxide init zsh)"
# zsh-syntax-highlighting must be sourced last, after every other ZLE plugin.
# Path differs per platform: Homebrew on macOS, omz custom plugin or distro
# package on Linux.
for _zsh_hl in \
  /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  "${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
  /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh; do
  [[ -f "$_zsh_hl" ]] && source "$_zsh_hl" && break
done
unset _zsh_hl

# source secrets
[[ -f ~/.config/zsh/secrets.zsh ]] && source ~/.config/zsh/secrets.zsh

# 1password ssh
if [[ "$OSTYPE" == darwin* ]]; then
  export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
else
  export SSH_AUTH_SOCK="$HOME/.1password/agent.sock"
fi
