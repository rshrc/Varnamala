/**
 * Prints what every language is actually serving: its active release, how many
 * files that release carries, and which courses in its manifest have no file
 * yet.
 *
 *   bun run scripts/show-releases.ts
 *
 * Talks to the Firestore REST API directly rather than through the admin
 * client. The client's REST transport has twice returned truncated query
 * results here - six of thirteen documents, silently - which is exactly the
 * kind of wrong answer you must not get from a tool you use to check
 * production. This paginates explicitly and reports the count it found.
 */
import { writeFileSync } from "node:fs";
import {
  accessToken,
  documentId,
  documentsUrl,
  listAll,
} from "./firestore-rest.ts";

const outFile = process.argv.slice(2).find((arg) => !arg.startsWith("--"));

const projectId = process.env.FIREBASE_PROJECT_ID;
if (!projectId) throw new Error("FIREBASE_PROJECT_ID is required.");

const token = await accessToken();
const base = documentsUrl(projectId);

const configs = await listAll(base, token, "courseConfig");
const lines: string[] = [`Languages on a release: ${configs.length}`, ""];

for (const config of configs.sort((a, b) => documentId(a.name).localeCompare(documentId(b.name)))) {
  const language = documentId(config.name);
  const releaseId = config.fields.activeReleaseId?.stringValue;
  if (!releaseId) {
    lines.push(`${language.padEnd(10)} (no active release - serving bundled JSON)`);
    continue;
  }

  const files = await listAll(base, token, `courseReleases/${language}/versions/${releaseId}/files`);
  const fileIds = new Set(files.map((file) => documentId(file.name)));
  const manifestRaw = files.find((file) => documentId(file.name) === "manifest")?.fields.contentJson
    ?.stringValue;
  const courseIds: string[] = manifestRaw
    ? JSON.parse(manifestRaw).courses.map((course: { id: string }) => course.id)
    : [];
  const absent = courseIds.filter((courseId) => !fileIds.has(courseId));

  lines.push(
    `${language.padEnd(10)} ${releaseId}  files=${String(files.length).padStart(2)}  ` +
      `manifest=${String(courseIds.length).padStart(2)}  ` +
      `prev=${config.fields.previousReleaseId?.stringValue ?? "(none)"}` +
      (absent.length ? `  no file yet: ${absent.join(", ")}` : ""),
  );
}

const report = lines.join("\n") + "\n";
if (outFile) writeFileSync(outFile, report);
process.stdout.write(report);
