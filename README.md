# Product Template

Next.js + Supabase monolith starter for rapidly bootstrapping products.
Read `CLAUDE.md` first — it encodes the conventions agents should follow.

## Quick start

```bash
npm install
cp .env.example .env.local        # fill in Supabase values
supabase start                    # local Postgres/Auth/Storage (needs Supabase CLI + Docker)
supabase db reset                 # applies migrations + seed
npm run db:types                  # regenerate lib/supabase/types.ts
npm run dev
```

Visit http://localhost:3000. Health check at /api/health.

## Scripts

- `npm run dev` / `build` / `start` — Next.js
- `npm test` — Vitest unit tests
- `npm run test:e2e` — Playwright smoke test
- `npm run typecheck` — tsc, no emit
- `npm run db:types` — regenerate Supabase types from local schema

## What's included

- Next.js App Router + TypeScript (strict) + Tailwind
- Supabase clients: `server`, `browser`, `admin`, plus session `middleware`
- Auth callback route + root middleware (session refresh)
- Example RLS migration (`profiles`) showing conventions
- Vitest + Playwright baselines
- `.claude/skills/` — `define-product`, `create-product`, `new-feature`, `add-auth`
- `integrations/` — stubs for stripe, resend, sentry, posthog (add when needed)
- `docs/decisions/` — ADRs for the monolith and Python-service choices

## Per-product setup

Each product is its own repo + Supabase project + Vercel project (full isolation).
Bootstrap all three with one command (see `scripts/create-product.sh`):

```bash
TEMPLATE_REPO=<owner/product-template> GH_OWNER=<owner> SUPABASE_ORG_ID=<org> \
  ./scripts/create-product.sh my-cool-app
```

This creates the GitHub repo from the template (clean history), a Supabase
project with migrations pushed, and a linked Vercel project with env vars set.
Use `--public`, or skip a phase with `--no-github` / `--no-supabase` / `--no-vercel`.
The `create-product` skill wraps this and handles the judgment steps (slug
choice, redirect URLs, saving the DB password). Prereqs: authenticated `gh`,
`supabase`, `vercel`, plus `jq` and `openssl`.

After bootstrap: save the printed DB password, add Supabase auth redirect URLs
(site + `/auth/callback`), set `NEXT_PUBLIC_SITE_URL` in Vercel, then build your
first slice with the `new-feature` skill.
