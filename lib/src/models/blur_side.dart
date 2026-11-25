import 'package:variable_blur/src/models/blur_side_base.dart';

/// Defines blur intensities for each side of a widget as a ratio of the child's size.
///
/// The [BlurSides] class is used when you want to specify the blur region as a fraction
/// of the child's width or height. For example, a value of 0.1 means 10% of the child's
/// corresponding dimension. All values must be between 0.0 and 1.0.
///
/// Example:
///   BlurSides.vertical(top: 0.1, bottom: 0.2) // 10% from top, 20% from bottom
///   BlurSides.horizontal(left: 0.3, right: 0.0) // 30% from left, 0% from right
class BlurSides extends BlurSidesBase {
  /// Creates a horizontal blur effect with left and right as ratios (0.0 to 1.0) of the child's width.
  const BlurSides.horizontal({super.left, super.right})
    : assert(
        left >= 0.0 && left <= 1.0,
        'Left blur value must be between 0.0 and 1.0, got $left',
      ),
      assert(
        right >= 0.0 && right <= 1.0,
        'Right blur value must be between 0.0 and 1.0, got $right',
      );

  /// Creates a vertical blur effect with top and bottom as ratios (0.0 to 1.0) of the child's height.
  const BlurSides.vertical({super.top, super.bottom})
    : assert(
        top >= 0.0 && top <= 1.0,
        'Top blur value must be between 0.0 and 1.0, got $top',
      ),
      assert(
        bottom >= 0.0 && bottom <= 1.0,
        'Bottom blur value must be between 0.0 and 1.0, got $bottom',
      );
}

/// Defines blur intensities for each side of a widget in absolute pixels.
///
/// The [ResponsiveBlurSides] class is used when you want to specify the blur region
/// in pixels, regardless of the child's size. This is useful for fixed blur distances.
///
/// Example:
///   ResponsiveBlurSides.vertical(top: 20.0, bottom: 40.0) // 20px from top, 40px from bottom
///   ResponsiveBlurSides.horizontal(left: 10.0, right: 0.0) // 10px from left, 0px from right
class ResponsiveBlurSides extends BlurSidesBase {
  /// Internal constructor for pixel-based blur sides.
  const ResponsiveBlurSides._({
    super.top,
    super.bottom,
    super.left,
    super.right,
  }) : assert(
         top >= 0.0,
         'Top blur pixel value must be non-negative, got $top',
       ),
       assert(
         bottom >= 0.0,
         'Bottom blur pixel value must be non-negative, got $bottom',
       ),
       assert(
         left >= 0.0,
         'Left blur pixel value must be non-negative, got $left',
       ),
       assert(
         right >= 0.0,
         'Right blur pixel value must be non-negative, got $right',
       );

  /// Creates a vertical blur effect with top and bottom in pixels.
  const ResponsiveBlurSides.vertical({double top = 0.0, double bottom = 0.0})
    : this._(top: top, bottom: bottom);

  /// Creates a horizontal blur effect with left and right in pixels.
  const ResponsiveBlurSides.horizontal({double left = 0.0, double right = 0.0})
    : this._(left: left, right: right);
}
