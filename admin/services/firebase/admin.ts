import "server-only";

import { existsSync } from "node:fs";
import { homedir } from "node:os";
import path from "node:path";
import { applicationDefault, cert, getApps, initializeApp, type App } from "firebase-admin/app";
import { getAuth, type Auth } from "firebase-admin/auth";
import { getFirestore, initializeFirestore, type Firestore } from "firebase-admin/firestore";
import { configureFirebaseCliApplicationDefault, hasFirebaseCliCredential } from "@/services/firebase/local-credential";

function hasServiceAccount(): boolean {
  return Boolean(process.env.FIREBASE_CLIENT_EMAIL && process.env.FIREBASE_PRIVATE_KEY);
}

function hasApplicationDefaultCredentials(): boolean {
  const configuredPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;
  if (configuredPath) return existsSync(configuredPath);
  return existsSync(path.join(homedir(), ".config", "gcloud", "application_default_credentials.json"));
}

export function isFirebaseAdminConfigured(): boolean {
  return hasServiceAccount() || hasFirebaseCliCredential() || hasApplicationDefaultCredentials();
}

function adminApp(): App {
  if (getApps().length) return getApps()[0] as App;
  if (!isFirebaseAdminConfigured()) {
    throw new Error("Firebase Admin credentials are missing. Run `gcloud auth application-default login` locally or configure the Vercel service-account variables.");
  }

  const projectId = process.env.FIREBASE_PROJECT_ID;
  if (!projectId) throw new Error("FIREBASE_PROJECT_ID is required.");
  if (!hasServiceAccount()) configureFirebaseCliApplicationDefault();
  const credential = hasServiceAccount()
    ? cert({
        projectId,
        clientEmail: process.env.FIREBASE_CLIENT_EMAIL as string,
        privateKey: (process.env.FIREBASE_PRIVATE_KEY as string).replace(/\\n/g, "\n"),
      })
    : applicationDefault();

  return initializeApp({ credential, projectId });
}

export function adminAuth(): Auth { return getAuth(adminApp()); }
const firebaseGlobal = globalThis as typeof globalThis & { varnamalaAdminFirestore?: Firestore };
export function adminFirestore(): Firestore {
  if (!firebaseGlobal.varnamalaAdminFirestore) {
    const app = adminApp();
    try {
      firebaseGlobal.varnamalaAdminFirestore = initializeFirestore(app, { preferRest: true });
    } catch (error) {
      if (!(error instanceof Error) || !error.message.includes("already been called")) throw error;
      firebaseGlobal.varnamalaAdminFirestore = getFirestore(app);
    }
  }
  return firebaseGlobal.varnamalaAdminFirestore;
}
