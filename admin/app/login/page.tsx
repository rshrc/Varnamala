import Link from "next/link";
import { ArrowLeft } from "lucide-react";
import { Brand } from "@/components/brand";
import { GoogleSignIn } from "@/features/auth/google-sign-in";

export default function LoginPage() {
  return <main className="grid min-h-screen place-items-center px-5 py-14"><div className="w-full max-w-sm"><div className="mb-8 flex justify-center"><Brand /></div><div className="card p-6 sm:p-8"><p className="text-xs font-bold tracking-[0.15em] text-brand uppercase">Staff workspace</p><h1 className="mt-3 text-2xl font-semibold tracking-tight">Welcome back</h1><p className="mt-2 mb-7 text-sm leading-6 text-muted">Use the Google account connected to your moderator or admin access.</p><GoogleSignIn /><div className="my-6 h-px bg-line" /><Link href="/apply" className="focus-ring block rounded-lg border border-line px-4 py-2.5 text-center text-sm font-semibold hover:border-brand/30 hover:bg-brand-soft">Not staff yet? Apply to volunteer</Link></div><Link href="/" className="mx-auto mt-5 flex w-fit items-center gap-2 text-xs font-semibold text-muted hover:text-ink"><ArrowLeft className="size-3.5" />Back to Varnamala Admin</Link></div></main>;
}
