import { describe, expect, test } from "bun:test";
import { canTransitionRelease } from "./release-state";

describe("release lifecycle", () => {
  test("requires readiness before activation", () => { expect(canTransitionRelease("staging", "active")).toBe(false); expect(canTransitionRelease("ready", "active")).toBe(true); });
  test("supports rollback to a superseded release", () => { expect(canTransitionRelease("superseded", "active")).toBe(true); });
});
