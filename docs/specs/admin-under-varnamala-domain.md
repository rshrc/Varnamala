# Moving the admin console to `varnamala.com/admin`

Status: **plan only, nothing implemented.** No files in `admin/` have been
touched. This is a record of the decision and the work it implies, so it can be
picked up later on its own branch.

## The premise to correct first

The original idea was `varnamala.org` for the website and `app.varnamala.org`
for the Flutter app, which was then dropped on cost grounds ("I can't afford
another Vercel project"). That constraint does not actually apply: **one Vercel
project already covers both**, because `admin/` is a single Next app containing
the public site *and* the console.

- `admin/app/page.tsx` — already a full marketing landing page (hero,
  `EthosSection`, `GameplayPlayground`, `ReleaseProof`, `languageCatalog`, its
  own `landing.module.css` and `components/landing/`)
- `admin/app/(workspace)/` — the console, in a Next **route group**, so the
  parentheses add no URL segment
- `admin/app/apply/`, `admin/app/login/` — public, top-level

So the real problem is not hosting cost. It is that the console currently sits
on bare root paths right next to the marketing pages:

| today | wanted |
|---|---|
| `/` → landing | `/` → landing |
| `/apply` → volunteer form | `/apply` |
| `/dashboard`, `/courses`, `/releases`, `/moderators`, `/tasks`, `/settings/admins` | `/admin/...` |

`/courses` is ambiguous between "our public course catalogue" and "the admin
course editor". Namespacing the console under `/admin` fixes that and matches
what was asked for.

## Plan

### 1. One directory rename

`admin/app/(workspace)/` → `admin/app/admin/`

Dropping the parentheses turns a route group into a real URL segment, and every
console page moves under `/admin` at once. No page file contents change.

### 2. Update internal references

Roughly six, from a partial read — grep for `href="/` and `redirect("` across
`admin/` rather than trusting this table.

| file | change |
|---|---|
| `app/admin/layout.tsx` | `redirect("/login")` → carry a `?next=` (see 3) |
| `app/admin/tasks/page.tsx` | same `redirect("/login")` |
| `app/admin/settings/admins/page.tsx` | `redirect("/dashboard")` → `/admin/dashboard` |
| `app/admin/moderators/page.tsx` | `redirect("/dashboard")` → `/admin/dashboard` |
| nav / landing components | `href="/courses"`, `href="/releases"`, `href="/tasks"` → `/admin/...` |

### 3. Post-login destination

`/login` sends you to `/dashboard` today; it should send you to
`/admin/dashboard`, and honour a `?next=` param so a deep link into the console
survives the login bounce.

### 4. Keep the old URLs alive

Permanent redirects in `next.config` for `/dashboard`, `/tasks`, `/releases`,
`/moderators`, `/settings/*` → `/admin/*`, so existing bookmarks and Slack links
still land. Cheap insurance; delete in a few months.

### 5. Docs

`admin/README.md` still documents `admin.varnamala.org` on Vercel — rewrite for
the single-origin layout. Add a line to the root `CLAUDE.md`, since "where does
the admin console live" is invisible from the code.

## What the shared origin costs, and the mitigations

Separate origins were doing real security work: a stored-XSS on a marketing page
could not touch admin session cookies, because the browser would not hand them
over. On one origin it can. Since the single-project constraint stands, these
replace that isolation:

- **A strict CSP across the whole app** — no `unsafe-inline`, nonce-based
  scripts. This is the main substitute for origin isolation.
- **No third-party scripts on public pages.** Analytics, chat widgets, embeds —
  each becomes a path to the admin session. Self-host or use something
  script-free.
- **`httpOnly` + `SameSite=Strict` + `Secure` session cookies**, scoped
  `path=/admin` so the cookie is not even sent on marketing requests.
- **Keep the guard server-side in `app/admin/layout.tsx`**, where it already is
  (`getStaffSession()` → `redirect("/login")`). Do not move it to middleware — a
  layout guard is harder to bypass than a matcher someone forgets to update.

## Domain

`.org` vs `.com` is independent of all of the above: one Vercel domain setting
plus a redirect from the other. Pick one as canonical; the code does not care.
Same for `app.varnamala.org` later — a subdomain costs nothing on the same
project if it is ever pointed at a separate deploy.

## Sequencing

Own branch off `main`. The `responsiveness` branch carries ~35 uncommitted
Flutter files and no commits; tangling a Next.js restructure into it makes both
harder to review.

`admin/` may have its own `CLAUDE.md` / `AGENTS.md` conventions — read those
before writing anything.
