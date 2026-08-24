import { describe, expect, test } from "bun:test";
import { createDemoCourse } from "./demo-course";
import { isReleaseReady, validateCourse } from "./validate-course";

describe("course validation", () => {
  test("accepts a complete course", () => { expect(isReleaseReady(createDemoCourse())).toBe(true); });
  test("finds duplicate sentences", () => {
    const course = createDemoCourse();
    const first = course.levels[0]?.questions[0];
    const second = course.levels[0]?.questions[1];
    if (!first || !second) throw new Error("Fixture is incomplete");
    second.sentence = first.sentence;
    expect(validateCourse(course).some((issue) => issue.message.startsWith("Repeated sentence"))).toBe(true);
  });
});
