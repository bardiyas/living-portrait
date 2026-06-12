# Project Conventions

This is a product-bootstrap template. The goal is to go from empty repo to a deployable, iterable product quickly, with consistent structure across many different thematic domains. Read this file fully before making changes.

## Stack (the default path)

This project is a **Next.js monolith**. The frontend and all backend logic live in one Next.js app. There is no separate API server by default.

- **Framework:** Next.js (App Router). UI in `app/`, server logic in route handlers (`app/api/.../route.ts`) and server actions.
- **Data/auth/storage:** Supabase (Postgres, Storage, Vector, Auth).
- **Styling:** Tailwind only. Do not add a component library unless asked. If richer components are needed, the user will request shadcn/ui explicitly.
- **Hosting:** Vercel for the Next.js app; Supabase cloud for the database.
- **Language:** TypeScript everywhere. Strict mode on.

### When to reach for the Python service

There is an *optional* `python-service/` add-on (FastAPI). **Do not create or wire it up by default.** Only introduce it when the task genuinely needs Python — heavy data work, an ML model, a specific Python-only library, or long-running/background jobs that don't fit Vercel's request model. When that happens, consult `docs/decisions/0002-python-service.md` and ask the user before adding the integration tax of a second service.

If you find yourself about to add FastAPI for something a Next.js route handler could do, stop and use a route handler instead.

## Project structure

```
app/                  Next.js App Router — pages, layouts, route handlers
  api/                Route handlers (server-side endpoints)
lib/
  supabase/           Supabase client factories (server, browser, admin)
  utils.ts            Shared helpers
components/            React components (presentational + feature)
supabase/
  migrations/         SQL migrations, checked in, source of truth for schema
  seed.sql            Local seed data
integrations/         Stubbed deferred concerns (stripe, resend, sentry, posthog)
docs/decisions/       Short ADRs — read before relitigating a choice
.claude/skills/       Skills for deferred/repeated workflows
```

## Product lifecycle

The order for a brand-new product: `define-product` (write `docs/BRIEF.md`) → `create-product` (provision repo/Supabase/Vercel) → `new-feature` (build slices). **`docs/BRIEF.md` is the source of truth for what this product is** — read it at the start of a session before making scope decisions, check features against its V1/out-of-scope lists, and append scope changes to its decisions log rather than letting code and brief diverge.

The brief's **Intent** field (personal / exploring / business) affects build order: personal projects keep all deferred concerns deferred; business-intent briefs usually pull `add-observability` forward and schedule `add-payments` at their validation milestone — follow the brief's build-order notes.

## How to add a feature (vertical slice)

Use the `new-feature` skill. The short version: schema migration → data access in `lib/` → route handler or server action → UI → a smoke test. Keep each slice self-contained.

To bootstrap a brand-new product (its own repo, Supabase project, and Vercel project), use the `create-product` skill, which drives `scripts/create-product.sh`. One product = one repo = one Supabase project = one Vercel project.

## Database conventions

- **Migrations are files, not dashboard clicks.** Every schema change is a timestamped SQL file in `supabase/migrations/`, created via the Supabase CLI. Never instruct the user to change schema in the Supabase dashboard — it drifts from the repo and agents lose track of it.
- Generate TypeScript types from the schema after migrations (`supabase gen types typescript`). Keep them in `lib/supabase/types.ts`.
- Row Level Security (RLS) is **on** for any table holding user data. Write policies in the same migration that creates the table.

## Secrets and environment

- All required env vars live in `.env.example` with safe placeholder values and a one-line comment each. When you add a feature needing a new secret, add it to `.env.example` in the same change.
- Never print real secret values or commit a real `.env`. Assume secrets live in Vercel env vars (prod) and a local `.env.local` (dev).

## Deferred concerns — add only when needed

Auth is the one exception worth wiring early since most products need it; use the `add-auth` skill. The rest stay stubbed until the product actually needs them:

- **Payments (Stripe):** only when the product monetizes. Use the `add-payments` skill.
- **Email (Resend):** only when the product sends email. Use the `add-email` skill.
- **Observability (Sentry/PostHog):** only once real users exist. Use the `add-observability` skill.

The `integrations/` folder holds documented stubs for each so wiring them later is "follow the stub," not greenfield work.

## Guardrails — things NOT to do

- Don't add dependencies casually. Each new package is a long-term cost; prefer the platform (Next.js, Supabase) and standard library first. If a package is non-obvious, note why in a one-line comment or an ADR.
- Don't introduce a second styling system alongside Tailwind.
- Don't scaffold the Python service, Stripe, Resend, or analytics "just in case."
- Don't make schema changes outside `supabase/migrations/`.
- Don't disable TypeScript strictness or RLS to make something compile/work faster.
- Don't leave secrets, keys, or tokens in committed code.

## Testing baseline

There's a minimal setup: Vitest for unit logic and one Playwright smoke test that loads the home page. When you add a feature, extend these rather than starting from zero. A feature isn't done until the smoke test still passes.

## Decisions

Before re-deciding anything architectural, check `docs/decisions/`. If you make a new significant decision, add a short ADR there (see the existing ones for format).
