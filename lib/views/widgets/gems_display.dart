// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:words625/application/gems_provider.dart';
import 'package:words625/views/theme.dart';
import 'package:words625/views/widgets/loader.dart';

class GemsDisplay extends StatelessWidget {
  const GemsDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: context.appDanger.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(VarnamalaTheme.radiusRound),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.diamond_rounded, color: context.appDanger, size: 18),
          const SizedBox(width: 4),
          StreamBuilder<int>(
            stream: context.read<GemsProvider>().getGemsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Loader();
              }

              final gems = snapshot.data ?? 0;
              return Text(
                '$gems',
                style: TextStyle(
                  color: context.appDanger,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
