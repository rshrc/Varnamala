import { BookHeart, HandHeart, Scale, Sparkles } from "lucide-react";

const principles = [
  [HandHeart, "Community before market size", "A language does not need to prove its profitability before it deserves excellent learning tools."],
  [BookHeart, "Human knowledge stays central", "Automation can shape an exercise. Fluent maintainers decide what is true, natural, and respectful."],
  [Sparkles, "Play is not childish", "Sequencing, recall, listening, and mistakes turned into practice make serious learning feel alive."],
  [Scale, "One language cannot hold another hostage", "Each language is reviewed and released independently by people who understand it."],
] as const;

export function EthosSection() {
  return <section className="mx-auto max-w-7xl px-5 py-24 sm:px-8 lg:py-32">
    <div className="grid gap-12 lg:grid-cols-[0.9fr_1.1fr] lg:gap-20">
      <div>
        <p className="text-xs font-black tracking-[0.16em] text-coral uppercase">Our position, plainly</p>
        <h2 className="mt-5 text-4xl font-semibold tracking-[-0.045em] sm:text-5xl">Language is inheritance.<br />Not a premium SKU.</h2>
      </div>
      <div className="border-l-2 border-coral/40 pl-6 sm:pl-9">
        <p className="text-xl leading-9 font-medium tracking-[-0.015em] sm:text-2xl sm:leading-10">A billion-dollar green owl can find shelf space for High Valyrian and Klingon. Fiction is fun. But living, Indigenous, and ancient languages should not be left waiting behind a market-size spreadsheet.</p>
        <p className="mt-5 text-base leading-7 text-muted">That is not an innocent product gap. It is gatekeeping wrapped in cheerful branding. Varnamala exists because communities should not need corporate permission to teach what they inherited.</p>
      </div>
    </div>
    <div className="mt-16 grid gap-px overflow-hidden rounded-3xl border border-line bg-line md:grid-cols-2 lg:grid-cols-4">
      {principles.map(([Icon, title, copy]) => <article key={title} className="bg-surface p-6 sm:p-7"><Icon className="size-5 text-brand" /><h3 className="mt-6 text-base font-black tracking-tight">{title}</h3><p className="mt-3 text-sm leading-6 text-muted">{copy}</p></article>)}
    </div>
  </section>;
}
