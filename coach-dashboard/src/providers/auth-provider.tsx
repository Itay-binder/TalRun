"use client";

import {
  onAuthStateChanged,
  signInWithPopup,
  signOut,
  type User,
} from "firebase/auth";
import {
  collection,
  doc,
  getDoc,
  getDocs,
  query,
  serverTimestamp,
  setDoc,
  where,
} from "firebase/firestore";
import { createContext, useContext, useEffect, useMemo, useState } from "react";
import { auth, db, firebaseConfigured, googleProvider } from "@/lib/firebase";

type Role = "coach" | "trainee" | null;

type AuthContextValue = {
  user: User | null;
  role: Role;
  loading: boolean;
  firebaseConfigured: boolean;
  coachAllowed: boolean;
  accessDeniedMessage: string | null;
  loginWithGoogle: () => Promise<void>;
  logout: () => Promise<void>;
};

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [role, setRole] = useState<Role>(null);
  const [loading, setLoading] = useState(firebaseConfigured);
  const [coachAllowed, setCoachAllowed] = useState(false);
  const [accessDeniedMessage, setAccessDeniedMessage] = useState<string | null>(
    null,
  );

  useEffect(() => {
    if (!firebaseConfigured || !auth || !db) {
      return;
    }

    const authClient = auth;
    const dbClient = db;

    const unsub = onAuthStateChanged(authClient, async (nextUser) => {
      setUser(nextUser);
      if (!nextUser) {
        setRole(null);
        setCoachAllowed(false);
        setAccessDeniedMessage(null);
        setLoading(false);
        return;
      }

      const wlByUid = await getDoc(doc(dbClient, "coach_whitelist", nextUser.uid));
      let allowed = wlByUid.exists();
      if (!allowed && nextUser.email) {
        const q = query(
          collection(dbClient, "coach_whitelist"),
          where("emailLower", "==", nextUser.email.toLowerCase()),
        );
        const qs = await getDocs(q);
        allowed = !qs.empty;
      }
      if (!allowed) {
        setRole(null);
        setCoachAllowed(false);
        setAccessDeniedMessage(
          "החשבון לא מורשה כמאמן. פנה לאדמין כדי להצטרף ל-whitelist.",
        );
        await signOut(authClient);
        setLoading(false);
        return;
      }

      const userRef = doc(dbClient, "users", nextUser.uid);
      const snap = await getDoc(userRef);

      if (!snap.exists()) {
        await setDoc(userRef, {
          role: "coach",
          email: nextUser.email ?? "",
          displayName: nextUser.displayName ?? "",
          photoUrl: nextUser.photoURL ?? "",
          createdAt: serverTimestamp(),
          updatedAt: serverTimestamp(),
        });
        setRole("coach");
        setCoachAllowed(true);
        setAccessDeniedMessage(null);
      } else {
        const nextRole = (snap.data().role as Role) ?? null;
        setRole(nextRole);
        setCoachAllowed(nextRole == "coach");
        setAccessDeniedMessage(
          nextRole == "coach"
              ? null
              : "החשבון קיים אך role אינו coach. עדכן users/{uid}.role ל-coach.",
        );
      }
      setLoading(false);
    });

    return () => unsub();
  }, []);

  const value = useMemo<AuthContextValue>(
    () => ({
      user,
      role,
      loading,
      firebaseConfigured,
      coachAllowed,
      accessDeniedMessage,
      loginWithGoogle: async () => {
        if (!auth || !googleProvider) {
          throw new Error("Firebase config is missing.");
        }
        await signInWithPopup(auth, googleProvider);
      },
      logout: async () => {
        if (!auth) return;
        await signOut(auth);
      },
    }),
    [user, role, loading, coachAllowed, accessDeniedMessage],
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) {
    throw new Error("useAuth must be used inside AuthProvider");
  }
  return ctx;
}
