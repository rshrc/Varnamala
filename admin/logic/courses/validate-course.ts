import type { CourseFile } from "./schemas";

export type ValidationIssue = {
  path: string;
  message: string;
  severity: "error" | "warning";
};

export function validateCourse(course: CourseFile): ValidationIssue[] {
  const issues: ValidationIssue[] = [];
  const sentences = new Map<string, number>();

  if (course.levels.length < 5 || course.levels.length > 6) {
    issues.push({ path: "levels", message: "Courses need 5–6 levels.", severity: "error" });
  }

  course.levels.forEach((level, levelIndex) => {
    if (level.level !== levelIndex + 1) {
      issues.push({ path: `levels.${levelIndex}.level`, message: "Levels must be sequential.", severity: "error" });
    }
    if (level.questions.length < 8 || level.questions.length > 10) {
      issues.push({ path: `levels.${levelIndex}.questions`, message: "Levels need 8–10 questions.", severity: "error" });
    }
    level.questions.forEach((question, questionIndex) => {
      if (!question.options.includes(question.correctAnswer)) {
        issues.push({ path: `levels.${levelIndex}.questions.${questionIndex}.correctAnswer`, message: "Correct answer must exactly match an option.", severity: "error" });
      }
      if (new Set(question.options).size !== question.options.length) {
        issues.push({ path: `levels.${levelIndex}.questions.${questionIndex}.options`, message: "Options must be unique.", severity: "error" });
      }
      sentences.set(question.sentence, (sentences.get(question.sentence) ?? 0) + 1);
    });
  });

  for (const [value, count] of sentences) {
    if (count > 1) issues.push({ path: "levels", message: `Repeated sentence: “${value}”.`, severity: "error" });
  }
  return issues;
}

export function isReleaseReady(course: CourseFile): boolean {
  return validateCourse(course).every((issue) => issue.severity !== "error");
}
