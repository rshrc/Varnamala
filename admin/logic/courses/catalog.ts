export const languages = [
  ["assamese", "Assamese", "অসমীয়া"], ["bengali", "Bengali", "বাংলা"],
  ["gujarati", "Gujarati", "ગુજરાતી"], ["hindi", "Hindi", "हिन्दी"],
  ["kannada", "Kannada", "ಕನ್ನಡ"], ["malayalam", "Malayalam", "മലയാളം"],
  ["marathi", "Marathi", "मराठी"], ["nepali", "Nepali", "नेपाली"],
  ["odia", "Odia", "ଓଡ଼ିଆ"], ["sanskrit", "Sanskrit", "संस्कृतम्"],
  ["tamil", "Tamil", "தமிழ்"], ["telugu", "Telugu", "తెలుగు"],
  ["urdu", "Urdu", "اردو"],
] as const;

export type LanguageId = (typeof languages)[number][0];
export type Language = { id: LanguageId; name: string; nativeName: string };

export function isLanguageId(value: string): value is LanguageId {
  return languages.some(([id]) => id === value);
}

export function getLanguage(id: LanguageId): Language {
  const entry = languages.find(([languageId]) => languageId === id);
  if (!entry) throw new Error(`Unknown language: ${id}`);
  return { id: entry[0], name: entry[1], nativeName: entry[2] };
}

export const languageCatalog: readonly Language[] = languages.map(([id, name, nativeName]) => ({ id, name, nativeName }));
