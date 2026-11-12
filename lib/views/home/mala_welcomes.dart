// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:words625/gen/assets.gen.dart';

class MalaWelcomes extends StatefulWidget {
  const MalaWelcomes({super.key});

  @override
  _MalaWelcomesState createState() => _MalaWelcomesState();
}

class _MalaWelcomesState extends State<MalaWelcomes> {
  final List<String> images = [
    Assets.images.mala.malaExcited.path,
    Assets.images.mala.malaWave.path,
    Assets.images.mala.malaLusty.path,
  ];
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % images.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        //
        child: Image.asset(
          images[_currentIndex],
          key: ValueKey<String>(images[_currentIndex]),
          height: 250,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
