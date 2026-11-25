import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import 'package:variable_blur/variable_blur.dart';

class BlurTransitions extends StatefulWidget {
  const BlurTransitions({super.key});

  @override
  State<BlurTransitions> createState() => _BlurTransitionsState();
}

class _BlurTransitionsState extends State<BlurTransitions>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _rotateController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _pulseAnimation;

  bool _isAnimating = false;
  int _currentDemo = 0;

  final List<String> _demoNames = [
    'Fade Blur',
    'Slide Blur',
    'Rotate Blur',
    'Pulse Blur',
  ];

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _rotateController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 15.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: const Offset(1.0, 0.0),
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 2.0).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.0, end: 12.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.elasticInOut),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _rotateController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startAnimation(int demoIndex) {
    setState(() {
      _isAnimating = true;
      _currentDemo = demoIndex;
    });

    switch (demoIndex) {
      case 0:
        _fadeController.reset();
        _fadeController.forward().then((_) {
          _fadeController.reverse().then((_) {
            setState(() => _isAnimating = false);
          });
        });
        break;
      case 1:
        _slideController.reset();
        _slideController.forward().then((_) {
          _slideController.reverse().then((_) {
            setState(() => _isAnimating = false);
          });
        });
        break;
      case 2:
        _rotateController.reset();
        _rotateController.forward().then((_) {
          setState(() => _isAnimating = false);
        });
        break;
      case 3:
        _pulseController.reset();
        _pulseController.repeat(reverse: true);
        Future.delayed(const Duration(seconds: 6), () {
          _pulseController.stop();
          setState(() => _isAnimating = false);
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blur Transitions'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Demo Selection
          Container(
            height: 120,
            margin: const EdgeInsets.all(16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _demoNames.length,
              itemBuilder: (context, index) {
                final isSelected = _currentDemo == index;
                return GestureDetector(
                  onTap: _isAnimating ? null : () => _startAnimation(index),
                  child: Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.teal : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isSelected
                                ? Colors.teal.shade700
                                : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getIconForDemo(index),
                          size: 30,
                          color:
                              isSelected ? Colors.white : Colors.grey.shade600,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _demoNames[index],
                          style: TextStyle(
                            color:
                                isSelected
                                    ? Colors.white
                                    : Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (_isAnimating && isSelected) ...[
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(
                                isSelected ? Colors.white : Colors.teal,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Animation Display Area
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: _buildCurrentDemo(),
              ),
            ),
          ),

          // Controls
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  _getDemoDescription(_currentDemo),
                  style: const TextStyle(fontSize: 16, height: 1.4),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed:
                        _isAnimating
                            ? null
                            : () => _startAnimation(_currentDemo),
                    icon: Icon(_isAnimating ? Icons.stop : Icons.play_arrow),
                    label: Text(
                      _isAnimating ? 'Animating...' : 'Start Animation',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentDemo() {
    const imageUrl =
        'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800';

    switch (_currentDemo) {
      case 0: // Fade Blur
        return AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return VariableBlur(
              sigma: _fadeAnimation.value,
              blurSides: BlurSides.vertical(top: 0.5, bottom: 0.35),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(imageUrl, fit: BoxFit.cover),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        'Blur: ${_fadeAnimation.value.toStringAsFixed(1)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );

      case 1: // Slide Blur
        return AnimatedBuilder(
          animation: _slideAnimation,
          builder: (context, child) {
            final progress = (_slideAnimation.value.dx + 1.0) / 2.0;
            return VariableBlur(
              sigma: 8.0,
              blurSides: BlurSides.horizontal(
                left: 1.0 - progress,
                right: progress,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(imageUrl, fit: BoxFit.cover),
                  Positioned(
                    left: (progress - 0.5) * MediaQuery.of(context).size.width,
                    top: 0,
                    bottom: 0,
                    width: 4,
                    child: Container(color: Colors.red.withValues(alpha: 0.8)),
                  ),
                ],
              ),
            );
          },
        );

      case 2: // Rotate Blur
        return AnimatedBuilder(
          animation: _rotateAnimation,
          builder: (context, child) {
            final angle = _rotateAnimation.value * 3.14159;
            final topBlur = (1.0 + math.cos(angle)) / 2.0;
            final bottomBlur = (1.0 - math.cos(angle)) / 2.0;

            return Transform.rotate(
              angle: _rotateAnimation.value * 0.1,
              child: VariableBlur(
                sigma: 6.0,
                blurSides: BlurSides.vertical(top: topBlur, bottom: bottomBlur),
                child: Image.network(imageUrl, fit: BoxFit.cover),
              ),
            );
          },
        );

      case 3: // Pulse Blur
        return AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            final scale = 1.0 + (_pulseAnimation.value / 100.0);
            return Transform.scale(
              scale: scale,
              child: VariableBlur(
                sigma: _pulseAnimation.value,
                blurSides: BlurSides.vertical(top: _pulseAnimation.value / 2.0),

                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(imageUrl, fit: BoxFit.cover),
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.3),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.7),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.favorite,
                            color: Colors.red.withValues(alpha: 0.8),
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );

      default:
        return Container(
          color: Colors.grey.shade200,
          child: const Center(child: Text('Select a demo to begin')),
        );
    }
  }

  IconData _getIconForDemo(int index) {
    switch (index) {
      case 0:
        return Icons.opacity;
      case 1:
        return Icons.swipe;
      case 2:
        return Icons.rotate_right;
      case 3:
        return Icons.graphic_eq;
      default:
        return Icons.blur_on;
    }
  }

  String _getDemoDescription(int index) {
    switch (index) {
      case 0:
        return 'Watch as the blur intensity gradually increases and decreases, creating a smooth fade effect that can be used for focus transitions.';
      case 1:
        return 'See how blur zones can slide across the image, perfect for creating dynamic focus areas that follow user interaction or content.';
      case 2:
        return 'Experience a rotating blur pattern that creates an interesting visual effect while the entire image gently rotates.';
      case 3:
        return 'Observe a pulsing blur effect that rhythmically changes intensity, ideal for drawing attention to specific content areas.';
      default:
        return 'Select a demo above to see different blur transition effects in action.';
    }
  }
}
