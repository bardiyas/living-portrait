import { createClient } from "@supabase/supabase-js";

/**
 * Admin client using the service role key. SERVER-ONLY.
 * Bypasses Row Level Security — never import this into client code.
 * Use only for trusted server-side operations (webhooks, background jobs).
 */
export function createAdminClient() {
  return createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!,
    { auth: { persistSession: false, autoRefreshToken: false } },
  );
}
