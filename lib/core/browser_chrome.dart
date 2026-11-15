// The page behind the Flutter view, which the browser shows wherever the app
// does not reach: under the iPhone's notch and status bar, and in the
// toolbars that Safari and Chrome tint to match the page.
export 'browser_chrome_stub.dart'
    if (dart.library.js_interop) 'browser_chrome_web.dart';
