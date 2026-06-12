import { createServerClient, type CookieOptions } from "@supabase/ssr";
import { NextResponse, type NextRequest } from "next/server";

/**
 * Refreshes the Supabase auth session on every matched request and
 * makes the user available for route gating. Call this from the root
 * middleware.ts. To protect routes, check `user` below and redirect.
 */
export async function updateSession(request: NextRequest) {
  let response = NextResponse.next({ request });

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll();
        },
        setAll(
          cookiesToSet: { name: string; value: string; options: CookieOptions }[],
        ) {
          cookiesToSet.forEach(({ name, value }) =>
            request.cookies.set(name, value),
          );
          response = NextResponse.next({ request });
          cookiesToSet.forEach(({ name, value, options }) =>
            response.cookies.set(name, value, options),
          );
        },
      },
    },
  );

  // IMPORTANT: getUser() refreshes the session. Don't remove it.
  const {
    data: { user },
  } = await supabase.auth.getUser();

  // Example route gate — uncomment and adjust once auth pages exist:
  // if (!user && request.nextUrl.pathname.startsWith("/app")) {
  //   const url = request.nextUrl.clone();
  //   url.pathname = "/sign-in";
  //   return NextResponse.redirect(url);
  // }

  return response;
}
