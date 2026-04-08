"use client";

import {
  onAuthStateChanged,
  signInWithPopup,
  signOut,
  type User,
} from "firebase/auth";
import {
  doc,
  getDoc,
  serverTimestamp,
  setDoc,
} from "firebase/firestore";
import { createContext, useContext, useEffect, useMemo, useState } from "react";
import { auth, db, firebaseConfigured, googleProvider } from "@/lib/firebase";

type Role = "coach" | "trainee" | null;

type AuthContextValue = {
  user: User | null;
  role: Role;
  loading: boolean;
  firebaseConfigured: boolean;
  loginWithGoogle: () => Promise<void>;
  logout: () => Promise<void>;
};

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [role, setRole] = useState<Role>(null);
  const [loading, setLoading] = useState(firebaseConfigured);

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
      } else {
        const nextRole = (snap.data().role as Role) ?? "coach";
        setRole(nextRole);
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
    [user, role, loading],
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
