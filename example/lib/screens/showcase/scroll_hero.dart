import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:variable_blur/variable_blur.dart';

import 'demo_scroll.dart';

/// A magazine story: the cover photo stays put while the article slides up
/// over it, and the photo blurs more, and higher, the further you read.
///
/// The blur is driven by the scroll position: `sigma` and the blurred
/// region both grow with the scroll offset.
class ScrollHeroShowcase extends StatefulWidget {
  const ScrollHeroShowcase({super.key});

  @override
  State<ScrollHeroShowcase> createState() => _ScrollHeroShowcaseState();
}

class _ScrollHeroShowcaseState extends State<ScrollHeroShowcase> {
  static const _cover =
      'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=1400';

  final _controller = ScrollController();

  /// 0 at the top, 1 once the article covers most of the photo.
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
    startDemoScroll(this, _controller);
  }

  void _onScroll() {
    final height = MediaQuery.sizeOf(context).height;
    final p = (_controller.offset / (height * 0.55)).clamp(0.0, 1.0);
    if (p != _progress) setState(() => _progress = p);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final p = Curves.easeOut.transform(_progress);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // The cover: always blurred a little at the bottom, and more,
            // and higher up, as the reader scrolls.
            Positioned.fill(
              child: VariableBlur(
                sigma: 6 + 26 * p,
                edgeIntensity: 0.3,
                blurSides: BlurSides.vertical(
                  top: 0.12 * p,
                  bottom: 0.35 + 0.65 * p,
                ),
                child: Transform.scale(
                  scale: 1 + 0.08 * p,
                  child: Image.network(_cover, fit: BoxFit.cover),
                ),
              ),
            ),
            // Darken slightly as the photo turns into a backdrop.
            Positioned.fill(
              child: IgnorePointer(
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.35 * p),
                ),
              ),
            ),
            CustomScrollView(
              controller: _controller,
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: size.height * 0.62,
                    child: Opacity(
                      opacity: 1 - p,
                      child: _CoverTitle(bottomPadding: 28),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: _Article()),
                SliverToBoxAdapter(
                  child: SizedBox(height: padding.bottom + 40),
                ),
              ],
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _TopBar(
                progress: p,
                topInset: padding.top,
                onBack: () => Navigator.maybePop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoverTitle extends StatelessWidget {
  const _CoverTitle({required this.bottomPadding});
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, bottomPadding),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TRAVEL · 8 MIN READ',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Above the\nClouds',
            style: TextStyle(
              color: Colors.white,
              fontSize: 52,
              fontWeight: FontWeight.w800,
              height: 1.0,
              letterSpacing: -1,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Five days walking the ridges of the Alps, where the sea of clouds rolls in every morning.',
            style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.35),
          ),
          SizedBox(height: 18),
          Row(
            children: [
              Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white54),
              SizedBox(width: 4),
              Text(
                'Scroll to read',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Article extends StatelessWidget {
  const _Article();

  static const _body = TextStyle(
    color: Color(0xFFE6E6E6),
    fontSize: 17,
    height: 1.6,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF111113).withValues(alpha: 0.82),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: const Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 22),
          const Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=120&h=120&fit=crop',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Elena Moretti',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '14 November · Photography by the author',
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Icon(Icons.bookmark_border_rounded, color: Colors.white70),
            ],
          ),
          const SizedBox(height: 26),
          const Text(
            'The alarm goes off at five. Outside the hut it is still dark, '
            'and the valley below has vanished under a slow white ocean. '
            'Nobody speaks; we just pull on our boots and walk toward the '
            'edge to watch the first light hit the peaks.',
            style: _body,
          ),
          const SizedBox(height: 18),
          const Text(
            'By the third day the rhythm settles in. Climb before the heat, '
            'rest at noon, and reach the next ridge in time for the clouds '
            'to rise again in the evening, turning the whole horizon pink.',
            style: _body,
          ),
          const SizedBox(height: 26),
          Container(
            padding: const EdgeInsets.only(left: 16),
            decoration: const BoxDecoration(
              border: Border(left: BorderSide(color: Colors.white, width: 3)),
            ),
            child: const Text(
              '“Up here the clouds are the ground, and the ground is a rumour.”',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 26),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Image.network(
                'https://images.unsplash.com/photo-1444927714506-8492d94b4e3d?w=1000',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Morning fog over the Matterhorn ridge.',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 26),
          const Text(
            'On the last morning nobody wants to leave. We sit on our packs, '
            'coffee going cold, and watch the sea of clouds break apart '
            'until the green valley appears beneath it, exactly where we '
            'left it five days ago.',
            style: _body,
          ),
          const SizedBox(height: 18),
          const Text(
            'The way down takes four hours. The way back, we already know, '
            'will take much longer.',
            style: _body,
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.progress,
    required this.topInset,
    required this.onBack,
  });

  final double progress;
  final double topInset;
  final VoidCallback onBack;

  Widget _button(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, topInset + 6, 16, 0),
      child: Row(
        children: [
          _button(Icons.arrow_back_ios_new_rounded, onBack),
          Expanded(
            child: Opacity(
              opacity: progress,
              child: const Text(
                'Above the Clouds',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          _button(Icons.ios_share_rounded, () {}),
        ],
      ),
    );
  }
}
