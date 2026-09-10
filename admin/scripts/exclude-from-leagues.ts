/**
 * Keeps an account off the leaderboards, or puts it back.
 *
 *   bun run scripts/exclude-from-leagues.ts someone@example.com
 *   bun run scripts/exclude-from-leagues.ts --include someone@example.com
 *   bun run scripts/exclude-from-leagues.ts --list
 *
 * For the people building the app. A maintainer who has replayed a lesson two
 * hundred times is not a learner other learners should be ranked against.
 *
 * Sets `excludedFromLeagues` on the user document; `rankForLeague` drops those
 * entries. Deliberately a flag on the data rather than a list of addresses in
 * the app: the web bundle is public, so hardcoding staff emails there would
 * publish them, and a flag also covers accounts added later without a release.
 */
import { accessToken, documentId, documentsUrl, listAll } from "./firestore-rest.ts";

const args = process.argv.slice(2);
const include = args.includes("--include");
const listOnly = args.includes("--list");
const emails = args.filter((a) => !a.startsWith("--"));

const projectId = process.env.FIREBASE_PROJECT_ID;
if (!projectId) throw new Error("FIREBASE_PROJECT_ID is required.");

const token = await accessToken();
const base = documentsUrl(projectId);
const auth = { Authorization: `Bearer ${token}` };

if (listOnly) {
  const users = await listAll(base, token, "users");
  const excluded = users.filter(
    (u: any) => u.fields?.excludedFromLeagues?.booleanValue === true,
  );
  console.error(`excluded accounts: ${excluded.length}`);
  for (const u of excluded) {
    console.error(`  ${documentId(u.name)}  ${(u.fields as any).name?.stringValue ?? "-"}`);
  }
  process.exit(0);
}

if (emails.length === 0) {
  throw new Error("Pass at least one email address, or --list.");
}

// User documents are keyed by Auth uid and do not store the address, so the
// address has to be resolved through Auth first.
const lookup = await fetch(
  `https://identitytoolkit.googleapis.com/v1/projects/${projectId}/accounts:lookup`,
  {
    method: "POST",
    headers: { ...auth, "Content-Type": "application/json" },
    body: JSON.stringify({ email: emails }),
  },
);
if (!lookup.ok) throw new Error(`Auth lookup failed: HTTP ${lookup.status}`);
const found = ((await lookup.json()) as { users?: { email: string; localId: string }[] })
  .users ?? [];

const missing = emails.filter(
  (e) => !found.some((u) => u.email.toLowerCase() === e.toLowerCase()),
);
for (const email of missing) console.error(`${email}: no such account`);

for (const user of found) {
  const url =
    `${base}/users/${user.localId}` +
    `?updateMask.fieldPaths=excludedFromLeagues`;
  const response = await fetch(url, {
    method: "PATCH",
    headers: { ...auth, "Content-Type": "application/json" },
    body: JSON.stringify({
      fields: { excludedFromLeagues: { booleanValue: !include } },
    }),
  });
  console.error(
    `${user.email} (${user.localId}): ` +
      (response.ok
        ? include
          ? "back on the boards"
          : "excluded from the boards"
        : `FAILED HTTP ${response.status}`),
  );
}

if (missing.length > 0) process.exit(1);
