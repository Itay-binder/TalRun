"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { useEffect } from "react";
import { useAuth } from "@/providers/auth-provider";

const nav = [
  { href: "/dashboard", label: "דשבורד מאמן" },
  { href: "/trainees", label: "מתאמנים" },
  { href: "/settings", label: "הגדרות" },
];

export function CrmShell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const router = useRouter();
  const { user, role, loading, coachAllowed, logout } = useAuth();

  useEffect(() => {
    if (loading) return;
    if (!user) {
      router.replace("/");
    }
  }, [loading, user, router]);

  if (loading) {
    return (
      <div className="min-h-screen grid place-items-center bg-slate-100">
        <p className="text-zinc-600">טוען...</p>
      </div>
    );
  }

  if (!user) {
    return (
      <div className="min-h-screen grid place-items-center bg-slate-100">
        <p className="text-zinc-600">מעביר לכניסה...</p>
      </div>
    );
  }

  if (role !== "coach" || !coachAllowed) {
    return (
      <div className="min-h-screen grid place-items-center bg-slate-100 p-6 text-center">
        <div>
          <h1 className="text-2xl font-bold text-zinc-900">אין גישה</h1>
          <p className="mt-2 text-zinc-600">הממשק מיועד לחשבונות מאמן בלבד.</p>
          <Link href="/" className="mt-4 inline-block text-emerald-700 underline">
            חזרה לכניסה
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="flex min-h-screen bg-slate-100">
      <aside className="flex w-56 shrink-0 flex-col border-l border-zinc-200 bg-white shadow-sm">
        <div className="border-b border-zinc-100 px-4 py-4">
          <p className="text-xs font-medium uppercase tracking-wide text-zinc-400">TalRun CRM</p>
          <p className="mt-1 truncate text-sm font-semibold text-zinc-900">
            {user.displayName || user.email || "מאמן"}
          </p>
          <p className="truncate text-xs text-zinc-500">{user.email}</p>
        </div>
        <nav className="flex flex-1 flex-col gap-0.5 p-2">
          {nav.map((item) => {
            const active =
              item.href === "/dashboard"
                ? pathname === "/dashboard"
                : pathname === item.href || pathname.startsWith(`${item.href}/`);
            return (
              <Link
                key={item.href}
                href={item.href}
                className={`rounded-xl px-3 py-2.5 text-sm font-medium transition-colors ${
                  active
                    ? "bg-emerald-50 text-emerald-800"
                    : "text-zinc-700 hover:bg-zinc-50"
                }`}
              >
                {item.label}
              </Link>
            );
          })}
        </nav>
        <div className="border-t border-zinc-100 p-2">
          <button
            type="button"
            onClick={() => void logout()}
            className="w-full rounded-xl px-3 py-2.5 text-sm text-zinc-600 hover:bg-zinc-50"
          >
            התנתק
          </button>
        </div>
      </aside>
      <div className="min-w-0 flex-1">{children}</div>
    </div>
  );
}
