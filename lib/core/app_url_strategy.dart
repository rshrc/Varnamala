// URL strategy is a browser concern. Keeping the web implementation behind a
// conditional export lets the same entrypoint continue to compile on mobile
// and desktop.
export 'app_url_strategy_stub.dart'
    if (dart.library.js_interop) 'app_url_strategy_web.dart';
