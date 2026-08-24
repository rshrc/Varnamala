import "server-only";

import { isLanguageId, type LanguageId } from "@/logic/courses/catalog";
import { adminFirestore } from "./admin";

function timestampIso(value: unknown): string | null {
  if (value && typeof value === "object" && "toDate" in value && typeof value.toDate === "function") return value.toDate().toISOString();
  return null;
}

export type ModeratorApplication = {
  uid: string;
  name: string;
  email: string | null;
  language: LanguageId;
  relationship: string;
  hours: number;
  motivation: string;
  status: "submitted" | "approved" | "rejected";
  submittedAt: string | null;
};

export type AdminMember = { uid: string; name: string; email: string; languages: LanguageId[]; updatedAt: string | null };

export async function getModeratorApplications(): Promise<ModeratorApplication[]> {
  const snapshot = await adminFirestore().collection("moderatorApplications").orderBy("submittedAt", "desc").limit(100).get();
  return snapshot.docs.flatMap((document) => {
    const data = document.data();
    const status = data.status;
    if (!isLanguageId(String(data.language)) || !["submitted", "approved", "rejected"].includes(status)) return [];
    return [{ uid: document.id, name: String(data.displayName ?? "Applicant"), email: typeof data.emailSnapshot === "string" ? data.emailSnapshot : null, language: data.language as LanguageId, relationship: String(data.relationship ?? ""), hours: Number(data.availabilityHoursPerWeek ?? 0), motivation: String(data.motivation ?? ""), status, submittedAt: timestampIso(data.submittedAt) }];
  });
}

export async function getAdministrators(): Promise<AdminMember[]> {
  const snapshot = await adminFirestore().collection("staff").where("roles", "array-contains", "admin").get();
  return snapshot.docs.map((document) => {
    const data = document.data();
    const languages = Array.isArray(data.languages) ? data.languages.filter((value): value is LanguageId => typeof value === "string" && isLanguageId(value)) : [];
    return { uid: document.id, name: String(data.displayName ?? data.email ?? "Administrator"), email: String(data.email ?? ""), languages, updatedAt: timestampIso(data.updatedAt ?? data.grantedAt) };
  });
}
