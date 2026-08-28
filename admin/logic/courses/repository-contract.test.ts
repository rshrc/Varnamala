import { describe, expect, test } from "bun:test";
import { readFile, readdir } from "node:fs/promises";
import path from "node:path";
import { courseFileSchema, manifestSchema } from "./schemas";

const courseRoot = path.resolve(process.cwd(), "../assets/courses");

describe("repository course contract", () => {
  test("Admin parses and preserves every course for all 13 languages", async () => {
    const languages = (await readdir(courseRoot, { withFileTypes: true }))
      .filter((entry) => entry.isDirectory())
      .map((entry) => entry.name)
      .sort();
    let courseCount = 0;
    let questionCount = 0;

    for (const language of languages) {
      const directory = path.join(courseRoot, language);
      const manifestRaw: unknown = JSON.parse(
        await readFile(path.join(directory, "manifest.json"), "utf8"),
      );
      const manifest = manifestSchema.parse(manifestRaw);

      for (const entry of manifest.courses) {
        const raw: unknown = JSON.parse(
          await readFile(path.join(directory, `${entry.id}.json`), "utf8"),
        );
        const parsed = courseFileSchema.parse(raw);
        const roundTrip: unknown = JSON.parse(JSON.stringify(parsed));

        expect(roundTrip).toEqual(raw);
        courseCount += 1;
        questionCount += parsed.levels.reduce(
          (sum, level) => sum + level.questions.length,
          0,
        );
      }
    }

    expect(languages).toHaveLength(13);
    expect(courseCount).toBe(195);
    expect(questionCount).toBe(10_530);
  });
});
