import { applicationDefault, cert, getApps, initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { initializeFirestore } from "firebase-admin/firestore";
import { configureFirebaseCliApplicationDefault } from "../services/firebase/local-credential.ts";

function required(name: "FIREBASE_PROJECT_ID"): string {
  const value = process.env[name];
  if (!value) throw new Error(`${name} is required.`);
  return value;
}

const projectId = required("FIREBASE_PROJECT_ID");
const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
const privateKey = process.env.FIREBASE_PRIVATE_KEY;

export function scriptCredential() {
  if (clientEmail && privateKey) {
    return cert({ projectId, clientEmail, privateKey: privateKey.replace(/\\n/g, "\n") });
  }
  configureFirebaseCliApplicationDefault();
  return applicationDefault();
}

const app = getApps()[0] ?? initializeApp({ credential: scriptCredential(), projectId });

export const scriptProjectId = projectId;
export const scriptAuth = getAuth(app);
export function scriptFirestore() { return initializeFirestore(app, { preferRest: true }); }
