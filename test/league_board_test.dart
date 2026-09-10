// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:words625/core/enums.dart';
import 'package:words625/domain/league.dart';
import 'package:words625/views/leaderboard/components/league_board.dart';
import 'package:words625/views/theme.dart';

LeaderboardEntry rival(String name, int xp) => LeaderboardEntry(
      userId: name,
      name: name,
      profileImage: name,
      score: xp,
      leagueXp: xp,
      league: 'bronze',
      languages: const ['kannada'],
      leagueXpByLanguage: {'kannada': xp},
    );

List<LeaderboardEntry> ordered(List<LeaderboardEntry> users) {
  final sorted = [...users]..sort(
      (a, b) => b.leagueXpFor('kannada').compareTo(a.leagueXpFor('kannada')));
  return sorted;
}

Widget host(Widget child) => MaterialApp(
      theme: VarnamalaTheme.lightTheme,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

double topOf(WidgetTester tester, String name) =>
    tester.getTopLeft(find.byKey(ValueKey(name))).dy;

void main() {
  testWidgets('a row that overtakes another actually moves', (tester) async {
    // The regression this guards: the board was a ListView, so a change of
    // standing swapped children between frames and the climb was invisible.
    final before = ordered([rival('ahead', 300), rival('me', 100)]);

    await tester.pumpWidget(host(
      LeagueBoard(
        users: before,
        language: TargetLanguage.kannada,
        myUserId: 'me',
      ),
    ));
    await tester.pumpAndSettle();

    final myStart = topOf(tester, 'me');
    expect(topOf(tester, 'ahead'), lessThan(myStart));

    // Earn enough to overtake.
    await tester.pumpWidget(host(
      LeagueBoard(
        users: ordered([rival('ahead', 300), rival('me', 400)]),
        language: TargetLanguage.kannada,
        myUserId: 'me',
      ),
    ));

    // Mid-flight: the row has left its old place but not arrived at the new
    // one. That gap is the animation.
    await tester.pump(const Duration(milliseconds: 200));
    final midway = topOf(tester, 'me');
    expect(midway, lessThan(myStart), reason: 'the row never moved');

    await tester.pumpAndSettle();
    expect(topOf(tester, 'me'), lessThan(topOf(tester, 'ahead')));
  });

  testWidgets('the top three get their own marks', (tester) async {
    await tester.pumpWidget(host(
      LeagueBoard(
        users: ordered([
          rival('first', 500),
          rival('second', 400),
          rival('third', 300),
          rival('fourth', 200),
        ]),
        language: TargetLanguage.kannada,
      ),
    ));
    await tester.pump();

    // Gold takes a different glyph from silver and bronze, and fourth gets a
    // number rather than a medal.
    expect(find.byIcon(Icons.workspace_premium_rounded), findsOneWidget);
    expect(find.byIcon(Icons.military_tech_rounded), findsNWidgets(2));
    expect(find.text('4'), findsOneWidget);
    expect(find.text('1'), findsNothing);
  });

  testWidgets('the board shows the XP it ranks on', (tester) async {
    // Showing account-wide XP while ranking per-language made a board read
    // 170, 95, 52, 320 top to bottom.
    const mixed = LeaderboardEntry(
      userId: 'mixed',
      name: 'Mixed',
      profileImage: 'mixed',
      score: 900,
      leagueXp: 320,
      league: 'bronze',
      languages: ['kannada', 'tamil'],
      leagueXpByLanguage: {'kannada': 12, 'tamil': 308},
    );

    await tester.pumpWidget(host(
      const LeagueBoard(
        users: [mixed],
        language: TargetLanguage.kannada,
      ),
    ));
    await tester.pump();

    expect(find.text('12 XP'), findsOneWidget);
    expect(find.text('320 XP'), findsNothing);
  });

  testWidgets('reduced motion still ranks, it just does not perform',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: VarnamalaTheme.lightTheme,
      home: MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: Scaffold(
          body: LeagueBoard(
            users: ordered([rival('a', 200), rival('b', 100)]),
            language: TargetLanguage.kannada,
          ),
        ),
      ),
    ));
    await tester.pump();

    expect(topOf(tester, 'a'), lessThan(topOf(tester, 'b')));
    expect(tester.takeException(), isNull);
  });
}
