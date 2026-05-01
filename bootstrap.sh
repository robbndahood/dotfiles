#!/usr/bin/env bash
set -euo pipefail

DOTFILES_REPO="${DOTFILES_REPO:-git@github.com:robbndahood/dotfiles.git}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/code/github.com/robbndahood/dotfiles}"

log() {
  printf '\n==> %s\n' "$*"
}

has() {
  command -v "$1" >/dev/null 2>&1
}

# backup existing config files before replacing them with symlinks
backup_path() {
  local path="$1"

  if [ -e "$path" ] || [ -L "$path" ]; then
    if [ ! -L "$path" ]; then
      local backup="${path}.backup.$(date +%Y%m%d%H%M%S)"
      log "Backing up $path to $backup"
      mv "$path" "$backup"
    else
      rm "$path"
    fi
  fi
}

link_file() {
  local source="$1"
  local target="$2"

  mkdir -p "$(dirname "$target")"
  backup_path "$target"
  ln -s "$source" "$target"
}

link_optional_file() {
  local source="$1"
  local target="$2"

  if [ ! -e "$source" ] && [ ! -L "$source" ]; then
    log "Skipping missing optional config: $source"
    return
  fi

  link_file "$source" "$target"
}

# handle repo idempotently
clone_or_update_repo() {
  local repo="$1"
  local dir="$2"

  if [ -d "$dir/.git" ]; then
    log "Updating $dir"
    git -C "$dir" pull --ff-only
  else
    log "Cloning $repo to $dir"
    mkdir -p "$(dirname "$dir")"
    git clone "$repo" "$dir"
  fi
}

install_homebrew() {
  if has brew; then
    log "Homebrew already installed"
    return
  fi

  log "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

install_packages() {
  log "Installing packages"

  brew bundle --file="$DOTFILES_DIR/Brewfile"
}

install_oh_my_zsh() {
  if [ -d "$HOME/.oh-my-zsh" ]; then
    log "Oh My Zsh already installed"
    return
  fi

  log "Installing Oh My Zsh"
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
}

install_powerlevel10k() {
  local target="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

  if [ -d "$target/.git" ]; then
    log "Updating Powerlevel10k"
    git -C "$target" pull --ff-only
  else
    log "Installing Powerlevel10k"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$target"
  fi
}

set_default_shell() {
  local zsh_path

  zsh_path="$(command -v zsh)"

  if [ "$SHELL" = "$zsh_path" ]; then
    log "Default shell already set to zsh"
    return
  fi

  log "Setting default shell to $zsh_path"

  if ! grep -qx "$zsh_path" /etc/shells; then
    echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
  fi

  chsh -s "$zsh_path"
}

link_configs() {
  log "Linking configs"

  link_file "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
  link_file "$DOTFILES_DIR/zsh/.zshenv" "$HOME/.zshenv"
  link_file "$DOTFILES_DIR/zsh/.zprofile" "$HOME/.zprofile"

  link_optional_file "$DOTFILES_DIR/zsh/.p10k.zsh" "$HOME/.p10k.zsh"

  link_file "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
  link_file "$DOTFILES_DIR/kitty" "$HOME/.config/kitty"
}

main() {
  install_homebrew

  if ! has git; then
    brew install git
  fi

  clone_or_update_repo "$DOTFILES_REPO" "$DOTFILES_DIR"

  install_packages
  install_oh_my_zsh
  install_powerlevel10k
  link_configs
  set_default_shell

  log "Done. Restart your terminal."
}

main "$@"
