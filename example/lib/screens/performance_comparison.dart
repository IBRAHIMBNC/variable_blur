import 'dart:async';
import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';

class PerformanceComparison extends StatefulWidget {
  const PerformanceComparison({super.key});

  @override
  State<PerformanceComparison> createState() => _PerformanceComparisonState();
}

class _PerformanceComparisonState extends State<PerformanceComparison>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  Timer? _fpsTimer;

  int _frameCount = 0;
  int _fps = 0;
  bool _isRunning = false;
  bool _showBlur = true;

  double _blurStrength = 5.0;
  int _numberOfElements = 50;

  final List<BlurredElement> _elements = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _generateElements();
    _startFpsCounter();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fpsTimer?.cancel();
    super.dispose();
  }

  void _generateElements() {
    _elements.clear();
    final random = math.Random();

    for (int i = 0; i < _numberOfElements; i++) {
      _elements.add(
        BlurredElement(
          color: Color.fromRGBO(
            random.nextInt(255),
            random.nextInt(255),
            random.nextInt(255),
            0.8,
          ),
          size: 20 + random.nextDouble() * 60,
          startX: random.nextDouble(),
          startY: random.nextDouble(),
          speedX: (random.nextDouble() - 0.5) * 2,
          speedY: (random.nextDouble() - 0.5) * 2,
        ),
      );
    }
  }

  void _startFpsCounter() {
    _fpsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _fps = _frameCount;
          _frameCount = 0;
        });
      }
    });
  }

  void _toggleAnimation() {
    setState(() {
      _isRunning = !_isRunning;
      if (_isRunning) {
        _animationController.repeat();
      } else {
        _animationController.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Comparison'),
        backgroundColor: Colors.indigo.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade600, Colors.indigo.shade50],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Performance Stats
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard('FPS', _fps.toString(), Colors.green),
                    _buildStatCard(
                      'Elements',
                      _numberOfElements.toString(),
                      Colors.blue,
                    ),
                    _buildStatCard(
                      'Blur',
                      _showBlur ? 'ON' : 'OFF',
                      _showBlur ? Colors.orange : Colors.grey,
                    ),
                  ],
                ),
              ),

              // Animation Area
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      // Background
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF1e3c72), Color(0xFF2a5298)],
                          ),
                        ),
                      ),

                      // Animated Elements
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          _frameCount++;
                          return CustomPaint(
                            painter: ElementsPainter(
                              elements: _elements,
                              animationValue: _animationController.value,
                              showBlur: _showBlur,
                              blurStrength: _blurStrength,
                            ),
                            size: Size(double.infinity, 400),
                          );
                        },
                      ),

                      // Performance Overlay
                      if (_isRunning)
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'FPS: $_fps',
                              style: TextStyle(
                                color:
                                    _fps > 55
                                        ? Colors.green
                                        : _fps > 30
                                        ? Colors.yellow
                                        : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Controls
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Animation Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _toggleAnimation,
                          icon: Icon(
                            _isRunning ? Icons.pause : Icons.play_arrow,
                          ),
                          label: Text(_isRunning ? 'Pause' : 'Start'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _isRunning ? Colors.orange : Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _generateElements();
                            });
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Regenerate'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Blur Toggle
                    SwitchListTile(
                      title: const Text('Enable Blur Effects'),
                      subtitle: Text(
                        'Impact on performance: ${_showBlur ? 'High' : 'Low'}',
                      ),
                      value: _showBlur,
                      onChanged: (value) {
                        setState(() {
                          _showBlur = value;
                        });
                      },
                      activeThumbColor: Colors.indigo,
                    ),

                    // Blur Strength
                    if (_showBlur) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Blur Strength: ${_blurStrength.toStringAsFixed(1)}',
                      ),
                      Slider(
                        value: _blurStrength,
                        min: 1.0,
                        max: 15.0,
                        divisions: 14,
                        onChanged: (value) {
                          setState(() {
                            _blurStrength = value;
                          });
                        },
                        activeColor: Colors.indigo,
                      ),
                    ],

                    // Number of Elements
                    const SizedBox(height: 8),
                    Text('Elements: $_numberOfElements'),
                    Slider(
                      value: _numberOfElements.toDouble(),
                      min: 10,
                      max: 200,
                      divisions: 19,
                      onChanged: (value) {
                        setState(() {
                          _numberOfElements = value.round();
                          _generateElements();
                        });
                      },
                      activeColor: Colors.indigo,
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

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class BlurredElement {
  final Color color;
  final double size;
  final double startX;
  final double startY;
  final double speedX;
  final double speedY;

  BlurredElement({
    required this.color,
    required this.size,
    required this.startX,
    required this.startY,
    required this.speedX,
    required this.speedY,
  });
}

class ElementsPainter extends CustomPainter {
  final List<BlurredElement> elements;
  final double animationValue;
  final bool showBlur;
  final double blurStrength;

  ElementsPainter({
    required this.elements,
    required this.animationValue,
    required this.showBlur,
    required this.blurStrength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final element in elements) {
      final x =
          (element.startX + element.speedX * animationValue) % 1.0 * size.width;
      final y =
          (element.startY + element.speedY * animationValue) %
          1.0 *
          size.height;

      final paint =
          Paint()
            ..color = element.color
            ..style = PaintingStyle.fill;

      if (showBlur) {
        // Simulate blur by drawing multiple overlapping circles with reduced opacity
        final blurPaint =
            Paint()
              ..color = element.color.withValues(alpha: 0.1)
              ..style = PaintingStyle.fill;

        for (int i = 0; i < blurStrength.round(); i++) {
          final offset = i * 2.0;
          canvas.drawCircle(
            Offset(x + offset, y + offset),
            element.size / 2 + offset,
            blurPaint,
          );
        }
      }

      canvas.drawCircle(Offset(x, y), element.size / 2, paint);
    }
  }

  @override
  bool shouldRepaint(ElementsPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.showBlur != showBlur ||
        oldDelegate.blurStrength != blurStrength;
  }
}
