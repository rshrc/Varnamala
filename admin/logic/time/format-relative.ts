export function formatRelativeTime(iso: string | null): string {
  if (!iso) return "Not yet";
  const elapsed = Date.now() - new Date(iso).getTime();
  if (!Number.isFinite(elapsed)) return "Unknown";
  const minutes = Math.max(0, Math.floor(elapsed / 60_000));
  if (minutes < 1) return "Just now";
  if (minutes < 60) return `${minutes}m ago`;
  const hours = Math.floor(minutes / 60);
  if (hours < 24) return `${hours}h ago`;
  const days = Math.floor(hours / 24);
  if (days < 30) return `${days}d ago`;
  return new Intl.DateTimeFormat("en", { dateStyle: "medium" }).format(new Date(iso));
}
