import { NextResponse } from "next/server";
import { z } from "zod";
import { adminAuth, isFirebaseAdminConfigured } from "@/services/firebase/admin";
import { SESSION_COOKIE } from "@/services/firebase/session";

const bodySchema = z.object({ idToken: z.string().min(100) });
const fiveDays = 5 * 24 * 60 * 60 * 1000;

export async function POST(request: Request): Promise<NextResponse> {
  if (!isFirebaseAdminConfigured()) return NextResponse.json({ error: "Authentication is not configured." }, { status: 503 });
  const parsed = bodySchema.safeParse(await request.json());
  if (!parsed.success) return NextResponse.json({ error: "Invalid token." }, { status: 400 });
  try {
    const decoded = await adminAuth().verifyIdToken(parsed.data.idToken);
    if (decoded.admin !== true && decoded.moderator !== true) return NextResponse.json({ error: "Your account does not have staff access." }, { status: 403 });
    const cookie = await adminAuth().createSessionCookie(parsed.data.idToken, { expiresIn: fiveDays });
    const response = NextResponse.json({ ok: true });
    response.cookies.set(SESSION_COOKIE, cookie, { httpOnly: true, secure: process.env.NODE_ENV === "production", sameSite: "lax", path: "/", maxAge: fiveDays / 1000 });
    return response;
  } catch { return NextResponse.json({ error: "Could not verify your Google session." }, { status: 401 }); }
}

export async function DELETE(): Promise<NextResponse> {
  const response = NextResponse.json({ ok: true });
  response.cookies.delete(SESSION_COOKIE);
  return response;
}
