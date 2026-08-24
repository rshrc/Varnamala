import { NextResponse } from "next/server";
import { z } from "zod";
import { FieldValue } from "firebase-admin/firestore";
import { adminFirestore } from "@/services/firebase/admin";
import { getStaffSession } from "@/services/firebase/session";

const requestSchema = z.object({ reportId: z.string().min(1).max(160), action: z.enum(["claim", "resolve"]) });

export async function PATCH(request: Request): Promise<NextResponse> {
  const session = await getStaffSession();
  if (!session) return NextResponse.json({ error: "Authentication required." }, { status: 401 });
  const parsed = requestSchema.safeParse(await request.json());
  if (!parsed.success) return NextResponse.json({ error: "Invalid task update." }, { status: 400 });
  const db = adminFirestore();
  const report = db.doc(`contentReports/${parsed.data.reportId}`);
  try {
    await db.runTransaction(async (transaction) => {
      const [reportDocument, staffDocument] = await Promise.all([transaction.get(report), transaction.get(db.doc(`staff/${session.uid}`))]);
      if (!reportDocument.exists) throw new Error("NOT_FOUND");
      const data = reportDocument.data();
      if (session.role === "moderator") {
        const languages = staffDocument.data()?.languages;
        if (!Array.isArray(languages) || !languages.includes(data?.language)) throw new Error("NOT_ASSIGNED");
      }
      if (parsed.data.action === "claim") {
        if (data?.status !== "open") throw new Error("ALREADY_CLAIMED");
        transaction.update(report, { status: "in_progress", assignedTo: session.uid, assignedToName: session.name, assignedAt: FieldValue.serverTimestamp(), updatedAt: FieldValue.serverTimestamp() });
      } else {
        if (data?.status !== "in_progress") throw new Error("NOT_IN_PROGRESS");
        if (session.role !== "admin" && data.assignedTo !== session.uid) throw new Error("NOT_OWNER");
        transaction.update(report, { status: "resolved", resolvedBy: session.uid, resolvedAt: FieldValue.serverTimestamp(), updatedAt: FieldValue.serverTimestamp() });
      }
      transaction.set(db.collection("courseAuditLog").doc(), { actorUid: session.uid, action: `report_${parsed.data.action}`, reportId: parsed.data.reportId, createdAt: FieldValue.serverTimestamp() });
    });
  } catch (error) {
    const code = error instanceof Error ? error.message : "";
    if (code === "NOT_FOUND") return NextResponse.json({ error: "Task not found." }, { status: 404 });
    if (["NOT_ASSIGNED", "NOT_OWNER"].includes(code)) return NextResponse.json({ error: "You cannot update this task." }, { status: 403 });
    if (["ALREADY_CLAIMED", "NOT_IN_PROGRESS"].includes(code)) return NextResponse.json({ error: "This task changed. Refresh and try again." }, { status: 409 });
    throw error;
  }
  return NextResponse.json({ ok: true });
}
