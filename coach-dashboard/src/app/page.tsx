"use client";

import Link from "next/link";
import { useAuth } from "@/providers/auth-provider";

export default function HomePage() {
  const { user, role, loading, firebaseConfigured, loginWithGoogle, logout } =
    useAuth();

  if (loading) {
    return (
      <main className="min-h-screen grid place-items-center bg-zinc-50">
        <p className="text-zinc-600">Loading dashboard...</p>
      </main>
    );
  }

  return (
    <main className="min-h-screen bg-zinc-50">
      <div className="mx-auto max-w-3xl px-6 py-12">
        <h1 className="text-3xl font-bold tracking-tight">TalRun Coach Dashboard</h1>
        <p className="mt-2 text-zinc-600">
          Google login for coaches. Next step: trainees list, plan builder, weekly unlock.
        </p>

        <section className="mt-8 rounded-xl border border-zinc-200 bg-white p-6 shadow-sm">
          {!firebaseConfigured && (
            <div className="mb-5 rounded-lg border border-amber-300 bg-amber-50 p-3 text-sm text-amber-800">
              Firebase Web env vars are missing. Set them in
              <code className="mx-1 rounded bg-amber-100 px-1 py-0.5">
                coach-dashboard/.env.local
              </code>
              (and Vercel env settings).
            </div>
          )}
          {!user ? (
            <>
              <h2 className="text-lg font-semibold">Sign in</h2>
              <p className="mt-1 text-sm text-zinc-600">
                Sign in with Google. A first-time user is created as role = coach.
              </p>
              <button
                onClick={() => void loginWithGoogle()}
                disabled={!firebaseConfigured}
                className="mt-4 rounded-lg bg-black px-4 py-2 text-white hover:bg-zinc-800"
              >
                Continue with Google
              </button>
            </>
          ) : (
            <div className="space-y-4">
              <div>
                <h2 className="text-lg font-semibold">Signed in</h2>
                <p className="text-sm text-zinc-600">
                  {user.email} · role: <strong>{role ?? "unknown"}</strong>
                </p>
              </div>
              <div className="flex gap-3">
                <Link
                  href="/trainees"
                  className="rounded-lg bg-emerald-700 px-4 py-2 text-white hover:bg-emerald-600"
                >
                  Open trainees dashboard
                </Link>
                <button
                  onClick={() => void logout()}
                  className="rounded-lg border border-zinc-300 px-4 py-2 hover:bg-zinc-100"
                >
                  Log out
                </button>
              </div>
            </div>
          )}
        </section>
      </div>
    </main>
  );
}
