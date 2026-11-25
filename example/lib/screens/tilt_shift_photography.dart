import 'package:material_ui/material_ui.dart';
import 'package:variable_blur/variable_blur.dart';

class TiltShiftPhotography extends StatefulWidget {
  const TiltShiftPhotography({super.key});

  @override
  State<TiltShiftPhotography> createState() => _TiltShiftPhotographyState();
}

class _TiltShiftPhotographyState extends State<TiltShiftPhotography> {
  double _blurIntensity = 8.0;
  double _topBlur = 0.3;
  double _bottomBlur = 0.3;
  int _selectedImageIndex = 0;

  final List<String> _sampleImages = [
    'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
    'https://images.unsplash.com/photo-1519904981063-b0cf448d479e?w=800',
    'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tilt-Shift Photography'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: ListView(
        children: [
          // Image Display Area
          Container(
            height: 400,
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: VariableBlur(
                sigma: _blurIntensity,
                blurSides: BlurSides.vertical(
                  top: _topBlur,
                  bottom: _bottomBlur,
                ),
                // kernelSize: _kernelSize,
                quality: BlurQuality.high,
                child: Image.network(
                  _sampleImages[_selectedImageIndex],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade800,
                      child: const Center(
                        child: Icon(Icons.error, color: Colors.white, size: 50),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Image Selection
          Container(
            height: 80,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _sampleImages.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedImageIndex = index;
                    });
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            _selectedImageIndex == index
                                ? Colors.blue
                                : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        _sampleImages[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Controls Panel
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tilt-Shift Controls',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Blur Intensity
                _buildSlider(
                  'Blur Intensity',
                  _blurIntensity,
                  0.0,
                  15.0,
                  (value) => setState(() => _blurIntensity = value),
                ),

                // Top Blur
                _buildSlider(
                  'Top Blur',
                  _topBlur,
                  0.0,
                  1.0 - _bottomBlur,
                  (value) => setState(() => _topBlur = value),
                ),

                // Bottom Blur
                _buildSlider(
                  'Bottom Blur',
                  _bottomBlur,
                  0.0,
                  1.0 - _topBlur,
                  (value) => setState(() => _bottomBlur = value),
                ),

                // Clear area indicator
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Clear Focus Area',
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text(
                        '${((1.0 - _topBlur - _bottomBlur) * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70)),
            Text(
              value.toStringAsFixed(1),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.blue,
            inactiveTrackColor: Colors.grey.shade700,
            thumbColor: Colors.blue,
            overlayColor: Colors.blue.withValues(alpha: 0.2),
          ),
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
