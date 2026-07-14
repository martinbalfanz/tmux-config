#!/usr/bin/env bash
# One-line installer for martinbalfanz/tmux-config.
#
#   curl -fsSL https://raw.githubusercontent.com/martinbalfanz/tmux-config/main/install.sh | bash
#
# Idempotent: safe to re-run. Existing ~/.tmux.conf or ~/.tmux/scripts that
# aren't already our symlinks get backed up (never deleted) before linking.
set -euo pipefail

REPO_URL="https://github.com/martinbalfanz/tmux-config.git"
CONFIG_DIR="${TMUX_CONFIG_DIR:-$HOME/code/tmux-config}"
MIN_TMUX_VERSION="3.0"
TPM_DIR="$HOME/.tmux/plugins/tpm"

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31mERROR:\033[0m %s\n' "$*" >&2; exit 1; }

version_ge() { [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" = "$2" ]; }

detect_os() {
  case "$(uname -s)" in
    Darwin) OS=macos ;;
    Linux)  [ -f /etc/debian_version ] && OS=debian || OS=linux ;;
    *) die "Unsupported OS: $(uname -s)" ;;
  esac
}

pkg_install() {
  # $@ = package names
  case "$OS" in
    macos)
      command -v brew >/dev/null 2>&1 || die "Homebrew not found. Install it from https://brew.sh and re-run."
      brew install "$@"
      ;;
    debian)
      local sudo=""
      [ "$(id -u)" -ne 0 ] && sudo="sudo"
      $sudo apt-get update -y
      $sudo apt-get install -y "$@"
      ;;
    *)
      die "Don't know how to install packages on this OS. Install manually: $*"
      ;;
  esac
}

ensure_tmux() {
  if command -v tmux >/dev/null 2>&1; then
    local current
    current="$(tmux -V | grep -oE '[0-9]+\.[0-9]+' | head -1)"
    if version_ge "$current" "$MIN_TMUX_VERSION"; then
      log "tmux $current found (>= $MIN_TMUX_VERSION required)"
      return
    fi
    warn "tmux $current found, but $MIN_TMUX_VERSION+ required — upgrading"
  else
    log "tmux not found — installing"
  fi
  pkg_install tmux
  command -v tmux >/dev/null 2>&1 || die "tmux install failed"
}

ensure_deps() {
  for cmd in git curl; do
    command -v "$cmd" >/dev/null 2>&1 || pkg_install "$cmd"
  done
}

clone_or_update_config() {
  if [ -d "$CONFIG_DIR/.git" ]; then
    log "Updating existing config repo at $CONFIG_DIR"
    git -C "$CONFIG_DIR" pull --ff-only
  else
    log "Cloning config repo into $CONFIG_DIR"
    mkdir -p "$(dirname "$CONFIG_DIR")"
    git clone "$REPO_URL" "$CONFIG_DIR"
  fi
}

# link_into TARGET LINK_PATH
# Symlinks LINK_PATH -> TARGET. Backs up whatever's already at LINK_PATH
# unless it's already the correct symlink.
link_into() {
  local target="$1" link_path="$2"
  if [ -L "$link_path" ] && [ "$(readlink "$link_path")" = "$target" ]; then
    log "$link_path already linked"
    return
  fi
  if [ -e "$link_path" ] || [ -L "$link_path" ]; then
    local backup="${link_path}.bak.$(date +%Y%m%d%H%M%S)"
    warn "Backing up existing $link_path -> $backup"
    mv "$link_path" "$backup"
  fi
  mkdir -p "$(dirname "$link_path")"
  ln -s "$target" "$link_path"
  log "Linked $link_path -> $target"
}

ensure_tpm() {
  if [ -d "$TPM_DIR" ]; then
    log "TPM already installed, updating"
    git -C "$TPM_DIR" pull --ff-only || warn "Couldn't update TPM, continuing with existing checkout"
  else
    log "Installing TPM"
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
  fi
}

install_tpm_plugins() {
  log "Installing tmux plugins (same as prefix + I)"
  "$TPM_DIR/bin/install_plugins"
}

main() {
  detect_os
  ensure_deps
  ensure_tmux
  clone_or_update_config
  link_into "$CONFIG_DIR/tmux.conf" "$HOME/.tmux.conf"
  link_into "$CONFIG_DIR/scripts" "$HOME/.tmux/scripts"
  ensure_tpm
  install_tpm_plugins

  log "Done. Start tmux, or if a server is already running: tmux source ~/.tmux.conf"
}

main "$@"
