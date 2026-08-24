"use client";

import { getApp, getApps, initializeApp, type FirebaseApp, type FirebaseOptions } from "firebase/app";
import { getAuth, type Auth } from "firebase/auth";

const config = {
  apiKey: process.env.NEXT_PUBLIC_FIREBASE_API_KEY,
  authDomain: process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN,
  projectId: process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID,
  storageBucket: process.env.NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: process.env.NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID,
  appId: process.env.NEXT_PUBLIC_FIREBASE_APP_ID,
};

type ConfiguredFirebaseClient = typeof config & {
  apiKey: string;
  authDomain: string;
  projectId: string;
  appId: string;
};

function hasRequiredConfig(value: typeof config): value is ConfiguredFirebaseClient {
  return Boolean(value.apiKey && value.authDomain && value.projectId && value.appId);
}

export function isFirebaseClientConfigured(): boolean {
  return hasRequiredConfig(config);
}

function firebaseApp(): FirebaseApp {
  if (!hasRequiredConfig(config)) throw new Error("Firebase browser configuration is missing.");
  const validatedConfig: FirebaseOptions = {
    apiKey: config.apiKey,
    authDomain: config.authDomain,
    projectId: config.projectId,
    appId: config.appId,
    ...(config.storageBucket ? { storageBucket: config.storageBucket } : {}),
    ...(config.messagingSenderId ? { messagingSenderId: config.messagingSenderId } : {}),
  };
  return getApps().length ? getApp() : initializeApp(validatedConfig);
}

export function firebaseAuth(): Auth { return getAuth(firebaseApp()); }
