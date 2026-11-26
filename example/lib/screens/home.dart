import 'package:example/screens/gradual_top_blur.dart';
import 'package:example/screens/performance_comparison.dart';
import 'package:example/screens/showcase/frosted_feed.dart';
import 'package:example/screens/showcase/lock_screen.dart';
import 'package:example/screens/showcase/map_explorer.dart';
import 'package:example/screens/showcase/miniature.dart';
import 'package:example/screens/showcase/music_player.dart';
import 'package:example/screens/showcase/story_cards.dart';
import 'package:example/screens/showcase/travel_cards.dart';
import 'package:example/screens/showcase/video_story.dart';
import 'package:example/screens/tilt_shift_photography.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:variable_blur/variable_blur.dart';

/// The example app's home: every card is a photo that melts into blur behind
/// its title, and the page itself blurs under the status bar.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _showcases = [
    _Entry(
      'Video Story',
      'Blur that follows a playing video',
      '1490750967868-88aa4486c946',
      VideoStoryShowcase(),
    ),
    _Entry(
      'Story Cards',
      'Photos melting into their own colour',
      '1493225457124-a3eb161ffa5f',
      StoryCardsShowcase(),
    ),
    _Entry(
      'Music Player',
      'Album art flowing into the controls',
      '1470225620780-dba8ba36b745',
      MusicPlayerShowcase(),
    ),
    _Entry(
      'Frosted Bars',
      'A feed fading under header and tabs',
      '1514565131-fce0801e5785',
      FrostedFeedShowcase(),
    ),
    _Entry(
      'Travel Cards',
      'Text that reads on any photo',
      '1501785888041-af3ef285b470',
      TravelCardsShowcase(),
    ),
    _Entry(
      'Lock Screen',
      'A sky softening behind alerts',
      '1534447677768-be436bb09401',
      LockScreenShowcase(),
    ),
    _Entry(
      'Miniature City',
      'Tilt-shift toy-model look',
      '1477959858617-67f85cf4f1df',
      MiniatureShowcase(),
    ),
    _Entry(
      'Map Explorer',
      'A map fading behind its panels',
      '1499856871958-5b9627545d1a',
      MapExplorerShowcase(),
    ),
  ];

  static const _more = [
    _MoreEntry(
      'Tilt-shift playground',
      'Tune every setting with sliders',
      Icons.tune_rounded,
      TiltShiftPhotography(),
    ),
    _MoreEntry(
      'Blur on scroll',
      'Blur strength that follows the scroll',
      Icons.swap_vert_rounded,
      GradualTopBlur(),
    ),
    _MoreEntry(
      'Quality and speed',
      'Compare the quality settings',
      Icons.speed_rounded,
      PerformanceComparison(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        // The page blurs as it slides under the status bar.
        body: VariableBlur(
          sigma: 12,
          edgeIntensity: 0.04,
          blurSides: ResponsiveBlurSides.vertical(top: padding.top + 12),
          child: ColoredBox(
            color: Colors.black,
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, padding.top + 28, 20, 24),
                  sliver: const SliverToBoxAdapter(child: _Header()),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.66,
                        ),
                    itemCount: _showcases.length,
                    itemBuilder:
                        (context, i) => _ShowcaseCard(entry: _showcases[i]),
                  ),
                ),
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, 36, 20, 12),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'MORE EXAMPLES',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, padding.bottom + 24),
                  sliver: SliverList.list(
                    children: [for (final e in _more) _MoreRow(entry: e)],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Entry {
  const _Entry(this.title, this.caption, this.photo, this.page);
  final String title;
  final String caption;
  final String photo;
  final Widget page;
}

class _MoreEntry {
  const _MoreEntry(this.title, this.caption, this.icon, this.page);
  final String title;
  final String caption;
  final IconData icon;
  final Widget page;
}

void _open(BuildContext context, Widget page) =>
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => page));

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'VARIABLE BLUR',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.4,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Sharp to soft,\nin one widget.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Tap a design to see the progressive blur in a real screen.',
          style: TextStyle(color: Colors.white60, fontSize: 15),
        ),
      ],
    );
  }
}

class _ShowcaseCard extends StatelessWidget {
  const _ShowcaseCard({required this.entry});
  final _Entry entry;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _open(context, entry.page),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            VariableBlur(
              sigma: 18,
              edgeIntensity: 0.2,
              quality: BlurQuality.medium,
              blurSides: const BlurSides.vertical(bottom: 0.45),
              child: Image.network(
                'https://images.unsplash.com/photo-${entry.photo}?w=500',
                fit: BoxFit.cover,
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.45, 1.0],
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    entry.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12.5,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreRow extends StatelessWidget {
  const _MoreRow({required this.entry});
  final _MoreEntry entry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: const Color(0xFF1A1A1D),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _open(context, entry.page),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(entry.icon, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        entry.caption,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.white38),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
