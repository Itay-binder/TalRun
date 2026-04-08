"use client";

import Link from "next/link";
import { useEffect, useState } from "react";
import { useAuth } from "@/providers/auth-provider";
import {
  endCoachLink,
  loadCoachLink,
  loadLatestPlanForTrainee,
  loadTraineeProfile,
} from "@/lib/dashboard-service";
import type { CoachPlan, TraineeProfile } from "@/lib/dashboard-types";

export default function TraineeDetailsPage({
  params,
}: {
  params: { uid: string };
}) {
  const { user, role, loading, coachAllowed } = useAuth();
  const [profile, setProfile] = useState<TraineeProfile | null>(null);
  const [plan, setPlan] = useState<CoachPlan | null>(null);
  const [linkStatus, setLinkStatus] = useState<"active" | "ended" | "none">("none");
  const [busy, setBusy] = useState(true);

  const canUse = !!user && role === "coach" && coachAllowed;

  useEffect(() => {
    if (!canUse) return;
    void (async () => {
      setBusy(true);
      try {
        const [p, l, pl] = await Promise.all([
          loadTraineeProfile(params.uid),
          loadCoachLink(user.uid, params.uid),
          loadLatestPlanForTrainee(user.uid, params.uid),
        ]);
        setProfile(p);
        setLinkStatus(l?.status ?? "none");
        setPlan(pl);
      } finally {
        setBusy(false);
      }
    })();
  }, [canUse, params.uid, user]);

  async function onEndLink() {
    if (!user) return;
    await endCoachLink(user.uid, params.uid);
    setLinkStatus("ended");
  }

  if (loading || busy) {
    return <main className="min-h-screen grid place-items-center">Loading...</main>;
  }

  if (!canUse) {
    return (
      <main className="min-h-screen grid place-items-center bg-slate-100 p-6 text-center">
        <p>אין הרשאה לדף זה.</p>
      </main>
    );
  }

  return (
    <main className="min-h-screen bg-slate-100">
      <div className="mx-auto max-w-5xl px-4 py-6 sm:px-6 sm:py-10">
        <div className="mb-5 flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold">{profile?.displayName ?? "מתאמן"}</h1>
            <p className="text-sm text-zinc-600">{profile?.email ?? ""}</p>
          </div>
          <Link
            href="/trainees"
            className="rounded-xl border border-zinc-300 bg-white px-3 py-2 text-sm hover:bg-zinc-50"
          >
            חזרה לרשימה
          </Link>
        </div>

        <div className="grid gap-4 lg:grid-cols-3">
          <section className="rounded-2xl border border-zinc-200 bg-white p-4 shadow-sm lg:col-span-2">
            <h2 className="text-lg font-semibold">ניהול תכנית</h2>
            <p className="mt-1 text-sm text-zinc-600">יצירה, עריכה ופתיחת שבועות.</p>
            <div className="mt-4 space-y-3">
              <div className="rounded-xl bg-zinc-50 p-3">
                <p className="text-sm text-zinc-600">סטטוס שיוך</p>
                <p className="font-semibold">
                  {linkStatus === "active"
                    ? "פעיל"
                    : linkStatus === "ended"
                      ? "הסתיים"
                      : "לא קיים"}
                </p>
              </div>
              <div className="rounded-xl bg-zinc-50 p-3">
                <p className="text-sm text-zinc-600">תכנית</p>
                <p className="font-semibold">{plan?.title ?? "אין תכנית"}</p>
                {plan && (
                  <p className="mt-1 text-sm text-zinc-600">
                    שבוע פתוח נוכחי: {plan.currentOpenWeek} / {plan.weeksTotal}
                  </p>
                )}
              </div>
              <Link
                href={`/trainees/${params.uid}/plan`}
                className="inline-block rounded-xl bg-emerald-700 px-4 py-2.5 text-sm font-medium text-white hover:bg-emerald-600"
              >
                כניסה למסך ניהול תכנית
              </Link>
            </div>
          </section>

          <section className="rounded-2xl border border-zinc-200 bg-white p-4 shadow-sm">
            <h2 className="text-lg font-semibold">פעולות מהירות</h2>
            <div className="mt-3 space-y-2">
              <button
                onClick={() => void onEndLink()}
                className="w-full rounded-xl border border-rose-300 px-3 py-2 text-sm text-rose-700 hover:bg-rose-50"
                disabled={linkStatus !== "active"}
              >
                סיום שיוך מאמן-מתאמן
              </button>
              <p className="text-xs text-zinc-500">
                המתאמן ימשיך להשתמש באפליקציה גם אחרי סיום שיוך.
              </p>
            </div>
          </section>
        </div>
      </div>
    </main>
  );
}
