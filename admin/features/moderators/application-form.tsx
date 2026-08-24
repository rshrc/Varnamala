"use client";

import { useState, type FormEvent } from "react";
import { CheckCircle2, FileUp } from "lucide-react";
import { GoogleAuthProvider, signInWithPopup } from "firebase/auth";
import { languages } from "@/logic/courses/catalog";
import { firebaseAuth, isFirebaseClientConfigured } from "@/services/firebase/client";

export function ApplicationForm() {
  const [submitted, setSubmitted] = useState(false);
  const [idToken, setIdToken] = useState<string | null>(null);
  const [account, setAccount] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  async function connectGoogle(): Promise<void> {
    setBusy(true); setError(null);
    try {
      const credential = await signInWithPopup(firebaseAuth(), new GoogleAuthProvider());
      setIdToken(await credential.user.getIdToken(true));
      setAccount(credential.user.email ?? credential.user.displayName ?? "Google account");
    } catch (caught) { setError(caught instanceof Error ? caught.message : "Google sign-in failed."); }
    finally { setBusy(false); }
  }
  async function submit(event: FormEvent<HTMLFormElement>): Promise<void> {
    event.preventDefault(); setBusy(true); setError(null);
    try {
      if (isFirebaseClientConfigured() && !idToken) throw new Error("Connect your Google account before submitting.");
      const response = await fetch("/api/applications", { method: "POST", headers: idToken ? { authorization: `Bearer ${idToken}` } : {}, body: new FormData(event.currentTarget) });
      const data: unknown = await response.json();
      if (!response.ok) throw new Error(typeof data === "object" && data && "error" in data ? String(data.error) : "Could not submit application.");
      setSubmitted(true);
    } catch (caught) { setError(caught instanceof Error ? caught.message : "Could not submit application."); }
    finally { setBusy(false); }
  }
  if (submitted) return <div className="card p-8 text-center"><CheckCircle2 className="mx-auto size-10 text-emerald-600" /><h2 className="mt-4 text-xl font-semibold">Application received</h2><p className="mx-auto mt-2 max-w-md text-sm leading-6 text-muted">Thank you for volunteering. An administrator will review your language sample and contact you through your Google account.</p></div>;
  return <form onSubmit={(event) => void submit(event)} className="card p-5 sm:p-8"><div className="mb-6 rounded-lg border border-line bg-slate-50 p-3"><div className="flex flex-wrap items-center justify-between gap-3"><div><p className="text-xs font-bold">Google account</p><p className="mt-0.5 text-xs text-muted">{account ?? "Required so you can track your application"}</p></div><button type="button" onClick={() => void connectGoogle()} disabled={busy || !isFirebaseClientConfigured()} className="focus-ring rounded-lg border border-line bg-white px-3 py-2 text-xs font-bold disabled:opacity-50">{account ? "Connected" : "Connect Google"}</button></div></div><div className="grid gap-5 sm:grid-cols-2"><div><label className="label" htmlFor="name">Community name</label><input required id="name" name="name" className="field" placeholder="How we should address you" /></div><div><label className="label" htmlFor="language">Language</label><select required id="language" name="language" className="field"><option value="">Choose a language</option>{languages.map(([id, name, native]) => <option value={id} key={id}>{name} · {native}</option>)}</select></div><div><label className="label" htmlFor="relationship">Your relationship to the language</label><select required id="relationship" name="relationship" className="field"><option>Native speaker</option><option>Heritage speaker</option><option>Teacher</option><option>Translator</option><option>Advanced learner</option></select></div><div><label className="label" htmlFor="hours">Hours available each week</label><input required id="hours" name="hours" type="number" min="1" max="40" className="field" placeholder="3" /></div></div><div className="mt-5"><label className="label" htmlFor="motivation">Why would you like to help?</label><textarea required minLength={40} id="motivation" name="motivation" rows={4} className="field" placeholder="Tell us about the language and the contribution you hope to make." /></div><div className="mt-5"><span className="label">Handwritten language sample</span><label className="focus-ring flex cursor-pointer flex-col items-center rounded-xl border border-dashed border-slate-300 bg-slate-50 px-5 py-7 text-center hover:border-brand"><FileUp className="size-6 text-brand" /><strong className="mt-3 text-sm">Upload JPEG, PNG, or PDF</strong><span className="mt-1 max-w-md text-xs leading-5 text-muted">Include five original sentences, romanization, English meaning, today&apos;s date, and your initials. Keep the file below 600 KB; never upload identity documents.</span><input required name="proof" type="file" accept="image/jpeg,image/png,application/pdf" className="sr-only" /></label></div><label className="mt-5 flex items-start gap-3 text-xs leading-5 text-muted"><input required type="checkbox" className="mt-1 accent-[#187b78]" />I agree to the contributor code of conduct and understand that my private sample is used only for application review.</label>{error && <p className="mt-4 text-sm text-red-600" role="alert">{error}</p>}<button disabled={busy} type="submit" className="focus-ring mt-6 w-full rounded-lg bg-brand px-5 py-3 text-sm font-bold text-white hover:bg-brand-dark disabled:opacity-60">{busy ? "Submitting…" : "Submit application"}</button></form>;
}
