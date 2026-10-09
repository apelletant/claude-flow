# Tracker adapter: GitLab Issues

## Access
The `glab` CLI, authenticated (`glab auth status`), or a GitLab MCP server. For a
self-managed instance, `glab` must be logged in to that host. If a flag below is rejected,
check `glab <command> --help`: the CLI evolves.

## Ticket reference and TICKET_KEY
The user passes `123`, `#123`, `group/project#123` or an issue URL. Without an explicit
project, the issue belongs to the launch repo's `origin`. TICKET_KEY = the number alone
(`123`): `#` is not valid in a branch name. Commit subjects are prefixed with `#123`
instead, which GitLab turns into a link.

## Read a ticket
`glab issue view <n> [--repo group/project] --comments`. Acceptance criteria usually live
in the description: a task list (`- [ ]`) or an "Acceptance criteria" section. If there is
neither, say so at step 1 — it is a gap.

## Comment on a ticket
`glab issue note <n> --message "<text>"`.

## Transition a ticket
`glab issue close <n>`. Workflow states are usually scoped labels (`status::doing`):
`glab issue update <n> --label ... --unlabel ...`. Ask which labels the project uses
before touching them.

## Link a PR to the ticket
`Closes #123` in the merge request description: GitLab links the MR and closes the issue
on merge into the default branch.
