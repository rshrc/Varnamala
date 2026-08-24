import { z } from "zod";

const sentence = z.string().trim().min(1);
const options = z.tuple([sentence, sentence, sentence]);
const questionBase = z.object({
  sentence,
  sentenceIsTargetLanguage: z.literal(true),
  options,
  correctAnswer: sentence,
});

export const multipleChoiceQuestionSchema = questionBase.extend({
  type: z.literal("multiple_choice"),
  prompt: z.literal("Choose an appropriate response"),
  translatedSentence: sentence,
});

export const translateQuestionSchema = questionBase.extend({
  type: z.literal("translate"),
  prompt: z.literal("Translate the sentence"),
});

export const questionSchema = z.discriminatedUnion("type", [
  multipleChoiceQuestionSchema,
  translateQuestionSchema,
]);

export const levelSchema = z.object({
  level: z.number().int().positive(),
  title: sentence,
  questions: z.array(questionSchema),
});

export const courseFileSchema = z.object({
  course: z.string().regex(/^[a-z][a-z0-9-]*$/),
  title: sentence,
  description: sentence,
  levels: z.array(levelSchema),
});

export const manifestCourseSchema = z.object({
  id: z.string().regex(/^[a-z][a-z0-9-]*$/),
  title: sentence,
  icon: sentence,
  color: z.string().regex(/^0x[0-9a-fA-F]{8}$/),
});

export const manifestSchema = z.object({
  language: z.string().regex(/^[a-z]+$/),
  nativeName: sentence,
  romanization: sentence,
  tree: z.array(z.array(z.string()).min(1).max(3)),
  courses: z.array(manifestCourseSchema),
});

export type CourseQuestion = z.infer<typeof questionSchema>;
export type CourseLevel = z.infer<typeof levelSchema>;
export type CourseFile = z.infer<typeof courseFileSchema>;
export type CourseManifest = z.infer<typeof manifestSchema>;

export type CourseContentFile =
  | { fileName: "manifest.json"; kind: "manifest"; content: CourseManifest }
  | { fileName: `${string}.json`; kind: "course"; content: CourseFile }
  | { fileName: "dictionary.json"; kind: "dictionary"; content: Record<string, string> }
  | { fileName: "notes.json"; kind: "notes"; content: Record<string, unknown> };
