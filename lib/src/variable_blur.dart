import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:variable_blur/src/legacy_variable_blur.dart';
import 'package:variable_blur/src/models/blur_side.dart';
import 'package:variable_blur/src/models/blur_side_base.dart';

/// A widget that blurs the edges of its child, with the blur strength rising
/// smoothly from sharp to [sigma] inside each blur region.
///
/// The blur runs inside Flutter's rendering engine as an image filter, so the
/// child is never copied into a Dart-side image. Each pixel gets its own blur
/// strength, which gives a true variable (progressive) blur rather than a
/// sharp image faded into a blurred one.
///
/// Requires Impeller (the default on iOS and on modern Android). When an app
/// turns Impeller off, the widget falls back to the older snapshot-based
/// shader blur.
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
    this.isYFlipNeed = false,
    this.useRepaintBoundary = true,
  });

  /// The widget to blur.
  final Widget child;

  /// The strongest blur, in logical pixels. 0 or less shows the child as is.
  final double sigma;

  /// How far each blur region reaches into the child.
  final BlurSidesBase blurSides;

  /// Trades smoothness for speed by changing how many samples each pixel
  /// reads.
  final BlurQuality quality;

  /// How gradually the blur rises (0.0 to 1.0), as a fraction of the child's
  /// larger side.
  final double edgeIntensity;

  /// Flips the Y axis. Only used by the fallback blur when Impeller is off;
  /// the engine path detects this by itself.
  final bool isYFlipNeed;

  /// Whether to wrap the blur in a [RepaintBoundary].
  final bool useRepaintBoundary;

  static const String _assetKey =
      'packages/variable_blur/shaders/variable_blur.frag';
  static ui.FragmentProgram? _program;
  static Future<ui.FragmentProgram>? _loading;

  static Future<ui.FragmentProgram> _load() =>
      _loading ??= ui.FragmentProgram.fromAsset(
        _assetKey,
      ).then((program) => _program = program);

  /// Loads the blur shader ahead of time so the first blurred frame is not
  /// delayed. Call it early, for example in `main()` after
  /// `WidgetsFlutterBinding.ensureInitialized()`.
  static Future<void> precacheShaders() async {
    if (ui.ImageFilter.isShaderFilterSupported) {
      await _load();
    } else {
      await LegacyVariableBlur.precacheShaders();
    }
  }

  @override
  State<VariableBlur> createState() => _VariableBlurState();
}

class _VariableBlurState extends State<VariableBlur> {
  ui.FragmentShader? _horizontal;
  ui.FragmentShader? _vertical;

  @override
  void initState() {
    super.initState();
    if (ui.ImageFilter.isShaderFilterSupported &&
        VariableBlur._program == null) {
      VariableBlur._load().then((_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _horizontal?.dispose();
    _vertical?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final sides = w.blurSides;
    final hasRegion =
        sides.top > 0 || sides.bottom > 0 || sides.left > 0 || sides.right > 0;
    if (w.sigma <= 0 || !hasRegion) return _wrap(w.child);

    if (!ui.ImageFilter.isShaderFilterSupported) {
      return LegacyVariableBlur(
        sigma: w.sigma,
        blurSides: w.blurSides,
        quality: w.quality,
        edgeIntensity: w.edgeIntensity,
        isYFlipNeed: w.isYFlipNeed,
        useRepaintBoundary: w.useRepaintBoundary,
        child: w.child,
      );
    }

    final program = VariableBlur._program;
    if (program == null) return _wrap(w.child);

    final taps = switch (w.quality) {
      BlurQuality.low => 16.0,
      BlurQuality.medium => 24.0,
      BlurQuality.high => 32.0,
    };
    return _wrap(
      _EngineBlur(
        horizontal: _horizontal ??= program.fragmentShader(),
        vertical: _vertical ??= program.fragmentShader(),
        sigma: w.sigma,
        sides: sides,
        edgeIntensity: w.edgeIntensity,
        taps: taps,
        // Keeps the child's picture cached while the blur repaints on scroll.
        child: RepaintBoundary(child: w.child),
      ),
    );
  }

  Widget _wrap(Widget child) =>
      widget.useRepaintBoundary ? RepaintBoundary(child: child) : child;
}

class _EngineBlur extends SingleChildRenderObjectWidget {
  const _EngineBlur({
    required this.horizontal,
    required this.vertical,
    required this.sigma,
    required this.sides,
    required this.edgeIntensity,
    required this.taps,
    super.child,
  });

  final ui.FragmentShader horizontal;
  final ui.FragmentShader vertical;
  final double sigma;
  final BlurSidesBase sides;
  final double edgeIntensity;
  final double taps;

  @override
  _RenderEngineBlur createRenderObject(BuildContext context) =>
      _RenderEngineBlur(horizontal, vertical)..update(this);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderEngineBlur renderObject,
  ) => renderObject.update(this);
}

/// Paints the child through the variable blur image filter.
///
/// The engine only gives the filter the on-screen part of the child, with
/// coordinates starting at that part's corner. So on every paint this works
/// out where the visible part sits inside the whole child, and it repaints
/// whenever the child moves on screen (for example while scrolling).
class _RenderEngineBlur extends RenderProxyBox {
  _RenderEngineBlur(this._horizontal, this._vertical);

  final ui.FragmentShader _horizontal;
  final ui.FragmentShader _vertical;
  double _sigma = 0;
  BlurSidesBase _sides = const BlurSidesBase();
  double _edgeIntensity = 0;
  double _taps = 24;

  final LayerHandle<ImageFilterLayer> _layer = LayerHandle<ImageFilterLayer>();
  Rect? _lastSeen;
  bool _watching = false;

  void update(_EngineBlur w) {
    _sigma = w.sigma;
    _sides = w.sides;
    _edgeIntensity = w.edgeIntensity;
    _taps = w.taps;
    markNeedsPaint();
  }

  @override
  bool get alwaysNeedsCompositing => child != null;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _watching = true;
    _watch();
  }

  @override
  void detach() {
    _watching = false;
    super.detach();
  }

  @override
  void dispose() {
    _layer.layer = null;
    super.dispose();
  }

  // Once per frame, after painting, check whether the child moved on screen.
  // Moving does not repaint this object by itself when an ancestor scrolls.
  void _watch() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!_watching || !attached) return;
      // Compare with the previous check, not the last paint: while the child
      // keeps moving this repaints every frame, plus one frame after it stops.
      if (hasSize) {
        final seen = _visibleRect();
        if (seen != _lastSeen) markNeedsPaint();
        _lastSeen = seen;
      }
      _watch();
    });
  }

  double get _dpr =>
      ui.PlatformDispatcher.instance.implicitView?.devicePixelRatio ?? 1.0;

  /// The on-screen part of this object, in this object's own coordinates.
  Rect _visibleRect() {
    final toScreen = getTransformTo(null);
    var clip = Offset.zero & _screenSize();
    RenderObject node = this;
    while (node.parent != null) {
      final parent = node.parent!;
      final c = parent.describeApproximatePaintClip(node);
      if (c != null) {
        clip = clip.intersect(
          MatrixUtils.transformRect(parent.getTransformTo(null), c),
        );
      }
      node = parent;
    }
    final bounds = MatrixUtils.transformRect(toScreen, Offset.zero & size);
    final visible = bounds.intersect(clip);
    if (visible.isEmpty) return Rect.zero;
    return visible.shift(-bounds.topLeft);
  }

  Size _screenSize() {
    final view = ui.PlatformDispatcher.instance.implicitView;
    if (view == null) return Size.infinite;
    return view.physicalSize / view.devicePixelRatio;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;
    final visible = _visibleRect();
    // Physical pixels per local unit, including any Transform.scale above.
    // Rotation is not supported: the blur zones stay screen-aligned.
    final m = getTransformTo(null).storage;
    final px = _dpr * Offset(m[0], m[1]).distance;
    final dpr = _dpr;
    final sides = _sides;
    final inPixels = sides is ResponsiveBlurSides;
    final w = size.width * px, h = size.height * px;
    final sx = inPixels ? px : w, sy = inPixels ? px : h;
    // The engine rounds the visible area out to whole pixels.
    final ox = (visible.left * dpr).floorToDouble();
    final oy = (visible.top * dpr).floorToDouble();

    void configure(ui.FragmentShader shader, double dx, double dy) {
      // Index 0 and 1 (uSize) are filled in by the engine.
      shader
        ..setFloat(2, _sigma * px)
        ..setFloat(3, sides.top * sy)
        ..setFloat(4, sides.bottom * sy)
        ..setFloat(5, sides.left * sx)
        ..setFloat(6, sides.right * sx)
        ..setFloat(7, (w > h ? w : h) * _edgeIntensity)
        ..setFloat(8, dx)
        ..setFloat(9, dy)
        ..setFloat(10, _taps)
        ..setFloat(11, ox)
        ..setFloat(12, oy)
        ..setFloat(13, w)
        ..setFloat(14, h);
    }

    configure(_horizontal, 1, 0);
    configure(_vertical, 0, 1);
    final filter = ui.ImageFilter.compose(
      outer: ui.ImageFilter.shader(_vertical),
      inner: ui.ImageFilter.shader(_horizontal),
    );
    // A fresh layer each paint: setting a new filter on an old layer compares
    // the two filters, which crashes on some Flutter versions (3.32) for
    // shader filters.
    _layer.layer = ImageFilterLayer(imageFilter: filter);
    context.pushLayer(_layer.layer!, super.paint, offset);
  }
}

/// Rendering quality levels for the blur.
///
/// Higher quality reads more samples per pixel: smoother on strong blurs,
/// slower on large areas.
enum BlurQuality {
  /// 16 samples per side: fastest, for animations or low-end devices.
  low,

  /// 24 samples per side: balanced.
  medium,

  /// 32 samples per side: smoothest.
  high,
}
