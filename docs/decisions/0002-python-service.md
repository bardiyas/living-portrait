# 0002 — Python/FastAPI service is an opt-in add-on

**Status:** Accepted

## Context

Some products will need Python — ML inference, heavy data processing, or a Python-only library. But scaffolding FastAPI into every project costs a second language, deploy target, and integration surface that most side projects never use.

## Decision

Keep a Python service out of the default scaffold. Add it only when a task genuinely requires Python, and ask the user before introducing it.

## When it's justified

- An ML model or library with no good JS equivalent.
- Heavy/long-running data work that doesn't fit a request/response handler.
- Background or scheduled jobs beyond Vercel's request model.

If a Next.js route handler can do the job, use the route handler.

## Hosting note

Vercel suits short, stateless request/response only. A Python service doing long-running, stateful, websocket, or >~10s inference work should run on Render, Railway, or Fly — not Vercel functions. Decide hosting when the service is added.

## Consequences

- Most projects stay single-language and simpler.
- When added, introduce type sharing (e.g., Pydantic → TS) and document the boundary in a new ADR.
