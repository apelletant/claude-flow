# Code host adapter: GitHub

## Access
The `gh` CLI, authenticated (`gh auth status`), or a GitHub MCP server. If a flag below is
rejected, check `gh <command> --help`.

## Open a PR
From the repo's directory, once the branch is pushed:
`gh pr create --base <default> --head <branch> --title "<title>" --body-file <file>`.
Prints the PR URL.

## Read the comments of a PR
- General comments and reviews: `gh pr view <n> --comments`.
- Inline review comments, with path and line:
  `gh api repos/{owner}/{repo}/pulls/<n>/comments` (`gh api` fills `{owner}/{repo}` from
  the current repo).

## Vocabulary
Pull request, referenced as `#<n>`.
