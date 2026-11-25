import 'package:material_ui/material_ui.dart';
import 'package:variable_blur/variable_blur.dart';

class ScrollBlurHeader extends StatefulWidget {
  const ScrollBlurHeader({super.key});

  @override
  State<ScrollBlurHeader> createState() => _ScrollBlurHeaderState();
}

class _ScrollBlurHeaderState extends State<ScrollBlurHeader> {
  final ScrollController _scrollController = ScrollController();
  double _blurIntensity = 0;
  double _headerOpacity = 1.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    const maxBlur = 12.0;
    const scrollThreshold = 200.0;

    final offset = _scrollController.offset.clamp(1.0, scrollThreshold);
    final progress = offset / scrollThreshold;

    setState(() {
      _blurIntensity = maxBlur * progress;
      _headerOpacity = (1.0 - progress * 0.7).clamp(0.3, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Blurred Header
          SliverAppBar(
            surfaceTintColor: Colors.transparent,
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background Image
                  VariableBlur(
                    sigma: _blurIntensity,
                    blurSides: BlurSides.vertical(top: 0.8),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=1200',
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey.shade300,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                    ),
                  ),

                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.3),
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),

                  // Header Content
                  Positioned(
                    bottom: 60,
                    left: 20,
                    right: 20,
                    child: Opacity(
                      opacity: _headerOpacity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mountain Adventure',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Discover breathtaking landscapes and hidden gems',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 16,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Blur Indicator
                  Positioned(
                    top: 100,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Blur: ${_blurIntensity.toStringAsFixed(1)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Instructions
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade600),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Scroll down to see the dynamic blur effect on the header image',
                            style: TextStyle(
                              color: Colors.blue.shade800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Sample Content
                  ...List.generate(20, (index) => _buildContentCard(index)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getRandomIcon(index),
              color: Colors.blue.shade600,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Adventure Tip #${index + 1}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Essential information for your mountain adventure journey. Plan ahead and stay safe.',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRandomIcon(int index) {
    final icons = [
      Icons.hiking,
      Icons.terrain,
      Icons.camera_alt,
      Icons.map,
      Icons.compass_calibration,
      Icons.wb_sunny,
      Icons.water_drop,
      Icons.local_fire_department,
    ];
    return icons[index % icons.length];
  }
}
