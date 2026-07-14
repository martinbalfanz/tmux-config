#!/usr/bin/env bash
# tmux-agent-sidebar only applies @sidebar_width once, at pane-creation time.
# This re-asserts it on every client-resized event so the sidebar stays a
# consistent width across windows/sessions even when the terminal itself
# gets resized (different monitor, different Space, fullscreen toggle, etc).
set -euo pipefail

width="$(tmux show -gqv @sidebar_width 2>/dev/null || true)"
[ -z "$width" ] && width=30

# A fixed pin only makes sense with an absolute column count. If the user
# has @sidebar_width set to a percentage, there's nothing consistent to pin
# to, so skip rather than resize to a stale/misleading number.
case "$width" in
  *%) exit 0 ;;
esac

tmux list-panes -a -F '#{pane_id} #{@pane_role}' 2>/dev/null | awk '$2=="sidebar"{print $1}' | while read -r pid; do
  tmux resize-pane -t "$pid" -x "$width" 2>/dev/null || true
done
