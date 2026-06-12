import { NextResponse } from "next/server";

/** Liveness check. Useful for uptime monitors and deploy smoke tests. */
export async function GET() {
  return NextResponse.json({ status: "ok", time: new Date().toISOString() });
}
