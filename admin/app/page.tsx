import Link from "next/link";
import { ArrowRight, BookOpenCheck, Languages, ShieldCheck } from "lucide-react";
import { Brand } from "@/components/brand";
import { getLanguageReleaseSummaries } from "@/services/firebase/course-repository";

export const dynamic = "force-dynamic";

export default async function Home() {
  const releases = await getLanguageReleaseSummaries();
  const active = releases.filter((release) => release.activeReleaseId);
  const totals = active.reduce((sum, release) => ({ courses: sum.courses + release.courseCount, questions: sum.questions + release.questionCount }), { courses: 0, questions: 0 });
  const features = [
    [Languages, "Independent releases", "Ship one language confidently without touching the other twelve."],
    [BookOpenCheck, "Purpose-built editing", "Course structure, answers, and dictionary coverage are checked as you work."],
    [ShieldCheck, "Human review", "Only approved moderators edit; only admins can activate or roll back releases."],
  ] as const;
  return <main className="min-h-screen px-5 py-5 sm:px-8">
    <nav className="mx-auto flex max-w-6xl items-center justify-between py-2"><Brand /><div className="flex items-center gap-2"><Link href="/apply" className="focus-ring rounded-lg px-4 py-2 text-sm font-semibold text-slate-600 hover:bg-white">Volunteer</Link><Link href="/login" className="focus-ring rounded-lg bg-ink px-4 py-2 text-sm font-semibold text-white hover:bg-slate-800">Staff sign in</Link></div></nav>
    <section className="mx-auto grid max-w-6xl items-center gap-14 py-24 lg:grid-cols-[1.05fr_.95fr] lg:py-32">
      <div><div className="mb-6 inline-flex items-center gap-2 rounded-full border border-brand/15 bg-brand-soft px-3 py-1.5 text-xs font-bold text-brand-dark"><span className="size-1.5 rounded-full bg-brand" />Built with the community</div><h1 className="max-w-3xl text-5xl font-semibold leading-[1.05] tracking-[-0.045em] text-ink sm:text-6xl">Language knowledge deserves careful hands.</h1><p className="mt-6 max-w-xl text-lg leading-8 text-muted">Varnamala Admin gives volunteer language experts a thoughtful place to improve lessons, review changes, and publish each language independently.</p><div className="mt-8 flex flex-wrap gap-3"><Link href="/dashboard" className="focus-ring inline-flex items-center gap-2 rounded-lg bg-brand px-5 py-3 text-sm font-bold text-white shadow-sm hover:bg-brand-dark">Open workspace <ArrowRight className="size-4" /></Link><Link href="/apply" className="focus-ring rounded-lg border border-line bg-white px-5 py-3 text-sm font-bold text-ink hover:border-slate-300">Apply to moderate</Link></div><p className="mt-5 text-xs text-muted">{active.length} languages · {totals.courses.toLocaleString()} courses · {totals.questions.toLocaleString()} validated questions</p></div>
      <div className="card relative overflow-hidden p-5 sm:p-7"><div className="mb-5 flex items-center justify-between"><div><p className="text-xs font-bold tracking-wider text-muted uppercase">Live Firestore releases</p><p className="mt-1 text-lg font-semibold">Repository content is active</p></div><span className="rounded-full bg-emerald-50 px-2.5 py-1 text-xs font-bold text-emerald-700">{active.length} live</span></div><div className="space-y-3">{active.slice(0, 3).map((release) => <div key={release.language} className="flex items-center gap-3 rounded-lg border border-line p-3"><span className="grid size-9 place-items-center rounded-lg bg-brand-soft text-sm font-bold text-brand">{release.nativeName.slice(0, 1)}</span><span className="flex-1"><strong className="block text-sm">{release.name}</strong><span className="text-xs text-muted">{release.courseCount} courses · {release.questionCount.toLocaleString()} questions</span></span><span className="font-mono text-[11px] font-semibold text-muted">{release.activeReleaseId}</span></div>)}</div><div className="mt-5 flex items-center justify-between border-t border-line pt-5 text-sm"><span className="text-muted">Every language has its own active pointer</span><Link href="/login" className="rounded-lg bg-ink px-4 py-2 font-semibold text-white">Staff sign in</Link></div></div>
    </section>
    <section className="mx-auto grid max-w-6xl gap-4 pb-20 md:grid-cols-3">{features.map(([Icon, title, copy]) => <article key={title} className="card p-5"><Icon className="size-5 text-brand" /><h2 className="mt-4 text-sm font-bold">{title}</h2><p className="mt-2 text-sm leading-6 text-muted">{copy}</p></article>)}</section>
  </main>;
}
