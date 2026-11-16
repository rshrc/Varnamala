# Katha stories

The stories are written here, in YAML. The app reads compact JSON compiled from
these files into `assets/katha/`. That JSON is not in git.

```bash
ruby tool/katha_build.rb             # compile every episode (run after editing, and before flutter)
ruby tool/katha_build.rb s2e03       # just one
ruby tool/katha_build.rb --check     # exit 1 if the JSON is out of date
```

If the build finds a problem, it tells you the file, the beat and what is
wrong, for example: `stories/dev-in-the-city/s2e03/kn.yaml b07: 5 words in the
sentence, 4 listed`.

## Layout

```
stories/dev-in-the-city/
  series.yaml        the cast, and the cue library every episode draws on
  voices.yaml        how it sounds: the ElevenLabs voice for each character, per language
  kn.yaml, hi.yaml   every character's name in that language
  recordings/kn/     what has been recorded (written by the recorder; see below)
  s1e01/
    episode.yaml     level, next episode, opening shot, memento, cue overrides
    script.yaml      the panels in order: the set, who stands where, the beats
    kn.yaml          the Kannada lines, word by word
    hi.yaml          the Hindi lines
```

A beat is one line of the story. Its id (`b07`) appears in `script.yaml`
(who says it, and what happens) and in every language file (the words).

## script.yaml

```yaml
p2:
  set: street_auto                 # bg.street_auto, and the ambience amb.street_auto
  ambient: traffic                 # only when the ambience differs from the set
  cast:
    dev:  standing @ 0.26          # pose @ x (0 = left edge, 1 = right edge)
    raju: in_auto @ 0.66
  props:
    meter: auto_meter on raju.auto # prop.auto_meter, attached to raju's auto
  beats:
    b05: narrator                                        # just a speaker
    b06: { who: dev, mood: curious, icons: [speech, question] }
    b07: { who: raju, mood: amused, start: [raju.shrug], tags: [laughing] }
```

These are the keys a beat can take:

| key | meaning |
|---|---|
| `who` | the speaker: someone in the series cast, or `narrator` |
| `mood` | how it is delivered; picks the voice's default emotion tag in `voices.yaml` |
| `tags` | the ElevenLabs emotion tags to use instead, one per sentence |
| `icons`, `digits` | the picture-only speech bubble |
| `start`, `end` | cues fired when the line starts and ends |
| `cliffhanger` | `true` on the episode's last hook |

## Language files (kn.yaml, hi.yaml)

```yaml
title: ನನ್ನ ಊರು | nanna uuru | My City          # native | roman | English
tease: ಅಮ್ಮ ಬರ್ತಾರೆ! | amma bartaare! | Amma is coming!

b04:
  say: ಆಗ, ರಸ್ತೆಯಲ್ಲಿ ಮೈಕ್.
  en: "Just then: a loudspeaker in the street."
  words: |
    aaga                                  "then"
    rasteyalli  raste·yalli:LOC  < raste  "in the street"
    maik                                  "a loudspeaker (mic)" loan
```

There is one row per word, in the order the words appear in the sentence:

```
roman[:FN]  [part·part:FN]  [< lemma]  "gloss"  [@cue] [loan] [name] [=native]
```

| field | meaning |
|---|---|
| `roman` | the word in Latin letters, as the learner sees it under the native script |
| `:FN` | a grammar label: `PRES.3SG`, `LOC`, `IMP.HON` |
| `part·part` | the word split into its pieces; a piece can carry its own `:FN` |
| `< lemma` | the dictionary form. Leave it out when it is the roman word itself (lower case, no `~`). Quote it if it has a space |
| `"gloss"` | the meaning shown when the word is tapped. Always quoted |
| `@cue` | a cue fired as the voice reaches this word: `@raju.shrug` |
| `loan` | an English loanword |
| `name` | a proper name |
| `=native` | the native spelling. You almost never need it: it is taken from `say`, word by word. Give it on every row only if the spaces in `say` do not line up with the words |

These are worked out by the build, so don't write them:

- **The native spelling of each word**, taken from `say`.
- **Chunks**, the groups of up to three words the band under the picture moves
  through. They never cross a sentence end. Add `chunks: [2, 1, 3]` (group
  sizes) only to override them.
- **The recording and word timings.** These come from `recordings/<lang>/`. If
  you change `say`, the line keeps its old recording until it is re-recorded,
  and the build warns about it.

## Cues

`series.yaml` holds the library:

```yaml
cues:
  raju.shrug:  raju shrug 700                            # target move milliseconds
  dev.bag_drop: dev bag_drop 500 sfx.thud                # ...with a sound
  meter.tap:   meter tap 400 -> meter.broken 300, raju.laugh 800   # then these, after ms
```

An episode can retime a cue for itself under `cues:` in its `episode.yaml`. The
build includes in the app's JSON only the cues an episode actually fires.

## episode.yaml

```yaml
level: A2
next: s2e01            # this episode's language files carry next episode's `tease`
preview: { panel: p1, ms: 5000, camera: [[0, 0.5, 1.1], [5000, 0.5, 1.0]] }   # [at ms, x, zoom]
memento: b30           # the beat the memento replays (and the "steal this line")
```

## Recordings

The recorder writes `recordings/<lang>/`, one row per recording. Don't edit it
by hand.

```
# recordings/kn/s1e01.yaml
b05: dd1d10c078a03edd  80-480 640-1360
     └ fingerprint      └ when each word starts-ends, in ms
```

The fingerprint covers the text sent, the voice and the settings. If any of
them changes, the line no longer matches and the next recorder run records it
again. `words.yaml` lists the words recorded on their own, for tap-to-hear.

Now and then ElevenLabs returns a recording without timings, and every word
reads `0-0`. `ruby tool/katha_estimate_timings.rb` estimates them from the
pauses in the audio and marks the row `estimated`.

## Recording and publishing

```bash
export ELEVENLABS_API_KEY=...                       # never commit it
ruby tool/render_katha_audio.rb --dry-run           # what changed, and what it would cost
ruby tool/render_katha_audio.rb --episode s2e03     # record it; compiles before and after

set -a; . ~/.katha/cloudflare.env; set +a           # CLOUDFLARE_API_TOKEN, CLOUDFLARE_ACCOUNT_ID
ruby tool/katha_cdn.rb push                         # upload what changed, per language
ruby tool/katha_cdn.rb verify
```

The MP3s are not in git. They live on Cloudflare Pages, one site per language
(`https://katha-audio-<lang>.pages.dev/`), and the app streams them from there.
On a fresh checkout, `ruby tool/katha_cdn.rb pull` downloads them. A push pulls
any missing files first, because a deployment replaces the whole site.
