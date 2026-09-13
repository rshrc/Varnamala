/// Switches for the incremental `provider` -> `riverpod` migration.
///
/// Each flag lets one provider's Riverpod replacement be swapped in (or
/// reverted) at this single point, instead of by hunting down every call
/// site again. Flip to `false` to fall back to the legacy `ChangeNotifier`
/// provider while both implementations still live in the tree.
class MigrationFlags {
  const MigrationFlags._();

  /// When true, theme state is read from [themeModeProvider] (Riverpod)
  /// instead of the legacy `ThemeProvider` (package:provider).
  static const useRiverpodTheme = true;
}
