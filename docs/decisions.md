# Design decisions

Each entry records what was chosen and what it costs. Entries are never deleted: a replaced
decision stays with a pointer to the one that replaced it.

Money is `bigint` minor units (cents) with the suffix `_minor`, single currency USD.
Timestamps are `timestamptz` in UTC.

## M0–M1 (MCP server, data model, local stack)

| # | Decision | Choice | Trade-off |
|---|---|---|---|
| D1 | Go MCP library | Official `modelcontextprotocol/go-sdk` v1.8.0 | The SDK has no OpenTelemetry support, so the server needs its own tracing middleware (about 30 lines) |
| D2 | Transport | Streamable HTTP with `Stateless = true` on 127.0.0.1:8080/mcp; handler wrapped in `http.NewCrossOriginProtection()` | An extra process to run; no auth in v1. The stateless handler also serves clients on protocol 2025-11-25 |
| D3 | Trace UI | Jaeger v2, OTLP over HTTP on port 4318 | Poor for reading prompts; can be swapped at M4 by changing the OTLP endpoint |
| D4 | Money in `propose_refund` | The LLM picks refund components; the server computes every amount | The tool signature differs from a plain "amount" field |
| D5 | Approval | JWT HS256 with required claims `sub` (proposal ID), `amt` (cash total), `vch` (voucher total), `approver`, `iat`, `exp`; expiry checked against real time | One shared key; no per-token revocation (revocation is per proposal, M3) |
| D6 | Idempotency | `proposal_id` is the idempotency key: `UNIQUE(refunds.proposal_id)`. Executing an executed proposal returns its refund with `replayed: true`. No client-generated key | Cannot tell "my retry" from "someone else executed it"; nothing acts on that difference. Client keys fit calls with no natural key, such as an external payment provider |
| D7 | Clocks | A business clock (frozen or real) for "now"-relative fields of `get_order`; stored timestamps use real time (the seed passes historical times); token expiry always uses real time | Three time inputs to inject correctly |
| D8 | Tool schemas | Input schemas hand-written as JSON and embedded (`jsonschema` struct tags can only hold descriptions); output schemas inferred from structs and checked with golden files | Two sources of truth, guarded by a contract test |
| D9 | `search_policy` in M1 | Postgres full-text search; hybrid with pgvector in M2 | Weaker retrieval in M1 |
| D10 | Testing | Real Postgres. `make test` recreates one `copilot_test` database, migrates it once and runs `go test -p 1 ./...`; each test creates its own fixtures and asserts only on its own rows; no TRUNCATE, no template databases | Packages run one after another |
| D11 | Database layout | One database `copilot`, one DB user; LangGraph checkpoint storage decided in M3 | No least-privilege split; it would add no protection while the AI agent process holds the signing key |
| D12 | Repeat-claim counting | Distinct **other** orders of the customer with executed compensation (cash or voucher) in the last 30 days; the order under complaint is excluded | A customer reporting a second issue on the same order is not counted as a repeat claimer |
| D13 | Pending visibility | `get_order` returns `pending_proposals` | One more query |
| D14 | — | Replaced by D19 (was: one executed `subtotal_percent` line per order) | — |
| D15 | — | Removed (was: an idempotency key kept in graph state); see D6 | — |
| D16 | Customer scoping | `get_order` and `propose_refund` take `customer_id` set by code, never by the LLM; another customer's order returns `ORDER_NOT_FOUND` | One input field the LLM never sees |
| D17 | Item lines | Each `order_item_id` at most once per proposal: `UNIQUE(proposal_id, order_item_id)` | The LLM must merge quantities itself |
| D18 | Errors | Business errors return `isError: true` with body `{code, message, details}`; schema violations come back as the SDK's own text with `isError: true`, not rewritten | Two error body formats |
| D19 | Compensation model | Cash covers missing or wrong items at menu price and the delivery fee. Goodwill is a percent of the food subtotal **per reason code**, each reason code at most once per order, goodwill total at most 30% per order. The LLM sends `goodwill: [{reason_code, percent}]` | Two amounts per proposal and per refund; the 30% cap lives both in the policy text (for the LLM) and in Go (to enforce) |
| D20 | Goodwill form | A voucher for a future order; v1 records the issued amount only (no wallet, no redemption) | A very upset customer may read a voucher as a lure; the actual loss is still paid in cash |
| D21 | Loyalty bonus | Not in v1 (backlog). It would need `delivered_orders_last_90d`, a better signal than account age | Loyal and new customers with a clean history are treated the same |
| D22 | Customer summary | `get_order.customer` has only `other_orders_compensated_last_30d`; account age and 90-day fields are left out because no rule uses them | Fields the LLM sees but no rule uses invite made-up meaning |
| D23 | AI agent language | Python with LangGraph. Go is possible (official Anthropic and OpenAI Go SDKs, the go-sdk MCP client, ADK Go, Eino), but LangGraph itself is Python/JS only, and it is the framework many agent teams use | Two languages in the repo; interrupt and checkpointing come from LangGraph instead of being hand-built |
| D24 | Payment reversals | `payments.reversed_at` is written by the seed only, never by `execute_refund`; `get_order` returns `days_since_created` and `days_since_reversed` (business clock) for the 7-day bank window | v1 has no payments system, so nothing changes `reversed_at` after the seed; an escalated duplicate charge stays unreversed |
| D25 | Migrations | goose v3 SQL migrations embedded with `embed.FS` and applied by `server/cmd/migrate` through `goose.NewProvider` | One more small binary instead of the goose CLI; the same command migrates dev, test and CI |
| D26 | CI | GitHub Actions runs `make up`, `make lint`, `make test` against the same `docker-compose.yml` used locally, not service containers | Slower start (images pulled each run); one way to run the stack, so local and CI cannot drift |
| D27 | Policy section numbers | H2 headings in `data/policies/*.md` are numbered `N. Title` per file for easy reading; the policy parser strips the leading number, so `chunk_id` (e.g. `refunds/late-delivery`) and `section` stay the same when sections are renumbered | One more regex in the parser; the numbers never reach the LLM |
