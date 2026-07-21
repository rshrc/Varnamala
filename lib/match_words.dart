// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/annotations.dart';

// Project imports:
import 'package:words625/views/match/match_page.dart';

/// Route target for Match Madness. The screen itself lives under `views/match/`
/// with the rest of the UI; this file stays here because the generated router
/// points at it.
@RoutePage()
class MatchWordsPage extends StatelessWidget {
  const MatchWordsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const MatchPage();
}
