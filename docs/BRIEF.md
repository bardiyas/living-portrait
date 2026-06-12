# Living Portrait

**Slug:** `living-portrait` · **Started:** 2026-06-11 · **For:** just me · **Intent:** personal

## Why
Static headshots are boring. I want a Harry Potter-style living portrait on my website — visitors see me working, eating, or sleeping depending on when they visit.

## Core loop
Visitor loads my site → sees me doing something plausible for the current time of day → returning at a different hour shows a different activity. The portrait has a life.

## V1 scope
- Pipeline: photo → AI-generated clips (offline, curated by hand) — target 3-4 activities (working, eating, sleeping, idle)
- Portrait component: seamless looping playback, with a resolver → activity → player seam
- Time-of-day scheduler: client-side clock maps hours → activity
- Drop-in embed for my existing site

## Out of scope (for now)
- Real state awareness (calendar, presence) — revisit if the time schedule feels fake
- Random/weighted variety within a time slot — revisit after 3-4 clips exist
- Walking between frames / other sites, "one place at once" — the v2 dream, untouched until v1 delights
- Any tool/UI for other people to make portraits

## Data sketch
A set of Clips (activity, video file, loop points, type: loop/enter/exit — v1 uses only loop) and a Schedule mapping hour ranges to activities. Static config, no database.

## Done when
Live on my site for a week with at least 3 activities on the schedule, and someone who visited at night mentions — unprompted — that I was "asleep."

## Decisions log
- 2026-06-11: AI generation is build-time only; runtime is static video + client-side scheduler.
- 2026-06-11: Time-of-day switching pulled into v1 (one loop isn't "living"). True state-awareness stays out.
- 2026-06-11: Architecture seam: resolver separate from player so v2 can swap clock → shared-state endpoint. Manifest carries `type` field. No endpoint, sync, or transition logic until v1 proves AI can generate consistent clips of me.
