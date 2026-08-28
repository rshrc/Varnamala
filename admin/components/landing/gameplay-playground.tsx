"use client";

import { AlignHorizontalSpaceAround, ListChecks, Puzzle } from "lucide-react";
import { useState } from "react";
import { gameplayLanguages, type GameplayLanguage } from "@/logic/landing/gameplay-demo";
import { MissingWordExercise, QuickReplyExercise, WordOrderExercise } from "./gameplay-exercises";
import styles from "./gameplay.module.css";

type GameplayMode = "arrange" | "blank" | "reply";

const modes = [
  { id: "arrange", label: "Arrange words", Icon: AlignHorizontalSpaceAround },
  { id: "blank", label: "Missing word", Icon: Puzzle },
  { id: "reply", label: "Quick reply", Icon: ListChecks },
] as const;

function Exercise({ language, mode }: { language: GameplayLanguage; mode: GameplayMode }) {
  if (mode === "arrange") return <WordOrderExercise language={language} />;
  if (mode === "blank") return <MissingWordExercise language={language} />;
  return <QuickReplyExercise language={language} />;
}

export function GameplayPlayground() {
  const [languageId, setLanguageId] = useState<GameplayLanguage["id"]>("kannada");
  const [mode, setMode] = useState<GameplayMode>("arrange");
  const language = gameplayLanguages.find((item) => item.id === languageId) ?? gameplayLanguages[0]!;

  return <section id="playground" className={`${styles.shell} scroll-mt-8 p-5 sm:p-8 lg:p-10`}>
    <div className="relative grid gap-8 lg:grid-cols-[0.72fr_1.28fr] lg:gap-12">
      <div className="flex flex-col justify-between">
        <div>
          <span className="inline-flex rounded-full bg-brand-soft px-3 py-1 text-xs font-black tracking-[0.11em] text-brand-dark uppercase">Playable preview</span>
          <h2 className="mt-5 text-3xl font-semibold tracking-[-0.04em] sm:text-4xl">Don’t read about the app. Touch it.</h2>
          <p className="mt-4 max-w-md text-base leading-7 text-muted">Switch languages and exercise types. This is React—not a video, screenshot, or embedded Flutter build.</p>
        </div>
        <label className="mt-8 block max-w-sm">
          <span className="mb-2 block text-xs font-black tracking-[0.1em] text-muted uppercase">I want to try</span>
          <select value={languageId} onChange={(event) => setLanguageId(event.target.value as GameplayLanguage["id"])} className="focus-ring w-full rounded-xl border border-line bg-surface px-4 py-3 text-base font-bold text-ink">
            {gameplayLanguages.map((item) => <option key={item.id} value={item.id}>{item.nativeName} · {item.name}</option>)}
          </select>
        </label>
        <div className="mt-6 flex flex-wrap gap-2 text-xs font-bold text-muted"><span>13 languages</span><span>·</span><span>3 interaction modes</span><span>·</span><span>No account needed</span></div>
      </div>
      <div className="rounded-[24px] border border-line bg-surface/95 p-3 shadow-[0_18px_50px_rgba(13,55,53,0.12)] sm:p-5">
        <div className="grid grid-cols-3 gap-1 rounded-xl bg-canvas p-1">
          {modes.map(({ id, label, Icon }) => <button key={id} type="button" onClick={() => setMode(id)} aria-pressed={mode === id} className={`${styles.modeButton} focus-ring flex min-h-14 flex-col items-center justify-center gap-1 rounded-lg px-2 text-[11px] font-bold sm:flex-row sm:text-xs ${mode === id ? "bg-surface text-brand shadow-sm" : "text-muted hover:text-ink"}`}><Icon className="size-4" /><span>{label}</span></button>)}
        </div>
        <div className="px-2 py-6 sm:px-4 sm:py-8"><Exercise key={`${language.id}-${mode}`} language={language} mode={mode} /></div>
      </div>
    </div>
  </section>;
}
