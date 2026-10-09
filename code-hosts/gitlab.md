# Code host adapter: GitLab

## Access
The `glab` CLI, authenticated (`glab auth status`), or a GitLab MCP server. If a flag below
is rejected, check `glab <command> --help`.

## Open a PR
GitLab calls it a merge request. From the repo's directory, once the branch is pushed:
`glab mr create --source-branch <branch> --target-branch <default> --title "<title>" --description "<text>"`.
Prints the MR URL.

## Read the comments of a PR
- `glab mr view <n> --comments` for the discussion.
- Inline comments, with file and line, are discussions on the MR:
  `glab api projects/:id/merge_requests/<n>/discussions` (`glab api` fills `:id` from the
  current repo).

## Vocabulary
Merge request, referenced as `!<n>`.
