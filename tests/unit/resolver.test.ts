import { describe, expect, it } from "vitest";
import { clockResolver } from "@/lib/portrait/resolver";
import type { PortraitManifest } from "@/lib/portrait/types";

const manifest: PortraitManifest = {
  clips: [],
  schedule: [
    { startHour: 9, endHour: 17, activity: "working" },
    { startHour: 17, endHour: 23, activity: "idle" },
    { startHour: 23, endHour: 9, activity: "sleeping" },
  ],
};

function at(hour: number) {
  const d = new Date(2026, 0, 1, hour, 0, 0);
  return clockResolver(manifest).resolve(d);
}

describe("clockResolver", () => {
  it("picks the daytime activity", () => {
    expect(at(10)).toBe("working");
  });

  it("returns the activity at the start of a range", () => {
    expect(at(9)).toBe("working");
  });

  it("excludes the end of a range", () => {
    expect(at(17)).toBe("idle");
  });

  it("wraps midnight for sleeping", () => {
    expect(at(2)).toBe("sleeping");
    expect(at(23)).toBe("sleeping");
  });

  it("returns null when no entry matches", () => {
    const empty = clockResolver({ clips: [], schedule: [] });
    expect(empty.resolve(new Date())).toBe(null);
  });
});
