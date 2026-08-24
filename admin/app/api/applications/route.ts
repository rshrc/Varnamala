import { NextResponse } from "next/server";
import { z } from "zod";
import { FieldValue } from "firebase-admin/firestore";
import { isLanguageId } from "@/logic/courses/catalog";
import { adminAuth, adminFirestore, isFirebaseAdminConfigured } from "@/services/firebase/admin";
import { getStaffSession } from "@/services/firebase/session";

const fieldsSchema = z.object({
  name: z.string().trim().min(2).max(80), language: z.string(),
  relationship: z.string().trim().min(2).max(80),
  hours: z.coerce.number().int().min(1).max(40),
  motivation: z.string().trim().min(40).max(1500),
});
const allowedTypes = new Set(["image/jpeg", "image/png", "application/pdf"]);
const maxProofBytes = 600 * 1024;

export async function POST(request: Request): Promise<NextResponse> {
  if (!isFirebaseAdminConfigured()) {
    if (process.env.NODE_ENV !== "production") return NextResponse.json({ ok: true, preview: true });
    return NextResponse.json({ error: "Applications are not configured." }, { status: 503 });
  }
  const bearer = request.headers.get("authorization");
  if (!bearer?.startsWith("Bearer ")) return NextResponse.json({ error: "Google sign-in is required." }, { status: 401 });
  let user;
  try { user = await adminAuth().verifyIdToken(bearer.slice(7)); }
  catch { return NextResponse.json({ error: "Your sign-in expired. Please try again." }, { status: 401 }); }

  const form = await request.formData();
  const parsed = fieldsSchema.safeParse({ name: form.get("name"), language: form.get("language"), relationship: form.get("relationship"), hours: form.get("hours"), motivation: form.get("motivation") });
  if (!parsed.success || !isLanguageId(parsed.data.language)) return NextResponse.json({ error: "Please complete every application field." }, { status: 400 });
  const proof = form.get("proof");
  if (!(proof instanceof File) || !allowedTypes.has(proof.type) || proof.size === 0 || proof.size > maxProofBytes) return NextResponse.json({ error: "Proof must be a JPEG, PNG, or PDF smaller than 600 KB." }, { status: 400 });

  const db = adminFirestore();
  const application = db.doc(`moderatorApplications/${user.uid}`);
  try {
    await db.runTransaction(async (transaction) => {
      const existing = await transaction.get(application);
      const status = existing.data()?.status;
      if (status === "submitted" || status === "approved") throw new Error("OPEN_APPLICATION");
      transaction.set(application, {
        applicantUid: user.uid, emailSnapshot: user.email ?? null,
        displayName: parsed.data.name, language: parsed.data.language,
        relationship: parsed.data.relationship, availabilityHoursPerWeek: parsed.data.hours,
        motivation: parsed.data.motivation, status: "submitted",
        submittedAt: FieldValue.serverTimestamp(), updatedAt: FieldValue.serverTimestamp(),
      }, { merge: true });
      transaction.set(application.collection("private").doc("proof"), {
        bytes: Buffer.from(await proof.arrayBuffer()), contentType: proof.type,
        originalName: proof.name.slice(0, 120), size: proof.size,
        createdAt: FieldValue.serverTimestamp(),
      });
    });
  } catch (error) {
    if (error instanceof Error && error.message === "OPEN_APPLICATION") return NextResponse.json({ error: "You already have an open application." }, { status: 409 });
    throw error;
  }
  return NextResponse.json({ ok: true });
}

const decisionSchema = z.object({ uid: z.string().min(1).max(160), action: z.enum(["approve", "reject"]) });

export async function PATCH(request: Request): Promise<NextResponse> {
  const session = await getStaffSession();
  if (session?.role !== "admin") return NextResponse.json({ error: "Administrator access required." }, { status: 403 });
  const parsed = decisionSchema.safeParse(await request.json());
  if (!parsed.success) return NextResponse.json({ error: "Invalid application update." }, { status: 400 });
  const db = adminFirestore();
  const application = db.doc(`moderatorApplications/${parsed.data.uid}`);
  const applicationDocument = await application.get();
  if (!applicationDocument.exists) return NextResponse.json({ error: "Application not found." }, { status: 404 });
  const data = applicationDocument.data();
  if (data?.status !== "submitted") return NextResponse.json({ error: "Application has already been reviewed." }, { status: 409 });
  if (parsed.data.action === "approve") {
    const user = await adminAuth().getUser(parsed.data.uid);
    await adminAuth().setCustomUserClaims(user.uid, { ...user.customClaims, moderator: true });
    const batch = db.batch();
    batch.set(db.doc(`staff/${user.uid}`), { status: "active", roles: FieldValue.arrayUnion("moderator"), languages: FieldValue.arrayUnion(data.language), email: user.email ?? data.emailSnapshot ?? null, displayName: data.displayName, updatedAt: FieldValue.serverTimestamp(), grantedBy: session.uid }, { merge: true });
    batch.update(application, { status: "approved", reviewedBy: session.uid, reviewedAt: FieldValue.serverTimestamp(), updatedAt: FieldValue.serverTimestamp() });
    batch.set(db.collection("courseAuditLog").doc(), { actorUid: session.uid, action: "moderator_approved", targetUid: user.uid, language: data.language, createdAt: FieldValue.serverTimestamp() });
    await batch.commit();
  } else {
    const batch = db.batch();
    batch.update(application, { status: "rejected", reviewedBy: session.uid, reviewedAt: FieldValue.serverTimestamp(), updatedAt: FieldValue.serverTimestamp() });
    batch.set(db.collection("courseAuditLog").doc(), { actorUid: session.uid, action: "moderator_rejected", targetUid: parsed.data.uid, language: data.language, createdAt: FieldValue.serverTimestamp() });
    await batch.commit();
  }
  return NextResponse.json({ ok: true });
}
