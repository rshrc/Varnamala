export default function WorkspaceLoading() {
  return (
    <div className="animate-pulse" aria-label="Loading page" aria-live="polite">
      <div className="mb-7 space-y-3">
        <div className="h-3 w-24 rounded-full bg-brand/15" />
        <div className="h-8 w-64 max-w-full rounded-lg bg-slate-200" />
        <div className="h-4 w-full max-w-xl rounded bg-slate-200/80" />
      </div>
      <section className="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
        {Array.from({ length: 6 }, (_, index) => (
          <div className="card h-40 p-5" key={index}>
            <div className="size-10 rounded-xl bg-brand/10" />
            <div className="mt-5 h-4 w-2/3 rounded bg-slate-200" />
            <div className="mt-3 h-3 w-1/2 rounded bg-slate-200/80" />
            <div className="mt-5 h-px bg-line" />
          </div>
        ))}
      </section>
    </div>
  );
}
