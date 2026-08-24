import { adminFirestore } from "@/services/firebase/admin";
import { getStaffSession } from "@/services/firebase/session";

export async function GET(_request: Request, { params }: { params: Promise<{ uid: string }> }): Promise<Response> {
  const session = await getStaffSession();
  if (session?.role !== "admin") return Response.json({ error: "Administrator access required." }, { status: 403 });
  const { uid } = await params;
  const proof = await adminFirestore().doc(`moderatorApplications/${uid}/private/proof`).get();
  if (!proof.exists) return Response.json({ error: "Proof not found." }, { status: 404 });
  const data = proof.data();
  const bytes = data?.bytes;
  const body = bytes instanceof Uint8Array ? bytes : bytes?.toUint8Array?.();
  if (!(body instanceof Uint8Array)) return Response.json({ error: "Proof is invalid." }, { status: 500 });
  return new Response(Uint8Array.from(body).buffer, { headers: { "content-type": String(data?.contentType ?? "application/octet-stream"), "content-disposition": `inline; filename="${String(data?.originalName ?? "proof").replace(/["\\]/g, "")}"`, "cache-control": "private, no-store" } });
}
