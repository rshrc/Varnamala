import 'package:flutter/material.dart';
import 'package:words625/views/theme.dart';

/// A season's name above its episodes.
class KathaSeasonHeading extends StatelessWidget {
  const KathaSeasonHeading({
    super.key,
    required this.season,
    required this.episodes,
  });

  final int season;
  final int episodes;

  static const _names = {1: 'Season one', 2: 'Season two: The Lake'};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _names[season] ?? 'Season $season',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            '$episodes episodes',
            style: theme.textTheme.labelMedium?.copyWith(
              color: context.appTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
