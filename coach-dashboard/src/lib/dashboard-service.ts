"use client";

import {
  addDoc,
  collection,
  doc,
  getDoc,
  getDocs,
  limit,
  orderBy,
  query,
  serverTimestamp,
  setDoc,
  updateDoc,
  where,
} from "firebase/firestore";
import { db } from "@/lib/firebase";
import type {
  CoachLink,
  CoachPlan,
  PlanWeek,
  PlanWorkout,
  TraineeProfile,
} from "@/lib/dashboard-types";

function requireDb() {
  if (!db) throw new Error("Firebase is not configured");
  return db;
}

export async function loadCoachTrainees(coachId: string): Promise<TraineeProfile[]> {
  const dbClient = requireDb();
  const q = query(
    collection(dbClient, "coach_trainees"),
    where("coachId", "==", coachId),
    where("status", "==", "active"),
    orderBy("createdAt", "desc"),
  );
  const snap = await getDocs(q);
  const ids = snap.docs.map((d) => d.data().traineeId as string);
  const users: Array<TraineeProfile | null> = await Promise.all(
    ids.map(async (uid) => {
      const us = await getDoc(doc(dbClient, "users", uid));
      if (!us.exists()) return null;
      const data = us.data();
      return {
        uid,
        displayName: (data.displayName as string) || "Unnamed trainee",
        email: (data.email as string) || "",
        photoUrl: (data.photoUrl as string | undefined) ?? undefined,
        activePlanId: (data.activePlanId as string | null | undefined) ?? null,
      };
    }),
  );
  return users.filter((u): u is TraineeProfile => u !== null);
}

export async function createCoachInvite(coachId: string, traineeEmail: string) {
  const dbClient = requireDb();
  const code = cryptoRandomCode();
  const normalizedEmail = traineeEmail.trim().toLowerCase();
  await addDoc(collection(dbClient, "coach_invites"), {
    coachId,
    traineeEmail: normalizedEmail,
    code,
    status: "pending",
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
  });
  return code;
}

export async function loadCoachInviteStats(
  coachId: string,
): Promise<{ pending: number }> {
  const dbClient = requireDb();
  const q = query(
    collection(dbClient, "coach_invites"),
    where("coachId", "==", coachId),
    where("status", "==", "pending"),
  );
  const snap = await getDocs(q);
  return { pending: snap.size };
}

function cryptoRandomCode() {
  return Math.random().toString(36).slice(2, 10).toUpperCase();
}

export async function loadCoachLink(
  coachId: string,
  traineeId: string,
): Promise<CoachLink | null> {
  const dbClient = requireDb();
  const id = `${coachId}_${traineeId}`;
  const snap = await getDoc(doc(dbClient, "coach_trainees", id));
  if (!snap.exists()) return null;
  const d = snap.data();
  return {
    id,
    coachId: d.coachId as string,
    traineeId: d.traineeId as string,
    status: (d.status as "active" | "ended") ?? "active",
    createdAt: d.createdAt?.toDate?.() ?? null,
  };
}

export async function endCoachLink(coachId: string, traineeId: string) {
  const dbClient = requireDb();
  const id = `${coachId}_${traineeId}`;
  await updateDoc(doc(dbClient, "coach_trainees", id), {
    status: "ended",
    endedAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
  });
}

export async function loadTraineeProfile(uid: string): Promise<TraineeProfile | null> {
  const dbClient = requireDb();
  const us = await getDoc(doc(dbClient, "users", uid));
  if (!us.exists()) return null;
  const data = us.data();
  return {
    uid,
    displayName: (data.displayName as string) || "Unnamed trainee",
    email: (data.email as string) || "",
    photoUrl: (data.photoUrl as string | undefined) ?? undefined,
    activePlanId: (data.activePlanId as string | null | undefined) ?? null,
  };
}

export async function loadLatestPlanForTrainee(
  coachId: string,
  traineeId: string,
): Promise<CoachPlan | null> {
  const dbClient = requireDb();
  const q = query(
    collection(dbClient, "plans"),
    where("coachId", "==", coachId),
    where("traineeId", "==", traineeId),
    orderBy("updatedAt", "desc"),
    limit(1),
  );
  const snap = await getDocs(q);
  if (snap.empty) return null;
  const d = snap.docs[0];
  const data = d.data();
  return {
    id: d.id,
    title: (data.title as string) || "New plan",
    traineeId: data.traineeId as string,
    coachId: data.coachId as string,
    weeksTotal: (data.weeksTotal as number) ?? 12,
    currentOpenWeek: (data.currentOpenWeek as number) ?? 0,
    status: (data.status as CoachPlan["status"]) ?? "draft",
  };
}

export async function createPlanDraft(params: {
  coachId: string;
  traineeId: string;
  title: string;
  weeksTotal: number;
}) {
  const dbClient = requireDb();
  const planRef = await addDoc(collection(dbClient, "plans"), {
    coachId: params.coachId,
    traineeId: params.traineeId,
    title: params.title,
    weeksTotal: params.weeksTotal,
    currentOpenWeek: 0,
    status: "draft",
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
  });

  for (let i = 1; i <= params.weeksTotal; i++) {
    await setDoc(doc(dbClient, "plans", planRef.id, "weeks", `week-${i}`), {
      weekIndex: i,
      isOpen: false,
      createdAt: serverTimestamp(),
      updatedAt: serverTimestamp(),
    });
  }

  await updateDoc(doc(dbClient, "users", params.traineeId), {
    activePlanId: planRef.id,
    updatedAt: serverTimestamp(),
  });
  return planRef.id;
}

export async function loadPlanWeeks(planId: string): Promise<PlanWeek[]> {
  const dbClient = requireDb();
  const q = query(
    collection(dbClient, "plans", planId, "weeks"),
    orderBy("weekIndex", "asc"),
  );
  const snap = await getDocs(q);
  return snap.docs.map((d) => {
    const data = d.data();
    return {
      id: d.id,
      weekIndex: (data.weekIndex as number) ?? 0,
      isOpen: Boolean(data.isOpen),
      notes: (data.notes as string | undefined) ?? undefined,
    };
  });
}

export async function unlockWeek(planId: string, weekDocId: string, weekIndex: number) {
  const dbClient = requireDb();
  await updateDoc(doc(dbClient, "plans", planId, "weeks", weekDocId), {
    isOpen: true,
    updatedAt: serverTimestamp(),
  });
  await updateDoc(doc(dbClient, "plans", planId), {
    currentOpenWeek: weekIndex,
    status: "active",
    updatedAt: serverTimestamp(),
  });
}

export async function addWorkout(params: {
  planId: string;
  weekDocId: string;
  title: string;
  kind: string;
  dayIndex: number;
  targetDistanceKm?: number;
  targetDurationMin?: number;
}) {
  const dbClient = requireDb();
  await addDoc(
    collection(dbClient, "plans", params.planId, "weeks", params.weekDocId, "workouts"),
    {
      title: params.title,
      kind: params.kind,
      dayIndex: params.dayIndex,
      targetDistanceKm: params.targetDistanceKm ?? null,
      targetDurationMin: params.targetDurationMin ?? null,
      status: "planned",
      createdAt: serverTimestamp(),
      updatedAt: serverTimestamp(),
    },
  );
}

export async function loadWorkouts(planId: string, weekDocId: string): Promise<PlanWorkout[]> {
  const dbClient = requireDb();
  const q = query(
    collection(dbClient, "plans", planId, "weeks", weekDocId, "workouts"),
    orderBy("dayIndex", "asc"),
  );
  const snap = await getDocs(q);
  return snap.docs.map((d) => {
    const data = d.data();
    return {
      id: d.id,
      title: (data.title as string) || "Workout",
      kind: (data.kind as string) || "run",
      dayIndex: (data.dayIndex as number) ?? 0,
      targetDistanceKm: (data.targetDistanceKm as number | undefined) ?? undefined,
      targetDurationMin: (data.targetDurationMin as number | undefined) ?? undefined,
      status: (data.status as PlanWorkout["status"]) ?? "planned",
    };
  });
}
