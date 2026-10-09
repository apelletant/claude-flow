# Tracker adapter: Jira

## Access
Either a Jira MCP server configured in Claude Code, or the REST API:
`curl -s -H "Authorization: Bearer $<token_env>" "<url>/rest/api/2/..."`, with `url` and
`token_env` from the `jira:` section of flow.yaml (Jira Cloud may need basic auth with
`email:token` instead). Never print or write the token. A 401 means the token expired:
ask for a new one rather than working around it.

## Ticket reference and TICKET_KEY
The user passes a key (`PROJ-123`) or a browse URL. TICKET_KEY = the key, uppercase.

## Read a ticket
`GET /rest/api/2/issue/<KEY>?fields=*all&expand=renderedFields`, or the MCP equivalent.
Acceptance criteria are not always in the description: look in
`acceptance_criteria_field` from flow.yaml when set, otherwise scan the custom fields.
Checklist plugins store their items in a custom field that some MCP servers do not return
by default — request it explicitly. Read the comments and the issue links too.

## Comment on a ticket
`POST /rest/api/2/issue/<KEY>/comment` with `{"body": "..."}`, or the MCP equivalent.

## Transition a ticket
`GET /rest/api/2/issue/<KEY>/transitions` to list the allowed ones, then
`POST` the same path with `{"transition": {"id": "<id>"}}`.

## Link a PR to the ticket
Put the key in the branch name, the commit subjects and the PR title: Jira's development
panel picks it up when the code host is connected to Jira.
