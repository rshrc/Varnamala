"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { GoogleAuthProvider, signInWithPopup } from "firebase/auth";
import { firebaseAuth, isFirebaseClientConfigured } from "@/services/firebase/client";

export function GoogleSignIn() {
  const router = useRouter();
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);
  async function signIn(): Promise<void> {
    setBusy(true); setError(null);
    try {
      const credential = await signInWithPopup(firebaseAuth(), new GoogleAuthProvider());
      const response = await fetch("/api/session", { method: "POST", headers: { "content-type": "application/json" }, body: JSON.stringify({ idToken: await credential.user.getIdToken(true) }) });
      const data: unknown = await response.json();
      if (!response.ok) throw new Error(typeof data === "object" && data && "error" in data ? String(data.error) : "Sign-in failed.");
      router.push("/dashboard"); router.refresh();
    } catch (caught) { setError(caught instanceof Error ? caught.message : "Sign-in failed."); }
    finally { setBusy(false); }
  }
  return <div><button type="button" onClick={signIn} disabled={busy || !isFirebaseClientConfigured()} className="focus-ring flex h-11 w-full items-center justify-center gap-3 rounded-lg bg-ink px-5 text-sm font-semibold text-white hover:bg-slate-800 disabled:cursor-not-allowed disabled:opacity-50"><span className="grid size-5 place-items-center rounded-full bg-white text-xs font-bold text-[#4285f4]">G</span>{busy ? "Signing in…" : "Continue with Google"}</button>{error && <p className="mt-3 text-sm text-red-600" role="alert">{error}</p>}{!isFirebaseClientConfigured() && <p className="mt-3 text-xs leading-5 text-muted">Add the Firebase browser variables from <code className="rounded bg-slate-100 px-1">env.example</code> to enable sign-in.</p>}</div>;
}
