"use client";

import { useState, type FormEvent } from "react";
import { Plus, ShieldCheck } from "lucide-react";
import { useRouter } from "next/navigation";
import { formatRelativeTime } from "@/logic/time/format-relative";
import type { AdminMember } from "@/services/firebase/staff-repository";

export function AdminList({ admins }: { admins: AdminMember[] }) {
  const router = useRouter();
  const [adding, setAdding] = useState(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  async function submit(event: FormEvent<HTMLFormElement>): Promise<void> {
    event.preventDefault(); setBusy(true); setError(null);
    const form = new FormData(event.currentTarget);
    try {
      const response = await fetch("/api/admins", { method: "POST", headers: { "content-type": "application/json" }, body: JSON.stringify({ email: form.get("email") }) });
      const data: unknown = await response.json();
      if (!response.ok) throw new Error(typeof data === "object" && data && "error" in data ? String(data.error) : "Could not add administrator.");
      setAdding(false); router.refresh();
    } catch (caught) { setError(caught instanceof Error ? caught.message : "Could not add administrator."); }
    finally { setBusy(false); }
  }
  return <><div className="mb-5 flex justify-end"><button onClick={() => setAdding((value) => !value)} className="focus-ring inline-flex items-center gap-2 rounded-lg bg-brand px-4 py-2.5 text-sm font-bold text-white"><Plus className="size-4" />Add admin</button></div>{adding && <form onSubmit={(event) => void submit(event)} className="card mb-5 flex flex-col gap-3 p-4 sm:flex-row"><label className="flex-1"><span className="label">Existing Firebase user email</span><input required type="email" name="email" className="field" placeholder="person@example.com" /></label><button disabled={busy} className="focus-ring self-end rounded-lg bg-ink px-4 py-2.5 text-sm font-bold text-white disabled:opacity-50">{busy ? "Adding…" : "Grant access"}</button></form>}{error && <p className="mb-4 rounded-lg border border-red-200 bg-red-50 p-3 text-sm text-red-700">{error}</p>}<section className="card overflow-hidden"><div className="border-b border-line px-5 py-4"><h2 className="text-sm font-bold">Active administrators</h2></div>{admins.map((admin) => { const initials = admin.name.split(/\s+/).map((part) => part[0]).join("").slice(0, 2).toUpperCase(); return <div key={admin.uid} className="flex flex-col gap-4 border-b border-line p-5 last:border-0 sm:flex-row sm:items-center"><span className="grid size-11 place-items-center rounded-full bg-brand text-sm font-bold text-white">{initials || "A"}</span><div className="flex-1"><h3 className="text-sm font-bold">{admin.name}</h3><p className="mt-1 text-xs text-muted">{admin.email} · updated {formatRelativeTime(admin.updatedAt)}</p></div><span className="flex items-center gap-2 text-xs font-semibold text-emerald-700"><ShieldCheck className="size-4" />Full access</span></div>; })}{!admins.length && <p className="p-5 text-sm text-muted">No administrator records found.</p>}</section></>;
}
