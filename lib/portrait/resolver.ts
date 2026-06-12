import type { PortraitManifest } from "./types";

// A resolver picks the current activity. The brief calls out this seam
// explicitly so v2 can swap the clock for a shared-state endpoint
// without touching the player.
export interface Resolver {
  resolve(now: Date): string | null;
}

export function clockResolver(manifest: PortraitManifest): Resolver {
  return {
    resolve(now) {
      const h = now.getHours();
      for (const { startHour, endHour, activity } of manifest.schedule) {
        const inRange =
          startHour <= endHour
            ? h >= startHour && h < endHour
            : h >= startHour || h < endHour;
        if (inRange) return activity;
      }
      return null;
    },
  };
}
