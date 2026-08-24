import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { homedir, tmpdir } from "node:os";
import path from "node:path";

const firebaseCliConfigPath = path.join(homedir(), ".config", "configstore", "firebase-tools.json");

type FirebaseCliConfig = {
  tokens?: { refresh_token?: string };
};

function firebaseCliRefreshToken(): string | null {
  if (!existsSync(firebaseCliConfigPath)) return null;

  try {
    const config = JSON.parse(readFileSync(firebaseCliConfigPath, "utf8")) as FirebaseCliConfig;
    return config.tokens?.refresh_token ?? null;
  } catch {
    return null;
  }
}

export function hasFirebaseCliCredential(): boolean {
  return Boolean(firebaseCliRefreshToken() && process.env.FIREBASE_CLI_CLIENT_ID && process.env.FIREBASE_CLI_CLIENT_SECRET);
}

/** Makes the authenticated Firebase CLI session available as local ADC. */
export function configureFirebaseCliApplicationDefault(): boolean {
  if (process.env.GOOGLE_APPLICATION_CREDENTIALS) return true;
  const token = firebaseCliRefreshToken();
  const clientId = process.env.FIREBASE_CLI_CLIENT_ID;
  const clientSecret = process.env.FIREBASE_CLI_CLIENT_SECRET;
  if (!token || !clientId || !clientSecret) return false;

  const credentialPath = path.join(tmpdir(), `varnamala-firebase-adc-${process.getuid?.() ?? "local"}.json`);
  writeFileSync(credentialPath, JSON.stringify({
    // These identify the open-source Firebase CLI OAuth client; the user's
    // private refresh token is copied only to a mode-0600 temporary file.
    client_id: clientId,
    client_secret: clientSecret,
    refresh_token: token,
    type: "authorized_user",
  }), { mode: 0o600 });
  process.env.GOOGLE_APPLICATION_CREDENTIALS = credentialPath;
  return true;
}
