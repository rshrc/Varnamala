import "server-only";

import { createHash } from "node:crypto";
import { FieldValue, type DocumentData } from "firebase-admin/firestore";
import { getLanguage, languageCatalog, type LanguageId } from "@/logic/courses/catalog";
import { courseFileSchema, manifestSchema, type CourseContentFile, type CourseFile, type CourseManifest } from "@/logic/courses/schemas";
import { adminFirestore } from "./admin";

export type ActiveLanguageRelease = { activeReleaseId: string; previousReleaseId: string | null };

export type LanguageReleaseSummary = {
  language: LanguageId;
  name: string;
  nativeName: string;
  activeReleaseId: string | null;
  previousReleaseId: string | null;
  status: "active" | "missing";
  courseCount: number;
  levelCount: number;
  questionCount: number;
  publishedAt: string | null;
};

export type CourseLibraryItem = {
  id: string;
  title: string;
  icon: string;
  color: string;
  levels: number;
  questions: number;
};

export type LanguageCourseLibrary = {
  language: ReturnType<typeof getLanguage>;
  releaseId: string;
  previousReleaseId: string | null;
  manifest: CourseManifest;
  courses: CourseLibraryItem[];
  dictionaryEntries: number;
  openReports: number;
};

function timestampIso(value: unknown): string | null {
  if (value && typeof value === "object" && "toDate" in value && typeof value.toDate === "function") {
    return value.toDate().toISOString();
  }
  return null;
}

function storedContent(data: DocumentData | undefined): unknown {
  if (typeof data?.contentJson === "string") return JSON.parse(data.contentJson);
  return data?.content;
}

export async function getActiveLanguageRelease(language: LanguageId): Promise<ActiveLanguageRelease | null> {
  const snapshot = await adminFirestore().doc(`courseConfig/${language}`).get();
  if (!snapshot.exists) return null;
  const data = snapshot.data();
  return {
    activeReleaseId: String(data?.activeReleaseId ?? ""),
    previousReleaseId: typeof data?.previousReleaseId === "string" ? data.previousReleaseId : null,
  };
}

export async function getLanguageReleaseSummaries(): Promise<LanguageReleaseSummary[]> {
  const db = adminFirestore();
  const configs = await db.collection("courseConfig").get();
  const configByLanguage = new Map(configs.docs.map((document) => [document.id, document.data()]));
  const releaseRefs = languageCatalog.flatMap(({ id }) => {
    const releaseId = configByLanguage.get(id)?.activeReleaseId;
    return typeof releaseId === "string" && releaseId ? [db.doc(`courseReleases/${id}/versions/${releaseId}`)] : [];
  });
  const releases = releaseRefs.length ? await db.getAll(...releaseRefs) : [];
  const releaseByPath = new Map(releases.map((document) => [document.ref.path, document.data()]));

  return languageCatalog.map((language) => {
    const config = configByLanguage.get(language.id);
    const activeReleaseId = typeof config?.activeReleaseId === "string" && config.activeReleaseId ? config.activeReleaseId : null;
    const release = activeReleaseId ? releaseByPath.get(`courseReleases/${language.id}/versions/${activeReleaseId}`) : undefined;
    return {
      language: language.id,
      name: language.name,
      nativeName: language.nativeName,
      activeReleaseId,
      previousReleaseId: typeof config?.previousReleaseId === "string" && config.previousReleaseId ? config.previousReleaseId : null,
      status: activeReleaseId ? "active" : "missing",
      courseCount: Number(release?.courseCount ?? 0),
      levelCount: Number(release?.levelCount ?? 0),
      questionCount: Number(release?.questionCount ?? 0),
      publishedAt: timestampIso(config?.activatedAt ?? release?.createdAt),
    };
  });
}

export async function getLanguageCourseLibrary(languageId: LanguageId): Promise<LanguageCourseLibrary | null> {
  const db = adminFirestore();
  const active = await getActiveLanguageRelease(languageId);
  if (!active?.activeReleaseId) return null;
  const files = db.collection(`courseReleases/${languageId}/versions/${active.activeReleaseId}/files`);
  const [manifestDocument, dictionaryDocument, reportDocuments] = await Promise.all([
    files.doc("manifest").get(),
    files.doc("dictionary").get(),
    db.collection("contentReports").where("language", "==", languageId).get(),
  ]);
  if (!manifestDocument.exists) return null;
  const manifest = manifestSchema.parse(storedContent(manifestDocument.data()));
  const courseDocuments = manifest.courses.length
    ? await db.getAll(...manifest.courses.map(({ id }) => files.doc(id)))
    : [];
  const contentById = new Map(courseDocuments.map((document) => [document.id, courseFileSchema.parse(storedContent(document.data()))]));
  const courses = manifest.courses.map((course) => {
    const content = contentById.get(course.id);
    return {
      ...course,
      levels: content?.levels.length ?? 0,
      questions: content?.levels.reduce((sum, level) => sum + level.questions.length, 0) ?? 0,
    };
  });
  const dictionary = storedContent(dictionaryDocument.data());
  return {
    language: getLanguage(languageId),
    releaseId: active.activeReleaseId,
    previousReleaseId: active.previousReleaseId,
    manifest,
    courses,
    dictionaryEntries: dictionary && typeof dictionary === "object" ? Object.keys(dictionary).length : 0,
    openReports: reportDocuments.docs.filter((document) => ["open", "in_progress"].includes(String(document.data().status))).length,
  };
}

export async function getCourseForEditor(input: { language: LanguageId; courseId: string; uid: string }): Promise<{ course: CourseFile; baseReleaseId: string } | null> {
  const db = adminFirestore();
  const active = await getActiveLanguageRelease(input.language);
  if (!active?.activeReleaseId) return null;
  const draft = db.doc(`courseDrafts/${input.language}-${input.uid}/files/${input.courseId}`);
  const released = db.doc(`courseReleases/${input.language}/versions/${active.activeReleaseId}/files/${input.courseId}`);
  const [draftDocument, releasedDocument] = await Promise.all([draft.get(), released.get()]);
  const content = draftDocument.exists ? storedContent(draftDocument.data()) : storedContent(releasedDocument.data());
  const parsed = courseFileSchema.safeParse(content);
  return parsed.success ? { course: parsed.data, baseReleaseId: active.activeReleaseId } : null;
}

function checksum(content: unknown): string {
  return createHash("sha256").update(JSON.stringify(content)).digest("hex");
}

export async function publishLanguageRelease(input: {
  language: LanguageId;
  releaseId: string;
  sourceDraftId: string;
  actorUid: string;
  files: readonly CourseContentFile[];
}): Promise<void> {
  const db = adminFirestore();
  const release = db.doc(`courseReleases/${input.language}/versions/${input.releaseId}`);
  const batch = db.batch();
  const checksums: Record<string, string> = {};

  for (const file of input.files) {
    checksums[file.fileName] = checksum(file.content);
    const fileId = file.fileName.replace(/\.json$/, "");
    batch.create(release.collection("files").doc(fileId), {
      fileName: file.fileName, kind: file.kind, contentJson: JSON.stringify(file.content),
      language: input.language, checksum: checksums[file.fileName], createdAt: FieldValue.serverTimestamp(),
    });
  }
  batch.create(release, {
    language: input.language, status: "ready", sourceDraftId: input.sourceDraftId,
    fileCount: input.files.length, checksums, createdBy: input.actorUid, createdAt: FieldValue.serverTimestamp(),
  });
  await batch.commit();

  const config = db.doc(`courseConfig/${input.language}`);
  await db.runTransaction(async (transaction) => {
    const current = await transaction.get(config);
    const previous = current.exists ? String(current.data()?.activeReleaseId ?? "") : null;
    transaction.set(config, {
      language: input.language, activeReleaseId: input.releaseId,
      previousReleaseId: previous, activatedBy: input.actorUid, activatedAt: FieldValue.serverTimestamp(),
    });
    transaction.update(release, { status: "active", activatedAt: FieldValue.serverTimestamp() });
    if (previous) transaction.update(db.doc(`courseReleases/${input.language}/versions/${previous}`), { status: "superseded" });
  });
}
