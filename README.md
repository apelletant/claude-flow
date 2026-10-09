# claude-flow: multi-agent ticket → PR flow for Claude Code

`/ticket PROJ-123` (or `/ticket #123`) turns a Jira, GitHub or GitLab ticket into reviewed,
committed code. An architect agent reads the ticket, challenges it against the code and stops to ask what only a human can
decide. It then writes a plan, creates a branch in each repo the ticket touches, and runs
dev agents in parallel. A reviewer loops with them, the architect checks the diff against
the acceptance criteria, and it runs the tests and prepares the commits and the PR.

Nothing is written in your project repos apart from the ticket's code itself. Project
knowledge (context, ADRs, agent memory) lives in this folder, cloned into `~/.claude-flow`,
and grows with every ticket.

## Layout
```
claude/commands/ticket.md     → /ticket <ticket>, the architect (linked into ~/.claude/commands)
claude/agents/*.md            → dev-backend, dev-frontend, reviewer (linked into ~/.claude/agents)
flow.yaml                     → which tracker and code host to use, per project if needed
trackers/<name>.md            → how to read, comment and link tickets (jira, github, gitlab)
code-hosts/<name>.md          → how to open PRs and read their comments (github, gitlab)
projects.map                  → git remote → project name (several repos can share a project)
projects/_template/           → template copied on a new project's first ticket
projects/<project>/           → created automatically
  PROJECT_CONTEXT.md          → project knowledge (equivalent of a CLAUDE.md)
  adr/                        → architecture decisions
  memory/<agent>.md           → persistent memory of each agent for THIS project
  work/<TICKET>/              → plan, reviews, logs (not versioned)
scripts/run-ticket.sh         → headless launch (CI, k8s Job, tracker webhook)
install.sh                    → links into ~/.claude + permission instructions
```

## Requirements
- [Claude Code](https://claude.com/claude-code).
- Access to your tracker and code host, as their adapter describes: `gh`, `glab`, the Jira
  REST API with a token, or an MCP server.

## Installation
```
git clone <this repo> ~/.claude-flow
cd ~/.claude-flow && ./install.sh
```
Then add `~/.claude-flow` to `permissions.additionalDirectories` (see the install.sh output),
and set your platforms in `flow.yaml`.

## Platforms
Two roles, chosen independently in `flow.yaml`:

| Role | Where | Supported |
|---|---|---|
| `tracker` | where the ticket comes from | `jira`, `github`, `gitlab` |
| `code_host` | where the PR / MR is opened | `github`, `gitlab` |

Jira tickets with GitHub PRs, or GitHub for both, are just two lines. A project can
override the default under `projects:`.

The ticket key names the work folder, the branches and the commit prefix: `PROJ-123` for
Jira, the issue number for GitHub and GitLab (`#` is not valid in a branch name), so
issue #123 gives branch `123/<three-word-purpose>` and commits prefixed with `#123`.

**Adding a platform** (Linear, Bitbucket, Azure DevOps, …): copy `trackers/_template.md` or
`code-hosts/_template.md`, answer each section with concrete commands, and name it in
`flow.yaml`. The skill itself does not change.

## Usage
- Interactive: in the project repo, `claude` then `/ticket PROJ-123`, `/ticket #123` or a URL.
- Headless: `~/.claude-flow/scripts/run-ticket.sh PROJ-123` from the project repo. Set
  `EXTRA_TOOLS` to allow your tracker / code-host MCP tools. In a shell, pass a GitHub or
  GitLab issue as `123` or `'#123'`: an unquoted `#123` is a comment. In headless mode the flow stops
  and writes `questions.md` as soon as a ticket needs a human decision.

## Conventions baked in
- Everything written (code, commits, PRs, ticket comments, ADRs, memory) is in English. The
  conversation with you stays in your language.
- Branches are named `<ticket key>/<three-word-purpose>`, created from the remote's default
  branch.
- Agents commit without signing and never push. The flow ends with a "To sign" block of
  commands for you to sign and push.

## Caveats
- **Keep your knowledge private.** The flow commits each project's context, ADRs and agent
  memory into `projects/<project>/` of your clone. Do not push a clone with real projects
  to a public remote.
- An agent with the same name in a repo's `.claude/agents/` takes precedence over these.
- In CI / k8s Job: clone this repo in the runner and run `install.sh --copy` before the
  ticket. To keep what was learned across runs, push the step 8 commits to a (private) remote.
