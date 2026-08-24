import { z } from "zod";
import { isLanguageId, type LanguageId } from "@/logic/courses/catalog";

export const taskStatusSchema = z.enum(["open", "in_progress", "resolved"]);
export type TaskStatus = z.infer<typeof taskStatusSchema>;

export type ContentReportTask = {
  id: string;
  language: LanguageId;
  course: string;
  reason: string;
  reasonLabel: string;
  detail: string;
  sentence: string | null;
  status: TaskStatus;
  assignedTo: string | null;
  assignedToName: string | null;
  createdAt: string | null;
};

export function isTaskLanguage(value: unknown): value is LanguageId {
  return typeof value === "string" && isLanguageId(value);
}
