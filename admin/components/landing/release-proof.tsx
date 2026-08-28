import { CheckCircle2, GitBranch, ShieldCheck } from "lucide-react";

type ReleaseSummary = {
  language: string;
  name: string;
  nativeName: string;
  activeReleaseId: string | null;
  courseCount: number;
  questionCount: number;
};

export function ReleaseProof({ releases }: { releases: readonly ReleaseSummary[] }) {
  const active = releases.filter((release) => release.activeReleaseId);
  const totals = active.reduce((sum, release) => ({ courses: sum.courses + release.courseCount, questions: sum.questions + release.questionCount }), { courses: 0, questions: 0 });
  return <section className="border-y border-line bg-surface/65">
    <div className="mx-auto grid max-w-7xl gap-10 px-5 py-20 sm:px-8 lg:grid-cols-[0.85fr_1.15fr] lg:items-center">
      <div>
        <span className="inline-flex items-center gap-2 text-xs font-black tracking-[0.13em] text-brand uppercase"><ShieldCheck className="size-4" />Community publishing</span>
        <h2 className="mt-5 text-3xl font-semibold tracking-[-0.04em] sm:text-4xl">Careful releases, not content sludge.</h2>
        <p className="mt-4 max-w-lg text-base leading-7 text-muted">Maintainers edit structured courses, validators catch broken answers, and administrators can activate or roll back one language without disturbing the rest.</p>
        <div className="mt-8 flex flex-wrap gap-6"><span><strong className="block text-3xl tracking-tight">{active.length || 13}</strong><span className="text-xs font-bold text-muted uppercase">language tracks</span></span><span><strong className="block text-3xl tracking-tight">{totals.courses || "Independent"}</strong><span className="text-xs font-bold text-muted uppercase">{totals.courses ? "live courses" : "release paths"}</span></span><span><strong className="block text-3xl tracking-tight">{totals.questions ? totals.questions.toLocaleString() : "Human"}</strong><span className="text-xs font-bold text-muted uppercase">{totals.questions ? "reviewed prompts" : "reviewed"}</span></span></div>
      </div>
      <div className="rounded-3xl border border-line bg-surface p-4 shadow-sm sm:p-6">
        <div className="mb-4 flex items-center justify-between"><span className="text-xs font-black tracking-[0.11em] text-muted uppercase">Language release lanes</span><GitBranch className="size-4 text-brand" /></div>
        <div className="grid gap-2 sm:grid-cols-2">{(active.length ? active : releases).slice(0, 6).map((release) => <div key={release.language} className="flex items-center gap-3 rounded-xl border border-line bg-canvas/55 p-3"><span className="grid size-10 shrink-0 place-items-center rounded-xl bg-brand-soft text-sm font-black text-brand-dark">{release.nativeName.slice(0, 1)}</span><span className="min-w-0 flex-1"><strong className="block truncate text-sm">{release.nativeName}</strong><span className="text-xs text-muted">{release.name}</span></span><CheckCircle2 className="size-4 text-brand" /></div>)}</div>
      </div>
    </div>
  </section>;
}
