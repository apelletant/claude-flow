# Tracker adapter: <name>

Read by the architect when `tracker: <name>` in flow.yaml. Each section answers one
question the flow asks. Keep it short and concrete: commands, not prose.

## Access
What the session must have (MCP server, CLI, REST + token from flow.yaml), and how to tell
the user what is missing when it is not there.

## Ticket reference and TICKET_KEY
What the user may pass to /ticket, and how to turn it into TICKET_KEY: the string used for
WORK_DIR, the branch prefix and the commit prefix. It must be valid in a git branch name.

## Read a ticket
How to get the title, the description, the acceptance criteria, the comments and the links
to other tickets.

## Comment on a ticket
## Transition a ticket
Only used when the user asked for it.

## Link a PR to the ticket
What to put in the commit or PR so the platform links them (closing keyword, key in title…).
