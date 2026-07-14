# tmux-config

My personal tmux configuration, plus a helper script for keeping an
agent-sidebar pane pinned to a fixed width across resizes.

Prefix key is `C-a` (not the default `C-b`). See the quick reference at the
top of `tmux.conf` for the full keybinding list.

Plugins are managed with [TPM](https://github.com/tmux-plugins/tpm):
tmux-sensible, tmux-resurrect/continuum (session save/restore), tmux-thumbs
(jump-to-copy), tmux-fzf, tmux-battery, tmux-cpu, tmux-prefix-highlight, and
tmux-agent-sidebar.

## Setup on a new machine

One-liner (macOS, Ubuntu/Debian, Arch, or Fedora):

```
curl -fsSL https://raw.githubusercontent.com/martinbalfanz/tmux-config/main/install.sh | bash
```

This installs/upgrades tmux if needed (via Homebrew, `apt`, `pacman`, or
`dnf`, detected automatically), clones this repo to `~/code/tmux-config`, symlinks `tmux.conf` and
`scripts/` into place, installs TPM, and fetches all plugins (equivalent to
pressing `C-a I` inside tmux). It's idempotent — safe to re-run any time,
e.g. to pick up new plugins after a config update. Any pre-existing
`~/.tmux.conf` or `~/.tmux/scripts` that aren't already our symlinks get
backed up (timestamped, never deleted) before linking.

### Manual setup

1. Install tmux and [TPM](https://github.com/tmux-plugins/tpm):
   ```
   git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
   ```
2. Clone this repo:
   ```
   git clone https://github.com/martinbalfanz/tmux-config.git ~/code/tmux-config
   ```
3. Symlink the config and script into place:
   ```
   ln -s ~/code/tmux-config/tmux.conf ~/.tmux.conf
   mkdir -p ~/.tmux
   ln -s ~/code/tmux-config/scripts ~/.tmux/scripts
   ```
4. Start tmux, then press `C-a I` (capital I) to have TPM fetch the plugins
   listed in `tmux.conf`.

After this, editing `~/.tmux.conf` edits this repo directly (it's a
symlink), so changes can be committed and pushed from `~/code/tmux-config`.
