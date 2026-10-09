#!/usr/bin/env bash
# Runs the flow headless for a ticket, from the root of the project repo.
# Usage: cd ~/dev/my-project && ~/.claude-flow/scripts/run-ticket.sh <ticket reference>
#        (PROJ-123, '#123', owner/repo#123 or a URL, depending on the tracker in flow.yaml)
set -euo pipefail
TICKET="${1:?Usage: $0 <ticket reference>}"
LOG_NAME="$(printf '%s' "$TICKET" | tr -c 'A-Za-z0-9._-' '_')"
FLOW="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT="$(basename "$(git rev-parse --show-toplevel)")"
mkdir -p "$FLOW/projects/$PROJECT/work"

# The tracker and the code host (see flow.yaml) are reached through gh, glab, curl or
# MCP servers. Their credentials must be in the runner's environment. MCP tools must be
# allowed explicitly: add them to EXTRA_TOOLS, e.g. EXTRA_TOOLS="mcp__jira__*".
EXTRA_TOOLS="${EXTRA_TOOLS:-}"
claude -p "/ticket ${TICKET}" \
  --add-dir "$FLOW" \
  --permission-mode acceptEdits \
  --allowedTools "Bash(git *) Bash(go *) Bash(make *) Bash(npm *) Bash(gh *) Bash(glab *) Bash(curl *) Bash(basename *) Bash(cp *) Bash(mkdir *) Read Edit Write Grep Glob Agent SendMessage ${EXTRA_TOOLS}" \
  --output-format stream-json --verbose \
  | tee "$FLOW/projects/$PROJECT/work/run-${LOG_NAME}.log"
