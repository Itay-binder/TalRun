export type CoachLink = {
  id: string;
  coachId: string;
  traineeId: string;
  status: "active" | "ended";
  createdAt?: Date | null;
};

export type TraineeProfile = {
  uid: string;
  displayName: string;
  email: string;
  photoUrl?: string;
  activePlanId?: string | null;
};

export type CoachPlan = {
  id: string;
  title: string;
  traineeId: string;
  coachId: string;
  weeksTotal: number;
  currentOpenWeek: number;
  status: "draft" | "active" | "paused" | "completed" | "archived";
};

export type PlanWeek = {
  id: string;
  weekIndex: number;
  isOpen: boolean;
  notes?: string;
};

export type PlanWorkout = {
  id: string;
  title: string;
  kind: string;
  dayIndex: number;
  targetDistanceKm?: number;
  targetDurationMin?: number;
  status: "planned" | "completed" | "skipped";
};

