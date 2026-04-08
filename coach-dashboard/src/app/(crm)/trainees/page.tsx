"use client";

import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import { useAuth } from "@/providers/auth-provider";
import { createCoachInvite, loadCoachTrainees } from "@/lib/dashboard-service";
import type { TraineeProfile } from "@/lib/dashboard-types";

export default function TraineesPage() {
  const router = useRouter();
  const { user } = useAuth();
  const [trainees, setTrainees] = useState<TraineeProfile[]>([]);
  const [inviteEmail, setInviteEmail] = useState("");
  const [inviteCode, setInviteCode] = useState<string | null>(null);
  const [busy, setBusy] = useState(true);

  useEffect(() => {
    if (!user) return;
    void (async () => {
      setBusy(true);
      try {
        const next = await loadCoachTrainees(user.uid);
        setTrainees(next);
      } finally {
        setBusy(false);
      }
    })();
  }, [user]);

  async function onCreateInvite() {
    if (!user || !inviteEmail.trim()) return;
    setBusy(true);
    try {
      const code = await createCoachInvite(user.uid, inviteEmail);
      setInviteCode(code);
      setInviteEmail("");
    } finally {
      setBusy(false);
    }
  }

  return (
    <main className="min-h-full bg-slate-100 p-4 sm:p-8">
      <div className="mx-auto max-w-6xl">
        <div className="mb-6">
          <h1 className="text-2xl font-bold sm:text-3xl">מתאמנים</h1>
          <p className="mt-1 text-sm text-zinc-600">
            טבלת כל המתאמנים; לחיצה על שורה תפתח את דף המתאמן.
          </p>
        </div>

        <div className="grid gap-4 lg:grid-cols-3">
          <section className="overflow-hidden rounded-2xl border border-zinc-200 bg-white shadow-sm lg:col-span-2">
            <div className="border-b border-zinc-100 px-4 py-3">
              <h2 className="text-lg font-semibold">רשימת מתאמנים</h2>
            </div>
            <div className="overflow-x-auto">
              {busy && trainees.length === 0 ? (
                <p className="p-6 text-sm text-zinc-500">טוען מתאמנים...</p>
              ) : trainees.length === 0 ? (
                <div className="p-6 text-sm text-zinc-600">
                  אין עדיין מתאמנים משויכים. צור הזמנה מהעמודה הימנית.
                </div>
              ) : (
                <table className="w-full min-w-[480px] text-right text-sm">
                  <thead>
                    <tr className="border-b border-zinc-200 bg-zinc-50 text-zinc-600">
                      <th className="px-4 py-3 font-medium">שם</th>
                      <th className="px-4 py-3 font-medium">אימייל</th>
                      <th className="px-4 py-3 font-medium">תכנית</th>
                    </tr>
                  </thead>
                  <tbody>
                    {trainees.map((t) => (
                      <tr
                        key={t.uid}
                        onClick={() => router.push(`/trainees/${t.uid}`)}
                        className="cursor-pointer border-b border-zinc-100 transition-colors last:border-0 hover:bg-emerald-50/60"
                      >
                        <td className="px-4 py-3 font-semibold text-zinc-900">
                          {t.displayName}
                        </td>
                        <td className="px-4 py-3 text-zinc-600">{t.email || "—"}</td>
                        <td className="px-4 py-3">
                          <span
                            className={`inline-block rounded-lg px-2 py-1 text-xs ${
                              t.activePlanId
                                ? "bg-emerald-100 text-emerald-800"
                                : "bg-zinc-100 text-zinc-600"
                            }`}
                          >
                            {t.activePlanId ? "תכנית פעילה" : "ללא תכנית"}
                          </span>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              )}
            </div>
          </section>

          <section className="rounded-2xl border border-zinc-200 bg-white p-4 shadow-sm">
            <h2 className="text-lg font-semibold">הזמנת מתאמן</h2>
            <p className="mt-1 text-sm text-zinc-600">
              הזן אימייל מתאמן וקבל קוד הזמנה.
            </p>
            <div className="mt-4 space-y-3">
              <input
                type="email"
                value={inviteEmail}
                onChange={(e) => setInviteEmail(e.target.value)}
                placeholder="trainee@email.com"
                className="w-full rounded-xl border border-zinc-300 px-3 py-2 text-sm outline-none ring-emerald-500 focus:ring"
              />
              <button
                type="button"
                onClick={() => void onCreateInvite()}
                disabled={busy || !inviteEmail.trim()}
                className="w-full rounded-xl bg-emerald-700 px-4 py-2.5 text-sm font-medium text-white hover:bg-emerald-600 disabled:bg-zinc-400"
              >
                יצירת הזמנה
              </button>
              {inviteCode && (
                <div className="rounded-xl border border-emerald-300 bg-emerald-50 p-3 text-sm">
                  <p className="font-medium">קוד הזמנה:</p>
                  <p className="mt-1 font-mono text-base">{inviteCode}</p>
                </div>
              )}
            </div>
          </section>
        </div>
      </div>
    </main>
  );
}
