/// Where Katha's recordings live, and how they are named.
///
/// Each language has its own Cloudflare Pages site (see `tool/katha_cdn.rb`):
/// a line at `<episode>-<beat>.mp3`, a word at `words/<hash>.mp3`, and the
/// word index at `words/index.json`.
abstract final class KathaAudio {
  /// The site address, with `{lang}` for the telling code. Override at build
  /// time, for instance to try a preview deployment:
  /// `--dart-define=KATHA_AUDIO_BASE=https://abc123.katha-audio-{lang}.pages.dev/`
  static const baseTemplate = String.fromEnvironment(
    'KATHA_AUDIO_BASE',
    defaultValue: 'https://katha-audio-{lang}.pages.dev/',
  );

  /// The site serving [lang]'s recordings, ending in a slash.
  static String baseFor(String lang) {
    final base = baseTemplate.replaceAll('{lang}', lang);
    return base.endsWith('/') ? base : '$base/';
  }

  /// A word as the word index spells it: native script without its
  /// punctuation. Must match `word_key` in tool/render_katha_audio.rb.
  static String wordKey(String native) =>
      native.replaceAll(_punctuation, '').trim();

  static final _punctuation = RegExp('[.,!?;:।॥۔،؟…"“”‘’]');
}
