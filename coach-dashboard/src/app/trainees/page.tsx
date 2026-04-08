"use client";

import Link from "next/link";
import { useAuth } from "@/providers/auth-provider";

export default function TraineesPage() {
  const { user, role, loading } = useAuth();

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

  if (role !== "coach") {
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

  return (
    <main className="min-h-screen bg-zinc-50">
      <div className="mx-auto max-w-5xl px-6 py-10">
        <h1 className="text-3xl font-bold">Trainees</h1>
        <p className="mt-2 text-zinc-600">
          MVP coach area. Next step: load linked trainees from `coach_trainees`.
        </p>

        <div className="mt-8 rounded-xl border border-dashed border-zinc-300 bg-white p-8">
          <p className="font-medium">Coming soon:</p>
          <ul className="mt-3 list-disc space-y-2 pl-5 text-sm text-zinc-700">
            <li>Trainee list + invite flow</li>
            <li>Create/edit full plan per trainee</li>
            <li>Unlock weekly plan button</li>
            <li>Performance stats dashboard</li>
          </ul>
        </div>
      </div>
    </main>
  );
}
