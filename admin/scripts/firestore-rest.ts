/**
 * Firestore access over the REST API.
 *
 * Deliberately not the firebase-admin client. Its REST transport has, in this
 * project, silently returned truncated query results (eight of thirteen
 * documents, no error) and thrown "Did not receive document" for documents
 * that exist. Both failure modes are invisible at the call site, and the
 * scripts here decide what production serves.
 */
import { readFileSync } from "node:fs";
import { homedir } from "node:os";
import path from "node:path";

export type RestDocument = {
  name: string;
  fields: Record<string, { stringValue?: string; integerValue?: string }>;
};

export const documentId = (name: string) => name.split("/").pop()!;

/** Exchanges the Firebase CLI's refresh token for an access token. */
export async function accessToken(): Promise<string> {
  const config = JSON.parse(
    readFileSync(
      path.join(homedir(), ".config", "configstore", "firebase-tools.json"),
      "utf8",
    ),
  ) as { tokens?: { refresh_token?: string } };

  const refreshToken = config.tokens?.refresh_token;
  const clientId = process.env.FIREBASE_CLI_CLIENT_ID;
  const clientSecret = process.env.FIREBASE_CLI_CLIENT_SECRET;
  if (!refreshToken || !clientId || !clientSecret) {
    throw new Error(
      "Run `firebase login`, and set FIREBASE_CLI_CLIENT_ID and " +
        "FIREBASE_CLI_CLIENT_SECRET (see admin/env.example).",
    );
  }

  const response = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      client_id: clientId,
      client_secret: clientSecret,
      refresh_token: refreshToken,
      grant_type: "refresh_token",
    }),
  });
  const body = (await response.json()) as { access_token?: string };
  if (!body.access_token) throw new Error("Could not refresh the access token.");
  return body.access_token;
}

export function documentsUrl(projectId: string): string {
  return `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents`;
}

/** Every document in a collection, paginating explicitly to the end. */
export async function listAll(
  base: string,
  token: string,
  collectionPath: string,
): Promise<RestDocument[]> {
  const documents: RestDocument[] = [];
  let pageToken: string | undefined;
  do {
    const url = new URL(`${base}/${collectionPath}`);
    url.searchParams.set("pageSize", "300");
    if (pageToken) url.searchParams.set("pageToken", pageToken);
    const response = await fetch(url, {
      headers: { Authorization: `Bearer ${token}` },
    });
    if (!response.ok) {
      throw new Error(`${collectionPath}: HTTP ${response.status}`);
    }
    const body = (await response.json()) as {
      documents?: RestDocument[];
      nextPageToken?: string;
    };
    documents.push(...(body.documents ?? []));
    pageToken = body.nextPageToken;
  } while (pageToken);
  return documents;
}
