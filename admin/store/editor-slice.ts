import { createSlice, type PayloadAction } from "@reduxjs/toolkit";
import type { CourseFile } from "@/logic/courses/schemas";

type EditorState = {
  draft: CourseFile | null;
  selectedLevel: number;
  selectedQuestion: number;
  dirty: boolean;
  savedAt: string | null;
};

const initialState: EditorState = {
  draft: null, selectedLevel: 0, selectedQuestion: 0,
  dirty: false, savedAt: null,
};

export const editorSlice = createSlice({
  name: "editor",
  initialState,
  reducers: {
    openCourse: (state, action: PayloadAction<CourseFile>) => {
      state.draft = action.payload;
      state.selectedLevel = 0; state.selectedQuestion = 0; state.dirty = false;
    },
    selectLevel: (state, action: PayloadAction<number>) => {
      state.selectedLevel = action.payload; state.selectedQuestion = 0;
    },
    selectQuestion: (state, action: PayloadAction<number>) => { state.selectedQuestion = action.payload; },
    updateCourseField: (state, action: PayloadAction<{ field: "title" | "description"; value: string }>) => {
      if (state.draft) { state.draft[action.payload.field] = action.payload.value; state.dirty = true; }
    },
    updateLevelTitle: (state, action: PayloadAction<string>) => {
      const level = state.draft?.levels[state.selectedLevel];
      if (level) { level.title = action.payload; state.dirty = true; }
    },
    updateQuestionSentence: (state, action: PayloadAction<string>) => {
      const question = state.draft?.levels[state.selectedLevel]?.questions[state.selectedQuestion];
      if (question) { question.sentence = action.payload; state.dirty = true; }
    },
    updateOption: (state, action: PayloadAction<{ index: number; value: string }>) => {
      const question = state.draft?.levels[state.selectedLevel]?.questions[state.selectedQuestion];
      if (!question) return;
      const previous = question.options[action.payload.index];
      question.options[action.payload.index] = action.payload.value;
      if (question.correctAnswer === previous) question.correctAnswer = action.payload.value;
      state.dirty = true;
    },
    markSaved: (state) => { state.dirty = false; state.savedAt = new Date().toISOString(); },
  },
});

export const editorActions = editorSlice.actions;
