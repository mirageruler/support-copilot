# AGENTS.md

Instructions for the coding assistant working in this repo (Cursor reads this file).

Support Copilot: an AI copilot that helps a human support staff member handle food-delivery
complaints. It gathers context, checks the refund policy and proposes compensation; money moves
only after a human approves, and only once. Personal learning project; all data is synthetic.

In this repo, "AI agent" means the LangGraph program under `agent/` (from M3). You are the
coding assistant, not that agent.

## How to work in this repo

- **Go (`server/`) is written by the repo owner.** Explain, review, and point out bugs and
  risks. Do not write or rewrite the implementation. A short example to explain a concept is
  fine when asked.
- **Python (`agent/`, `evals/`, from M3):** you may write small pieces. Describe the approach in
  3–5 lines first and wait for a yes, then explain every part.
- **Data (`data/`)** comes from the design discussion and is reviewed by the owner. Do not
  change policy rules here; flag mismatches instead.
- Stay inside the current milestone. Anything else goes to `docs/backlog.md`.
- Every design decision goes to `docs/decisions.md`: options, choice, reason, trade-off.
- AI libraries change fast (MCP SDKs, LangGraph, pgvector clients, model APIs): check the
  current docs before using an API and say which version you checked.
- Never invent numbers such as cost, latency or pass rate. Use real runs only.
- Reply in Vietnamese. Code, comments, commit messages and docs are in English.

## Rules

- Synthetic data only. No code, documents, policies or internal names from any employer,
  client or other company, even if pasted by mistake. No real brands.
- No secrets in code or commits. `.env` is gitignored; `.env.example` holds variable names and
  local-only defaults, never a real key.
- The LLM in the AI agent is never given `execute_refund` or the approval signing key.

## Commands

- `make up` / `make down` / `make reset`: start, stop, or wipe the local stack (Postgres with
  pgvector, Jaeger)
- `make migrate`: apply migrations to the dev database
- `make test`: recreate `copilot_test`, migrate it, run `go test -p 1 ./...`
- `make lint`: gofmt check and `go vet`

## Layout

- `server/`: Go module for the MCP server; `server/migrations/`: goose SQL files, embedded
- `data/policies/`: policy documents, one H2 section per chunk; `data/fixtures/`: seed data
- `docs/decisions.md`, `docs/backlog.md`

## Milestones

M0 repo, local stack, CI · M1 Go MCP server with four tools and synthetic data · M2 policy RAG ·
M3 LangGraph workflow with an approval pause · M4 evals and tracing · M5 README and write-up.

Current milestone: M0.
