"use client";

import Link from "next/link";
import { useEffect, useState } from "react";
import { useAuth } from "@/providers/auth-provider";
import { loadCoachInviteStats, loadCoachTrainees } from "@/lib/dashboard-service";
import type { TraineeProfile } from "@/lib/dashboard-types";

export default function CoachDashboardPage() {
  const { user } = useAuth();
  const [trainees, setTrainees] = useState<TraineeProfile[]>([]);
  const [pendingInvites, setPendingInvites] = useState(0);
  const [busy, setBusy] = useState(true);

  useEffect(() => {
    if (!user) return;
    void (async () => {
      setBusy(true);
      try {
        const [list, invites] = await Promise.all([
          loadCoachTrainees(user.uid),
          loadCoachInviteStats(user.uid),
        ]);
        setTrainees(list);
        setPendingInvites(invites.pending);
      } finally {
        setBusy(false);
      }
    })();
  }, [user]);

  const withPlan = trainees.filter((t) => t.activePlanId).length;
  const withoutPlan = trainees.length - withPlan;

  return (
    <main className="min-h-full p-4 sm:p-8">
      <div className="mx-auto max-w-5xl">
        <h1 className="text-2xl font-bold tracking-tight sm:text-3xl">דשבורד מאמן</h1>
        <p className="mt-1 text-sm text-zinc-600">
          סיכום מתאמנים, הזמנות פתוחות ומשימות מהירות.
        </p>

        {busy ? (
          <p className="mt-8 text-sm text-zinc-500">טוען נתונים...</p>
        ) : (
          <div className="mt-8 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
            <section className="rounded-2xl border border-zinc-200 bg-white p-4 shadow-sm">
              <p className="text-sm text-zinc-500">סה״כ מתאמנים פעילים</p>
              <p className="mt-1 text-3xl font-bold text-zinc-900">{trainees.length}</p>
            </section>
            <section className="rounded-2xl border border-zinc-200 bg-white p-4 shadow-sm">
              <p className="text-sm text-zinc-500">עם תכנית פעילה</p>
              <p className="mt-1 text-3xl font-bold text-emerald-800">{withPlan}</p>
            </section>
            <section className="rounded-2xl border border-zinc-200 bg-white p-4 shadow-sm">
              <p className="text-sm text-zinc-500">ללא תכנית</p>
              <p className="mt-1 text-3xl font-bold text-amber-700">{withoutPlan}</p>
            </section>
            <section className="rounded-2xl border border-zinc-200 bg-white p-4 shadow-sm">
              <p className="text-sm text-zinc-500">הזמנות ממתינות</p>
              <p className="mt-1 text-3xl font-bold text-zinc-900">{pendingInvites}</p>
            </section>
          </div>
        )}

        <div className="mt-8 grid gap-4 lg:grid-cols-2">
          <section className="rounded-2xl border border-zinc-200 bg-white p-5 shadow-sm">
            <h2 className="text-lg font-semibold">משימות ופעולות</h2>
            <ul className="mt-4 space-y-3 text-sm text-zinc-700">
              {withoutPlan > 0 && (
                <li className="flex items-start gap-2">
                  <span className="mt-0.5 text-amber-600">•</span>
                  <span>
                    יש {withoutPlan} מתאמנים בלי תכנית —{" "}
                    <Link href="/trainees" className="font-medium text-emerald-700 underline">
                      עבור לרשימת מתאמנים
                    </Link>
                  </span>
                </li>
              )}
              {pendingInvites > 0 && (
                <li className="flex items-start gap-2">
                  <span className="mt-0.5 text-zinc-400">•</span>
                  <span>{pendingInvites} הזמנות ממתינות לאישור מתאמן.</span>
                </li>
              )}
              {trainees.length === 0 && !busy && (
                <li className="flex items-start gap-2">
                  <span className="mt-0.5 text-emerald-600">•</span>
                  <span>
                    התחל עם הזמנת מתאמן ראשון —{" "}
                    <Link href="/trainees" className="font-medium text-emerald-700 underline">
                      מתאמנים
                    </Link>
                    .
                  </span>
                </li>
              )}
              {withoutPlan === 0 && trainees.length > 0 && pendingInvites === 0 && (
                <li className="text-zinc-500">אין משימות דחופות כרגע.</li>
              )}
            </ul>
          </section>

          <section className="rounded-2xl border border-zinc-200 bg-white p-5 shadow-sm">
            <h2 className="text-lg font-semibold">נתונים חשובים</h2>
            <p className="mt-2 text-sm text-zinc-600">
              אחוז המתאמנים עם תכנית פעילה עוזר לעקוב אחרי מעורבות.
            </p>
            <p className="mt-4 text-2xl font-bold text-zinc-900">
              {trainees.length === 0
                ? "—"
                : `${Math.round((withPlan / trainees.length) * 100)}%`}
            </p>
            <p className="text-xs text-zinc-500">מתאמנים עם תכנית מתוך הסה״כ</p>
          </section>
        </div>
      </div>
    </main>
  );
}
