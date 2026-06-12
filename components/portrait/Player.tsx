"use client";

import { useEffect, useRef } from "react";
import type { Clip } from "@/lib/portrait/types";

export function Player({ clip }: { clip: Clip }) {
  const ref = useRef<HTMLVideoElement>(null);

  useEffect(() => {
    const v = ref.current;
    if (!v) return;
    v.load();
    v.play().catch(() => {});
  }, [clip.src]);

  return (
    <video
      ref={ref}
      src={clip.src}
      autoPlay
      muted
      loop
      playsInline
      preload="auto"
      className="h-full w-full object-cover"
    />
  );
}
