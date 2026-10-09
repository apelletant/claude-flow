# Project context (read by the architect and all agents)

> Filled in automatically by the architect on the first ticket, then enriched at each
> knowledge-capture step. The examples below are to be replaced.

## Architecture
- Go backend: cmd/api (HTTP), internal/service (business logic), internal/store (PostgreSQL)
- Front: web/ (framework to be specified)

## Conventions
- Errors: wrap with fmt.Errorf("...: %w", err), never panic outside main
- Commits: Conventional Commits prefixed with the ticket reference

## Commands
- Tests: make test
- Lint: make lint

## Known pitfalls

## Architecture decisions
- See adr/ (one decision per file)
