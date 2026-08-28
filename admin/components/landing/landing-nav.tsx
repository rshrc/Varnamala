import Link from "next/link";
import { Brand } from "@/components/brand";

export function LandingNav() {
  return <nav className="mx-auto flex max-w-7xl items-center justify-between px-5 py-5 sm:px-8">
    <Brand href="/" label="Community learning" />
    <div className="flex items-center gap-1 sm:gap-2">
      <Link href="#playground" className="focus-ring hidden rounded-lg px-4 py-2 text-sm font-semibold text-muted hover:bg-surface sm:block">Try a lesson</Link>
      <Link href="/apply" className="focus-ring hidden rounded-lg px-4 py-2 text-sm font-semibold text-ink hover:bg-surface sm:block">Volunteer</Link>
      <Link href="/login" className="focus-ring rounded-lg bg-ink px-3 py-2 text-sm font-bold text-white hover:bg-slate-800 sm:px-4">Staff sign in</Link>
    </div>
  </nav>;
}
