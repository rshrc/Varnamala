import Link from "next/link";
import { notFound } from "next/navigation";
import { ArrowRight, BookOpen, BookText, MessageSquareText } from "lucide-react";
import { PageHeader } from "@/components/page-header";
import { isLanguageId } from "@/logic/courses/catalog";
import { getLanguageCourseLibrary } from "@/services/firebase/course-repository";

export default async function LanguagePage({ params }: { params: Promise<{ language: string }> }) {
  const { language: languageParam } = await params;
  if (!isLanguageId(languageParam)) notFound();
  const library = await getLanguageCourseLibrary(languageParam);
  if (!library) notFound();
  const questions = library.courses.reduce((sum, course) => sum + course.questions, 0);
  return <><PageHeader eyebrow="Course library" title={`${library.language.name} · ${library.language.nativeName}`} description={`${library.courses.length} repository courses and ${questions.toLocaleString()} real questions. Changes release independently from every other language.`} actions={<Link href="/courses" className="focus-ring rounded-lg border border-line bg-white px-4 py-2.5 text-sm font-bold hover:border-brand/40">Change language</Link>} />
    <div className="mb-5 grid gap-3 sm:grid-cols-3"><div className="card flex items-center gap-3 p-4"><BookOpen className="size-5 text-brand" /><div><p className="text-xs text-muted">Active release</p><p className="text-sm font-bold">{library.releaseId}</p></div></div><div className="card flex items-center gap-3 p-4"><BookText className="size-5 text-violet-500" /><div><p className="text-xs text-muted">Dictionary</p><p className="text-sm font-bold">{library.dictionaryEntries.toLocaleString()} entries</p></div></div><div className="card flex items-center gap-3 p-4"><MessageSquareText className="size-5 text-amber-500" /><div><p className="text-xs text-muted">Open reports</p><p className="text-sm font-bold">{library.openReports} learner {library.openReports === 1 ? "task" : "tasks"}</p></div></div></div>
    <section className="card overflow-hidden"><div className="grid grid-cols-[1fr_auto_auto] border-b border-line bg-slate-50/70 px-5 py-3 text-[11px] font-bold tracking-wider text-muted uppercase"><span>Course</span><span className="hidden w-32 sm:block">Questions</span><span className="w-8" /></div>{library.courses.map((course, index) => <Link href={`/courses/${library.language.id}/${course.id}`} key={course.id} className="focus-ring grid grid-cols-[1fr_auto_auto] items-center border-b border-line px-5 py-3.5 last:border-0 hover:bg-slate-50"><span className="flex items-center gap-3"><span className="grid size-8 place-items-center rounded-lg bg-brand-soft text-xs font-bold text-brand">{index + 1}</span><span><strong className="block text-sm">{course.title}</strong><span className="text-xs text-muted">{course.levels} levels · Repository JSON</span></span></span><span className="hidden w-32 text-xs text-muted sm:block">{course.questions}</span><ArrowRight className="size-4 text-muted" /></Link>)}</section>
  </>;
}
