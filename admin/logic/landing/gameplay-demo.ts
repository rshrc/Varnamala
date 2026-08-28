import type { LanguageId } from "@/logic/courses/catalog";

export type GameplayLanguage = {
  id: LanguageId;
  name: string;
  nativeName: string;
  prompt: string;
  answer: string;
  options: readonly string[];
  translation: string;
};

export const gameplayLanguages: readonly GameplayLanguage[] = [
  { id: "assamese", name: "Assamese", nativeName: "অসমীয়া", prompt: "Apunar naam ki?", answer: "Mor naam Maya.", options: ["Mor naam Maya.", "Moi bhal ase.", "Eito mor ghor."], translation: "My name is Maya." },
  { id: "bengali", name: "Bengali", nativeName: "বাংলা", prompt: "Apnar naam ki?", answer: "Amar naam Maya.", options: ["Amar naam Maya.", "Ami bhalo achi.", "Ini amar bondhu."], translation: "My name is Maya." },
  { id: "gujarati", name: "Gujarati", nativeName: "ગુજરાતી", prompt: "Tamaru naam shu che?", answer: "Maru naam Maya che.", options: ["Maru naam Maya che.", "Hu majama chu.", "Maru ghar ahiya che."], translation: "My name is Maya." },
  { id: "hindi", name: "Hindi", nativeName: "हिन्दी", prompt: "Namaste, aap kaise hain?", answer: "Main theek hoon.", options: ["Main theek hoon.", "Main ghar jaata hoon.", "Yeh meri kitaab hai."], translation: "I am fine." },
  { id: "kannada", name: "Kannada", nativeName: "ಕನ್ನಡ", prompt: "Nimma hesaru enu?", answer: "Nanna hesaru Maya.", options: ["Nanna hesaru Maya.", "Nanage gottilla.", "Naanu chennagiddene."], translation: "My name is Maya." },
  { id: "malayalam", name: "Malayalam", nativeName: "മലയാളം", prompt: "Ningalude peru enthaanu?", answer: "Ente peru Maya aanu.", options: ["Ente peru Maya aanu.", "Ente veedu ivide aanu.", "Enikku chaya venam."], translation: "My name is Maya." },
  { id: "marathi", name: "Marathi", nativeName: "मराठी", prompt: "Tumche naav kay aahe?", answer: "Maze naav Maya aahe.", options: ["Maze naav Maya aahe.", "Mi Mumbai la jato.", "Ho, mi theek aahe."], translation: "My name is Maya." },
  { id: "nepali", name: "Nepali", nativeName: "नेपाली", prompt: "Namaste, tapaiko naam ke ho?", answer: "Mero naam Maya ho.", options: ["Mero naam Maya ho.", "Ma sanchai chu.", "Yo mero ghar ho."], translation: "My name is Maya." },
  { id: "odia", name: "Odia", nativeName: "ଓଡ଼ିଆ", prompt: "Namaskar, apananka naam kana?", answer: "Mora naam Maya.", options: ["Mora naam Maya.", "Mu Puri jauchi.", "Se mora bhai."], translation: "My name is Maya." },
  { id: "sanskrit", name: "Sanskrit", nativeName: "संस्कृतम्", prompt: "Namaste, bhavatah naama kim?", answer: "Mama naama Maya.", options: ["Mama naama Maya.", "Mama mitram atra asti.", "Aham samyak asmi."], translation: "My name is Maya." },
  { id: "tamil", name: "Tamil", nativeName: "தமிழ்", prompt: "Unga peru enna?", answer: "En peru Maya.", options: ["En peru Maya.", "Naan nalla irukkiren.", "Idhu en veedu."], translation: "My name is Maya." },
  { id: "telugu", name: "Telugu", nativeName: "తెలుగు", prompt: "Mee peru emiti?", answer: "Naa peru Maya.", options: ["Naa peru Maya.", "Nenu baagunnanu.", "Idi naa pustakam."], translation: "My name is Maya." },
  { id: "urdu", name: "Urdu", nativeName: "اردو", prompt: "Aap ka naam kya hai?", answer: "Mera naam Maya hai.", options: ["Mera naam Maya hai.", "Mera ghar yahan hai.", "Yeh mera bhai hai."], translation: "My name is Maya." },
] as const;
