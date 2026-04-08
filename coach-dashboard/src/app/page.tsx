"use client";

import { useRouter } from "next/navigation";
import { useEffect } from "react";
import { useAuth } from "@/providers/auth-provider";

export default function HomePage() {
  const router = useRouter();
  const {
    user,
    loading,
    firebaseConfigured,
    coachAllowed,
    accessDeniedMessage,
    loginWithGoogle,
    logout,
  } = useAuth();

  useEffect(() => {
    if (loading || !user || !coachAllowed) return;
    router.replace("/dashboard");
  }, [loading, user, coachAllowed, router]);

  if (loading) {
    return (
      <main className="min-h-screen grid place-items-center bg-zinc-50">
        <p className="text-zinc-600">בודק הרשאות...</p>
      </main>
    );
  }

  return (
    <main className="min-h-screen bg-slate-100">
      <div className="mx-auto max-w-4xl px-6 py-12">
        <h1 className="text-3xl font-bold tracking-tight">TalRun - ממשק מאמנים</h1>
        <p className="mt-2 text-zinc-600">
          התחברות Google והרשאת מאמן בלבד. לאחר אימות תועבר אוטומטית לדשבורד.
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
                הכניסה פתוחה רק למאמנים שמופיעים ב־<code className="text-xs">coach_whitelist</code>.
              </p>
              <button
                onClick={() => void loginWithGoogle()}
                disabled={!firebaseConfigured}
                className="mt-4 rounded-xl bg-black px-5 py-2.5 text-white hover:bg-zinc-800 disabled:bg-zinc-400"
              >
                כניסה עם Google
              </button>
            </>
          ) : !coachAllowed ? (
            <div className="space-y-3">
              <h2 className="text-lg font-semibold">אין גישה</h2>
              <p className="text-sm text-zinc-600">
                החשבון מחובר אך לא כמאמן מורשה. אם לדעתך זו טעות, פנה לאדמין.
              </p>
              <button
                type="button"
                onClick={() => void logout()}
                className="rounded-xl border border-zinc-300 px-5 py-2.5 text-sm hover:bg-zinc-50"
              >
                התנתק
              </button>
            </div>
          ) : (
            <p className="text-sm text-zinc-600">מעביר לדשבורד...</p>
          )}
        </section>
      </div>
    </main>
  );
}
