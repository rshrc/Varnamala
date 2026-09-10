/**
 * Publishes the repository's course JSON as a new Firestore release for every
 * language, and points courseConfig at it.
 *
 * The app reads a language's content from its active release when one exists
 * and from the bundled JSON otherwise (lib/courses/course_repository.dart).
 * Once a language is on a release, editing this repo does nothing until the
 * release is republished - so this script is the step that makes repo content
 * actually reach users.
 *
 *   bun run scripts/publish-release.ts --dry-run     # print, write nothing
 *   bun run scripts/publish-release.ts               # publish all languages
 *   bun run scripts/publish-release.ts --dry-run kannada tamil
 *
 * A course listed in the manifest whose file does not exist yet is skipped and
 * reported. The app drops the node, so the path is simply shorter until the
 * file is written - that is how First words rolls out one language at a time.
 */
import { createHash } from "node:crypto";
import { existsSync } from "node:fs";
import { readdir, readFile } from "node:fs/promises";
import path from "node:path";
import { FieldValue } from "firebase-admin/firestore";
import {
  courseFileSchema,
  manifestSchema,
  wordCourseFileSchema,
} from "../logic/courses/schemas.ts";
import { scriptFirestore } from "./firebase-admin.ts";
import {
  accessToken,
  documentId,
  documentsUrl,
  listAll,
} from "./firestore-rest.ts";

const args = process.argv.slice(2);
const dryRun = args.includes("--dry-run");
const only = args.filter((arg) => !arg.startsWith("--"));

const db = scriptFirestore();
const root = path.resolve(process.cwd(), "../assets/courses");

/**
 * Retries a Firestore call.
 *
 * The REST transport this client uses intermittently fails a query outright
 * with "No QuerySnapshot result" rather than returning data. A publish must
 * not abort halfway through thirteen languages because of that.
 */
async function retry<T>(label: string, call: () => Promise<T>): Promise<T> {
  let last: unknown;
  for (let attempt = 1; attempt <= 5; attempt++) {
    try {
      return await call();
    } catch (error) {
      last = error;
      await new Promise((resolve) => setTimeout(resolve, 400 * attempt));
    }
  }
  throw new Error(`${label} failed after 5 attempts: ${last}`);
}

function releaseStamp(): string {
  const now = new Date();
  const pad = (value: number) => String(value).padStart(2, "0");
  return [
    "repo",
    `${now.getFullYear()}${pad(now.getMonth() + 1)}${pad(now.getDate())}`,
    `${pad(now.getHours())}${pad(now.getMinutes())}${pad(now.getSeconds())}`,
  ].join("-");
}

const releaseId = releaseStamp();

const allLanguages = (await readdir(root, { withFileTypes: true }))
  .filter((entry) => entry.isDirectory())
  .map((entry) => entry.name)
  .sort();

const languages = only.length ? allLanguages.filter((l) => only.includes(l)) : allLanguages;
const unknown = only.filter((l) => !allLanguages.includes(l));
if (unknown.length) throw new Error(`Unknown language(s): ${unknown.join(", ")}`);

// Every currently active release, so each publish records the one it
// supersedes.
//
// Read over REST rather than through the admin client: that client returned
// only eight of thirteen documents here, with no error, which silently wrote
// "no previous release" onto five languages that had one. A rollback pointer
// that is quietly wrong is worse than none.
const activeBefore = new Map<string, string>();
if (!dryRun) {
  const projectId = process.env.FIREBASE_PROJECT_ID;
  if (!projectId) throw new Error("FIREBASE_PROJECT_ID is required.");
  const token = await accessToken();
  const configs = await listAll(documentsUrl(projectId), token, "courseConfig");
  for (const doc of configs) {
    const active = doc.fields.activeReleaseId?.stringValue;
    if (active) activeBefore.set(documentId(doc.name), active);
  }
}

console.info(`Release id: ${releaseId}${dryRun ? "  (DRY RUN - nothing will be written)" : ""}`);
console.info(`Languages : ${languages.length}\n`);

let published = 0;
const skippedByLanguage: Record<string, string[]> = {};

for (const language of languages) {
  const directory = path.join(root, language);
  const manifest = manifestSchema.parse(
    JSON.parse(await readFile(path.join(directory, "manifest.json"), "utf8")),
  );

  type Entry = { fileName: string; kind: string; content: unknown };
  const entries: Entry[] = [];
  const skipped: string[] = [];

  entries.push({ fileName: "manifest.json", kind: "manifest", content: manifest });

  for (const shared of ["dictionary.json", "notes.json"] as const) {
    const file = path.join(directory, shared);
    if (!existsSync(file)) {
      skipped.push(shared);
      continue;
    }
    entries.push({
      fileName: shared,
      kind: shared === "dictionary.json" ? "dictionary" : "notes",
      content: JSON.parse(await readFile(file, "utf8")),
    });
  }

  let levelCount = 0;
  let questionCount = 0;
  let wordCount = 0;

  for (const course of manifest.courses) {
    const fileName = `${course.id}.json`;
    const file = path.join(directory, fileName);
    if (!existsSync(file)) {
      // Not an error: this is how a course rolls out language by language.
      skipped.push(fileName);
      continue;
    }

    const raw: unknown = JSON.parse(await readFile(file, "utf8"));
    const isWordCourse =
      typeof raw === "object" && raw !== null && (raw as { schema?: number }).schema === 2;

    if (isWordCourse) {
      const parsed = wordCourseFileSchema.parse(raw);
      levelCount += parsed.levels.length;
      wordCount += parsed.levels.reduce((sum, level) => sum + level.words.length, 0);
    } else {
      const parsed = courseFileSchema.parse(raw);
      levelCount += parsed.levels.length;
      questionCount += parsed.levels.reduce((sum, level) => sum + level.questions.length, 0);
    }

    entries.push({ fileName, kind: "course", content: raw });
  }

  if (skipped.length) skippedByLanguage[language] = skipped;

  const dictionary = entries.find((entry) => entry.fileName === "dictionary.json");
  const dictionaryEntries = dictionary ? Object.keys(dictionary.content as object).length : 0;

  const summary =
    `${language.padEnd(10)} ${String(entries.length).padStart(2)} files  ` +
    `${String(levelCount).padStart(3)} levels  ` +
    `${String(questionCount).padStart(4)} questions  ` +
    `${String(wordCount).padStart(2)} words  ` +
    `${String(dictionaryEntries).padStart(4)} glosses` +
    (skipped.length ? `  skipped: ${skipped.join(", ")}` : "");
  console.info(summary);

  if (dryRun) continue;

  const release = db.doc(`courseReleases/${language}/versions/${releaseId}`);
  const config = db.doc(`courseConfig/${language}`);

  const batch = db.batch();
  const checksums: Record<string, string> = {};
  for (const entry of entries) {
    const contentJson = JSON.stringify(entry.content);
    checksums[entry.fileName] = createHash("sha256").update(contentJson).digest("hex");
    batch.set(release.collection("files").doc(entry.fileName.replace(/\.json$/, "")), {
      fileName: entry.fileName,
      kind: entry.kind,
      language,
      contentJson,
      checksum: checksums[entry.fileName],
      createdAt: FieldValue.serverTimestamp(),
    });
  }
  batch.set(release, {
    language,
    status: "active",
    source: "repository-publish",
    fileCount: entries.length,
    courseCount: entries.filter((entry) => entry.kind === "course").length,
    skippedFiles: skipped,
    levelCount,
    questionCount,
    wordCount,
    dictionaryEntries,
    checksums,
    createdAt: FieldValue.serverTimestamp(),
  });
  await retry(`${language} files`, () => batch.commit());

  // Activate last, and only after every file is committed, so a half-written
  // release is never the one the app is pointed at.
  const previous = activeBefore.get(language) ?? null;
  await retry(`${language} activate`, () => config.set({
    language,
    activeReleaseId: releaseId,
    previousReleaseId: previous,
    activatedBy: "repository-publish",
    activatedAt: FieldValue.serverTimestamp(),
  }));
  if (previous && previous !== releaseId) {
    await retry(`${language} supersede`, () =>
      db
        .doc(`courseReleases/${language}/versions/${previous}`)
        .update({ status: "superseded" }),
    );
  }

  published += 1;
}

console.info("");
if (dryRun) {
  console.info("Dry run complete. Nothing was written.");
} else {
  console.info(`Published and activated ${published} language(s) as ${releaseId}.`);
}
const stillMissing = Object.entries(skippedByLanguage);
if (stillMissing.length) {
  console.info("\nCourses not yet written (the app drops these nodes):");
  for (const [language, files] of stillMissing) {
    console.info(`  ${language}: ${files.join(", ")}`);
  }
}
