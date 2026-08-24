import Link from "next/link";
import { ArrowRight, BookOpen } from "lucide-react";
import { PageHeader } from "@/components/page-header";
import { StatusPill } from "@/components/status-pill";
import { getLanguageReleaseSummaries } from "@/services/firebase/course-repository";

export default async function CoursesPage() {
  const languages = await getLanguageReleaseSummaries();
  return <><PageHeader eyebrow="Course library" title="Choose a language" description="Open any language to edit its independently released repository courses." />
    <section className="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">{languages.map((language) => <Link key={language.language} href={`/courses/${language.language}`} className="card focus-ring group p-5 hover:border-brand/30"><div className="flex items-start justify-between gap-4"><span className="grid size-11 place-items-center rounded-xl bg-brand-soft text-lg font-bold text-brand">{language.nativeName.slice(0, 1)}</span><StatusPill status={language.status === "active" ? "active" : "review"} /></div><h2 className="mt-5 text-base font-bold">{language.name} · {language.nativeName}</h2><p className="mt-1 text-xs text-muted">{language.courseCount} courses · {language.questionCount.toLocaleString()} questions</p><div className="mt-5 flex items-center justify-between border-t border-line pt-4 text-xs"><span className="font-mono text-muted">{language.activeReleaseId ?? "Not seeded"}</span><span className="flex items-center gap-1 font-bold text-brand">Open <ArrowRight className="size-3.5 transition-transform group-hover:translate-x-0.5" /></span></div></Link>)}</section>
    {!languages.some((language) => language.activeReleaseId) && <div className="card mt-5 flex items-center gap-3 p-5 text-sm text-muted"><BookOpen className="size-5 text-brand" />Run <code>bun run seed:courses</code> once to publish the repository JSON.</div>}
  </>;
}
