import { redirect } from "next/navigation";
import { PageHeader } from "@/components/page-header";
import { ApplicationList } from "@/features/moderators/application-list";
import { getStaffSession } from "@/services/firebase/session";
import { getModeratorApplications } from "@/services/firebase/staff-repository";

export default async function ModeratorsPage() {
  const session = await getStaffSession();
  if (session?.role !== "admin") redirect("/dashboard");
  const applications = await getModeratorApplications();
  return <><PageHeader eyebrow="Community" title="Moderator applications" description="Review language work samples carefully. Proofs are private and used only to evaluate language contribution readiness." />
    <ApplicationList applications={applications} />
  </>;
}
