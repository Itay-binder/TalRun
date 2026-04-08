"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { useAuth } from "@/providers/auth-provider";
import { createCoachInvite, loadCoachTrainees } from "@/lib/dashboard-service";
import type { TraineeProfile } from "@/lib/dashboard-types";

export default function TraineesPage() {
  const { user, role, loading, coachAllowed } = useAuth();
  const [trainees, setTrainees] = useState<TraineeProfile[]>([]);
  const [inviteEmail, setInviteEmail] = useState("");
  const [inviteCode, setInviteCode] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);
  const canUse = !!user && role === "coach" && coachAllowed;

  useEffect(() => {
    if (!canUse) return;
    void (async () => {
      setBusy(true);
      try {
        const next = await loadCoachTrainees(user.uid);
        setTrainees(next);
      } finally {
        setBusy(false);
      }
    })();
  }, [canUse, user]);

  if (loading) {
    return <main className="min-h-screen grid place-items-center">Loading...</main>;
  }

  if (!user) {
    return (
      <main className="min-h-screen grid place-items-center bg-zinc-50 p-6 text-center">
        <div>
          <p className="text-zinc-700">You must sign in first.</p>
          <Link href="/" className="mt-3 inline-block text-emerald-700 underline">
            Back to login
          </Link>
        </div>
      </main>
    );
  }

  if (role !== "coach" || !coachAllowed) {
    return (
      <main className="min-h-screen grid place-items-center bg-zinc-50 p-6 text-center">
        <div>
          <h1 className="text-2xl font-bold">Access denied</h1>
          <p className="mt-2 text-zinc-600">
            This dashboard is only for coach accounts.
          </p>
          <Link href="/" className="mt-3 inline-block text-emerald-700 underline">
            Back
          </Link>
        </div>
      </main>
    );
  }

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
    <main className="min-h-screen bg-slate-100">
      <div className="mx-auto max-w-5xl px-4 py-6 sm:px-6 sm:py-10">
        <div className="mb-5 flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold sm:text-3xl">המתאמנים שלי</h1>
            <p className="mt-1 text-sm text-zinc-600">
              הזמנות, שיוך מתאמנים וניהול תכניות שבועיות.
            </p>
          </div>
          <Link
            href="/"
            className="rounded-xl border border-zinc-300 bg-white px-3 py-2 text-sm hover:bg-zinc-50"
          >
            דף ראשי
          </Link>
        </div>

        <div className="grid gap-4 lg:grid-cols-3">
          <section className="rounded-2xl border border-zinc-200 bg-white p-4 shadow-sm lg:col-span-2">
            <h2 className="text-lg font-semibold">רשימת מתאמנים</h2>
            <p className="mt-1 text-sm text-zinc-600">
              לחיצה על מתאמן תפתח דשבורד אישי.
            </p>
            <div className="mt-4 space-y-3">
              {busy && trainees.length === 0 && (
                <p className="text-sm text-zinc-500">טוען מתאמנים...</p>
              )}
              {!busy && trainees.length === 0 && (
                <div className="rounded-xl border border-dashed border-zinc-300 p-4 text-sm text-zinc-600">
                  אין עדיין מתאמנים משויכים. צור הזמנה בצד ימין.
                </div>
              )}
              {trainees.map((t) => (
                <Link
                  key={t.uid}
                  href={`/trainees/${t.uid}`}
                  className="block rounded-xl border border-zinc-200 bg-zinc-50 p-3 hover:border-emerald-300 hover:bg-emerald-50"
                >
                  <div className="flex items-center justify-between gap-3">
                    <div className="min-w-0">
                      <p className="truncate font-semibold">{t.displayName}</p>
                      <p className="truncate text-sm text-zinc-600">{t.email}</p>
                    </div>
                    <span className="rounded-lg bg-white px-2 py-1 text-xs text-zinc-600">
                      {t.activePlanId ? "תכנית פעילה" : "ללא תכנית"}
                    </span>
                  </div>
                </Link>
              ))}
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
