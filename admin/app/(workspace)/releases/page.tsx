import { CheckCircle2, GitBranch } from "lucide-react";
import { PageHeader } from "@/components/page-header";
import { StatusPill } from "@/components/status-pill";
import { formatRelativeTime } from "@/logic/time/format-relative";
import { getLanguageReleaseSummaries } from "@/services/firebase/course-repository";

export default async function ReleasesPage() {
  const releases = await getLanguageReleaseSummaries();
  return <><PageHeader eyebrow="Publishing" title="Language releases" description="Every language has its own history and active pointer. Publishing one language never touches another." />
    <div className="mb-5 rounded-xl border border-brand/15 bg-brand-soft/70 p-4"><div className="flex gap-3"><GitBranch className="mt-0.5 size-5 text-brand" /><div><p className="text-sm font-bold text-brand-dark">Independent by design</p><p className="mt-1 text-xs leading-5 text-muted">Activating Tamil updates <code>courseConfig/tamil</code> only. Kannada and all other active pointers remain unchanged.</p></div></div></div>
    <section className="card overflow-hidden"><div className="overflow-x-auto"><table className="w-full text-left"><thead><tr className="border-b border-line bg-slate-50 text-[11px] tracking-wider text-muted uppercase"><th className="px-5 py-3">Language</th><th className="px-4 py-3">Active</th><th className="px-4 py-3">Previous</th><th className="px-4 py-3">Health</th><th className="px-4 py-3">Published</th><th className="px-5 py-3">Content</th></tr></thead><tbody>{releases.map((language) => <tr className="border-b border-line last:border-0" key={language.language}><td className="px-5 py-4"><div className="flex items-center gap-3"><span className="grid size-8 place-items-center rounded-lg bg-brand-soft text-xs font-bold text-brand">{language.nativeName.slice(0, 1)}</span><span><strong className="block text-sm">{language.name}</strong><span className="text-xs text-muted">{language.nativeName}</span></span></div></td><td className="px-4 py-4 font-mono text-xs font-semibold">{language.activeReleaseId ?? "—"}</td><td className="px-4 py-4 font-mono text-xs text-muted">{language.previousReleaseId ?? "—"}</td><td className="px-4 py-4"><StatusPill status={language.status === "active" ? "active" : "review"} /></td><td className="px-4 py-4 text-xs text-muted">{formatRelativeTime(language.publishedAt)}</td><td className="px-5 py-4 text-xs text-muted">{language.courseCount} courses · {language.questionCount.toLocaleString()} questions</td></tr>)}</tbody></table></div></section>
    <p className="mt-4 flex items-center gap-2 text-xs text-muted"><CheckCircle2 className="size-4 text-emerald-600" />Values above come directly from Firestore release metadata.</p>
  </>;
}
