"use client";

import { Check, GripVertical, RotateCcw, X } from "lucide-react";
import { useMemo, useState } from "react";
import type { GameplayLanguage } from "@/logic/landing/gameplay-demo";
import styles from "./gameplay.module.css";

type Result = "idle" | "correct" | "incorrect";

function Feedback({ result, answer }: { result: Result; answer: string }) {
  if (result === "idle") return null;
  const correct = result === "correct";
  return (
    <div className={`${styles.feedback} mt-4 flex items-start gap-3 rounded-2xl px-4 py-3 ${correct ? "bg-emerald-50 text-emerald-700" : "bg-red-50 text-red-700"}`} role="status">
      <span className="mt-0.5 grid size-6 shrink-0 place-items-center rounded-full bg-current/10">
        {correct ? <Check className="size-4" /> : <X className="size-4" />}
      </span>
      <span><strong className="block text-sm">{correct ? "That’s it." : "Almost—try that order again."}</strong>{!correct && <span className="mt-0.5 block text-xs opacity-80">Answer: {answer}</span>}</span>
    </div>
  );
}

function CheckButton({ disabled, onClick }: { disabled: boolean; onClick: () => void }) {
  return <button type="button" disabled={disabled} onClick={onClick} className="focus-ring mt-5 w-full rounded-xl bg-brand px-5 py-3 text-sm font-black tracking-[0.08em] text-white uppercase shadow-[0_4px_0_var(--brand-dark)] transition active:translate-y-1 active:shadow-none disabled:cursor-not-allowed disabled:opacity-40">Check</button>;
}

export function WordOrderExercise({ language }: { language: GameplayLanguage }) {
  const tokens = useMemo(() => language.answer.split(/\s+/).map((text, index) => ({ id: `${index}-${text}`, text })), [language.answer]);
  const [selectedIds, setSelectedIds] = useState<string[]>([]);
  const [dragging, setDragging] = useState(false);
  const [result, setResult] = useState<Result>("idle");
  const bank = [...tokens].reverse().filter((token) => !selectedIds.includes(token.id));
  const selected = selectedIds.map((id) => tokens.find((token) => token.id === id)).filter((token): token is (typeof tokens)[number] => Boolean(token));

  function addToken(id: string) {
    setSelectedIds((current) => current.includes(id) ? current : [...current, id]);
    setResult("idle");
  }

  function removeToken(id: string) {
    setSelectedIds((current) => current.filter((item) => item !== id));
    setResult("idle");
  }

  return <div>
    <p className="text-xs font-black tracking-[0.12em] text-brand uppercase">Build the reply</p>
    <h3 className="mt-2 text-2xl font-bold tracking-tight">{language.prompt}</h3>
    <p className="mt-1 text-sm text-muted">{language.translation}</p>
    <div className={`${styles.answerZone} mt-6 flex min-h-24 flex-wrap content-start gap-2 rounded-2xl border-2 border-dashed border-line bg-canvas/70 p-3`} data-dragging={dragging} onDragOver={(event) => { event.preventDefault(); setDragging(true); }} onDragLeave={() => setDragging(false)} onDrop={(event) => { event.preventDefault(); setDragging(false); addToken(event.dataTransfer.getData("text/plain")); }}>
      {selected.length === 0 && <span className="m-auto text-sm font-semibold text-muted">Drag words here · or tap them</span>}
      {selected.map((token) => <button key={token.id} type="button" onClick={() => removeToken(token.id)} className={`${styles.token} focus-ring rounded-xl border border-brand/25 bg-brand-soft px-3 py-2 text-sm font-bold text-brand-dark`}>{token.text}</button>)}
    </div>
    <div className="mt-5 flex min-h-12 flex-wrap gap-2">
      {bank.map((token) => <button key={token.id} type="button" draggable onDragStart={(event) => { event.dataTransfer.setData("text/plain", token.id); event.dataTransfer.effectAllowed = "move"; }} onClick={() => addToken(token.id)} className={`${styles.token} focus-ring inline-flex items-center gap-1 rounded-xl border border-line bg-surface px-3 py-2 text-sm font-bold shadow-sm`}><GripVertical className="size-3.5 text-muted" />{token.text}</button>)}
    </div>
    <Feedback result={result} answer={language.answer} />
    {result === "correct" ? <button type="button" onClick={() => { setSelectedIds([]); setResult("idle"); }} className="focus-ring mt-5 inline-flex w-full items-center justify-center gap-2 rounded-xl border border-line bg-surface px-5 py-3 text-sm font-bold"><RotateCcw className="size-4" />Play again</button> : <CheckButton disabled={selected.length !== tokens.length} onClick={() => setResult(selected.map((token) => token.text).join(" ") === language.answer ? "correct" : "incorrect")} />}
  </div>;
}

function ChoiceButton({ text, selected, onClick }: { text: string; selected: boolean; onClick: () => void }) {
  return <button type="button" onClick={onClick} className={`focus-ring w-full rounded-xl border px-4 py-3 text-left text-sm font-bold transition ${selected ? "border-brand bg-brand-soft text-brand-dark shadow-[0_3px_0_var(--brand)]" : "border-line bg-surface hover:-translate-y-0.5 hover:border-brand/40"}`}>{text}</button>;
}

export function MissingWordExercise({ language }: { language: GameplayLanguage }) {
  const answerWords = language.answer.split(/\s+/);
  const blankIndex = Math.min(2, answerWords.length - 1);
  const correctWord = answerWords[blankIndex] ?? "";
  const choices = Array.from(new Set(language.options.map((option) => option.split(/\s+/)[blankIndex] ?? option.split(/\s+/)[0] ?? "")));
  const [selected, setSelected] = useState<string | null>(null);
  const [result, setResult] = useState<Result>("idle");
  return <div>
    <p className="text-xs font-black tracking-[0.12em] text-coral uppercase">Find the missing word</p>
    <h3 className="mt-2 text-2xl font-bold tracking-tight">{language.translation}</h3>
    <p className="mt-6 flex flex-wrap items-center gap-2 text-xl font-bold">{answerWords.map((word, index) => index === blankIndex ? <span key={`${word}-${index}`} className="min-w-24 rounded-lg border-b-2 border-brand bg-brand-soft px-3 py-1.5 text-center text-brand-dark">{selected ?? "••••"}</span> : <span key={`${word}-${index}`}>{word}</span>)}</p>
    <div className="mt-6 grid gap-2">{choices.map((choice) => <ChoiceButton key={choice} text={choice} selected={selected === choice} onClick={() => { setSelected(choice); setResult("idle"); }} />)}</div>
    <Feedback result={result} answer={language.answer} />
    <CheckButton disabled={!selected} onClick={() => setResult(selected === correctWord ? "correct" : "incorrect")} />
  </div>;
}

export function QuickReplyExercise({ language }: { language: GameplayLanguage }) {
  const [selected, setSelected] = useState<string | null>(null);
  const [result, setResult] = useState<Result>("idle");
  return <div>
    <p className="text-xs font-black tracking-[0.12em] text-violet-600 uppercase">Choose a natural reply</p>
    <h3 className="mt-2 text-2xl font-bold tracking-tight">{language.prompt}</h3>
    <div className="mt-6 grid gap-2">{language.options.map((option) => <ChoiceButton key={option} text={option} selected={selected === option} onClick={() => { setSelected(option); setResult("idle"); }} />)}</div>
    <Feedback result={result} answer={language.answer} />
    <CheckButton disabled={!selected} onClick={() => setResult(selected === language.answer ? "correct" : "incorrect")} />
  </div>;
}
