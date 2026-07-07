# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# oh my zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(
  git
  # zoxide
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-autocomplete
  )
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
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/ebinchanged/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions

# pnpm
export PNPM_HOME="/Users/ebinchanged/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# uv
eval "$(uv generate-shell-completion zsh)"
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
