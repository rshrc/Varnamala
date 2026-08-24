"use client";

import { useState } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { BookOpen, FileCheck2, LayoutDashboard, ListTodo, Menu, Settings, ShieldCheck, Users, X } from "lucide-react";
import { Brand } from "./brand";

const nav = [
  ["/dashboard", "Overview", LayoutDashboard, "moderator"],
  ["/courses", "Courses", BookOpen, "moderator"],
  ["/tasks", "Report tasks", ListTodo, "moderator"],
  ["/releases", "Releases", FileCheck2, "moderator"],
  ["/moderators", "Moderators", Users, "admin"],
  ["/settings/admins", "Access", ShieldCheck, "admin"],
] as const;

export function AppShell({ children, demo, name, role }: { children: React.ReactNode; demo: boolean; name: string; role: "moderator" | "admin" }) {
  const [open, setOpen] = useState(false);
  const pathname = usePathname();
  const initials = name.split(/\s+/).map((part) => part[0]).join("").slice(0, 2).toUpperCase();
  return <div className="min-h-screen lg:grid lg:grid-cols-[236px_1fr]">
    <button onClick={() => setOpen(true)} className="focus-ring fixed top-4 left-4 z-30 rounded-lg border border-line bg-white p-2 shadow-sm lg:hidden" aria-label="Open menu"><Menu className="size-5" /></button>
    {open && <button className="fixed inset-0 z-30 bg-slate-950/25 lg:hidden" onClick={() => setOpen(false)} aria-label="Close menu overlay" />}
    <aside className={`fixed inset-y-0 left-0 z-40 flex w-[236px] flex-col border-r border-line bg-[#fbfcfa] p-4 transition-transform lg:sticky lg:top-0 lg:h-screen ${open ? "translate-x-0" : "-translate-x-full lg:translate-x-0"}`}>
      <div className="flex items-center justify-between px-1 py-2"><Brand /><button onClick={() => setOpen(false)} className="p-1 lg:hidden" aria-label="Close menu"><X className="size-5" /></button></div>
      <nav className="mt-7 space-y-1" aria-label="Main navigation">{nav.filter(([, , , minimumRole]) => minimumRole === "moderator" || role === "admin").map(([href, label, Icon]) => { const active = pathname === href || (href !== "/dashboard" && pathname.startsWith(href)); return <Link key={href} href={href} onClick={() => setOpen(false)} className={`focus-ring soft-transition flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium ${active ? "bg-brand-soft text-brand-dark" : "text-slate-600 hover:bg-slate-100 hover:text-ink"}`}><Icon className="size-[18px]" strokeWidth={1.8} />{label}</Link>; })}</nav>
      <div className="mt-auto">
        {demo && <div className="mb-3 rounded-lg border border-amber-200 bg-amber-50 px-3 py-2.5 text-xs leading-5 text-amber-800"><strong>Preview mode</strong><br />Connect Firebase to enable secure writes.</div>}
        <div className="flex w-full items-center gap-3 rounded-lg border border-line bg-white p-2"><span className="grid size-8 place-items-center rounded-full bg-brand text-xs font-bold text-white">{initials}</span><span className="min-w-0 flex-1"><strong className="block truncate text-xs">{name}</strong><span className="text-[11px] text-muted">{role === "admin" ? "Administrator" : "Moderator"}</span></span></div>
        <Link href="/" className="mt-2 flex items-center gap-2 px-3 py-2 text-xs text-muted hover:text-ink"><Settings className="size-4" />Public site</Link>
      </div>
    </aside>
    <main className="min-w-0"><div className="mx-auto max-w-[1420px] px-5 py-20 sm:px-8 lg:px-10 lg:py-9">{children}</div></main>
  </div>;
}
