import { configureStore } from "@reduxjs/toolkit";
import { editorSlice } from "./editor-slice";

export function makeStore() {
  return configureStore({ reducer: { editor: editorSlice.reducer } });
}

export type AppStore = ReturnType<typeof makeStore>;
export type RootState = ReturnType<AppStore["getState"]>;
export type AppDispatch = AppStore["dispatch"];
