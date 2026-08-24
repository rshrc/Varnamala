"use client";

import { useState } from "react";
import Link from "next/link";
import { CheckCircle2, Clock3, Hand, Languages } from "lucide-react";
import { useRouter } from "next/navigation";
import { getLanguage } from "@/logic/courses/catalog";
import type { ContentReportTask } from "@/logic/tasks/schemas";
import { formatRelativeTime } from "@/logic/time/format-relative";

export function TaskBoard({ tasks, currentUid, isAdmin }: { tasks: ContentReportTask[]; currentUid: string; isAdmin: boolean }) {
  const router = useRouter();
  const [busyId, setBusyId] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  async function update(reportId: string, action: "claim" | "resolve"): Promise<void> {
    setBusyId(reportId); setError(null);
    try {
      const response = await fetch("/api/tasks", { method: "PATCH", headers: { "content-type": "application/json" }, body: JSON.stringify({ reportId, action }) });
      const data: unknown = await response.json();
      if (!response.ok) throw new Error(typeof data === "object" && data && "error" in data ? String(data.error) : "Could not update task.");
      router.refresh();
    } catch (caught) { setError(caught instanceof Error ? caught.message : "Could not update task."); }
    finally { setBusyId(null); }
  }
  if (!tasks.length) return <div className="card p-10 text-center"><CheckCircle2 className="mx-auto size-9 text-emerald-600" /><h2 className="mt-3 text-base font-bold">Report queue is clear</h2><p className="mt-1 text-sm text-muted">New learner reports from Flutter will appear here automatically.</p></div>;
  return <>{error && <p role="alert" className="mb-4 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">{error}</p>}<section className="grid gap-4 lg:grid-cols-2">{tasks.map((task) => { const language = getLanguage(task.language); const mine = task.assignedTo === currentUid; return <article key={task.id} className="card p-5"><div className="flex flex-wrap items-start justify-between gap-3"><div><div className="flex items-center gap-2"><span className="rounded-full bg-brand-soft px-2 py-1 text-[11px] font-bold text-brand-dark">{task.reasonLabel}</span><span className={`rounded-full px-2 py-1 text-[11px] font-bold ${task.status === "open" ? "bg-sky-50 text-sky-700" : task.status === "in_progress" ? "bg-amber-50 text-amber-700" : "bg-emerald-50 text-emerald-700"}`}>{task.status.replace("_", " ")}</span></div><h2 className="mt-3 text-sm font-bold">{language.name} · {task.course}</h2></div><span className="flex items-center gap-1 text-xs text-muted"><Clock3 className="size-3.5" />{formatRelativeTime(task.createdAt)}</span></div>{task.sentence && <blockquote className="mt-4 rounded-lg bg-slate-50 px-4 py-3 text-sm font-semibold leading-6">“{task.sentence}”</blockquote>}<p className="mt-3 text-sm leading-6 text-muted">{task.detail || "No additional detail was supplied."}</p><div className="mt-5 flex flex-wrap items-center justify-between gap-3 border-t border-line pt-4"><Link href={`/courses/${task.language}`} className="flex items-center gap-1.5 text-xs font-bold text-brand"><Languages className="size-3.5" />Open language</Link>{task.status === "open" ? <button disabled={busyId === task.id} onClick={() => void update(task.id, "claim")} className="focus-ring inline-flex items-center gap-2 rounded-lg bg-ink px-3 py-2 text-xs font-bold text-white disabled:opacity-50"><Hand className="size-3.5" />Take task</button> : task.status === "in_progress" ? <div className="flex items-center gap-3"><span className="text-xs text-muted">{mine ? "Assigned to you" : `Assigned to ${task.assignedToName ?? "a moderator"}`}</span>{(mine || isAdmin) && <button disabled={busyId === task.id} onClick={() => void update(task.id, "resolve")} className="focus-ring rounded-lg bg-brand px-3 py-2 text-xs font-bold text-white disabled:opacity-50">Mark resolved</button>}</div> : <span className="flex items-center gap-1.5 text-xs font-bold text-emerald-700"><CheckCircle2 className="size-4" />Resolved</span>}</div></article>; })}</section></>;
}
