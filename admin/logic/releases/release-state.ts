export type ReleaseStatus = "staging" | "ready" | "active" | "superseded" | "failed";
const transitions: Record<ReleaseStatus, readonly ReleaseStatus[]> = {
  staging: ["ready", "failed"], ready: ["active", "failed"],
  active: ["superseded"], superseded: ["active"], failed: [],
};

export function canTransitionRelease(from: ReleaseStatus, to: ReleaseStatus): boolean {
  return transitions[from].includes(to);
}
