import { describe, expect, test } from "bun:test";
import { languageCatalog } from "@/logic/courses/catalog";
import { gameplayLanguages } from "./gameplay-demo";

describe("landing gameplay catalogue", () => {
  test("offers a demo for every supported language", () => {
    expect(gameplayLanguages.map((language) => language.id).sort()).toEqual(
      languageCatalog.map((language) => language.id).sort(),
    );
  });

  test("every quick reply has one valid answer", () => {
    for (const language of gameplayLanguages) {
      expect(language.options).toContain(language.answer);
      expect(new Set(language.options).size).toBe(language.options.length);
    }
  });
});
