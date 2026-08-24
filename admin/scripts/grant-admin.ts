import { scriptAuth, scriptCredential, scriptProjectId } from "./firebase-admin.ts";

type FirestoreValue =
  | { stringValue: string }
  | { timestampValue: string }
  | { arrayValue: { values?: FirestoreValue[] } };

async function firestoreWrite(path: string, fields: Record<string, FirestoreValue>, method: "PATCH" | "POST") {
  const { access_token: accessToken } = await scriptCredential().getAccessToken();
  const url = new URL(`https://firestore.googleapis.com/v1/projects/${scriptProjectId}/databases/(default)/documents/${path}`);
  const response = await fetch(url, {
    method,
    headers: { authorization: `Bearer ${accessToken}`, "content-type": "application/json" },
    body: JSON.stringify({ fields }),
  });
  if (!response.ok) throw new Error(`Firestore write failed (${response.status}): ${await response.text()}`);
}

const email = "rishieric91@gmail.com";
const user = await scriptAuth.getUserByEmail(email);
const claims = user.customClaims ?? {};

await scriptAuth.setCustomUserClaims(user.uid, { ...claims, admin: true, moderator: true });
const now = new Date().toISOString();
await firestoreWrite(`staff/${user.uid}`, {
  status: { stringValue: "active" },
  roles: { arrayValue: { values: [{ stringValue: "admin" }, { stringValue: "moderator" }] } },
  languages: { arrayValue: {} },
  email: { stringValue: email },
  grantedAt: { timestampValue: now },
  updatedAt: { timestampValue: now },
}, "PATCH");
await firestoreWrite("courseAuditLog", {
  actorUid: { stringValue: user.uid },
  action: { stringValue: "bootstrap_admin_granted" },
  targetUid: { stringValue: user.uid },
  createdAt: { timestampValue: now },
}, "POST");

console.info(`Administrator access granted to ${email} (${user.uid}). Sign in again to refresh claims.`);
