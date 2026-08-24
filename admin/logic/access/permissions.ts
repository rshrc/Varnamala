export type StaffRole = "learner" | "moderator" | "admin";
export type Capability = "edit_course" | "submit_draft" | "review_draft" | "publish_release" | "manage_staff";

const grants: Record<StaffRole, readonly Capability[]> = {
  learner: [],
  moderator: ["edit_course", "submit_draft"],
  admin: ["edit_course", "submit_draft", "review_draft", "publish_release", "manage_staff"],
};

export function can(role: StaffRole, capability: Capability): boolean {
  return grants[role].includes(capability);
}
