import { NextResponse } from "next/server";
import { z } from "zod";
import { FieldValue } from "firebase-admin/firestore";
import { isLanguageId } from "@/logic/courses/catalog";
import { courseFileSchema } from "@/logic/courses/schemas";
import { validateCourse } from "@/logic/courses/validate-course";
import { adminFirestore } from "@/services/firebase/admin";
import { demoModeEnabled, getStaffSession } from "@/services/firebase/session";

const requestSchema = z.object({
  language: z.string(),
  baseReleaseId: z.string().min(1).max(80),
  course: courseFileSchema,
});

export async function POST(request: Request): Promise<NextResponse> {
  const session = await getStaffSession();
  if (!session) {
    if (demoModeEnabled()) return NextResponse.json({ ok: true, preview: true });
    return NextResponse.json({ error: "Authentication required." }, { status: 401 });
  }
  const parsed = requestSchema.safeParse(await request.json());
  if (!parsed.success || !isLanguageId(parsed.data.language)) return NextResponse.json({ error: "Invalid course draft." }, { status: 400 });

  const db = adminFirestore();
  if (session.role === "moderator") {
    const staff = await db.doc(`staff/${session.uid}`).get();
    const assigned = staff.data()?.languages;
    if (!Array.isArray(assigned) || !assigned.includes(parsed.data.language)) return NextResponse.json({ error: "This language is not assigned to you." }, { status: 403 });
  }

  const draftId = `${parsed.data.language}-${session.uid}`;
  const draft = db.doc(`courseDrafts/${draftId}`);
  const file = draft.collection("files").doc(parsed.data.course.course);
  const batch = db.batch();
  batch.set(draft, {
    language: parsed.data.language, baseReleaseId: parsed.data.baseReleaseId,
    status: "draft", updatedBy: session.uid, updatedAt: FieldValue.serverTimestamp(),
    createdBy: session.uid, createdAt: FieldValue.serverTimestamp(),
  }, { merge: true });
  batch.set(file, {
    fileName: `${parsed.data.course.course}.json`, kind: "course",
    language: parsed.data.language, contentJson: JSON.stringify(parsed.data.course),
    validationIssues: validateCourse(parsed.data.course), updatedBy: session.uid,
    updatedAt: FieldValue.serverTimestamp(),
  }, { merge: true });
  await batch.commit();
  return NextResponse.json({ ok: true, draftId });
}
