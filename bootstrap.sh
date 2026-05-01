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

repo_has_local_changes() {
  local dir="$1"

  git -C "$dir" update-index -q --refresh

  ! git -C "$dir" diff --quiet --ignore-submodules -- ||
    ! git -C "$dir" diff --cached --quiet --ignore-submodules --
}

# handle repo idempotently
clone_or_update_repo() {
  local repo="$1"
  local dir="$2"

  if [ -d "$dir/.git" ]; then
    log "Checking $dir"

    if repo_has_local_changes "$dir"; then
      cat <<EOF >&2

Local changes detected in:

  $dir

Refusing to pull because bootstrap should not overwrite your work.

Review changes with:

  git -C "$dir" status
  git -C "$dir" diff

Then either commit, stash, or discard them.

EOF
      return 1
    fi

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

install_neovim_nightly() {
  local arch
  local archive_name
  local url
  local install_dir="$HOME/.local/opt/nvim-nightly"
  local bin_dir="$HOME/.local/bin"
  local tmp_dir

  case "$(uname -m)" in
  arm64)
    arch="arm64"
    ;;
  x86_64)
    arch="x86_64"
    ;;
  *)
    echo "Unsupported architecture: $(uname -m)" >&2
    return 1
    ;;
  esac

  archive_name="nvim-macos-${arch}.tar.gz"
  url="https://github.com/neovim/neovim/releases/download/nightly/${archive_name}"

  tmp_dir="$(mktemp -d)"

  log "Installing Neovim nightly for macOS ${arch}"

  curl -fL "$url" -o "$tmp_dir/$archive_name"

  # Clear macOS quarantine / extended attributes when present.
  xattr -c "$tmp_dir/$archive_name" 2>/dev/null || true

  tar -xzf "$tmp_dir/$archive_name" -C "$tmp_dir"

  rm -rf "$install_dir"
  mkdir -p "$(dirname "$install_dir")"
  mv "$tmp_dir/nvim-macos-${arch}" "$install_dir"

  mkdir -p "$bin_dir"
  ln -sfn "$install_dir/bin/nvim" "$bin_dir/nvim"

  rm -rf "$tmp_dir"

  log "Neovim nightly installed: $("$bin_dir/nvim" --version | head -n 1)"
}

verify_neovim() {
  log "Checking Neovim"

  if ! has nvim; then
    echo "nvim was not found on PATH" >&2
    return 1
  fi

  command -v nvim
  nvim --version | head -n 1
}

homebrew_has_package() {
  local package="$1"

  brew list --formula "$package" >/dev/null 2>&1
}

homebrew_has_cask() {
  local cask="$1"

  brew list --cask "$cask" >/dev/null 2>&1
}

check_neovim_conflict() {
  log "Checking Neovim conflicts"

  if homebrew_has_package neovim; then
    cat <<EOF

Homebrew neovim is installed.

This script will still install Neovim nightly at:

  $HOME/.local/opt/nvim-nightly

and expose it through:

  $HOME/.local/bin/nvim

As long as ~/.local/bin appears before Homebrew in PATH, nightly will be used.

To remove Homebrew neovim, run:

  brew uninstall neovim

EOF
  fi
}

# make sure that ~/.local/bin is in the path
ensure_local_bin_on_path() {
  local zprofile="$DOTFILES_DIR/zsh/.zprofile"
  local line='export PATH="$HOME/.local/bin:$PATH"'

  mkdir -p "$(dirname "$zprofile")"
  touch "$zprofile"

  if grep -qxF "$line" "$zprofile"; then
    log "~/.local/bin already configured in .zprofile"
    return
  fi

  log "Adding ~/.local/bin to PATH in .zprofile"
  printf '\n%s\n' "$line" >>"$zprofile"
}

install_kitty_official() {
  local install_dir="$HOME/.local/kitty.app"
  local app_link="/Applications/kitty.app"

  log "Installing Kitty using official installer"

  curl -fsSL https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

  if [ ! -d "$install_dir" ]; then
    echo "Expected Kitty install not found at $install_dir" >&2
    return 1
  fi

  if [ -e "$app_link" ] || [ -L "$app_link" ]; then
    if [ -L "$app_link" ]; then
      log "Replacing existing Kitty app symlink"
      sudo rm "$app_link"
    else
      cat <<EOF

Kitty already exists at:

  $app_link

Leaving it in place.

If this was installed by Homebrew, remove it with:

  brew uninstall --cask kitty

Then rerun this script.

EOF
      return 0
    fi
  fi

  log "Linking Kitty into /Applications"
  sudo ln -s "$install_dir" "$app_link"
}

ensure_line_in_file() {
  local line="$1"
  local file="$2"

  mkdir -p "$(dirname "$file")"
  touch "$file"

  if grep -qxF "$line" "$file"; then
    return
  fi

  printf '\n%s\n' "$line" >>"$file"
}

ensure_shell_paths() {
  local zprofile="$DOTFILES_DIR/zsh/.zprofile"

  log "Ensuring shell PATH entries"

  ensure_line_in_file 'export PATH="$HOME/.local/bin:$PATH"' "$zprofile"
  ensure_line_in_file 'export PATH="$HOME/.local/kitty.app/bin:$PATH"' "$zprofile"
}

verify_kitty() {
  log "Checking Kitty"

  if [ ! -d "$HOME/.local/kitty.app" ]; then
    echo "Kitty was not found at $HOME/.local/kitty.app" >&2
    return 1
  fi

  if [ -x "$HOME/.local/kitty.app/bin/kitty" ]; then
    "$HOME/.local/kitty.app/bin/kitty" --version
  fi

  if [ -L "/Applications/kitty.app" ]; then
    echo "/Applications/kitty.app -> $(readlink /Applications/kitty.app)"
  fi
}

main() {
  install_homebrew

  if ! has git; then
    brew install git
  fi

  clone_or_update_repo "$DOTFILES_REPO" "$DOTFILES_DIR"

  install_packages

  check_neovim_conflict
  install_neovim_nightly
  ensure_local_bin_on_path

  check_kitty_conflict
  install_kitty_official

  ensure_shell_paths

  install_oh_my_zsh
  install_powerlevel10k
  link_configs
  set_default_shell
  verify_neovim

  log "Done. Restart your terminal."
}

main "$@"
