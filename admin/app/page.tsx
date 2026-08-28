import type { Metadata } from "next";
import Link from "next/link";
import { ArrowDown, ArrowRight, CirclePlay, HeartHandshake, Sparkles } from "lucide-react";
import { EthosSection } from "@/components/landing/ethos-section";
import { GameplayPlayground } from "@/components/landing/gameplay-playground";
import { LandingNav } from "@/components/landing/landing-nav";
import { ReleaseProof } from "@/components/landing/release-proof";
import { languageCatalog } from "@/logic/courses/catalog";
import { getLanguageReleaseSummaries } from "@/services/firebase/course-repository";
import styles from "./landing.module.css";

export const dynamic = "force-dynamic";

export const metadata: Metadata = {
  title: "Varnamala · Language learning belongs to everyone",
  description: "Playful, community-reviewed learning for thirteen South Asian languages—without waiting for a corporation to decide they are profitable enough.",
};

async function releaseSummaries() {
  try {
    return await getLanguageReleaseSummaries();
  } catch {
    return languageCatalog.map((language) => ({
      ...language,
      language: language.id,
      activeReleaseId: null,
      courseCount: 0,
      questionCount: 0,
    }));
  }
}

function LearningPathPreview() {
  return <div className={`${styles.pathCard} min-h-[500px] p-6 sm:p-8`} aria-label="Preview of a Varnamala learning path">
    <div className="flex items-center justify-between"><span className="rounded-full bg-brand-soft px-3 py-1 text-[10px] font-black tracking-[0.12em] text-brand-dark uppercase">Interactive lessons · Beta</span><span className="text-xs font-bold text-muted">ಕನ್ನಡ · Kannada</span></div>
    <div className={styles.pathLine} />
    <div className="relative mt-12 grid gap-9">
      <div className="mr-auto ml-[12%] flex items-center gap-4"><span className="grid size-16 place-items-center rounded-full bg-brand text-xl font-black text-white shadow-[0_6px_0_var(--brand-dark)]">1</span><span><strong className="block text-sm">Discover</strong><span className="text-xs text-muted">Meet the phrase</span></span></div>
      <div className="ml-auto flex items-center gap-4"><span className="text-right"><strong className="block text-sm">Build</strong><span className="text-xs text-muted">Put it together</span></span><span className="grid size-16 place-items-center rounded-full bg-coral text-xl font-black text-white shadow-[0_6px_0_#a94740]">2</span></div>
      <div className="mr-auto ml-[22%] flex items-center gap-4"><span className={`${styles.goldNode} grid size-16 place-items-center rounded-full bg-amber-400 text-xl font-black text-amber-950`}>✓</span><span><strong className="block text-sm">Recall</strong><span className="text-xs text-muted">Golden · revisit anytime</span></span></div>
    </div>
    <div className="mt-11 rounded-2xl border border-line bg-surface p-4"><div className="flex items-center gap-3"><span className="grid size-10 place-items-center rounded-xl bg-brand-soft text-lg">ವ</span><span><strong className="block text-sm">ನಮಸ್ಕಾರ</strong><span className="text-xs text-muted">Namaskāra · Hello</span></span><Sparkles className="ml-auto size-4 text-amber-500" /></div></div>
  </div>;
}

export default async function Home() {
  const releases = await releaseSummaries();
  const scripts = languageCatalog.map((language) => language.nativeName);
  return <main className={`${styles.page} min-h-screen`}>
    <LandingNav />

    <section className="relative mx-auto grid max-w-7xl items-center gap-14 px-5 pt-16 pb-20 sm:px-8 sm:pt-24 lg:grid-cols-[1.06fr_.94fr] lg:gap-20 lg:pt-28 lg:pb-28">
      <span className={`${styles.heroWord} -top-8 -left-32`} aria-hidden="true">ಅ</span>
      <div>
        <div className="inline-flex items-center gap-2 rounded-full border border-brand/15 bg-brand-soft px-3 py-1.5 text-xs font-black text-brand-dark"><HeartHandshake className="size-3.5" />Built with language communities</div>
        <h1 className="mt-7 max-w-3xl text-5xl leading-[0.98] font-semibold tracking-[-0.055em] text-ink sm:text-6xl lg:text-7xl">The languages that raised us deserve better software.</h1>
        <p className="mt-7 max-w-2xl text-lg leading-8 text-muted">Varnamala makes serious language learning tactile, playful, and community-reviewed—across thirteen South Asian languages that should never have needed a corporate permission slip.</p>
        <div className="mt-9 flex flex-wrap gap-3"><Link href="#playground" className="focus-ring inline-flex items-center gap-2 rounded-xl bg-brand px-5 py-3.5 text-sm font-black text-white shadow-[0_4px_0_var(--brand-dark)] transition hover:-translate-y-0.5"><CirclePlay className="size-4" />Try it in your browser</Link><Link href="/apply" className="focus-ring inline-flex items-center gap-2 rounded-xl border border-line bg-surface px-5 py-3.5 text-sm font-black text-ink hover:border-brand/40">Help your language <ArrowRight className="size-4" /></Link></div>
        <a href="#playground" className="focus-ring mt-9 inline-flex items-center gap-2 rounded-lg text-xs font-bold text-muted hover:text-brand"><ArrowDown className="size-3.5" />Three real gameplay modes below</a>
      </div>
      <LearningPathPreview />
    </section>

    <div className="overflow-hidden border-y border-line bg-surface py-4" aria-hidden="true"><div className={`${styles.scriptRail} flex w-max gap-12 pr-12 text-2xl font-black text-brand/45`}>{[...scripts, ...scripts].map((script, index) => <span key={`${script}-${index}`}>{script}</span>)}</div></div>

    <div className="mx-auto max-w-7xl px-5 py-24 sm:px-8 lg:py-32"><GameplayPlayground /></div>
    <EthosSection />
    <ReleaseProof releases={releases} />

    <section className="mx-auto max-w-5xl px-5 py-24 text-center sm:px-8 lg:py-32">
      <span className="text-xs font-black tracking-[0.15em] text-brand uppercase">This belongs to all of us</span>
      <h2 className="mx-auto mt-5 max-w-3xl text-4xl font-semibold tracking-[-0.045em] sm:text-5xl">Fluent speakers should shape the lesson—not clean up after it.</h2>
      <p className="mx-auto mt-5 max-w-2xl text-base leading-7 text-muted">Review phrasing, improve a course, report a mistake, or help release a language independently. The admin workspace exists to put careful human judgment at the centre.</p>
      <div className="mt-9 flex flex-wrap justify-center gap-3"><Link href="/apply" className="focus-ring rounded-xl bg-brand px-6 py-3.5 text-sm font-black text-white shadow-[0_4px_0_var(--brand-dark)]">Apply to volunteer</Link><Link href="/login" className="focus-ring rounded-xl border border-line bg-surface px-6 py-3.5 text-sm font-black">Open staff workspace</Link></div>
    </section>

    <footer className="border-t border-line"><div className="mx-auto flex max-w-7xl flex-col gap-4 px-5 py-8 text-xs text-muted sm:flex-row sm:items-center sm:justify-between sm:px-8"><span><strong className="text-ink">Varnamala</strong> · Community-shaped language learning.</span><div className="flex gap-5"><Link href="/apply" className="hover:text-brand">Volunteer</Link><Link href="/login" className="hover:text-brand">Staff sign in</Link><a href="#playground" className="hover:text-brand">Playground</a></div></div></footer>
  </main>;
}
