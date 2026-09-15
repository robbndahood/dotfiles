# Keep PATH/fpath entries unique. Deduping fpath keeps oh-my-zsh's compdump
# `#omz fpath:` marker stable across starts, so it stops rebuilding the
# completion dump every launch (brew shellenv would otherwise add
# site-functions twice).
typeset -U path fpath PATH FPATH

# Ubuntu's /etc/zsh/zshrc runs its own `compinit` before ~/.zshrc is read, so a
# dump gets built before zsh-autocomplete can put its Completions/ dir on fpath.
# zsh-autocomplete's install notes call for this on Ubuntu specifically; macOS
# ships no global compinit, which is why this only bites on Linux.
skip_global_compinit=1

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/kitty.app/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
