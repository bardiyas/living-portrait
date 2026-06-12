# Integrations (stubbed, deferred)

These are concerns the template deliberately does **not** wire up until a product needs them. Each gets a folder here so adding it later is "follow the stub," not greenfield work. The corresponding skill in `.claude/skills/` does the wiring.

| Concern | Add when… | Skill |
|---|---|---|
| `stripe/` | the product monetizes | `add-payments` |
| `resend/` | the product sends email | `add-email` |
| `sentry/` | real users exist and you need error tracking | `add-observability` |
| `posthog/` | real users exist and you need product analytics | `add-observability` |

Until then, leave these empty/stubbed. Don't add the SDKs or keys "just in case" — see the guardrails in the root `CLAUDE.md`.
