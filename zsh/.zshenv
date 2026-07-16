# Keep PATH/fpath entries unique. Deduping fpath keeps oh-my-zsh's compdump
# `#omz fpath:` marker stable across starts, so it stops rebuilding the
# completion dump every launch (brew shellenv would otherwise add
# site-functions twice).
typeset -U path fpath PATH FPATH

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/kitty.app/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
. "$HOME/.cargo/env"
