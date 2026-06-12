"use client";

import { useEffect, useState } from "react";
import { manifest } from "@/lib/portrait/manifest";
import { clockResolver } from "@/lib/portrait/resolver";
import type { Clip } from "@/lib/portrait/types";
import { Player } from "./Player";

const resolver = clockResolver(manifest);

function pickLoop(activity: string | null): Clip | null {
  if (!activity) return null;
  return (
    manifest.clips.find((c) => c.activity === activity && c.type === "loop") ??
    null
  );
}

export function LivingPortrait() {
  const [clip, setClip] = useState<Clip | null>(null);

  useEffect(() => {
    const tick = () => setClip(pickLoop(resolver.resolve(new Date())));
    tick();
    const id = setInterval(tick, 60_000);
    return () => clearInterval(id);
  }, []);

  return (
    <div
      data-testid="living-portrait"
      data-activity={clip?.activity ?? "none"}
      className="aspect-square w-64 overflow-hidden rounded-full bg-neutral-900"
    >
      {clip ? <Player clip={clip} /> : null}
    </div>
  );
}
