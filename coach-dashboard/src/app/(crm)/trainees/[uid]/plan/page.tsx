"use client";

import Link from "next/link";
import { useCallback, useEffect, useMemo, useState } from "react";
import { useAuth } from "@/providers/auth-provider";
import {
  addWorkout,
  createPlanDraft,
  loadLatestPlanForTrainee,
  loadPlanWeeks,
  loadWorkouts,
  unlockWeek,
} from "@/lib/dashboard-service";
import type { PlanWeek, PlanWorkout } from "@/lib/dashboard-types";

export default function TraineePlanPage({
  params,
}: {
  params: { uid: string };
}) {
  const { user } = useAuth();
  const [planId, setPlanId] = useState<string | null>(null);
  const [planTitle, setPlanTitle] = useState("תכנית אישית");
  const [weeksTotal, setWeeksTotal] = useState(12);
  const [weeks, setWeeks] = useState<PlanWeek[]>([]);
  const [selectedWeekDoc, setSelectedWeekDoc] = useState<string | null>(null);
  const [workouts, setWorkouts] = useState<PlanWorkout[]>([]);
  const [newTitle, setNewTitle] = useState("");
  const [newKind, setNewKind] = useState("run");
  const [newDay, setNewDay] = useState(1);
  const [busy, setBusy] = useState(true);

  const refreshPlan = useCallback(async () => {
    if (!user) return;
    const latest = await loadLatestPlanForTrainee(user.uid, params.uid);
    if (!latest) {
      setPlanId(null);
      setWeeks([]);
      setSelectedWeekDoc(null);
      setWorkouts([]);
      return;
    }
    setPlanId(latest.id);
    setPlanTitle(latest.title);
    const nextWeeks = await loadPlanWeeks(latest.id);
    setWeeks(nextWeeks);
    const open = nextWeeks.find((w) => w.isOpen) ?? nextWeeks[0] ?? null;
    setSelectedWeekDoc(open?.id ?? null);
    if (open) {
      const ws = await loadWorkouts(latest.id, open.id);
      setWorkouts(ws);
    } else {
      setWorkouts([]);
    }
  }, [params.uid, user]);

  useEffect(() => {
    if (!user) return;
    void (async () => {
      setBusy(true);
      try {
        await refreshPlan();
      } finally {
        setBusy(false);
      }
    })();
  }, [user, refreshPlan]);

  const selectedWeek = useMemo(
    () => weeks.find((w) => w.id === selectedWeekDoc) ?? null,
    [weeks, selectedWeekDoc],
  );

  async function onCreatePlan() {
    if (!user) return;
    setBusy(true);
    try {
      await createPlanDraft({
        coachId: user.uid,
        traineeId: params.uid,
        title: planTitle,
        weeksTotal,
      });
      await refreshPlan();
    } finally {
      setBusy(false);
    }
  }

  async function onUnlock(week: PlanWeek) {
    if (!planId) return;
    await unlockWeek(planId, week.id, week.weekIndex);
    await refreshPlan();
  }

  async function onSelectWeek(weekDocId: string) {
    if (!planId) return;
    setSelectedWeekDoc(weekDocId);
    const ws = await loadWorkouts(planId, weekDocId);
    setWorkouts(ws);
  }

  async function onAddWorkout() {
    if (!planId || !selectedWeekDoc || !newTitle.trim()) return;
    await addWorkout({
      planId,
      weekDocId: selectedWeekDoc,
      title: newTitle,
      kind: newKind,
      dayIndex: newDay,
    });
    setNewTitle("");
    const ws = await loadWorkouts(planId, selectedWeekDoc);
    setWorkouts(ws);
  }

  if (busy) {
    return (
      <main className="min-h-full grid place-items-center bg-slate-100 p-8">
        <p className="text-sm text-zinc-500">טוען...</p>
      </main>
    );
  }

  return (
    <main className="min-h-full bg-slate-100 p-4 sm:p-8">
      <div className="mx-auto max-w-6xl">
        <div className="mb-5 flex flex-wrap items-center justify-between gap-3">
          <h1 className="text-2xl font-bold">ניהול תכנית מתאמן</h1>
          <Link
            href={`/trainees/${params.uid}`}
            className="rounded-xl border border-zinc-300 bg-white px-3 py-2 text-sm hover:bg-zinc-50"
          >
            חזרה למתאמן
          </Link>
        </div>

        {!planId ? (
          <section className="rounded-2xl border border-zinc-200 bg-white p-4 shadow-sm">
            <h2 className="text-lg font-semibold">יצירת תכנית חדשה</h2>
            <div className="mt-3 grid gap-3 sm:grid-cols-2">
              <input
                value={planTitle}
                onChange={(e) => setPlanTitle(e.target.value)}
                className="rounded-xl border border-zinc-300 px-3 py-2 text-sm"
                placeholder="שם תכנית"
              />
              <input
                type="number"
                value={weeksTotal}
                min={4}
                max={52}
                onChange={(e) => setWeeksTotal(Number(e.target.value))}
                className="rounded-xl border border-zinc-300 px-3 py-2 text-sm"
              />
            </div>
            <button
              type="button"
              onClick={() => void onCreatePlan()}
              className="mt-4 rounded-xl bg-emerald-700 px-4 py-2.5 text-sm font-medium text-white hover:bg-emerald-600"
            >
              יצירת תכנית
            </button>
          </section>
        ) : (
          <div className="grid gap-4 lg:grid-cols-3">
            <section className="rounded-2xl border border-zinc-200 bg-white p-4 shadow-sm lg:col-span-1">
              <h2 className="text-lg font-semibold">{planTitle}</h2>
              <p className="mt-1 text-sm text-zinc-600">
                שבועות: {weeks.length} · פתוחים: {weeks.filter((w) => w.isOpen).length}
              </p>
              <div className="mt-4 space-y-2">
                {weeks.map((w) => (
                  <div
                    key={w.id}
                    className="rounded-xl border border-zinc-200 bg-zinc-50 p-3"
                  >
                    <div className="flex items-center justify-between gap-2">
                      <button
                        type="button"
                        onClick={() => void onSelectWeek(w.id)}
                        className="text-right text-sm font-medium hover:underline"
                      >
                        שבוע {w.weekIndex}
                      </button>
                      {w.isOpen ? (
                        <span className="rounded-lg bg-emerald-100 px-2 py-1 text-xs text-emerald-700">
                          פתוח
                        </span>
                      ) : (
                        <button
                          type="button"
                          onClick={() => void onUnlock(w)}
                          className="rounded-lg border border-emerald-300 px-2 py-1 text-xs text-emerald-700 hover:bg-emerald-50"
                        >
                          פתיחת שבוע
                        </button>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            </section>

            <section className="rounded-2xl border border-zinc-200 bg-white p-4 shadow-sm lg:col-span-2">
              <h2 className="text-lg font-semibold">
                אימונים לשבוע {selectedWeek?.weekIndex ?? "-"}
              </h2>
              <div className="mt-3 grid gap-2 sm:grid-cols-3">
                <input
                  value={newTitle}
                  onChange={(e) => setNewTitle(e.target.value)}
                  className="rounded-xl border border-zinc-300 px-3 py-2 text-sm"
                  placeholder="כותרת אימון"
                />
                <select
                  value={newKind}
                  onChange={(e) => setNewKind(e.target.value)}
                  className="rounded-xl border border-zinc-300 px-3 py-2 text-sm"
                >
                  <option value="run">Run</option>
                  <option value="strength">Strength</option>
                  <option value="mobility">Mobility</option>
                </select>
                <input
                  type="number"
                  value={newDay}
                  onChange={(e) => setNewDay(Number(e.target.value))}
                  min={0}
                  max={6}
                  className="rounded-xl border border-zinc-300 px-3 py-2 text-sm"
                  placeholder="dayIndex 0-6"
                />
              </div>
              <button
                type="button"
                onClick={() => void onAddWorkout()}
                disabled={!selectedWeekDoc}
                className="mt-3 rounded-xl bg-emerald-700 px-4 py-2.5 text-sm font-medium text-white hover:bg-emerald-600 disabled:bg-zinc-400"
              >
                הוספת אימון
              </button>

              <div className="mt-4 space-y-2">
                {workouts.length === 0 && (
                  <p className="rounded-xl border border-dashed border-zinc-300 p-3 text-sm text-zinc-600">
                    אין אימונים בשבוע הזה עדיין.
                  </p>
                )}
                {workouts.map((w) => (
                  <div
                    key={w.id}
                    className="rounded-xl border border-zinc-200 bg-zinc-50 p-3"
                  >
                    <div className="flex items-center justify-between">
                      <p className="font-medium">{w.title}</p>
                      <span className="text-xs text-zinc-600">{w.kind}</span>
                    </div>
                    <p className="mt-1 text-xs text-zinc-500">
                      dayIndex: {w.dayIndex} · status: {w.status}
                    </p>
                  </div>
                ))}
              </div>
            </section>
          </div>
        )}
      </div>
    </main>
  );
}
