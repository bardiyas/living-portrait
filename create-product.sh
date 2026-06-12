#!/usr/bin/env bash
#
# create-product.sh — bootstrap a new product from this template.
#
# Provisions, in order:
#   1. A new GitHub repo from the template (clean history)
#   2. A Supabase project, with migrations pushed
#   3. A Vercel project, linked, with env vars set
#
# Designed to be safe to re-run and to fail loudly. Each phase is opt-out
# via flags so you can skip anything you'd rather do by hand.
#
# Prerequisites (the script checks for these):
#   - gh        (authenticated: gh auth status)
#   - supabase  (SUPABASE_ACCESS_TOKEN set, or `supabase login` done)
#   - vercel    (VERCEL_TOKEN set, or `vercel login` done)
#   - jq        (for parsing CLI JSON output)
#
# Required env / config (see the prompts below if unset):
#   TEMPLATE_REPO     e.g. your-org/product-template
#   GH_OWNER          e.g. your-org or your-username
#   SUPABASE_ORG_ID   from `supabase orgs list`
#   SUPABASE_REGION   e.g. us-east-1 (defaults below)
#
# Usage:
#   ./scripts/create-product.sh my-cool-app
#   ./scripts/create-product.sh my-cool-app --private --no-vercel
#
set -euo pipefail

# ----- defaults & flags -------------------------------------------------------
VISIBILITY="--private"
DO_GITHUB=1
DO_SUPABASE=1
DO_VERCEL=1
SUPABASE_REGION="${SUPABASE_REGION:-us-east-1}"

PRODUCT_NAME="${1:-}"
[[ $# -gt 0 ]] && shift

while [[ $# -gt 0 ]]; do
  case "$1" in
    --public)      VISIBILITY="--public" ;;
    --private)     VISIBILITY="--private" ;;
    --no-github)   DO_GITHUB=0 ;;
    --no-supabase) DO_SUPABASE=0 ;;
    --no-vercel)   DO_VERCEL=0 ;;
    *) echo "Unknown flag: $1" >&2; exit 1 ;;
  esac
  shift
done

die() { echo "ERROR: $*" >&2; exit 1; }
need() { command -v "$1" >/dev/null 2>&1 || die "missing required tool: $1"; }

[[ -n "$PRODUCT_NAME" ]] || die "usage: $0 <product-name> [--public] [--no-github|--no-supabase|--no-vercel]"
# Product name must be a safe slug: lowercase letters, digits, hyphens.
[[ "$PRODUCT_NAME" =~ ^[a-z][a-z0-9-]*$ ]] || die "product name must be a lowercase slug (a-z, 0-9, -), starting with a letter"

TEMPLATE_REPO="${TEMPLATE_REPO:-}"
GH_OWNER="${GH_OWNER:-}"
SUPABASE_ORG_ID="${SUPABASE_ORG_ID:-}"

echo "==> Bootstrapping product: $PRODUCT_NAME"

# ----- 1. GitHub repo from template ------------------------------------------
if [[ "$DO_GITHUB" == "1" ]]; then
  need gh
  [[ -n "$TEMPLATE_REPO" ]] || die "set TEMPLATE_REPO=owner/product-template"
  [[ -n "$GH_OWNER" ]] || die "set GH_OWNER=your-org-or-username"
  gh auth status >/dev/null 2>&1 || die "run 'gh auth login' first"

  echo "==> Creating GitHub repo $GH_OWNER/$PRODUCT_NAME from template $TEMPLATE_REPO"
  # --template gives a clean single-commit history (not a fork).
  gh repo create "$GH_OWNER/$PRODUCT_NAME" \
    --template "$TEMPLATE_REPO" \
    $VISIBILITY \
    --clone
  cd "$PRODUCT_NAME"

  # Rename the package and clear the placeholder title so the product
  # doesn't ship as "product-template".
  if [[ -f package.json ]]; then
    tmp=$(mktemp)
    jq --arg n "$PRODUCT_NAME" '.name = $n' package.json > "$tmp" && mv "$tmp" package.json
  fi
  git add -A && git commit -m "chore: initialize $PRODUCT_NAME from template" --quiet || true
  git push --quiet || true
else
  echo "==> Skipping GitHub (assuming you're already in the project dir)"
fi

# ----- 2. Supabase project ----------------------------------------------------
if [[ "$DO_SUPABASE" == "1" ]]; then
  need supabase
  need jq
  [[ -n "$SUPABASE_ORG_ID" ]] || die "set SUPABASE_ORG_ID (see: supabase orgs list)"

  # Generate a strong DB password and keep it for the link/push steps.
  DB_PASSWORD="$(openssl rand -base64 24 | tr -d '/+=' | cut -c1-24)"
  echo "==> Creating Supabase project '$PRODUCT_NAME' in org $SUPABASE_ORG_ID ($SUPABASE_REGION)"

  CREATE_OUT="$(supabase projects create "$PRODUCT_NAME" \
    --org-id "$SUPABASE_ORG_ID" \
    --region "$SUPABASE_REGION" \
    --db-password "$DB_PASSWORD" \
    --output json 2>/dev/null || true)"

  PROJECT_REF="$(echo "$CREATE_OUT" | jq -r '.id // .ref // empty' 2>/dev/null || true)"
  # Fallback: some CLI versions print the ref in plain text.
  if [[ -z "$PROJECT_REF" ]]; then
    PROJECT_REF="$(echo "$CREATE_OUT" | grep -oE '[a-z]{20}' | head -n1 || true)"
  fi
  [[ -n "$PROJECT_REF" ]] || die "could not determine Supabase project ref; check output:\n$CREATE_OUT"
  echo "==> Supabase project ref: $PROJECT_REF"

  echo "==> Waiting for the project to finish provisioning (this can take a minute)…"
  # Poll until the project responds to a link, up to ~3 minutes.
  for i in $(seq 1 18); do
    if SUPABASE_DB_PASSWORD="$DB_PASSWORD" supabase link --project-ref "$PROJECT_REF" >/dev/null 2>&1; then
      echo "==> Linked."
      break
    fi
    sleep 10
    [[ "$i" == "18" ]] && die "timed out waiting for Supabase project to provision"
  done

  echo "==> Pushing migrations"
  # `db push` can prompt for confirmation; pipe 'yes' so it doesn't hang.
  yes | SUPABASE_DB_PASSWORD="$DB_PASSWORD" supabase db push || die "supabase db push failed"

  echo "==> Fetching API keys"
  KEYS_OUT="$(supabase projects api-keys --project-ref "$PROJECT_REF" --output json 2>/dev/null || true)"
  ANON_KEY="$(echo "$KEYS_OUT" | jq -r '.[] | select(.name=="anon") | .api_key' 2>/dev/null || true)"
  SERVICE_KEY="$(echo "$KEYS_OUT" | jq -r '.[] | select(.name=="service_role") | .api_key' 2>/dev/null || true)"
  SUPABASE_URL="https://${PROJECT_REF}.supabase.co"

  # Write a local env file for development. Never commit this.
  cat > .env.local <<ENVEOF
NEXT_PUBLIC_SUPABASE_URL=$SUPABASE_URL
NEXT_PUBLIC_SUPABASE_ANON_KEY=$ANON_KEY
SUPABASE_SERVICE_ROLE_KEY=$SERVICE_KEY
NEXT_PUBLIC_SITE_URL=http://localhost:3000
ENVEOF
  echo "==> Wrote .env.local (gitignored). DB password is NOT stored here; save it now if you need it:"
  echo "    DB password: $DB_PASSWORD"
else
  echo "==> Skipping Supabase"
fi

# ----- 3. Vercel project ------------------------------------------------------
if [[ "$DO_VERCEL" == "1" ]]; then
  need vercel

  echo "==> Linking/creating Vercel project '$PRODUCT_NAME'"
  # --yes accepts inferred defaults; CLI is non-interactive under agents.
  vercel link --yes --project "$PRODUCT_NAME" >/dev/null 2>&1 || \
    vercel link --yes >/dev/null 2>&1 || die "vercel link failed"

  if [[ "$DO_SUPABASE" == "1" ]]; then
    echo "==> Setting Vercel env vars (production + preview)"
    set_env() {
      local key="$1" val="$2"
      for target in production preview; do
        # `vercel env add` reads the value from stdin.
        printf '%s' "$val" | vercel env add "$key" "$target" >/dev/null 2>&1 || \
          echo "    (warn: could not set $key for $target; it may already exist)"
      done
    }
    set_env NEXT_PUBLIC_SUPABASE_URL "$SUPABASE_URL"
    set_env NEXT_PUBLIC_SUPABASE_ANON_KEY "$ANON_KEY"
    set_env SUPABASE_SERVICE_ROLE_KEY "$SERVICE_KEY"
  fi

  echo "==> Deploying a preview"
  vercel deploy >/dev/null 2>&1 || echo "    (warn: preview deploy failed; run 'vercel deploy' manually)"
else
  echo "==> Skipping Vercel"
fi

echo ""
echo "==> Done. Next steps:"
echo "    - cd $PRODUCT_NAME && npm install && npm run dev"
echo "    - Set NEXT_PUBLIC_SITE_URL in Vercel to your production URL"
echo "    - Add the Supabase redirect URLs (site + /auth/callback) in the dashboard"
echo "    - Build your first slice with the 'new-feature' skill"
