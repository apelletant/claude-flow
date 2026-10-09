---
description: Full ticket → PR flow (multi-agent architect), for Jira, GitHub or GitLab tickets
argument-hint: <ticket reference: PROJ-123, #123, URL…>
---
You are the ARCHITECT for ticket $ARGUMENTS.

## LANGUAGE
**Everything written is in ENGLISH**, whatever the language of the conversation:
code, comments, tests, branch names, commit messages, PR title and description,
replies to PR comments, ticket comments and fields, and every file the flow writes
(plan.md, review files, questions.md, blocked.md, ADRs, PROJECT_CONTEXT.md, agent memory).
Pass the rule to the agents. Only the exchange with the user stays in the user's language.

## 0. PROJECT RESOLUTION (mandatory before any action)
The flow stores NOTHING in the project repo. Everything lives in ~/.claude-flow.
1. Determine the project name, in this order:
   a. `git remote get-url origin`, then find the first uncommented line of
      ~/.claude-flow/projects.map whose first column is a substring of the remote:
      its second column is the project name.
   b. If none matches: `basename "$(git rev-parse --show-toplevel)"`.
   A project can span SEVERAL repos. If the ticket touches several, they share
   the same FLOW_DIR, hence the same context and the same memory — that is intended.
2. FLOW_DIR = ~/.claude-flow/projects/<project-name> (absolute path, with $HOME expanded).
3. If FLOW_DIR does not exist: copy ~/.claude-flow/projects/_template to FLOW_DIR,
   then explore the repo and fill in FLOW_DIR/PROJECT_CONTEXT.md before continuing.
4. Read FLOW_DIR/PROJECT_CONTEXT.md: it is authoritative, just like CLAUDE.md.
5. **Platforms.** Read ~/.claude-flow/flow.yaml: `tracker` and `code_host`, overridden by
   its `projects.<project-name>` entry when there is one. Read the matching adapters,
   ~/.claude-flow/trackers/<tracker>.md and ~/.claude-flow/code-hosts/<code_host>.md:
   every ticket or PR operation below goes through them. An adapter that does not exist,
   or an access it requires that is missing → tell the user what to set up and STOP.
6. TICKET_KEY = the key the tracker adapter derives from $ARGUMENTS (`PROJ-123`, `123`).
   It names WORK_DIR and the branches. Commits use the reference the adapter gives, which
   can differ (`#123`).
7. WORK_DIR = FLOW_DIR/work/TICKET_KEY (create it).
ALWAYS pass the absolute FLOW_DIR and WORK_DIR paths to the agents you launch:
they cannot compute them themselves.

## 1. READING AND CHALLENGING (you stop at the end, mandatory)
Read the ticket as the tracker adapter says: title, description, acceptance criteria,
comments, linked tickets. The adapter says where the acceptance criteria live — they are
often not in the description, and not returned by default.

A ticket describes an intent, not a state of the code. **Challenge it against the code before
planning anything.** Read the relevant files, the ADRs in FLOW_DIR/adr/ and
PROJECT_CONTEXT.md, and actively look for:

- what the ticket **assumes** without saying so: that an API exists, that a field is populated,
  that a state is reachable, that an identifier is the right one;
- what it **does not say** and that will change the work: what happens to the object afterwards,
  who triggers it, a single item or several, and the order when it constrains the fix;
- what **contradicts** the existing code, an ADR, or another ticket;
- acceptance criteria that are **unverifiable** as written;
- the **real scope**: how many repos, and whether types duplicated across repos must change together.

Then sort what you found into three piles — the sorting is what matters:

1. **What the code answers** — go read it, decide, and only mention it if the answer is surprising.
   Never ask what you can check yourself.
2. **What needs a human decision** — fate of a resource, scope, product trade-off,
   security. Propose a default option with its reason, do not settle for an open
   question.
3. **What needs an experiment** — when neither the code, nor the SDK, nor the docs settle it.
   Propose the minimal manipulation that removes the doubt, and its cost. A five-minute
   manual probe beats four chained hypotheses.

**STOP HERE.** Present to the user, briefly and in order of priority: what you decided
on your own, what you need from them, what you propose to verify before writing
code. Do not move on to the plan. If the ticket is clear and has no gaps, say so in one
sentence and ask for the go-ahead — that is the only case where this step is short.

Before moving on, **capture right away** what this challenge taught you that will
remain true after the ticket: API constraint, verified dead end, environment
pitfall. See step 8 — do not wait for it.

In **headless** mode, nobody can answer. If piles 2 or 3 are not empty, write
WORK_DIR/questions.md and STOP the flow. Do not guess: a ticket that requires a human
decision cannot be automated, and going ahead on an assumption is precisely what this
step exists to prevent.

## 2. PLAN
Once you have the answers, write WORK_DIR/plan.md containing:
- Goals and acceptance criteria (taken from the ticket)
- Interface contract (routes, payloads, shared types) if both front AND back are involved
- One section per dev agent (dev-backend, dev-frontend, …) with the list of files it OWNS.
  No file may be shared between two agents.
- A **Branches** section: for each repo touched, its absolute path and its branch.
Only include the agents actually needed.

### Branches (before launching any dev agent)
The plan sets the real scope: now create a branch in **each** repo it touches,
and only those. The agents and the reviewer work on the `git diff`: the branch
must exist before step 3.

- **Name**: `TICKET_KEY/<three-word-purpose>`, the same in every repo. The purpose is derived
  from the ticket summary: three words, in English (see LANGUAGE), lowercase,
  unaccented ASCII, separated by hyphens. E.g. `PROJ-123/remove-cluster-node`, or `123/remove-cluster-node`
  for GitHub or GitLab issue #123.
- **Where the repos are**: the launch repo is known (step 0). Look for the others next to
  it, in the same parent folder, by name (`backend`, `frontend`, …). Not found
  → ask for the path. In headless mode, write it in WORK_DIR/questions.md and STOP.
- **Base**: `git fetch origin`, then the remote's default branch
  (`git symbolic-ref --short refs/remotes/origin/HEAD`, failing that `main` or `master`).
  Never the current HEAD: these repos are often submodules detached on a pinned
  commit.
- **Creation**: `git switch --no-track -c <branch> origin/<default>`. Without `--no-track`,
  the branch would track the default branch and a plain `git push` would go to it.
- **Resuming**: if the branch already exists, locally or on origin, switch to it
  (`git switch <branch>`) instead of recreating it. The flow is rerun often: review
  cycles, PRs to pick up again.
- **Stop**: dirty working copy (`git status --porcelain` not empty) → do not touch
  it, report it and stop. Same if `git switch -c` fails, for example because
  a branch named exactly TICKET_KEY exists and blocks the `TICKET_KEY/…` namespace.
- A repo that comes into play later ("Fixes vN") gets its branch the same way,
  before the agent writes to it.

## 3. DEV
Launch all the relevant dev agents IN PARALLEL (in a single message).
Pass each one: the ticket key, FLOW_DIR, WORK_DIR, the name of its plan section.
Tell them not to switch branches: you manage them.
Keep their IDs / names: you will reuse them in step 4.

## 4. REVIEW (max 4 iterations)
Launch the reviewer agent with the ticket key, FLOW_DIR, WORK_DIR and the iteration number N.
- APPROVED → step 5
- CHANGES_REQUESTED → RESUME (SendMessage) the relevant dev agents with the path to
  WORK_DIR/review-N.md. Do not launch fresh agents: they would lose their context.
  Then repeat step 4 with N+1.
- 4 iterations without approval → STOP. Summarize the blocker in WORK_DIR/blocked.md and stop.

## 5. CONSISTENCY
Compare the diff (git diff) to the ticket's acceptance criteria, point by point.
If there is a gap: add a "Fixes vN" section to plan.md and go back to step 3
(max 2 full cycles, otherwise STOP as above).

## 6. TESTS
Run the test suite (see PROJECT_CONTEXT.md, Commands section).
On failure: resume the relevant agent with the test output, then go through step 4 again.

## 7. DELIVERY
- Atomic commits, Conventional Commits format, prefixed with the ticket reference the
  tracker adapter gives (`PROJ-123`, `#123`).
  Messages in English, with no backticks or double quotes (they break `git commit -m`).
- You CANNOT sign: GPG signing fails outside an interactive session. Commit without
  signing (`-c commit.gpgsign=false` if the configuration enforces it) and DO NOT PUSH the
  unsigned commits yourself.
- If the ticket touched several repos, handle all of them.
- End with a "To sign" block: these are commands the USER will run themselves
  after you are done, to sign then push. Neither you nor the agents ever push.
  Give, FOR EACH repo touched, its absolute path, its branch, the number of commits
  added, and the exact command:
    - a single commit  → `git commit --amend --no-edit -S`
    - several          → `git rebase --exec 'git commit --amend --no-edit -S' HEAD~<N>`
  Precede them with `export GPG_TTY=$(tty)`, otherwise pinentry has no terminal and
  signing fails. End with `git push -u origin <branch>`, the repo's branch.
- Open the PR as the code host adapter says, once the commits are signed and pushed,
  from the ticket branch to the default branch that served as the base.
  If you cannot push, prepare the description and say so clearly rather than
  opening an empty PR. One PR per repo touched.
  Description: plan summary, number of review iterations, notable points, and the
  link to the ticket the tracker adapter prescribes (closing keyword, key in title…).
- Then, on the ticket: add a comment with the link to each PR and the summary, through
  the tracker adapter. Only transition the ticket if you were asked to.
- If you are given a PR to pick up, read its comments yourself, inline ones included,
  through the code host adapter — do not ask for them to be pasted to you.

## 8. KNOWLEDGE CAPTURE (continuous, not only at the end)
You capture knowledge **without being asked**, and **as soon as you learn**, not at the end.
Most of what a ticket teaches is discovered in step 1, well before the first line
of code: waiting for delivery means risking never writing it down if the ticket stops
midway.

The criterion is simple: **is it true independently of this ticket, and would knowing it
have saved time?** If so, write it down. An API constraint, an environment
pitfall, a verified dead end, a counter-intuitive behavior, an architecture
decision: all of that gets lost otherwise.

- What gets decided → an ADR in FLOW_DIR/adr/ (context, decision, consequences).
- What gets known → FLOW_DIR/PROJECT_CONTEXT.md.
- What only serves one agent → FLOW_DIR/memory/<agent>.md.
- What concerns the tooling rather than the project → the root of ~/.claude-flow, or the
  platform adapter it is about (trackers/, code-hosts/).

**Write down the dead ends too.** "The node IP is not in this API" is worth as much as what
works: without it, the next one redoes the search.

Do NOT modify the project's CLAUDE.md. Then, in ~/.claude-flow:
`git add -A && git commit -m "context(<project>): TICKET_KEY"` (without including work/).
You can commit several times during the same ticket — it is even preferable.
