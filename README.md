# Support Copilot

An AI copilot that helps a human support staff member handle food-delivery complaints:
it gathers context, checks the refund policy and proposes compensation. Money moves only
after a human approves, and only once.

Personal learning project. All data is synthetic. Work in progress.

## Quick start

Requires Docker, Go 1.27 and GNU make.

    make up        # Postgres with pgvector, Jaeger (UI at http://127.0.0.1:16686)
    make migrate   # apply database migrations
    make test      # recreate the test database, migrate it, run Go tests
    make lint      # gofmt and go vet

`.env` is created from `.env.example` on the first `make` run, with a random approval key.

## Known limitations

- The MCP endpoint has no auth. It listens on 127.0.0.1 only and checks the Origin header.
- The complaining customer comes from a CLI flag; a real system takes it from the login session.
- The approver name is self-declared.
- The CLI and the AI agent share one process that holds the signing key. The protection against
  the LLM is structural: it has no tool that executes refunds and never sees the key.
- One database user, no least-privilege separation.
- Single currency, no discounts, no cancellation fees, small synthetic dataset.
- Vouchers are recorded, not redeemable.
- No per-token revocation; approval can be revoked per proposal (M3).
- Escalations are part of the AI agent's output only and are not stored, so a later run does
  not know a case was already escalated.