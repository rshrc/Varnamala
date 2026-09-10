/**
 * Screenshots the running web app for the README.
 *
 * The screens worth showing sit behind an auth guard, which is right for
 * learners and impossible for a headless browser. `/showcase` and
 * `/league-lab` are routed without one precisely so this can work - and so
 * anyone can be shown the app without an account.
 *
 *   flutter build web
 *   (cd build/web && python3 -m http.server 5050)
 *   node tool/screenshots/capture.mjs
 *
 * Port 5050, not 5000: macOS AirPlay Receiver holds 5000 and answers 403.
 * Needs `npm i playwright && npx playwright install chromium`.
 */
import { chromium } from 'playwright';
import { mkdirSync } from 'node:fs';

const BASE = process.env.BASE ?? 'http://localhost:5050';
const OUT = process.env.OUT ?? 'screenshots';

/**
 * Tap targets, in logical pixels.
 *
 * Flutter paints into a canvas, so there is no element to query - these are
 * read off a screenshot once. Halve every pixel position: the reference shot
 * is taken at devicePixelRatio 2, and forgetting that once put every
 * "Kannada" tap on the Tamil chip beside it.
 */
const LANGUAGE = {
  kannada: [68, 109], tamil: [163, 109], telugu: [243, 109],
  malayalam: [340, 109],
  hindi: [49, 147], bengali: [130, 147], odia: [210, 147], nepali: [286, 147],
  assamese: [65, 185], gujarati: [164, 185], marathi: [254, 185],
  urdu: [334, 185], sanskrit: [58, 223],
};

const ENTRY = {
  path: 297, firstWords: 381, sentence: 465,
  script: 549, match: 633, flashcards: 717,
};

/** Flutter offers the DOM no "ready" signal, so booting is timed. */
const BOOT_MS = 6000;

mkdirSync(OUT, { recursive: true });
const browser = await chromium.launch();

async function shoot(name, language, entry, { wait = 7000, dark = false, then } = {}) {
  const context = await browser.newContext({
    viewport: { width: 420, height: 1100 },
    deviceScaleFactor: 2,
    colorScheme: dark ? 'dark' : 'light',
    reducedMotion: 'no-preference',
  });
  const page = await context.newPage();
  const errors = [];
  page.on('pageerror', (error) => errors.push(String(error).slice(0, 160)));

  await page.goto(`${BASE}/#/showcase`, { waitUntil: 'load' });
  await page.waitForTimeout(BOOT_MS);
  await page.mouse.click(...LANGUAGE[language]);
  await page.waitForTimeout(700);
  await page.mouse.click(210, ENTRY[entry]);
  await page.waitForTimeout(wait);
  if (then) await then(page);

  await page.screenshot({ path: `${OUT}/${name}.png` });
  console.log(`${name.padEnd(34)} ${errors.length ? `JS ERROR: ${errors[0]}` : 'ok'}`);
  await context.close();
}

/** Answers in the Hindi "First words" lesson, whose order is seeded. */
const PAANI = [210, 431];   // water - the right one
const ANDA = [210, 364];    // egg - a wrong one
const CHECK = [210, 1054];

const tap = (...points) => async (page) => {
  for (const [x, y, wait] of points) {
    await page.mouse.click(x, y);
    await page.waitForTimeout(wait ?? 2500);
  }
};

await shoot('feature-path', 'kannada', 'path');
await shoot('feature-lesson-tamil', 'tamil', 'sentence');
await shoot('feature-lesson-bengali', 'bengali', 'sentence');

// One question, both verdicts. The point of the pair is that a miss marks the
// tile you touched *and* lights up the answer - a screenshot of only the happy
// path would not show that.
await shoot('feature-firstwords-hindi', 'hindi', 'firstWords');
await shoot('feature-answer-correct', 'hindi', 'firstWords', {
  then: tap(PAANI, [...CHECK, 2600]),
});
await shoot('feature-answer-wrong', 'hindi', 'firstWords', {
  then: tap(ANDA, [...CHECK, 2600]),
});

// The alphabet grid, one letter's sheet, and the tracing canvas behind it.
await shoot('feature-script', 'kannada', 'script');
await shoot('feature-script-letter', 'kannada', 'script', {
  then: tap([58, 115]),
});
await shoot('feature-script-drawing', 'kannada', 'script', {
  then: async (page) => {
    await tap([58, 115], [308, 1060, 3000])(page);
    // Trace the loop, so the canvas reads as something you draw on rather
    // than an empty box.
    const stroke = [
      [150, 330], [135, 360], [130, 400], [145, 435], [180, 450], [215, 440],
      [232, 410], [230, 375], [250, 360], [280, 365], [300, 390], [300, 430],
      [275, 455], [235, 462], [190, 462], [150, 450], [128, 425],
    ];
    await page.mouse.move(...stroke[0]);
    await page.mouse.down();
    for (const [x, y] of stroke.slice(1)) {
      await page.mouse.move(x, y);
      await page.waitForTimeout(24);
    }
    await page.mouse.up();
    await page.waitForTimeout(1200);
  },
});

// A card, and the same card turned over.
await shoot('feature-flashcard-front', 'malayalam', 'flashcards', {
  then: tap([210, 720]),
});
await shoot('feature-flashcard-answer', 'malayalam', 'flashcards', {
  then: tap([210, 720], [210, 548]),
});

await shoot('feature-match-telugu', 'telugu', 'match', {
  // The entry screen is a mode picker; the game is one tap further in.
  then: tap([210, 423, 3000]),
});

// The league lab has its own route: maintainers are excluded from the real
// standings, so the one screen worth demonstrating cannot be demonstrated on a
// maintainer's own account.
{
  const context = await browser.newContext({
    viewport: { width: 420, height: 1000 },
    deviceScaleFactor: 2,
    reducedMotion: 'no-preference',
  });
  const page = await context.newPage();
  await page.goto(`${BASE}/#/league-lab`, { waitUntil: 'load' });
  await page.waitForTimeout(BOOT_MS);

  const tap = () => page.mouse.click(164, 892);   // "Finish a lesson +85 XP"

  // Two lessons take the learner from eighth to fifth. Rows travel for 620ms,
  // so catching them in transit is the whole point of the shot.
  await tap();
  await page.waitForTimeout(900);
  await tap();
  await page.waitForTimeout(240);
  await page.screenshot({ path: `${OUT}/feature-league-climb.png` });
  console.log('feature-league-climb'.padEnd(34) + 'ok');

  // A third puts them on the podium, where the medals have their own arrival.
  await page.waitForTimeout(1200);
  await tap();
  await page.waitForTimeout(1400);
  await page.screenshot({ path: `${OUT}/feature-league-podium.png` });
  console.log('feature-league-podium'.padEnd(34) + 'ok');
  await context.close();
}

await browser.close();
