import 'package:flutter_web_plugins/url_strategy.dart';

/// Uses normal browser paths (`/katha-lab`) instead of hash paths
/// (`/#/katha-lab`). Firebase Hosting rewrites these paths to `index.html`.
void configureAppUrlStrategy() => usePathUrlStrategy();
