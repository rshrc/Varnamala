import Link from "next/link";

export function Brand({ compact = false, href = "/dashboard", label = "Admin" }: { compact?: boolean; href?: string; label?: string }) {
  return (
    <Link href={href} className="focus-ring flex items-center gap-3 rounded-lg" aria-label={`Varnamala ${label} home`}>
      <span className="grid size-9 place-items-center rounded-[11px] bg-brand text-sm font-bold text-white shadow-sm">ವ</span>
      {!compact && <span><strong className="block text-[15px] leading-4 tracking-tight">Varnamala</strong><span className="text-[11px] font-semibold tracking-[0.16em] text-muted uppercase">{label}</span></span>}
    </Link>
  );
}
