import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:variable_blur/variable_blur.dart';

/// A tilt-shift photo editor: blurring above and below a sharp band makes a
/// real city look like a tiny model. Drag the sliders to move the band and
/// change the blur.
class MiniatureShowcase extends StatefulWidget {
  const MiniatureShowcase({super.key});

  @override
  State<MiniatureShowcase> createState() => _MiniatureShowcaseState();
}

class _MiniatureShowcaseState extends State<MiniatureShowcase> {
  static const _city =
      'https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?w=1400';

  /// Centre of the sharp band, as a fraction of the height.
  double _focus = 0.42;

  /// Strongest blur.
  double _sigma = 14;

  /// Height of the sharp band, as a fraction of the height.
  static const _band = 0.22;

  @override
  Widget build(BuildContext context) {
    final top = (_focus - _band / 2).clamp(0.0, 1.0);
    final bottom = (1 - _focus - _band / 2).clamp(0.0, 1.0);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            VariableBlur(
              sigma: _sigma,
              edgeIntensity: 0.12,
              blurSides: BlurSides.vertical(top: top, bottom: bottom),
              child: Image.network(
                _city,
                fit: BoxFit.cover,
                // A touch more colour, like a toy model.
                color: const Color(0x1AFF8800),
                colorBlendMode: BlendMode.softLight,
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.18],
                  colors: [Colors.black54, Colors.transparent],
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  _TopBar(onClose: () => Navigator.maybePop(context)),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: _Panel(
                      focus: _focus,
                      sigma: _sigma,
                      onFocus: (v) => setState(() => _focus = v),
                      onSigma: (v) => setState(() => _sigma = v),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
      child: Row(
        children: [
          TextButton(
            onPressed: onClose,
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          const Spacer(),
          const Text(
            'TILT-SHIFT',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD60A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Done',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.focus,
    required this.sigma,
    required this.onFocus,
    required this.onSigma,
  });

  final double focus;
  final double sigma;
  final ValueChanged<double> onFocus;
  final ValueChanged<double> onSigma;

  @override
  Widget build(BuildContext context) {
    const tools = [
      (Icons.blur_linear_rounded, 'Tilt-shift'),
      (Icons.wb_sunny_outlined, 'Light'),
      (Icons.palette_outlined, 'Colour'),
      (Icons.crop_rounded, 'Crop'),
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SliderRow(
            label: 'Focus',
            value: focus,
            min: 0.15,
            max: 0.85,
            display: '${(focus * 100).round()}%',
            onChanged: onFocus,
          ),
          _SliderRow(
            label: 'Blur',
            value: sigma,
            min: 2,
            max: 30,
            display: sigma.toStringAsFixed(0),
            onChanged: onSigma,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var i = 0; i < tools.length; i++)
                Column(
                  children: [
                    Icon(
                      tools[i].$1,
                      color: i == 0 ? const Color(0xFFFFD60A) : Colors.white70,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tools[i].$2,
                      style: TextStyle(
                        fontSize: 11,
                        color:
                            i == 0 ? const Color(0xFFFFD60A) : Colors.white70,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.display,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final String display;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Text(label, style: const TextStyle(color: Colors.white)),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white24,
              thumbColor: Colors.white,
              overlayShape: SliderComponentShape.noOverlay,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(
            display,
            textAlign: TextAlign.right,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      ],
    );
  }
}
