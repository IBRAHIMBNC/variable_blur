import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:variable_blur/variable_blur.dart';

/// Memory comparison: the same auto-scrolling list with a blur band pinned
/// at the top, drawn three ways. Pick one per launch with
/// --dart-define=BENCH_MODE=none|variable|native.
///
/// - none: the list alone, the baseline.
/// - variable: the list wrapped in [VariableBlur] with a top band.
/// - native: one iOS UIVisualEffectView over the band (platform view).
///
/// After [_warmup] it samples the app's memory footprint (the number Xcode
/// shows) for [_window] and prints one BENCH_RESULT line.
class NativeCompare extends StatefulWidget {
  const NativeCompare({super.key});

  @override
  State<NativeCompare> createState() => _NativeCompareState();
}

class _NativeCompareState extends State<NativeCompare> {
  static const _mode = String.fromEnvironment(
    'BENCH_MODE',
    defaultValue: 'variable',
  );
  static const _band = 200.0;
  static const _quality = String.fromEnvironment('BENCH_QUALITY');
  static const _warmup = Duration(seconds: 10);
  static const _window = Duration(seconds: 20);
  static const _channel = MethodChannel('bench/memory');

  final _controller = ScrollController();
  final _samples = <double>[];
  final _raster = <double>[];
  final _build = <double>[];
  Timer? _timer;
  String _status = 'warming up';
  late final Stopwatch _clock = Stopwatch()..start();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addTimingsCallback(_onTimings);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loop());
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) => _tick());
  }

  void _onTimings(List<FrameTiming> timings) {
    if (_clock.elapsed < _warmup) return;
    for (final t in timings) {
      _raster.add(t.rasterDuration.inMicroseconds / 1000);
      _build.add(t.buildDuration.inMicroseconds / 1000);
    }
  }

  Future<void> _tick() async {
    final elapsed = _clock.elapsed;
    if (elapsed < _warmup) return;
    if (elapsed > _warmup + _window) {
      _timer?.cancel();
      _report();
      return;
    }
    final bytes = await _channel.invokeMethod<int>('footprint') ?? -1;
    _samples.add(bytes / (1024 * 1024));
    if (mounted) {
      setState(() => _status = 'sampling ${_samples.length}');
    }
  }

  void _report() {
    double avg(List<double> v) =>
        v.isEmpty ? 0 : v.reduce((a, b) => a + b) / v.length;
    final peak =
        _samples.isEmpty ? 0.0 : _samples.reduce((a, b) => a > b ? a : b);
    final line =
        'BENCH_RESULT mode=$_mode q=$_quality '
        'avgMB=${avg(_samples).toStringAsFixed(1)} '
        'peakMB=${peak.toStringAsFixed(1)} '
        'rasterMs=${avg(_raster).toStringAsFixed(2)} '
        'buildMs=${avg(_build).toStringAsFixed(2)} '
        'frames=${_raster.length}';
    debugPrint(line);
    if (mounted) setState(() => _status = line.replaceAll(' ', '\n'));
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
    SchedulerBinding.instance.removeTimingsCallback(_onTimings);
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = ListView.builder(
      controller: _controller,
      itemCount: 30,
      itemBuilder:
          (context, i) => SizedBox(height: 420, child: _Card(index: i)),
    );

    final Widget body = switch (_mode) {
      'variable' => VariableBlur(
        sigma: 20,
        edgeIntensity: 0.05,
        quality: switch (_quality) {
          'low' => BlurQuality.low,
          'medium' => BlurQuality.medium,
          _ => BlurQuality.high,
        },
        blurSides: const ResponsiveBlurSides.vertical(top: _band),
        child: list,
      ),
      'native' => Stack(
        children: [
          list,
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: _band,
            child: UiKitView(viewType: 'native-blur'),
          ),
        ],
      ),
      // Same layers as 'variable' but no blur: isolates the layer cost.
      'boundary' => RepaintBoundary(child: RepaintBoundary(child: list)),
      _ => list,
    };

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: body),
          Positioned(
            left: 12,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.black87,
              child: Text(
                'mode: $_mode\n$_status',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
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
