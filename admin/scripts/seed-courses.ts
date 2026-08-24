import { createHash } from "node:crypto";
import { readdir, readFile } from "node:fs/promises";
import path from "node:path";
import { FieldValue } from "firebase-admin/firestore";
import { courseFileSchema, manifestSchema } from "../logic/courses/schemas.ts";
import { scriptFirestore } from "./firebase-admin.ts";

const db = scriptFirestore();

const root = path.resolve(process.cwd(), "../assets/courses");
const languages = (await readdir(root, { withFileTypes: true })).filter((entry) => entry.isDirectory()).map((entry) => entry.name).sort();

for (const language of languages) {
  console.info(`Preparing ${language}…`);
  const directory = path.join(root, language);
  const manifest = manifestSchema.parse(JSON.parse(await readFile(path.join(directory, "manifest.json"), "utf8")));
  const fileNames = ["manifest.json", "dictionary.json", "notes.json", ...manifest.courses.map((course) => `${course.id}.json`)];
  const releaseId = "initial-v1";
  const release = db.doc(`courseReleases/${language}/versions/${releaseId}`);
  const batch = db.batch();
  const checksums: Record<string, string> = {};
  let levelCount = 0;
  let questionCount = 0;
  let dictionaryEntries = 0;

  for (const fileName of fileNames) {
    const content: unknown = JSON.parse(await readFile(path.join(directory, fileName), "utf8"));
    if (!fileName.match(/^(manifest|dictionary|notes)\.json$/)) {
      const course = courseFileSchema.parse(content);
      levelCount += course.levels.length;
      questionCount += course.levels.reduce((sum, level) => sum + level.questions.length, 0);
    }
    if (fileName === "dictionary.json" && content && typeof content === "object") dictionaryEntries = Object.keys(content).length;
    const checksum = createHash("sha256").update(JSON.stringify(content)).digest("hex");
    checksums[fileName] = checksum;
    batch.set(release.collection("files").doc(fileName.replace(/\.json$/, "")), {
      fileName, kind: fileName === "manifest.json" ? "manifest" : fileName === "dictionary.json" ? "dictionary" : fileName === "notes.json" ? "notes" : "course",
      language, contentJson: JSON.stringify(content), checksum, createdAt: FieldValue.serverTimestamp(),
    });
  }
  batch.set(release, {
    language, status: "active", source: "repository-seed", fileCount: fileNames.length,
    courseCount: manifest.courses.length, levelCount, questionCount, dictionaryEntries,
    checksums, createdAt: FieldValue.serverTimestamp(),
  });
  batch.set(db.doc(`courseConfig/${language}`), { language, activeReleaseId: releaseId, previousReleaseId: null, activatedAt: FieldValue.serverTimestamp(), activatedBy: "repository-seed" });
  try {
    await batch.commit();
  } catch (error) {
    console.error(`Failed while writing ${language}.`, error instanceof Error ? error.stack : error);
    throw error;
  }
  console.info(`Seeded ${language}: ${fileNames.length} files`);
}
