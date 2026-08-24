import Link from "next/link";
import { notFound } from "next/navigation";
import { ChevronLeft } from "lucide-react";
import { CourseEditor } from "@/features/courses/course-editor";
import { getLanguage, isLanguageId } from "@/logic/courses/catalog";
import { getCourseForEditor } from "@/services/firebase/course-repository";
import { getStaffSession } from "@/services/firebase/session";

export default async function CoursePage({ params }: { params: Promise<{ language: string; courseId: string }> }) {
  const { language: languageParam, courseId } = await params;
  if (!isLanguageId(languageParam)) notFound();
  const session = await getStaffSession();
  if (!session) notFound();
  const language = getLanguage(languageParam);
  const editor = await getCourseForEditor({ language: language.id, courseId, uid: session.uid });
  if (!editor) notFound();
  return <><div className="mb-5 flex flex-wrap items-end justify-between gap-4"><div><Link href={`/courses/${language.id}`} className="mb-3 inline-flex items-center gap-1 text-xs font-bold text-muted hover:text-ink"><ChevronLeft className="size-3.5" />{language.name} courses</Link><h1 className="text-2xl font-semibold tracking-tight">{editor.course.title}</h1><p className="mt-1.5 text-sm text-muted">Editing draft from {editor.baseReleaseId} · {language.nativeName}</p></div><div className="rounded-full border border-emerald-200 bg-emerald-50 px-3 py-1.5 text-xs font-bold text-emerald-700">Repository content</div></div><CourseEditor course={editor.course} language={language.id} baseReleaseId={editor.baseReleaseId} /></>;
}
