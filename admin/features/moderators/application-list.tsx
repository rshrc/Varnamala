"use client";

import { useMemo, useState } from "react";
import { Check, Clock3, FileText, Search, X } from "lucide-react";
import { useRouter } from "next/navigation";
import { getLanguage } from "@/logic/courses/catalog";
import { formatRelativeTime } from "@/logic/time/format-relative";
import type { ModeratorApplication } from "@/services/firebase/staff-repository";

export function ApplicationList({ applications }: { applications: ModeratorApplication[] }) {
  const router = useRouter();
  const [query, setQuery] = useState("");
  const [busy, setBusy] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const filtered = useMemo(() => applications.filter((item) => `${item.name} ${item.email ?? ""} ${item.language}`.toLowerCase().includes(query.toLowerCase())), [applications, query]);
  async function decide(uid: string, action: "approve" | "reject"): Promise<void> {
    setBusy(uid); setError(null);
    try {
      const response = await fetch("/api/applications", { method: "PATCH", headers: { "content-type": "application/json" }, body: JSON.stringify({ uid, action }) });
      const data: unknown = await response.json();
      if (!response.ok) throw new Error(typeof data === "object" && data && "error" in data ? String(data.error) : "Could not update application.");
      router.refresh();
    } catch (caught) { setError(caught instanceof Error ? caught.message : "Could not update application."); }
    finally { setBusy(null); }
  }
  return <><div className="card mb-5 p-3"><label className="relative block"><Search className="absolute top-1/2 left-3 size-4 -translate-y-1/2 text-muted" /><input value={query} onChange={(event) => setQuery(event.target.value)} className="field pl-9" placeholder="Search applicants or languages" aria-label="Search applications" /></label></div>{error && <p className="mb-4 rounded-lg border border-red-200 bg-red-50 p-3 text-sm text-red-700">{error}</p>}<section className="grid gap-4 lg:grid-cols-2">{filtered.map((item) => { const language = getLanguage(item.language); const initials = item.name.split(/\s+/).map((part) => part[0]).join("").slice(0, 2).toUpperCase(); return <article key={item.uid} className="card p-5"><div className="flex items-start gap-4"><span className="grid size-10 shrink-0 place-items-center rounded-full bg-brand-soft text-xs font-bold text-brand">{initials}</span><div className="min-w-0 flex-1"><div className="flex flex-wrap items-center justify-between gap-2"><h2 className="text-sm font-bold">{item.name}</h2><span className={`rounded-full px-2 py-1 text-[11px] font-bold ${item.status === "submitted" ? "bg-sky-50 text-sky-700" : item.status === "approved" ? "bg-emerald-50 text-emerald-700" : "bg-red-50 text-red-700"}`}>{item.status}</span></div><p className="mt-1 text-xs text-muted">{language.name} · {item.relationship} · {item.hours}h/week</p><p className="mt-3 text-sm leading-6 text-muted">{item.motivation}</p></div></div><div className="mt-5 flex flex-wrap items-center justify-between gap-3 border-t border-line pt-4"><span className="flex items-center gap-1.5 text-xs text-muted"><Clock3 className="size-3.5" />{formatRelativeTime(item.submittedAt)}</span><div className="flex gap-2"><a href={`/api/applications/${item.uid}/proof`} target="_blank" className="focus-ring inline-flex items-center gap-1.5 rounded-lg border border-line px-3 py-2 text-xs font-bold"><FileText className="size-3.5" />Proof</a>{item.status === "submitted" && <><button disabled={busy === item.uid} onClick={() => void decide(item.uid, "reject")} className="focus-ring rounded-lg border border-line px-3 py-2 text-xs font-bold"><X className="size-3.5" /></button><button disabled={busy === item.uid} onClick={() => void decide(item.uid, "approve")} className="focus-ring inline-flex items-center gap-1.5 rounded-lg bg-ink px-3 py-2 text-xs font-bold text-white"><Check className="size-3.5" />Approve</button></>}</div></div></article>; })}</section>{!filtered.length && <div className="card p-8 text-center text-sm text-muted">No applications match.</div>}</>;
}
