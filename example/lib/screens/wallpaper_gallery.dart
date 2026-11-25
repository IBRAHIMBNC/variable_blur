import 'package:material_ui/material_ui.dart';
import 'package:variable_blur/variable_blur.dart';

class WallpaperGallery extends StatefulWidget {
  const WallpaperGallery({super.key});

  @override
  State<WallpaperGallery> createState() => _WallpaperGalleryState();
}

class _WallpaperGalleryState extends State<WallpaperGallery> {
  final ScrollController _scrollController = ScrollController();

  double blurSigma = 1;

  final List<Map<String, dynamic>> _wallpapers = [
    {
      'title': 'Mountain Peak',
      'url':
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
      'category': 'Nature',
      'color': Colors.blue,
    },
    {
      'title': 'City Lights',
      'url':
          'https://images.unsplash.com/photo-1519904981063-b0cf448d479e?w=800',
      'category': 'Urban',
      'color': Colors.orange,
    },

    {
      'title': 'Ocean Waves',
      'url':
          'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?w=800',
      'category': 'Ocean',
      'color': Colors.teal,
    },
    {
      'title': 'Desert Dunes',
      'url':
          'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?w=800',
      'category': 'Desert',
      'color': Colors.amber,
    },
    {
      'title': 'Aurora Sky',
      'url':
          'https://images.unsplash.com/photo-1531366936337-7c912a4589a7?w=800',
      'category': 'Sky',
      'color': Colors.purple,
    },
    {
      'title': 'Cherry Blossom',
      'url':
          'https://images.unsplash.com/photo-1522383225653-ed111181a951?w=800',
      'category': 'Nature',
      'color': Colors.pink,
    },
    {
      'title': 'Abstract Art',
      'url':
          'https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=800',
      'category': 'Abstract',
      'color': Colors.deepPurple,
    },
  ];

  @override
  void initState() {
    _scrollController.addListener(_onScroll);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    const maxBlur = 8.0;
    const scrollThreshold = 200.0;

    if (_scrollController.offset < scrollThreshold) {
      // Calculate blurSigma based on scroll position
      setState(() {
        blurSigma = maxBlur * (_scrollController.offset / scrollThreshold);
        if (blurSigma == maxBlur) {
          blurSigma = maxBlur; // Ensure it doesn't exceed maxBlur
        } else if (blurSigma < 1) {
          blurSigma = 1; // Minimum blur value
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Wallpaper Gallery'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: VariableBlur(
        sigma: blurSigma,
        blurSides: BlurSides.vertical(top: 0.25),
        child: Stack(
          children: [
            // Background with blur effect
            Positioned.fill(
              child: VariableBlur(
                sigma: 8,
                blurSides: BlurSides.vertical(top: 0.3, bottom: 0.3),

                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.indigo.shade100, Colors.purple.shade100],
                    ),
                  ),
                ),
              ),
            ),

            // Main content
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                // App Bar with blur effect
                SliverToBoxAdapter(child: SizedBox(height: 120)),

                // Wallpaper Grid
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                        ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _buildWallpaperCard(_wallpapers[index]),
                      childCount: _wallpapers.length,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWallpaperCard(Map<String, dynamic> wallpaper) {
    return GestureDetector(
      onTap: () => _showWallpaperDetail(wallpaper),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Main image with subtle blur effect
              VariableBlur(
                sigma: 4.0,
                blurSides: BlurSides.vertical(top: 0.1, bottom: 0.4),
                child: Image.network(
                  wallpaper['url'],
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: wallpaper['color'].withValues(alpha: 0.1),
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              ),

              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.3),
                    ],
                  ),
                ),
              ),

              // Content
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wallpaper['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: wallpaper['color'].withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            wallpaper['category'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.favorite_border,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWallpaperDetail(Map<String, dynamic> wallpaper) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.8,
            maxChildSize: 0.95,
            minChildSize: 0.5,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    // Handle
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(top: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Content
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(20),
                        children: [
                          // Full image with interactive blur
                          Container(
                            height: 300,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: VariableBlur(
                                sigma: 5,
                                blurSides: BlurSides.vertical(
                                  top: 0.2,
                                  bottom: 0.3,
                                ),
                                child: Image.network(
                                  wallpaper['url'],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Details
                          Text(
                            wallpaper['title'],
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: wallpaper['color'].withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: wallpaper['color'].withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  wallpaper['category'],
                                  style: TextStyle(
                                    color: wallpaper['color'],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            'This wallpaper showcases the variable blur effect with carefully crafted blur zones to create depth and visual interest. The blur effect is applied using advanced GPU shaders for optimal performance.',
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: Colors.grey,
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Action buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.download),
                                  label: const Text('Download'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: wallpaper['color'],
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.favorite_border),
                                label: const Text('Like'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade100,
                                  foregroundColor: Colors.grey.shade700,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }
}
