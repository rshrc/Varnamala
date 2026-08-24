import { KeyRound } from "lucide-react";
import { redirect } from "next/navigation";
import { PageHeader } from "@/components/page-header";
import { AdminList } from "@/features/admins/admin-list";
import { getStaffSession } from "@/services/firebase/session";
import { getAdministrators } from "@/services/firebase/staff-repository";

export default async function AdminAccessPage() {
  const session = await getStaffSession();
  if (session?.role !== "admin") redirect("/dashboard");
  const admins = await getAdministrators();
  return <><PageHeader eyebrow="Access control" title="Administrators" description="Admins can approve moderators, publish language releases, and grant access." />
    <AdminList admins={admins} />
    <section className="card mt-5 p-5"><div className="flex gap-3"><KeyRound className="mt-0.5 size-5 text-brand" /><div><h2 className="text-sm font-bold">Protected role changes</h2><p className="mt-1 max-w-2xl text-xs leading-5 text-muted">Adding or removing an admin requires a recent Google sign-in, exact account confirmation, and an immutable audit entry. No administrator credentials are sent to the browser.</p></div></div></section>
  </>;
}
