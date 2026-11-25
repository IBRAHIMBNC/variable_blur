import 'package:example/screens/blur_benchmark.dart';
import 'package:example/screens/blur_transitions.dart';
import 'package:example/screens/performance_comparison.dart';
import 'package:example/screens/scroll_blur_header.dart';
import 'package:example/screens/tilt_shift_photography.dart';
import 'package:example/screens/wallpaper_gallery.dart';
import 'package:material_ui/material_ui.dart';
import 'package:example/screens/gradual_top_blur.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Variable Blur Examples',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home:
          const bool.fromEnvironment('BENCH')
              ? const BlurBenchmark()
              : const ExampleShowcase(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ExampleShowcase extends StatelessWidget {
  const ExampleShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Variable Blur Examples'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade600, Colors.blue.shade50],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 0.9,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildExampleCard(
                  context,
                  'Tilt-Shift Photography',
                  'Professional depth-of-field effects',
                  Icons.camera_alt,
                  Colors.purple,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TiltShiftPhotography(),
                    ),
                  ),
                ),
                _buildExampleCard(
                  context,
                  'Scroll Blur Header',
                  'Dynamic blur based on scroll position',
                  Icons.vertical_align_center,
                  Colors.green,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ScrollBlurHeader(),
                    ),
                  ),
                ),
                _buildExampleCard(
                  context,
                  'Scroll Base Blur',
                  'Dynamic blur based on scroll position',
                  Icons.vertical_align_center,
                  Colors.green,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GradualTopBlur()),
                  ),
                ),

                _buildExampleCard(
                  context,
                  'Wallpaper Gallery',
                  'Beautiful blur effects in galleries',
                  Icons.photo_library,
                  Colors.pink,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WallpaperGallery(),
                    ),
                  ),
                ),
                _buildExampleCard(
                  context,
                  'Blur Transitions',
                  'Smooth animated blur transitions',
                  Icons.animation,
                  Colors.teal,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BlurTransitions(),
                    ),
                  ),
                ),
                _buildExampleCard(
                  context,
                  'Performance Test',
                  'Compare quality vs performance',
                  Icons.speed,
                  Colors.red,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PerformanceComparison(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExampleCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.1),
                color.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: color),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
