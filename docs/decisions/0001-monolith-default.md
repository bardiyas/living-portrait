# 0001 — Next.js monolith is the default

**Status:** Accepted

## Context

The template targets rapid bootstrapping of many small products across different domains, some of which are side projects rather than commercial. A Next.js frontend + separate FastAPI backend was considered, but two languages, two deploy targets, two dependency systems, CORS, and duplicated types impose an integration tax on *every* project regardless of whether it benefits.

## Decision

Default to a single Next.js (App Router) application. All backend logic lives in route handlers and server actions. Supabase provides data, auth, storage, and vector. The Python/FastAPI service is an optional, documented add-on (see ADR 0002), introduced only when a task genuinely needs Python.

## Consequences

- Faster zero-to-deploy; one mental model, one deploy.
- Some workloads (heavy ML, long-running jobs) will eventually need the Python service or a different host than Vercel.
- Type sharing is trivial while everything is TypeScript; reassess if the Python service is added.
