import { redirect } from "next/navigation";
import { PageHeader } from "@/components/page-header";
import { TaskBoard } from "@/features/tasks/task-board";
import { getContentReportTasks } from "@/services/firebase/task-repository";
import { getStaffSession } from "@/services/firebase/session";

export default async function TasksPage() {
  const session = await getStaffSession();
  if (!session) redirect("/login");
  const tasks = await getContentReportTasks();
  return <><PageHeader eyebrow="Learner feedback" title="Report tasks" description="Mistakes reported from the Flutter app arrive here. Take ownership, correct the repository course, and resolve the task." /><TaskBoard tasks={tasks} currentUid={session.uid} isAdmin={session.role === "admin"} /></>;
}
