import Link from "next/link";
import { ArrowLeft, HeartHandshake } from "lucide-react";
import { Brand } from "@/components/brand";
import { ApplicationForm } from "@/features/moderators/application-form";

export default function ApplyPage() {
  return <main className="min-h-screen px-5 py-6 sm:px-8"><nav className="mx-auto flex max-w-4xl items-center justify-between"><Brand /><Link href="/" className="focus-ring flex items-center gap-2 rounded-lg px-3 py-2 text-xs font-bold text-muted hover:bg-white hover:text-ink"><ArrowLeft className="size-3.5" />Back</Link></nav><section className="mx-auto max-w-3xl py-14"><div className="mb-8 text-center"><span className="mx-auto grid size-11 place-items-center rounded-xl bg-brand-soft"><HeartHandshake className="size-5 text-brand" /></span><p className="mt-5 text-xs font-bold tracking-[0.15em] text-brand uppercase">Volunteer with us</p><h1 className="mt-3 text-3xl font-semibold tracking-tight sm:text-4xl">Help a language feel at home.</h1><p className="mx-auto mt-4 max-w-2xl text-sm leading-6 text-muted">Moderators review lessons for natural language, regional nuance, and useful everyday speech. You do not need a formal certificate—just care, fluency, and a little time.</p></div><ApplicationForm /></section></main>;
}
