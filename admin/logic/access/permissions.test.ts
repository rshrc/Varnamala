import { describe, expect, test } from "bun:test";
import { can } from "./permissions";

describe("staff permissions", () => {
  test("moderators edit but do not publish", () => { expect(can("moderator", "edit_course")).toBe(true); expect(can("moderator", "publish_release")).toBe(false); });
  test("admins manage staff and releases", () => { expect(can("admin", "manage_staff")).toBe(true); expect(can("admin", "publish_release")).toBe(true); });
});
