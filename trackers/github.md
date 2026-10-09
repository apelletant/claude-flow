# Tracker adapter: GitHub Issues

## Access
The `gh` CLI, authenticated (`gh auth status`), or a GitHub MCP server. If a flag below is
rejected, check `gh <command> --help`: the CLI evolves.

## Ticket reference and TICKET_KEY
The user passes `123`, `#123`, `owner/repo#123` or an issue URL. Without an explicit repo,
the issue belongs to the launch repo's `origin`. TICKET_KEY = the number alone (`123`):
`#` is not valid in a branch name. Commit subjects are prefixed with `#123` instead, which
GitHub turns into a link.

## Read a ticket
`gh issue view <n> [--repo owner/repo] --json title,body,labels,state,comments,assignees`.
Acceptance criteria usually live in the body: a task list (`- [ ]`) or an
"Acceptance criteria" section. If there is neither, say so at step 1 — it is a gap.

## Comment on a ticket
`gh issue comment <n> --body-file <file>` (a file avoids quoting problems).

## Transition a ticket
GitHub issues are only open or closed: `gh issue close <n>`. A "status" is usually a label
(`gh issue edit <n> --add-label ... --remove-label ...`) or a GitHub Projects field; ask
which one the project uses before touching it.

## Link a PR to the ticket
`Closes #123` (or `Closes owner/repo#123` across repos) in the PR description: GitHub
links the PR and closes the issue on merge.
