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
  zsh-autocomplete
  )
# NOTE: zsh-syntax-highlighting is intentionally NOT listed here. It must be
# sourced last, after every other ZLE plugin — see the bottom of this file.
# zsh-autocomplete provides the live as-you-type completion menu; it's tuned
# (debounced) below so it doesn't recompute on every keystroke (the lag cause).

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
zstyle '*:compinit' arguments -C      # reuse our cached compdump instead of re-scanning fpath
source $ZSH/oh-my-zsh.sh

## Path
export PATH="$HOME/.cargo/bin":$PATH

# go binary
export PATH="$PATH:/usr/local/go/bin"

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
export PNPM_HOME="$HOME/Library/pnpm"
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
  open -na kitty --args \
    --working-directory "$PWD" \
    --session "$HOME/.config/kitty/sessions/code.session"
}

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
#
# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# zoxide
eval "$(zoxide init zsh)"
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# source secrets
[[ -f ~/.config/zsh/secrets.zsh ]] && source ~/.config/zsh/secrets.zsh

# 1password ssh
export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
