import "server-only";

import { cache } from "react";
import { cookies } from "next/headers";
import type { StaffRole } from "@/logic/access/permissions";
import { adminAuth, isFirebaseAdminConfigured } from "./admin";

export const SESSION_COOKIE = "varnamala_admin_session";

export type StaffSession = { uid: string; role: StaffRole; name: string };

export const getStaffSession = cache(async (): Promise<StaffSession | null> => {
  if (!isFirebaseAdminConfigured()) return null;
  const value = (await cookies()).get(SESSION_COOKIE)?.value;
  if (!value) return null;
  try {
    const token = await adminAuth().verifySessionCookie(value, true);
    const role: StaffRole = token.admin === true ? "admin" : token.moderator === true ? "moderator" : "learner";
    if (role === "learner") return null;
    return { uid: token.uid, role, name: typeof token.name === "string" ? token.name : "Varnamala staff" };
  } catch { return null; }
});

export function demoModeEnabled(): boolean {
  return !isFirebaseAdminConfigured() && process.env.NODE_ENV !== "production";
}
