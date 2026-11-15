import 'package:words625/service/speech_service.dart';

/// How each `delivery` named in a scene file sounds.
///
/// A device voice cannot act, but it can be pitched and paced line by line,
/// and that carries more than it sounds like it should: "a hundred rupees?"
/// said high and fast is a different line from the same words said flat.
/// Kept as data so a new mood is one entry here, not code in the reader.
const Map<String, SpeechTone> kathaTones = {
  'calling': SpeechTone(pitch: 1.15, rate: 1.02),
  'breezy': SpeechTone(pitch: 1.05, rate: 1.08),
  'wary': SpeechTone(pitch: 1.0, rate: 0.92),
  'curious': SpeechTone(pitch: 1.1, rate: 1.0),
  'sheepish': SpeechTone(pitch: 0.96, rate: 0.86, volume: 0.8),
  'annoyed': SpeechTone(pitch: 1.18, rate: 1.15),
  'proud': SpeechTone(pitch: 1.08, rate: 0.95),
  'happy': SpeechTone(pitch: 1.15, rate: 1.05),
  'firm': SpeechTone(pitch: 0.95, rate: 0.95),
  'sly': SpeechTone(pitch: 0.92, rate: 0.9),
  'shocked': SpeechTone(pitch: 1.5, rate: 1.12),
  'amused': SpeechTone(pitch: 1.15, rate: 1.05),
  'weary': SpeechTone(pitch: 0.85, rate: 0.82),
  'stern': SpeechTone(pitch: 0.8, rate: 0.9),
};

/// The breath between two sentences of one line.
const Duration kathaSentencePause = Duration(milliseconds: 480);

/// With autoplay on, the breath between one line and the next: a reply
/// follows quickly, and a cut to a new picture gets a moment to land.
const Duration kathaLineBreath = Duration(milliseconds: 650);
const Duration kathaPanelBreath = Duration(milliseconds: 1100);
