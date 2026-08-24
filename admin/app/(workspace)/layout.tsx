import { redirect } from "next/navigation";
import { AppShell } from "@/components/app-shell";
import { StoreProvider } from "@/store/store-provider";
import { demoModeEnabled, getStaffSession } from "@/services/firebase/session";

export const dynamic = "force-dynamic";

export default async function WorkspaceLayout({ children }: { children: React.ReactNode }) {
  const session = await getStaffSession();
  const demo = demoModeEnabled() || process.env.ENABLE_DEMO_MODE === "true";
  if (!session && !demo) redirect("/login");
  return <StoreProvider><AppShell demo={demo} name={session?.name ?? "Rishi Banerjee"} role={session?.role === "moderator" ? "moderator" : "admin"}>{children}</AppShell></StoreProvider>;
}
