"use client";

import { useDispatch, useSelector, type TypedUseSelectorHook } from "react-redux";
import type { AppDispatch, RootState } from "./make-store";

export const useAppDispatch = useDispatch.withTypes<AppDispatch>();
export const useAppSelector: TypedUseSelectorHook<RootState> = useSelector;
