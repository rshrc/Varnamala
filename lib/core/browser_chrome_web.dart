import 'dart:js_interop';
import 'dart:ui';

/// Paints the page behind the app, and the browser's own bars, in [colour].
///
/// `index.html` starts the page in one fixed colour, so on an iPhone the strip
/// under the notch stayed that colour whatever theme the app was in: a white
/// band over a dark app bar. Safari tints that strip, and its toolbars, from
/// the page's background (iOS 26) or from `theme-color` (iOS 15 to 18; Chrome
/// on Android uses it too), so both follow the theme.
void paintBrowserChrome(Color colour) {
  final css = _hex(colour);
  _document.documentElement.style.backgroundColor = css;
  _document.body?.style.backgroundColor = css;
  _document
      .querySelector('meta[name="theme-color"]')
      ?.setAttribute('content', css);
}

String _hex(Color colour) {
  String channel(double value) =>
      (value * 255).round().clamp(0, 255).toRadixString(16).padLeft(2, '0');
  return '#${channel(colour.r)}${channel(colour.g)}${channel(colour.b)}';
}

@JS('document')
external _Document get _document;

extension type _Document._(JSObject _) implements JSObject {
  external _Element get documentElement;
  external _Element? get body;
  external _Element? querySelector(String selectors);
}

extension type _Element._(JSObject _) implements JSObject {
  external _Style get style;
  external void setAttribute(String name, String value);
}

extension type _Style._(JSObject _) implements JSObject {
  external set backgroundColor(String value);
}
