import type { PortraitManifest } from "./types";

// Static manifest: clips live under /public/portrait/*.mp4.
// Schedule is hour-based, [startHour, endHour) in local time;
// an entry where startHour > endHour wraps midnight.
export const manifest: PortraitManifest = {
  clips: [
    { activity: "working", src: "/portrait/working.mp4", type: "loop" },
    { activity: "eating", src: "/portrait/eating.mp4", type: "loop" },
    { activity: "idle", src: "/portrait/idle.mp4", type: "loop" },
    { activity: "sleeping", src: "/portrait/sleeping.mp4", type: "loop" },
  ],
  schedule: [
    { startHour: 9, endHour: 12, activity: "working" },
    { startHour: 12, endHour: 13, activity: "eating" },
    { startHour: 13, endHour: 18, activity: "working" },
    { startHour: 18, endHour: 19, activity: "eating" },
    { startHour: 19, endHour: 23, activity: "idle" },
    { startHour: 23, endHour: 9, activity: "sleeping" },
  ],
};
