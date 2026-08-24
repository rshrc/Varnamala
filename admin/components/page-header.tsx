export function PageHeader({ eyebrow, title, description, actions }: { eyebrow?: string; title: string; description: string; actions?: React.ReactNode }) {
  return <header className="mb-7 flex flex-col justify-between gap-4 sm:flex-row sm:items-end">
    <div>{eyebrow && <p className="mb-2 text-xs font-bold tracking-[0.15em] text-brand uppercase">{eyebrow}</p>}<h1 className="text-2xl font-semibold tracking-tight text-ink sm:text-[28px]">{title}</h1><p className="mt-2 max-w-2xl text-sm leading-6 text-muted">{description}</p></div>
    {actions && <div className="flex shrink-0 items-center gap-2">{actions}</div>}
  </header>;
}
