"use client";

import Link from "next/link";
import { useAuth } from "@/providers/auth-provider";

export default function HomePage() {
  const {
    user,
    role,
    loading,
    firebaseConfigured,
    coachAllowed,
    accessDeniedMessage,
    loginWithGoogle,
    logout,
  } = useAuth();

  if (loading) {
    return (
      <main className="min-h-screen grid place-items-center bg-zinc-50">
        <p className="text-zinc-600">Loading dashboard...</p>
      </main>
    );
  }

  return (
    <main className="min-h-screen bg-slate-100">
      <div className="mx-auto max-w-4xl px-6 py-12">
        <h1 className="text-3xl font-bold tracking-tight">TalRun - ממשק מאמנים</h1>
        <p className="mt-2 text-zinc-600">
          התחברות Google והרשאת coach בלבד. לאחר כניסה, מעבר לדשבורד האישי.
        </p>

        <section className="mt-8 rounded-2xl border border-zinc-200 bg-white p-8 shadow-sm">
          {!firebaseConfigured && (
            <div className="mb-5 rounded-lg border border-amber-300 bg-amber-50 p-3 text-sm text-amber-800">
              Firebase Web env vars are missing. Set them in
              <code className="mx-1 rounded bg-amber-100 px-1 py-0.5">
                coach-dashboard/.env.local
              </code>
              (and Vercel env settings).
            </div>
          )}
          {accessDeniedMessage && (
            <div className="mb-5 rounded-lg border border-rose-300 bg-rose-50 p-3 text-sm text-rose-800">
              {accessDeniedMessage}
            </div>
          )}
          {!user ? (
            <>
              <h2 className="text-lg font-semibold">כניסת מאמן</h2>
              <p className="mt-1 text-sm text-zinc-600">
                הכניסה פתוחה רק למאמנים שמופיעים ב-`coach_whitelist`.
              </p>
              <button
                onClick={() => void loginWithGoogle()}
                disabled={!firebaseConfigured}
                className="mt-4 rounded-xl bg-black px-5 py-2.5 text-white hover:bg-zinc-800 disabled:bg-zinc-400"
              >
                כניסה עם Google
              </button>
            </>
          ) : (
            <div className="space-y-4">
              <div>
                <h2 className="text-lg font-semibold">מחובר כעת</h2>
                <p className="text-sm text-zinc-600">
                  {user.email} · role: <strong>{role ?? "unknown"}</strong>{" "}
                  {coachAllowed ? "✅" : "⛔"}
                </p>
              </div>
              <div className="flex gap-3">
                <Link
                  href="/trainees"
                  className="rounded-xl bg-emerald-700 px-5 py-2.5 text-white hover:bg-emerald-600"
                >
                  כניסה לדשבורד מאמן
                </Link>
                <button
                  onClick={() => void logout()}
                  className="rounded-xl border border-zinc-300 px-5 py-2.5 hover:bg-zinc-100"
                >
                  התנתק
                </button>
              </div>
            </div>
          )}
        </section>
      </div>
    </main>
  );
}
