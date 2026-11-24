# Backlog

Work that is out of scope for the current milestone. Items move into a milestone when it starts.

## Product (after v1)

- Loyalty bonus for long-time customers (D21); needs `delivered_orders_last_90d`.
- Voucher wallet and redemption (v1 only records issued vouchers, D20).
- Cancellation fees.
- Redelivery as a compensation option.
- Goodwill voucher for a long wait before cancellation. Needs who cancelled and when, a new
  reason code, and proposals on cancelled orders.
- Claim time limit (how long after delivery a complaint is accepted).
- Store open escalations so later runs can see that a case was already escalated.
- Compare a hand-written AI agent loop in Go (Anthropic Go SDK + go-sdk MCP client) with the
  LangGraph workflow on the same eval cases.

## Notes for later milestones

### M2: policy RAG
- Build the retrieval evaluation set from queries the LLM actually sends (taken from traces).
- Seed policies separately from business tables (upsert by `chunk_id` and content hash) so a
  reset does not re-embed every chunk.

### M3: LangGraph workflow
- At most one proposal per run: a code step blocks a second `propose_refund` call.
- Proposals declined by the support staff, or failing at execute, become `rejected`, so
  `pending_proposals` stays accurate.
- The node holding `interrupt()` re-runs from its start on resume, so it must not call a tool
  before `interrupt()`.
- Bind the three LLM tools from an explicit allowlist; `execute_refund` is never bound.
- A tool-call budget that falls back to escalation.
- MCP client library still open: `mcp` 2.x `Client`, or `langchain-mcp-adapters` (which needs
  `mcp<2` and speaks protocol 2025-11-25; the server serves both).
- The final output must allow a proposal and an escalation in the same case (rule A1 with a
  service issue).

### M4: evals and tracing
- Each eval case's expected outcome: a proposal (none, or the expected components) plus
  escalations (teams, possibly none), or "ask".
- Level 1 assertions on behaviour: at most one proposal; none where none is expected; cited
  chunk IDs appeared in this run's search results.
- Reset the database per case.
