export type ClipType = "loop" | "enter" | "exit";

export interface Clip {
  activity: string;
  src: string;
  type: ClipType;
}

export interface ScheduleEntry {
  startHour: number;
  endHour: number;
  activity: string;
}

export interface PortraitManifest {
  clips: Clip[];
  schedule: ScheduleEntry[];
}
