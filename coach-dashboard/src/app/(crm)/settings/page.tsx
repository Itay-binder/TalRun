"use client";

import { useAuth } from "@/providers/auth-provider";

export default function SettingsPage() {
  const { user, firebaseConfigured } = useAuth();

  return (
    <main className="min-h-full p-4 sm:p-8">
      <div className="mx-auto max-w-2xl">
        <h1 className="text-2xl font-bold tracking-tight sm:text-3xl">הגדרות</h1>
        <p className="mt-1 text-sm text-zinc-600">חשבון מאמן והגדרות מערכת בסיסיות.</p>

        <section className="mt-8 rounded-2xl border border-zinc-200 bg-white p-5 shadow-sm">
          <h2 className="text-lg font-semibold">חשבון</h2>
          <dl className="mt-4 space-y-3 text-sm">
            <div>
              <dt className="text-zinc-500">אימייל</dt>
              <dd className="font-medium text-zinc-900">{user?.email ?? "—"}</dd>
            </div>
            <div>
              <dt className="text-zinc-500">שם תצוגה</dt>
              <dd className="font-medium text-zinc-900">{user?.displayName || "—"}</dd>
            </div>
          </dl>
        </section>

        <section className="mt-4 rounded-2xl border border-zinc-200 bg-white p-5 shadow-sm">
          <h2 className="text-lg font-semibold">מערכת</h2>
          <p className="mt-2 text-sm text-zinc-600">
            Firebase:{" "}
            <span className={firebaseConfigured ? "text-emerald-700" : "text-rose-600"}>
              {firebaseConfigured ? "מוגדר" : "חסרות משתני סביבה"}
            </span>
          </p>
          {!firebaseConfigured && (
            <p className="mt-2 text-xs text-zinc-500">
              הוסף את המשתנים ב־<code className="rounded bg-zinc-100 px-1">.env.local</code> וב־Vercel
              לפני דיפלוי.
            </p>
          )}
        </section>
      </div>
    </main>
  );
}
