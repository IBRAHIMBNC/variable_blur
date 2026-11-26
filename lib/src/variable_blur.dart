import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:variable_blur/src/models/blur_side.dart';
import 'package:variable_blur/src/models/blur_side_base.dart';

/// A widget that blurs the edges of its child, with the blur strength rising
/// smoothly from sharp to [sigma] inside each blur region.
///
/// Works like Flutter's own blur: it blurs a small, downscaled copy of the
/// child and stretches it back over the sharp child. Each pixel gets its own
/// blur strength, so this is a true variable (progressive) blur, and the
/// sharp part keeps every original pixel.
///
/// The blur is only worked out again when the child's content changes.
/// Moving the widget, for example while scrolling, reuses the last result.
///
/// ## Example
///
/// ```dart
/// VariableBlur(
///   sigma: 15.0,
///   blurSides: BlurSides.vertical(top: 0.3, bottom: 0.2),
///   edgeIntensity: 0.2,
///   child: Image.asset('assets/photo.jpg'),
/// )
///
/// // Blur regions in logical pixels instead of fractions:
/// VariableBlur(
///   sigma: 15.0,
///   blurSides: ResponsiveBlurSides.vertical(top: 100.0, bottom: 50.0),
///   child: Image.asset('assets/photo.jpg'),
/// )
/// ```
///
/// Blur effects need visible pixels: transparent or empty children show no
/// blur.
class VariableBlur extends StatefulWidget {
  /// Creates a [VariableBlur] widget.
  ///
  /// [sigma] is the strongest blur, in logical pixels, reached inside the
  /// blur regions. [blurSides] sets how far each region reaches: fractions of
  /// the child's size with [BlurSides], or logical pixels with
  /// [ResponsiveBlurSides]. [edgeIntensity] sets how gradually the blur rises,
  /// as a fraction of the child's larger side.
  const VariableBlur({
    super.key,
    required this.child,
    required this.sigma,
    required this.blurSides,
    this.quality = BlurQuality.high,
    this.edgeIntensity = 0.15,
    @Deprecated(
      'The blur is the right way up on every backend now. '
      'This will be removed in a future release.',
    )
    this.isYFlipNeed = false,
    this.useRepaintBoundary = true,
  });

  /// The widget to blur.
  final Widget child;

  /// The strongest blur, in logical pixels. 0 or less shows the child as is.
  final double sigma;

  /// How far each blur region reaches into the child.
  final BlurSidesBase blurSides;

  /// Trades smoothness for speed and memory: lower quality blurs a smaller
  /// copy with fewer samples.
  final BlurQuality quality;

  /// How gradually the blur rises (0.0 to 1.0), as a fraction of the child's
  /// larger side.
  final double edgeIntensity;

  /// Flips the Y axis when reading the blurred copy.
  ///
  /// Not needed any more: the blur is the right way up on every backend,
  /// including Impeller on OpenGL ES. Kept only so existing code still
  /// compiles; it will be removed in a future release.
  @Deprecated(
    'The blur is the right way up on every backend now. '
    'This will be removed in a future release.',
  )
  final bool isYFlipNeed;

  /// Whether to wrap the blur in a [RepaintBoundary].
  final bool useRepaintBoundary;

  static const String _passKey =
      'packages/variable_blur/shaders/variable_blur_pass.frag';
  static const String _compositeKey =
      'packages/variable_blur/shaders/variable_blur_composite.frag';
  static ui.FragmentProgram? _pass;
  static ui.FragmentProgram? _composite;
  static Future<void>? _loading;

  static Future<void> _load() => _loading ??= Future.wait([
    ui.FragmentProgram.fromAsset(_passKey).then((p) => _pass = p),
    ui.FragmentProgram.fromAsset(_compositeKey).then((p) => _composite = p),
  ]);

  /// Loads the blur shaders ahead of time so the first blurred frame is not
  /// delayed. Call it early, for example in `main()` after
  /// `WidgetsFlutterBinding.ensureInitialized()`.
  static Future<void> precacheShaders() => _load();

  @override
  State<VariableBlur> createState() => _VariableBlurState();
}

class _VariableBlurState extends State<VariableBlur> {
  _Shaders? _shaders;

  bool _waiting = false;

  @override
  void dispose() {
    _shaders?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final sides = w.blurSides;
    final hasRegion =
        sides.top > 0 || sides.bottom > 0 || sides.left > 0 || sides.right > 0;
    final pass = VariableBlur._pass;
    final composite = VariableBlur._composite;
    if (w.sigma <= 0 || !hasRegion) return _wrap(w.child);
    if (pass == null || composite == null) {
      // Show the child unblurred until the shaders have loaded.
      if (!_waiting) {
        _waiting = true;
        VariableBlur._load().then((_) {
          if (mounted) setState(() {});
        });
      }
      return _wrap(w.child);
    }
    final shaders = _shaders ??= _Shaders(
      pass.fragmentShader(),
      pass.fragmentShader(),
      composite.fragmentShader(),
    );
    return _wrap(
      _SnapshotBlur(
        shaders: shaders,
        sigma: w.sigma,
        sides: sides,
        edgeIntensity: w.edgeIntensity,
        quality: w.quality,
        // ignore: deprecated_member_use_from_same_package
        flip: w.isYFlipNeed,
        devicePixelRatio:
            MediaQuery.maybeDevicePixelRatioOf(context) ??
            View.maybeOf(context)?.devicePixelRatio ??
            1.0,
        child: w.child,
      ),
    );
  }

  Widget _wrap(Widget child) =>
      widget.useRepaintBoundary ? RepaintBoundary(child: child) : child;
}

class _Shaders {
  _Shaders(this.horizontal, this.vertical, this.composite);

  final ui.FragmentShader horizontal;
  final ui.FragmentShader vertical;
  final ui.FragmentShader composite;

  void dispose() {
    horizontal.dispose();
    vertical.dispose();
    composite.dispose();
  }
}

class _SnapshotBlur extends SingleChildRenderObjectWidget {
  const _SnapshotBlur({
    required this.shaders,
    required this.sigma,
    required this.sides,
    required this.edgeIntensity,
    required this.quality,
    required this.flip,
    required this.devicePixelRatio,
    super.child,
  });

  final _Shaders shaders;
  final double sigma;
  final BlurSidesBase sides;
  final double edgeIntensity;
  final BlurQuality quality;
  final bool flip;
  final double devicePixelRatio;

  @override
  _RenderSnapshotBlur createRenderObject(BuildContext context) =>
      _RenderSnapshotBlur()..update(this);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderSnapshotBlur renderObject,
  ) => renderObject.update(this);
}

/// Paints the child as it is, plus a blurred overlay made from a small copy
/// of the child.
///
/// It is its own repaint boundary, so moving it (for example while an
/// ancestor scrolls) reuses the finished overlay. The overlay is rebuilt only
/// when the child's content or the blur settings change.
class _RenderSnapshotBlur extends RenderProxyBox {
  _Config? _config;
  final LayerHandle<_BlurLayer> _blurLayer = LayerHandle<_BlurLayer>();

  void update(_SnapshotBlur w) {
    final next = _Config(
      shaders: w.shaders,
      sigma: w.sigma,
      sides: w.sides,
      edgeIntensity: w.edgeIntensity,
      quality: w.quality,
      flip: w.flip,
      devicePixelRatio: w.devicePixelRatio,
    );
    if (next == _config) return;
    _config = next;
    markNeedsPaint();
  }

  @override
  bool get isRepaintBoundary => true;

  @override
  void dispose() {
    _blurLayer.layer = null;
    super.dispose();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final config = _config;
    if (child == null || config == null || size.isEmpty) {
      super.paint(context, offset);
      return;
    }
    final layer = _blurLayer.layer ??= _BlurLayer();
    layer
      ..config = config
      ..size = size;
    context.pushLayer(layer, super.paint, offset);
  }
}

@immutable
class _Config {
  const _Config({
    required this.shaders,
    required this.sigma,
    required this.sides,
    required this.edgeIntensity,
    required this.quality,
    required this.flip,
    required this.devicePixelRatio,
  });

  final _Shaders shaders;
  final double sigma;
  final BlurSidesBase sides;
  final double edgeIntensity;
  final BlurQuality quality;
  final bool flip;
  final double devicePixelRatio;

  @override
  bool operator ==(Object other) =>
      other is _Config &&
      identical(other.shaders, shaders) &&
      other.sigma == sigma &&
      other.sides.runtimeType == sides.runtimeType &&
      other.sides.top == sides.top &&
      other.sides.bottom == sides.bottom &&
      other.sides.left == sides.left &&
      other.sides.right == sides.right &&
      other.edgeIntensity == edgeIntensity &&
      other.quality == quality &&
      other.flip == flip &&
      other.devicePixelRatio == devicePixelRatio;

  @override
  int get hashCode => Object.hash(
    shaders,
    sigma,
    sides.runtimeType,
    sides.top,
    sides.bottom,
    sides.left,
    sides.right,
    edgeIntensity,
    quality,
    flip,
    devicePixelRatio,
  );
}

/// Adds the sharp child to the scene, then a picture that lays the blurred
/// small copy over it.
class _BlurLayer extends OffsetLayer {
  late _Config config;
  Size size = Size.zero;
  ui.Picture? _overlay;

  @override
  void addToScene(ui.SceneBuilder builder) {
    engineLayer = builder.pushOffset(
      offset.dx,
      offset.dy,
      oldLayer: engineLayer as ui.OffsetEngineLayer?,
    );
    addChildrenToScene(builder);
    _overlay?.dispose();
    _overlay = _buildOverlay();
    if (_overlay != null) builder.addPicture(Offset.zero, _overlay!);
    builder.pop();
  }

  @override
  void dispose() {
    _overlay?.dispose();
    _overlay = null;
    super.dispose();
  }

  ui.Picture? _buildOverlay() {
    final c = config;
    final shrink = _shrinkFactor(c.sigma * c.devicePixelRatio, c.quality);
    final ratio = c.devicePixelRatio / shrink;

    // Blur regions, in logical pixels.
    final sides = c.sides;
    final inPixels = sides is ResponsiveBlurSides;
    final top = inPixels ? sides.top : sides.top * size.height;
    final bottom = inPixels ? sides.bottom : sides.bottom * size.height;
    final left = inPixels ? sides.left : sides.left * size.width;
    final right = inPixels ? sides.right : sides.right * size.width;
    final transition = size.longestSide * c.edgeIntensity;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    for (final crop in _crops(top, bottom, left, right, c.sigma)) {
      _blurCrop(canvas, crop, ratio, top, bottom, left, right, transition);
    }
    return recorder.endRecording();
  }

  /// The parts of the child that need blurring, in logical pixels.
  ///
  /// Only the blur regions, plus how far their blur reaches inward, are
  /// copied and blurred, not the whole child. This saves memory and work
  /// when the regions cover only part of the child, such as a top fade.
  /// Opposite regions that do not touch (top and bottom, or left and right)
  /// get one copy each; any other mix gets one copy covering them all.
  List<Rect> _crops(
    double top,
    double bottom,
    double left,
    double right,
    double sigma,
  ) {
    final full = Offset.zero & size;
    // A pixel's blur reaches at most 2.5 sigma, the reach of the blur pass.
    final reach = 2.5 * sigma;
    Rect band(double l, double t, double r, double b) =>
        Rect.fromLTRB(l, t, r, b).intersect(full);
    final rects = <Rect>[
      if (top > 0) band(0, 0, size.width, top + reach),
      if (bottom > 0)
        band(0, size.height - bottom - reach, size.width, size.height),
      if (left > 0) band(0, 0, left + reach, size.height),
      if (right > 0)
        band(size.width - right - reach, 0, size.width, size.height),
    ];
    final vertical = left <= 0 && right <= 0;
    final horizontal = top <= 0 && bottom <= 0;
    if (rects.length == 2 &&
        (vertical || horizontal) &&
        !rects[0].overlaps(rects[1])) {
      return rects;
    }
    return [rects.reduce((a, b) => a.expandToInclude(b))];
  }

  /// Blurs one part of the child and paints it, as an overlay, onto [canvas].
  void _blurCrop(
    Canvas canvas,
    Rect crop,
    double ratio,
    double top,
    double bottom,
    double left,
    double right,
    double transition,
  ) {
    final c = config;
    final w = math.max(1, (crop.width * ratio).ceil());
    final h = math.max(1, (crop.height * ratio).ceil());

    // 1. The cropped child, rendered straight into a small image.
    // Scale each axis so the crop fills the whole image exactly; a half
    // filled last row or column would let the sharp child show through near
    // the edges once blurred.
    final sx = w / crop.width, sy = h / crop.height;
    final builder = ui.SceneBuilder()
      ..pushTransform(
        (Matrix4.diagonal3Values(
          sx,
          sy,
          1,
        )..translateByDouble(-crop.left, -crop.top, 0, 1)).storage,
      );
    addChildrenToScene(builder);
    builder.pop();
    final scene = builder.build();
    final small = scene.toImageSync(w, h);
    scene.dispose();

    // The regions, measured from the crop's own edges.
    final cropTop = math.max(0.0, top - crop.top);
    final cropBottom = math.max(0.0, bottom - (size.height - crop.bottom));
    final cropLeft = math.max(0.0, left - crop.left);
    final cropRight = math.max(0.0, right - (size.width - crop.right));
    final taps = switch (c.quality) {
      BlurQuality.low => 16.0,
      BlurQuality.medium => 24.0,
      BlurQuality.high => 32.0,
    };
    final flip = c.flip ? 1.0 : 0.0;

    // 2. Horizontal, then vertical blur, both on the small image.
    ui.Image blurPass(ui.FragmentShader s, ui.Image src, double dx, double dy) {
      s
        ..setFloat(0, w.toDouble())
        ..setFloat(1, h.toDouble())
        ..setFloat(2, c.sigma * ratio)
        ..setFloat(3, cropTop * sy)
        ..setFloat(4, cropBottom * sy)
        ..setFloat(5, cropLeft * sx)
        ..setFloat(6, cropRight * sx)
        ..setFloat(7, transition * ratio)
        ..setFloat(8, dx)
        ..setFloat(9, dy)
        ..setFloat(10, taps)
        ..setFloat(11, flip)
        ..setImageSampler(0, src);
      final recorder = ui.PictureRecorder();
      Canvas(recorder).drawRect(
        Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()),
        Paint()..shader = s,
      );
      final picture = recorder.endRecording();
      final image = picture.toImageSync(w, h);
      picture.dispose();
      return image;
    }

    final across = blurPass(c.shaders.horizontal, small, 1, 0);
    final blurred = blurPass(c.shaders.vertical, across, 0, 1);
    across.dispose();

    // 3. The overlay: the blurred copy stretched back over the crop, faded
    // out where the blur is weak.
    c.shaders.composite
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, top)
      ..setFloat(3, bottom)
      ..setFloat(4, left)
      ..setFloat(5, right)
      ..setFloat(6, transition)
      ..setFloat(7, c.sigma * ratio)
      ..setFloat(8, flip)
      ..setFloat(9, w.toDouble())
      ..setFloat(10, h.toDouble())
      ..setFloat(11, crop.left)
      ..setFloat(12, crop.top)
      ..setFloat(13, crop.width)
      ..setFloat(14, crop.height)
      ..setImageSampler(0, blurred)
      ..setImageSampler(1, small);
    canvas.drawRect(crop, Paint()..shader = c.shaders.composite);
    blurred.dispose();
    small.dispose();
  }

  /// How much smaller the blurred copy is than the screen, like Flutter's own
  /// blur: the stronger the blur, the less detail survives, so the smaller
  /// the copy can be. The blur on the small copy stays at 2.5 pixels or more.
  static double _shrinkFactor(double physicalSigma, BlurQuality quality) {
    final cap = switch (quality) {
      BlurQuality.low => 8.0,
      BlurQuality.medium => 8.0,
      BlurQuality.high => 4.0,
    };
    var shrink = 1.0;
    while (shrink < cap && physicalSigma / (shrink * 2) >= 2.5) {
      shrink *= 2;
    }
    return shrink;
  }
}

/// Rendering quality levels for the blur.
///
/// Higher quality blurs a larger copy with more samples per pixel: smoother
/// on strong blurs, slower and more memory on large areas.
enum BlurQuality {
  /// Smallest copy (down to 1/8 size) and 16 samples per side: fastest.
  low,

  /// Small copy (down to 1/8 size) and 24 samples per side: balanced.
  medium,

  /// Copy down to 1/4 size and 32 samples per side: smoothest.
  high,
}
