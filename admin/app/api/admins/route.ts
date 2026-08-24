import { NextResponse } from "next/server";
import { z } from "zod";
import { FieldValue } from "firebase-admin/firestore";
import { adminAuth, adminFirestore } from "@/services/firebase/admin";
import { getStaffSession } from "@/services/firebase/session";

const requestSchema = z.object({ email: z.string().trim().email().max(254) });

export async function POST(request: Request): Promise<NextResponse> {
  const session = await getStaffSession();
  if (session?.role !== "admin") return NextResponse.json({ error: "Administrator access required." }, { status: 403 });
  const parsed = requestSchema.safeParse(await request.json());
  if (!parsed.success) return NextResponse.json({ error: "Enter a valid Firebase user email." }, { status: 400 });
  let user;
  try { user = await adminAuth().getUserByEmail(parsed.data.email.toLowerCase()); }
  catch { return NextResponse.json({ error: "That person must sign in to Varnamala once before becoming an admin." }, { status: 404 }); }
  await adminAuth().setCustomUserClaims(user.uid, { ...user.customClaims, admin: true, moderator: true });
  const db = adminFirestore();
  const batch = db.batch();
  batch.set(db.doc(`staff/${user.uid}`), { status: "active", roles: FieldValue.arrayUnion("admin", "moderator"), email: user.email ?? parsed.data.email, displayName: user.displayName ?? user.email ?? "Administrator", updatedAt: FieldValue.serverTimestamp(), grantedBy: session.uid }, { merge: true });
  batch.set(db.collection("courseAuditLog").doc(), { actorUid: session.uid, action: "admin_granted", targetUid: user.uid, createdAt: FieldValue.serverTimestamp() });
  await batch.commit();
  return NextResponse.json({ ok: true });
}
