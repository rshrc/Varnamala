import 'package:flutter_test/flutter_test.dart';
import 'package:words625/courses/katha.dart';
import 'package:words625/domain/katha.dart';
import 'package:words625/views/katha/reader/widgets/katha_word_gloss.dart';
import 'package:words625/views/katha/scene/engine/moves.dart';
import 'package:words625/views/katha/scene/staging/katha_backdrops.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<KathaEpisode> load(String lang, [String episode = 's1e01']) =>
      KathaRepository().load(
        series: KathaCatalogue.series,
        episode: episode,
        lang: lang,
      );

  final episodes = KathaCatalogue.episodes;

  /// Panels the reader actually shows: those set somewhere already drawn.
  List<String> drawn(KathaEpisode story) => [
    for (final panel in story.scene.panels)
      if (kathaDrawnBackdrops.contains(panel.background)) panel.id,
  ];

  group('Katha sample episode', () {
    for (final (episode, lang) in [
      for (final e in episodes)
        for (final l in ['kn', 'hi']) (e, l),
    ]) {
      test('$episode: the $lang telling fits the scene', () async {
        final story = await load(lang, episode);
        expect(story.telling.problemsAgainst(story.scene), isEmpty);
        expect(story.language, isNotNull);
        expect(story.telling.isBeta, isTrue);
      });
    }

    test(
      'one scene, two tellings: the same cue hangs off different words',
      () async {
        final kannada = await load('kn');
        final hindi = await load('hi');
        String shrugWord(KathaEpisode story) => story
            .telling
            .lines['b09']!
            .tokens
            .firstWhere((token) => token.cue == 'raju.shrug')
            .roman;
        expect(shrugWord(kannada), 'maaDtilla');
        expect(shrugWord(hindi), 'kharaab');
      },
    );

    test(
      'every move a drawn scene asks of a person exists in the move library',
      () async {
        for (final (episode, lang) in [
          for (final e in episodes)
            for (final l in ['kn', 'hi']) (e, l),
        ]) {
          final story = await load(lang, episode);
          final scene = story.scene;
          for (final panelId in drawn(story)) {
            final panel = scene.panel(panelId);
            final people = {
              for (final c in panel.characters)
                if (c.rig != 'char.cow') c.id,
            };
            final cuesUsed = <String>{
              for (final beat in scene.beatsIn(panelId)) ...[
                ...beat.onStart,
                ...beat.onEnd,
                for (final token in story.telling.lines[beat.id]!.tokens)
                  if (token.cue != null) token.cue!,
              ],
            };
            for (final id in cuesUsed) {
              final cue = scene.cues[id]!;
              final onStage =
                  people.contains(cue.target) ||
                  panel.props.any((p) => p.id == cue.target) ||
                  panel.characters.any((c) => c.id == cue.target) ||
                  (kathaBackdropActors[panel.background]?.contains(
                        cue.target,
                      ) ??
                      false);
              expect(
                onStage,
                isTrue,
                reason: '$lang $panelId: $id targets nobody in the scene',
              );
              if (people.contains(cue.target)) {
                expect(kathaMoveNames, contains(cue.anim), reason: '$lang $id');
              }
            }
          }
        }
      },
    );

    test(
      'Dev is shocked by the first price, not by his own counter-offer',
      () async {
        final story = await load('kn');
        final beats = story.scene.beatsIn('p2');
        final firstPrice = beats.indexWhere(
          (beat) => story.telling.lines[beat.id]!.tokens.any(
            (token) => token.cue == 'raju.fingers',
          ),
        );
        final shock = beats.indexWhere(
          (beat) => beat.onStart.contains('dev.shock'),
        );
        expect(shock, firstPrice + 1);
        expect(beats[shock].delivery, 'shocked');
      },
    );

    test(
      'the meter shows broken when Raju says so, not when Dev mentions it',
      () async {
        final story = await load('kn');
        final cues = {
          for (final beat in story.scene.beatsIn('p2'))
            for (final token in story.telling.lines[beat.id]!.tokens)
              if (token.cue != null) token.cue!: beat.speaker,
        };
        expect(cues['meter.tap'], 'dev');
        expect(cues['meter.broken'], 'raju');
      },
    );

    test(
      'everyone who speaks is cast, and the two men are pitched apart',
      () async {
        final scene = (await load('kn')).scene;
        for (final beat in scene.beats) {
          if (beat.isNarration) continue;
          expect(scene.cast, contains(beat.speaker), reason: beat.id);
        }
        expect(scene.cast['dev']!.gender, 'male');
        expect(scene.cast['raju']!.pitch, lessThan(scene.cast['dev']!.pitch));
      },
    );

    test('every spoken beat in a drawn scene has a picture bubble', () async {
      for (final episode in episodes) {
        final story = await load('kn', episode);
        for (final beat in [
          for (final id in drawn(story)) ...story.scene.beatsIn(id),
        ].where((beat) => !beat.isNarration)) {
          expect(
            beat.bubble,
            isNotNull,
            reason: '$episode ${beat.id} fails the mute test',
          );
        }
      }
    });

    test('each episode ends on a cliffhanger', () async {
      for (final episode in episodes) {
        final beats = (await load('kn', episode)).scene.beats;
        expect(beats.last.cliffhanger, isTrue, reason: episode);
      }
    });
  });

  group('the meaning shown on a long press', () {
    test('gives the gloss, the parts and where the word comes from', () async {
      final token = (await load('kn')).telling.lines['b11']!.tokens[2];
      final text = kathaGloss(token, KathaSpelling.casual).toPlainText();
      expect(text, contains('uurige'));
      expect(text, contains('to (this) town'));
      expect(text, contains('uur · ige (to)'));
      expect(text, contains('from: uuru'));
    });

    test('says when a word is borrowed from English', () async {
      final token = (await load('kn')).telling.lines['b09']!.tokens[0];
      expect(
        kathaGloss(token, KathaSpelling.casual).toPlainText(),
        contains('borrowed from English'),
      );
    });
  });

  group('roman text', () {
    test('punctuation is recovered from the native sentence', () async {
      final line = (await load('kn')).telling.lines['b04']!;
      expect(line.trailingPunctuation(), ['!', '', '?']);
      final comma = (await load('kn')).telling.lines['b09']!;
      expect(comma.trailingPunctuation(), ['', '', ',', '.']);
    });

    test('a danda reads as a full stop', () async {
      final line = (await load('hi')).telling.lines['b01']!;
      expect(line.trailingPunctuation().last, '.');
    });

    test(
      'a line splits into sentences, so the reader can pause between them',
      () async {
        final line = (await load('kn')).telling.lines['b05']!;
        final sentences = line.sentences();
        expect(sentences, hasLength(2));
        expect((sentences[0].first, sentences[0].last), (0, 0));
        expect((sentences[1].first, sentences[1].last), (1, 1));
        expect(sentences[0].native, 'ಬರ್ತೀನಿ.');
        // A comma is a breath inside a sentence, not the end of one.
        expect(
          (await load('kn')).telling.lines['b09']!.sentences(),
          hasLength(1),
        );
      },
    );

    test('the cast is named by the telling', () async {
      for (final lang in ['kn', 'hi']) {
        final strings = (await load(lang)).telling.strings;
        expect(strings['name.raju']!.roman, 'Raju Autowala');
      }
    });

    test('casual spelling drops capitals and spells out nasals', () {
      expect(KathaSpelling.casual.show('miiTar'), 'miitar');
      expect(KathaSpelling.casual.show('chale~ge'), 'chalenge');
      expect(KathaSpelling.precise.show('miiTar'), 'miiTar');
    });
  });

  group('recorded voices', () {
    final pairs = [
      for (final e in episodes)
        for (final l in ['kn', 'hi']) (e, l),
    ];

    test(
      'a line is directed once, or once per sentence in every telling',
      () async {
        for (final (episode, lang) in pairs) {
          final story = await load(lang, episode);
          for (final beat in story.scene.beats) {
            final sentences = story.telling.lines[beat.id]!.sentences().length;
            expect(
              beat.tags.length <= 1 || beat.tags.length == sentences,
              isTrue,
              reason:
                  '$episode/$lang ${beat.id}: '
                  '${beat.tags.length} tags for $sentences sentences',
            );
          }
        }
      },
    );

    test(
      'every recorded line is named for its beat and timed in order',
      () async {
        for (final (episode, lang) in pairs) {
          final story = await load(lang, episode);
          for (final entry in story.telling.lines.entries) {
            final file = story.recordingFile(entry.value);
            if (file == null) continue;
            final where = '$episode/$lang ${entry.key}';
            expect(file, '$episode-${entry.key}.mp3', reason: where);
            expect(
              story.audioFor(entry.value),
              '${KathaAudio.baseFor(lang)}$file',
              reason: where,
            );
            var last = 0;
            for (final token in entry.value.tokens) {
              final time = token.time;
              expect(time, isNotNull, reason: '$where ${token.roman}: untimed');
              expect(time!.start <= time.end, isTrue, reason: where);
              expect(
                time.start >= last,
                isTrue,
                reason: '$where ${token.roman}',
              );
              last = time.start;
            }
            // A line whose words all read 0 ms never moves its highlight.
            expect(
              entry.value.tokens.last.time!.end,
              greaterThan(0),
              reason: '$where: timings are all zero',
            );
          }
        }
      },
    );

    test('every chained cue names a cue the scene has', () async {
      for (final episode in episodes) {
        final scene = (await load('kn', episode)).scene;
        for (final cue in scene.cues.values) {
          for (final step in cue.then) {
            expect(
              scene.cues,
              contains(step.cue),
              reason: '$episode: ${step.cue}',
            );
          }
        }
      }
    });

    test('every line has its English, in every telling', () async {
      for (final (episode, lang) in pairs) {
        final story = await load(lang, episode);
        for (final entry in story.telling.lines.entries) {
          expect(
            entry.value.translation?.trim(),
            isNotEmpty,
            reason: '$episode/$lang ${entry.key} has no translation',
          );
        }
      }
    });

    test('the app and the recorder agree on how a word is keyed', () {
      expect(KathaAudio.wordKey('ಮಾಡ್ತಿಲ್ಲ,'), 'ಮಾಡ್ತಿಲ್ಲ');
      expect(KathaAudio.wordKey('ನೂರೈವತ್ತಾ?!'), 'ನೂರೈವತ್ತಾ');
      expect(KathaAudio.wordKey('है।'), 'है');
    });
  });
}
