import 'package:flutter/material.dart';
import 'package:variable_blur/variable_blur.dart';

class GradualTopBlur extends StatefulWidget {
  const GradualTopBlur({super.key});

  @override
  State<GradualTopBlur> createState() => _GradualTopBlurState();
}

class _GradualTopBlurState extends State<GradualTopBlur> {
  final ScrollController _scrollController = ScrollController();
  double _blurIntensity = 0.0;

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
    const maxBlur = 15;
    const scrollThreshold = 200.0;

    final offset = _scrollController.offset.clamp(1.0, scrollThreshold);
    final progress = offset / scrollThreshold;

    setState(() {
      _blurIntensity = maxBlur * progress;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Gradual Background Blur'),
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: VariableBlur(
        sigma: _blurIntensity,
        edgeIntensity: 0.06,
        blurSides: ResponsiveBlurSides.vertical(top: screenHeight * 0.2),
        child: Container(
          color: Colors.black,
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.only(top: 100),
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
            color: Colors.grey.withOpacity(0.1),
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
