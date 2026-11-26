import 'package:material_ui/material_ui.dart';
import 'package:variable_blur/variable_blur.dart';

/// Tilt-shift: blurring the top and bottom of an aerial photo makes a real
/// city look like a tiny model.
class MiniatureShowcase extends StatelessWidget {
  const MiniatureShowcase({super.key});

  static const _city =
      'https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?w=1400';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          VariableBlur(
            sigma: 14,
            edgeIntensity: 0.18,
            blurSides: const BlurSides.vertical(top: 0.38, bottom: 0.38),
            child: Image.network(
              _city,
              fit: BoxFit.cover,
              // A touch more colour, like a toy model.
              color: const Color(0x14FF8800),
              colorBlendMode: BlendMode.softLight,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton.filledTonal(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const Spacer(),
                  const Text(
                    'Miniature City',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Text(
                    'Tilt-shift with BlurSides.vertical',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
