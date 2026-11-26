import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';
import 'package:variable_blur/variable_blur.dart';

/// Repeatable memory benchmark: a list of blurred cards that scrolls by
/// itself, with no network images, so runs can be compared.
class BlurBenchmark extends StatefulWidget {
  const BlurBenchmark({super.key});

  @override
  State<BlurBenchmark> createState() => _BlurBenchmarkState();
}

class _BlurBenchmarkState extends State<BlurBenchmark>
    with SingleTickerProviderStateMixin {
  final _controller = ScrollController();

  /// With --dart-define=BENCH_ANIM=true the blur strength changes every
  /// frame, the worst case: the blur has to be worked out again each frame.
  static const _animate = bool.fromEnvironment('BENCH_ANIM');
  Ticker? _ticker;
  double _sigma = 20;

  @override
  void initState() {
    super.initState();
    if (_animate) {
      _ticker = createTicker((elapsed) {
        final t = elapsed.inMicroseconds / 1e6;
        setState(() => _sigma = 12 + 8 * math.sin(t * 2));
      })..start();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _loop());
  }

  Future<void> _loop() async {
    var down = true;
    while (mounted) {
      final target = down ? _controller.position.maxScrollExtent : 0.0;
      await _controller.animateTo(
        target,
        duration: const Duration(seconds: 6),
        curve: Curves.linear,
      );
      down = !down;
    }
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        controller: _controller,
        itemCount: 30,
        itemBuilder:
            (context, i) => SizedBox(
              height: 420,
              child: VariableBlur(
                sigma: _sigma,
                blurSides: const BlurSides.vertical(top: 0.4, bottom: 0.4),
                child: _Card(index: i),
              ),
            ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    final hue = (index * 37) % 360.0;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            HSLColor.fromAHSL(1, hue, .7, .45).toColor(),
            HSLColor.fromAHSL(1, (hue + 80) % 360, .7, .6).toColor(),
          ],
        ),
      ),
      child: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 8,
        children: List.generate(
          64,
          (j) => Center(
            child: Text(
              '${index * 64 + j}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
