/// A Flutter package for creating variable blur effects with customizable blur regions.
///
/// This package provides widgets and utilities to apply blur effects selectively to different
/// parts of a widget, including tilt-shift photography effects, gradual blur transitions,
/// and variable blur intensities across different regions.
///
/// **Supported Platforms:** iOS and Android only
///
/// ## Features
/// - Variable blur intensity for different regions (top, bottom, left, right)
/// - Tilt-shift photography effects
/// - Smooth edge transitions
/// - High-performance GPU-accelerated rendering using Fragment Shaders
/// - Support for quality adjustments
/// - iOS and Android platform optimizations
///
/// ## Important Note
/// **Blur effects only work on images or colored containers.** The blur will not be visible
/// on transparent or empty widgets. For comprehensive examples and implementation details,
/// please refer to the example app included with this package.
///
/// ## Example Usage
///
/// ```dart
/// VariableBlur(
///   sigma: 10.0,
///   blurSides: BlurSides.vertical(top: 1.0, bottom: 0.5),
///   edgeIntensity: 0.2,
///   quality: BlurQuality.high,
///   child: Image.asset('path/to/image.jpg'),
/// )
/// ```
library;

export 'src/variable_blur.dart';
export 'src/models/blur_side.dart';
export 'src/models/blur_side_base.dart';
