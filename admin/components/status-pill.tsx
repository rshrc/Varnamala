export function StatusPill({ status }: { status: "ready" | "review" | "active" | "pending" }) {
  const styles = status === "ready" || status === "active"
    ? "bg-emerald-50 text-emerald-700 ring-emerald-600/15"
    : "bg-amber-50 text-amber-700 ring-amber-600/15";
  return <span className={`inline-flex items-center gap-1.5 rounded-full px-2 py-1 text-xs font-semibold ring-1 ring-inset ${styles}`}><span className="size-1.5 rounded-full bg-current" />{status === "review" ? "Needs review" : status[0]?.toUpperCase() + status.slice(1)}</span>;
}
