import "server-only";

import type { ContentReportTask, TaskStatus } from "@/logic/tasks/schemas";
import { isTaskLanguage, taskStatusSchema } from "@/logic/tasks/schemas";
import { adminFirestore } from "./admin";

function timestampIso(value: unknown): string | null {
  if (value && typeof value === "object" && "toDate" in value && typeof value.toDate === "function") return value.toDate().toISOString();
  return null;
}

export async function getContentReportTasks(): Promise<ContentReportTask[]> {
  const snapshot = await adminFirestore().collection("contentReports").orderBy("createdAt", "desc").limit(200).get();
  return snapshot.docs.flatMap((document) => {
    const data = document.data();
    const status = taskStatusSchema.safeParse(data.status);
    if (!isTaskLanguage(data.language) || !status.success) return [];
    return [{
      id: document.id,
      language: data.language,
      course: String(data.course ?? "Unknown course"),
      reason: String(data.reason ?? "other"),
      reasonLabel: String(data.reasonLabel ?? "Content issue"),
      detail: String(data.detail ?? ""),
      sentence: typeof data.sentence === "string" && data.sentence ? data.sentence : null,
      status: status.data,
      assignedTo: typeof data.assignedTo === "string" ? data.assignedTo : null,
      assignedToName: typeof data.assignedToName === "string" ? data.assignedToName : null,
      createdAt: timestampIso(data.createdAt),
    }];
  });
}

export async function countTasks(statuses: readonly TaskStatus[]): Promise<number> {
  const snapshot = await adminFirestore().collection("contentReports").where("status", "in", [...statuses]).count().get();
  return snapshot.data().count;
}
