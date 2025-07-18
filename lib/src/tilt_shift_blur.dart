import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'package:variable_blur/src/models/blur_side.dart';
import 'package:variable_blur/src/models/blur_side_base.dart';

/// A widget that applies variable blur effects to its child widget.
///
/// [VariableBlur] enables you to create sophisticated blur effects with different
/// intensities for different regions of the widget. It's perfect for creating
/// tilt-shift photography effects, focus transitions, or artistic blur overlays.
///
/// The widget uses GPU-accelerated Fragment Shaders for high-performance rendering
/// and supports customizable blur regions, quality settings, and smooth edge transitions.
///
/// ## Key Features
/// - Variable blur intensity across different regions
/// - Smooth edge transitions with customizable intensity
/// - High-performance GPU-accelerated rendering
/// - Quality control for performance optimization
/// - Android device compatibility support
///
/// ## Important Compatibility Note
/// **Blur effects only work on images or colored containers.** The child widget must have
/// visible content (pixels) for the blur effect to be applied. Transparent widgets,
/// empty containers, or widgets without background colors will not show blur effects.
///
/// Supported child widgets include:
/// - `Image` widgets (network, asset, file, memory)
/// - `Container` with background color or decoration
/// - Widgets with colored backgrounds
/// - Custom painted widgets with visible content
///
/// For comprehensive usage examples, please refer to the example app.
///
/// ## Example Usage
///
/// ```dart
/// // Using normalized blur values (0.0 to 1.0)
/// VariableBlur(
///   sigma: 15.0,
///   blurSides: BlurSides.vertical(top: 1.0, bottom: 0.3),
///   edgeIntensity: 0.2,
///   quality: BlurQuality.high,
///   useRepaintBoundary: true, // For performance optimization
///   child: Image.asset('assets/photo.jpg'),
/// )
///
/// // Using pixel-based blur values with ResponsiveBlurSides
/// VariableBlur(
///   sigma: 15.0,
///   blurSides: ResponsiveBlurSides(top: 100.0, bottom: 50.0), // pixels
///   edgeIntensity: 0.2,
///   quality: BlurQuality.high,
///   child: Image.asset('assets/photo.jpg'),
/// )
/// ```
///
/// ## Performance Considerations
/// - Use [BlurQuality.low] or [BlurQuality.medium] for better performance on lower-end devices
/// - Higher [sigma] values require more processing power and automatically use larger kernel sizes
/// - The [edgeIntensity] affects the smoothness of blur transitions
/// - Quality settings automatically adjust kernel size for optimal performance
/// - RepaintBoundary is enabled by default to isolate expensive blur operations
/// - Set [useRepaintBoundary] to false only if you need manual RepaintBoundary management
class VariableBlur extends StatelessWidget {
  /// Creates a [VariableBlur] widget.
  ///
  /// The [child], [sigma], and [blurSides] parameters are required.
  ///
  /// [sigma] controls the overall blur intensity and must be greater than 0.
  /// Values close to 0 result in minimal blur, while larger values create stronger effects.
  /// [blurSides] defines the blur intensity for different regions. Use [BlurSides] for normalized
  /// values (0.0-1.0) or [ResponsiveBlurSides] for pixel-based values that auto-scale to widget size.
  /// [quality] controls the rendering quality vs performance trade-off.
  /// [edgeIntensity] controls the smoothness of blur transitions (0.0 to 1.0).
  /// [isYFlipNeed] should be set to true on Android devices that flip the Y-axis.
  /// [useRepaintBoundary] isolates expensive blur operations for better performance.
  const VariableBlur(
      {super.key,
      required this.child,
      required this.sigma,
      required this.blurSides,
      this.quality = BlurQuality.high,
      this.edgeIntensity = 0.15,
      this.isYFlipNeed = false,
      this.useRepaintBoundary = true});

  /// The widget to apply the blur effect to.
  final Widget child;

  /// The blur intensity/radius in logical pixels.
  ///
  /// Must be greater than 0. Values close to 0 (like 0.1-1.0) create subtle blur effects,
  /// while larger values create more pronounced blur. When sigma is 0, no blur is applied
  /// and the original image is displayed.
  final double sigma;

  /// Defines the blur intensity for different regions of the widget.
  final BlurSidesBase blurSides;

  /// Controls the rendering quality vs performance trade-off.
  final BlurQuality quality;

  /// Controls the intensity of smooth edge transitions (0.0 to 1.0).
  final double edgeIntensity;

  /// Whether to flip the Y-axis coordinate system.
  final bool isYFlipNeed;

  /// Whether to wrap the blur widget with RepaintBoundary for performance optimization.
  final bool useRepaintBoundary;

  /// Precaches the blur shaders to improve first-render performance.
  ///
  /// Call this method early in your app lifecycle (e.g., during app initialization
  /// or in main()) to eliminate shader compilation delays on first use.
  ///
  /// Example:
  /// ```dart
  /// void main() {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///   VariableBlur.precacheShaders();
  ///   runApp(MyApp());
  /// }
  /// ```
  static Future<void> precacheShaders() async {
    await Future.wait([
      ShaderBuilder.precacheShader(
          'packages/variable_blur/shaders/tilt_shift_horizontal.frag'),
      ShaderBuilder.precacheShader(
          'packages/variable_blur/shaders/tilt_shift_vertical.frag'),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    Widget blurWidget = ShaderBuilder((context, horizontalShader, _) {
      return ShaderBuilder((context, verticalShader, _) {
        return AnimatedSampler((image, size, canvas) {
          ui.Picture? horizontalPicture;
          ui.Image? horizontalImage;

          try {
            // Calculate normalized blur sides based on size for ResponsiveBlurSides
            final normalizedBlurSides = _calculateNormalizedBlurSides(size);

            // Create intermediate render target for horizontal pass
            horizontalPicture = _createHorizontalPass(
                horizontalShader, image, size, normalizedBlurSides);
            horizontalImage = horizontalPicture.toImageSync(
                size.width.toInt(), size.height.toInt());

            // Vertical pass with final blending
            verticalShader
              ..setFloat(0, size.width)
              ..setFloat(1, size.height)
              ..setFloat(2, _getAdjustedSigma())
              ..setFloat(3, normalizedBlurSides.top)
              ..setFloat(4, normalizedBlurSides.bottom)
              ..setFloat(5, normalizedBlurSides.left)
              ..setFloat(6, normalizedBlurSides.right)
              ..setFloat(7, !isYFlipNeed ? 0.0 : 1.0)
              ..setFloat(8, edgeIntensity)
              ..setFloat(9, _getAdjustedKernelSize());

            verticalShader.setImageSampler(0, horizontalImage);
            verticalShader.setImageSampler(1, image); // Original for blending

            canvas.drawRect(
              Rect.fromLTWH(0, 0, size.width, size.height),
              Paint()..shader = verticalShader,
            );
          } catch (e) {
            // Fallback: render original image without blur on error
            canvas.drawImage(image, Offset.zero, Paint());
          } finally {
            // Always dispose of intermediate resources to prevent memory leaks
            horizontalImage?.dispose();
            horizontalPicture?.dispose();
          }
        }, child: child);
      }, assetKey: 'packages/variable_blur/shaders/tilt_shift_vertical.frag');
    }, assetKey: 'packages/variable_blur/shaders/tilt_shift_horizontal.frag');

    // Optionally wrap with RepaintBoundary for performance isolation
    return useRepaintBoundary ? RepaintBoundary(child: blurWidget) : blurWidget;
  }

  ui.Picture _createHorizontalPass(ui.FragmentShader shader, ui.Image image,
      Size size, BlurSidesBase normalizedBlurSides) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, _getAdjustedSigma())
      ..setFloat(3, normalizedBlurSides.top)
      ..setFloat(4, normalizedBlurSides.bottom)
      ..setFloat(5, normalizedBlurSides.left)
      ..setFloat(6, normalizedBlurSides.right)
      ..setFloat(7, !isYFlipNeed ? 0.0 : 1.0)
      ..setFloat(8, _getAdjustedKernelSize());

    shader.setImageSampler(0, image);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = shader,
    );

    final picture = recorder.endRecording();
    return picture;
  }

  double _getAdjustedSigma() {
    // For large sigma values, quality adjustment should be minimal
    // to preserve the blur effect
    switch (quality) {
      case BlurQuality.low:
        return sigma > 10
            ? sigma * 0.8
            : sigma * 0.5; // Less reduction for large sigma
      case BlurQuality.medium:
        return sigma > 10 ? sigma * 0.9 : sigma * 0.75;
      case BlurQuality.high:
        return sigma;
    }
  }

  double _getAdjustedKernelSize() {
    // Calculate kernel size based on sigma and quality setting
    // Base formula: kernel_radius = ceil(3.0 * sigma), kernel_size = 2 * radius + 1
    // double baseKernelSize = 2.0 * (3.0 * _getAdjustedSigma()).ceil() + 1.0;
    double baseKernelSize = (3.0 * _getAdjustedSigma());
    switch (quality) {
      case BlurQuality.low:
        // Reduce kernel size for performance, but ensure minimum quality
        return (baseKernelSize * 0.6).clamp(5.0, 50.0);
      case BlurQuality.medium:
        // Moderate kernel size for balanced performance
        return (baseKernelSize * 0.8).clamp(7.0, 75.0);
      case BlurQuality.high:
        // Full kernel size for best quality, but cap for safety
        return baseKernelSize.clamp(9.0, 100.0);
    }
  }

  /// Calculates normalized blur values based on widget size for ResponsiveBlurSides
  BlurSidesBase _calculateNormalizedBlurSides(Size size) {
    if (blurSides is ResponsiveBlurSides) {
      final responsive = blurSides as ResponsiveBlurSides;
      return BlurSidesBase(
        top: responsive.top / size.height,
        bottom: responsive.bottom / size.height,
        left: responsive.left / size.width,
        right: responsive.right / size.width,
      );
    }
    return blurSides;
  }
}

/// Defines the rendering quality levels for blur effects.
///
/// Different quality levels provide a trade-off between visual quality
/// and performance. Choose the appropriate level based on your target
/// devices and performance requirements.
///
/// ## Quality Levels
/// - [low]: Fastest rendering, suitable for real-time animations or lower-end devices
/// - [medium]: Balanced quality and performance for most use cases
/// - [high]: Best visual quality, recommended for static images or high-end devices
enum BlurQuality {
  /// Fastest rendering with reduced quality.
  ///
  /// Recommended for:
  /// - Real-time blur animations
  /// - Lower-end devices
  /// - Cases where performance is critical
  low,

  /// Balanced quality and performance.
  ///
  /// Recommended for:
  /// - Most general use cases
  /// - Mid-range devices
  /// - Interactive blur effects
  medium,

  /// Highest quality rendering.
  ///
  /// Recommended for:
  /// - Static images with blur effects
  /// - High-end devices
  /// - Cases where visual quality is paramount
  high
}
