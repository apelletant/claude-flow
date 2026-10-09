#!/usr/bin/env bash
# Installs the flow: links the commands and agents into ~/.claude and allows ~/.claude-flow.
# Usage: ./install.sh          (symlinks: a git pull is enough to update)
#        ./install.sh --copy   (copy, if the links cause problems)
set -euo pipefail
FLOW="$(cd "$(dirname "$0")" && pwd)"
MODE="${1:-}"
mkdir -p ~/.claude/commands ~/.claude/agents

link() {
  if [ "$MODE" = "--copy" ]; then cp "$1" "$2"; else ln -sf "$1" "$2"; fi
  echo "  $2"
}
echo "Installing from $FLOW:"
for f in "$FLOW"/claude/commands/*.md; do link "$f" ~/.claude/commands/"$(basename "$f")"; done
for f in "$FLOW"/claude/agents/*.md;   do link "$f" ~/.claude/agents/"$(basename "$f")";   done

cat <<MSG

Last manual step: allow access to $FLOW in ~/.claude/settings.json
  {
    "permissions": {
      "additionalDirectories": ["$FLOW"]
    }
  }
(merge with your existing file). Then restart Claude Code.
MSG
