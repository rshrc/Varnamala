import type { CourseFile, CourseQuestion } from "./schemas";

function question(level: number, position: number): CourseQuestion {
  const label = `${level}.${position}`;
  return position % 2 === 0 ? {
    type: "translate", prompt: "Translate the sentence",
    sentence: `Practice sentence ${label}`, sentenceIsTargetLanguage: true,
    options: [`Meaning ${label}`, `Alternative ${label}`, `Distractor ${label}`],
    correctAnswer: `Meaning ${label}`,
  } : {
    type: "multiple_choice", prompt: "Choose an appropriate response",
    sentence: `Conversation prompt ${label}`, sentenceIsTargetLanguage: true,
    options: [`Response ${label}`, `Reply ${label}`, `Other ${label}`],
    correctAnswer: `Response ${label}`, translatedSentence: `Example translation ${label}`,
  };
}

export function createDemoCourse(id = "basics", title = "Basics"): CourseFile {
  const titles = ["Starting gently", "Everyday exchanges", "Building confidence", "Longer thoughts", "Ready to speak"];
  return {
    course: id, title,
    description: "The essential phrases learners use to begin speaking with confidence.",
    levels: Array.from({ length: 5 }, (_, levelIndex) => ({
      level: levelIndex + 1,
      title: titles[levelIndex] ?? "Practice",
      questions: Array.from({ length: 8 }, (_, questionIndex) => question(levelIndex + 1, questionIndex + 1)),
    })),
  };
}
