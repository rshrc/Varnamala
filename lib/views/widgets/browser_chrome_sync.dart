import 'package:flutter/material.dart';
import 'package:words625/core/browser_chrome.dart';

/// Keeps the page behind the app in the colour of the app's top edge, so on a
/// phone the status bar and notch read as part of the app rather than a strip
/// of some other colour above it.
///
/// Sits in `MaterialApp.builder`, under the theme, so a palette or light/dark
/// change repaints it in the same frame.
class BrowserChromeSync extends StatefulWidget {
  const BrowserChromeSync({required this.child, super.key});

  final Widget child;

  @override
  State<BrowserChromeSync> createState() => _BrowserChromeSyncState();
}

class _BrowserChromeSyncState extends State<BrowserChromeSync> {
  Color? _painted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // The app bar is what meets the status bar on nearly every screen.
    final top = theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface;
    if (top != _painted) {
      _painted = top;
      paintBrowserChrome(top);
    }
    return widget.child;
  }
}
