---
name: define-product
description: Use this skill when the user has a product idea but no brief yet — phrases like "I have an idea for", "I want to build something that", "thinking about making", or when they ask to scope, define, plan, or spec a new product. Also use it if create-product is invoked but no docs/BRIEF.md exists yet, or when the user wants to revisit/upgrade an existing brief (e.g. "I think this could be a real business"). It turns a fuzzy idea into a short brief (docs/BRIEF.md) that becomes the agent's persistent context for all future sessions, preventing scope drift. Run it BEFORE create-product and before writing any code.
---

# Define the Product (Brief)

Turn an idea into a one-page brief at `docs/BRIEF.md`. The brief has two audiences: the user (to sharpen their own thinking) and **future agent sessions** (as durable context). Every later skill builds against it; `new-feature` checks slices against the brief's scope.

## Step 0: Intent check (routes everything else)

Before any other questions, establish which of these the project is. Often the user's first message makes it obvious — if so, state your read and confirm rather than asking:

- **A. Personal / fun** — built for the user (or friends), success is enjoyment and use. No revenue intent.
- **B. Might become something** — starting personal, but the user suspects others might want it. Build for self, keep the door open.
- **C. Business idea** — the explicit goal is paying users or another concrete return.

Record the intent at the top of the brief. **Intent can change** — a toy can earn an upgrade. When that happens, re-run this skill against the existing brief: keep what holds, add the business section, log the change in the decisions log.

## Core questions (all tracks)

Have a short, genuine conversation — not a questionnaire. Ask at most 2-3 questions at a time, infer what you can, and if the user's first message already answers most of this, draft the brief and let them correct it.

**Response posture (matters most on track C, applies everywhere):** Take a position on every answer and say what evidence would change it. The first answer is usually the polished version — push once, then once more if it's still vague. Never retreat to "that's an interesting approach," "there are many ways to think about this," or "that could work"; say whether it works and why. Vague answers get pushed: "everyone" is not a customer, "seamless" is not a feature, and you can't email a category. Calibrated acknowledgment over praise — when an answer is specific and evidence-based, name why it's good and move to a harder question. Interest is not demand: waitlists and compliments are free; behavior, money, and someone being upset if it disappeared are evidence.

**Escape hatch:** If the user says "just do it" or shows impatience, ask only the 1-2 most critical unanswered questions (core loop and out-of-scope for A/B; who-pays and riskiest assumption for C), then draft. If they push back a second time, draft immediately from what you have and mark gaps in the brief as `TBD`.

1. **The itch.** What prompted this? One or two sentences.
2. **The user.** For track A, "just me" is a fine answer and changes decisions (simpler auth, no onboarding). For track C, "everyone" is not an answer — push for a specific first customer.
3. **The core loop.** The one repeated action that IS the product: "user does X, sees Y, comes back to do X again." A product has one core loop; everything else is decoration.
4. **V1 scope — the smallest lovable version.** The least that would make the user (track A/B) or a first customer (track C) actually use it next week. When they list five features, ask which single one delivers the core loop.
5. **Explicitly out of scope.** The section that does the most work later. Name the tempting adjacent features and park them.
6. **Data sketch.** 3-6 nouns and how they relate. Not a schema — `new-feature` designs real tables later.
7. **Done-enough signal.** Track-dependent — see below.
8. **Name/slug.** Propose a lowercase slug for `create-product` and confirm.

## Track-specific routing

**Track A (personal/fun):** Stop at the core questions. No personas, no market sizing, no KPIs — banning rigor theater is the point. "Done when" is a usage signal ("I logged waterings for a week without opening my notes app").

**Track B (might become something):** Core questions, plus two light additions:
- **The tell.** What observed signal would upgrade this to a business idea? ("Three friends ask for accounts"; "I'd pay for this myself if someone else built it.") Write it down — it makes the later upgrade decision honest instead of vibes.
- **Keep-the-door-open notes.** Anything cheap now that's expensive later, noted, not built: e.g. don't hard-code single-user assumptions into the schema. Do NOT pre-build multi-tenancy, billing, or analytics — just avoid actively walling them off.

**Track C (business):** Core questions, plus a short business section. Keep it to first-test level, not a business plan:
- **Who pays, and what for.** The specific person/role and the pain that opens their wallet. If user ≠ payer (e.g. teams), name both. Push past category answers to a person you could actually email.
- **Pricing hypothesis.** One sentence — model and rough price point ("$9/mo subscription", "one-time $29"). It's a hypothesis to test, not a commitment.
- **Why this vs. the status quo.** The real competitor is whatever users do today — usually a spreadsheet, a group chat, or a workaround, not a rival startup. What does the current workaround cost them in hours or dollars? If the honest answer is "nothing, they just live with it," that's a warning: a problem nobody acts on may not be painful enough to pay for. If the user hasn't looked at alternatives, suggest a quick search before building.
- **Riskiest assumption + cheapest test.** What must be true for this to work, and the smallest thing that tests it. Remember interest is not demand — the test should produce behavior or money, not opinions. Sometimes that's a landing page before any product — say so if the brief points that way.
- **Indie-hackability check (gating priority).** Analyze the opportunity honestly first — then assess whether *this user* can pursue it: solo, on the side, without significant upfront capital. Score it frankly across:
  - *Regulatory surface.* Health data, payments custody, lending/insurance, legal advice, children's products → heavy compliance burden a solo side-timer can't carry.
  - *Upfront costs.* Inventory, hardware, licensed data, paid certifications, or a sales-heavy go-to-market all break the indie model.
  - *Reachable distribution.* Can one person reach the first customers via communities, SEO, content, or product-led growth? Enterprise sales cycles cannot be run on evenings.
  - *Operational load.* 24/7 support expectations, marketplace chicken-and-egg, or human-in-the-loop fulfillment don't fit side-project hours.
  - *Time-to-MVP.* Buildable to a testable v1 with this template in weeks, not months?

  Verdict is one of: **indie-hackable as-is**, **indie-hackable via a niche**, or **not indie-hackable**. If it's the middle one, do the most useful work in this skill: find the wedge inside the big idea that avoids the regulated/expensive part — e.g. "AI for medical diagnosis" is out, but "appointment-prep checklist app patients pay $5 for" might be in. If it's genuinely not indie-hackable, say so plainly and let the user decide; don't quietly shrink the idea without flagging that you did.
- **"Done when" becomes a validation milestone**, not a usage signal: "5 strangers used it twice", "1 person paid", "20 waitlist signups from the landing page".
- **Build-order implications.** Track C usually pulls deferred concerns forward: `add-observability` (PostHog) early — you can't validate what you can't see — and `add-payments` as soon as the validation milestone involves payment. Note this in the brief so later sessions sequence accordingly. Auth almost always matters from day one.

## Brief format

Write `docs/BRIEF.md` in this shape (still under a page):

```markdown
# <Product Name>

**Slug:** `<slug>` · **Started:** <date> · **For:** <who> · **Intent:** <personal | exploring | business>

## Why
<The itch, 1-3 sentences.>

## Core loop
<One sentence: user does X, sees Y, returns to do X.>

## V1 scope
- <feature that delivers the core loop>
- <only what v1 truly needs — typically 2-4 bullets>

## Out of scope (for now)
- <tempting adjacent feature> — revisit if <condition>

## Data sketch
<Nouns and relations in prose, 2-4 sentences.>

## Done when
<Track A/B: concrete usage signal. Track C: validation milestone.>

## Business (tracks B/C only — B gets just "The tell")
- **The tell (B):** <signal that upgrades this to a business>
- **Who pays:** <person/role and the pain> (C)
- **Pricing hypothesis:** <one sentence> (C)
- **Vs. status quo:** <what users do today and what it costs them> (C)
- **Riskiest assumption:** <assumption> — test: <cheapest test> (C)
- **Indie-hackability:** <as-is | via niche: <the wedge> | not indie-hackable> — <one line why> (C)
- **Build-order notes:** <e.g. observability early; payments at milestone X> (C)

## Decisions log
- <date>: <scope/intent decision, appended over time>
```

Omit the Business section entirely for track A.

## After the brief

- If the repo doesn't exist yet, hand off to `create-product` with the slug, then commit the brief as `docs/BRIEF.md` in the new repo.
- If working in an existing repo, write the file and commit it.
- The brief is living: when scope or intent changes mid-build, update it and append to the decisions log rather than letting code and brief diverge.

## Guardrails

- Don't inflate track A projects into business plans, and don't let track C projects skip the uncomfortable questions (who pays, vs. what). The intent check exists so each gets the scrutiny it deserves — no more, no less.
- Analyze the opportunity on its merits *before* applying the indie-hackability gate — a big regulated idea deserves an honest read, then a frank verdict and a search for the niche. Never silently shrink an idea to fit the gate without saying so.
- On track C, take positions. If the evidence says the idea is weak, say it's weak and what would change your mind. A flattering brief that fails in the market wastes months; an uncomfortable conversation costs minutes.
- Don't let "out of scope" stay empty. If the user can't name cut features, propose the obvious tempting ones and ask.
- For track C, if the riskiest assumption can be tested without building the product, say so plainly before provisioning anything.
- Don't start building in the same breath. Finish the brief, get a "yes, that's it," then move on.
- One brief per product. If the conversation reveals two products, say so and split them.
