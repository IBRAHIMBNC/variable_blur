import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:variable_blur/variable_blur.dart';

import 'demo_scroll.dart';

/// Editorial story cards: each photo melts into a blur tinted with the
/// photo's own colour, and the whole page blurs under the status bar and
/// the floating tab bar.
class StoryCardsShowcase extends StatefulWidget {
  const StoryCardsShowcase({super.key});

  @override
  State<StoryCardsShowcase> createState() => _StoryCardsShowcaseState();
}

class _StoryCardsShowcaseState extends State<StoryCardsShowcase> {
  final _controller = ScrollController();

  static const _stories = [
    _Story(
      photo: '1493225457124-a3eb161ffa5f',
      eyebrow: 'FROM THE EDITORS',
      title: 'Turn up the volume',
      subtitle: 'Fresh music apps for every mood.',
      tint: Color(0xFF3A2A2E),
      apps: [Colors.redAccent, Colors.indigo, Colors.amber, Colors.teal],
    ),
    _Story(
      photo: '1500530855697-b586d89ba3ee',
      eyebrow: 'GAMES WE LOVE',
      title: 'Desert Drift',
      subtitle: 'Hit the open road in sunset races.',
      tint: Color(0xFF6B4A3A),
      apps: [Colors.deepOrange],
    ),
    _Story(
      photo: '1501785888041-af3ef285b470',
      eyebrow: 'GET OUTSIDE',
      title: 'Plan your next escape',
      subtitle: 'Maps, trails and weather for the trip.',
      tint: Color(0xFF1F4A44),
      apps: [Colors.green, Colors.cyan, Colors.lightBlue],
    ),
  ];

  @override
  void initState() {
    super.initState();
    startDemoScroll(this, _controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // The page itself blurs under the status bar and the tab bar.
            VariableBlur(
              sigma: 14,
              edgeIntensity: 0.05,
              blurSides: ResponsiveBlurSides.vertical(
                top: padding.top + 16,
                bottom: padding.bottom + 90,
              ),
              child: ColoredBox(
                color: Colors.black,
                child: ListView(
                  controller: _controller,
                  padding: EdgeInsets.fromLTRB(
                    16,
                    padding.top + 8,
                    16,
                    padding.bottom + 110,
                  ),
                  children: [
                    const _DateHeader(),
                    for (final story in _stories) _StoryCard(story: story),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: padding.bottom + 8,
              child: _FloatingTabBar(onBack: () => Navigator.maybePop(context)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Story {
  const _Story({
    required this.photo,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.tint,
    required this.apps,
  });

  final String photo;
  final String eyebrow;
  final String title;
  final String subtitle;
  final Color tint;
  final List<Color> apps;
}

class _DateHeader extends StatelessWidget {
  const _DateHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(4, 12, 4, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FRIDAY 14 NOVEMBER',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Today',
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.story});
  final _Story story;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: SizedBox(
          height: 460,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // The photo blurs over its bottom half...
              VariableBlur(
                sigma: 28,
                edgeIntensity: 0.25,
                blurSides: const BlurSides.vertical(bottom: 0.5),
                child: Image.network(
                  'https://images.unsplash.com/photo-${story.photo}?w=900',
                  fit: BoxFit.cover,
                ),
              ),
              // ...and fades into the photo's own colour.
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.4, 0.85],
                    colors: [
                      story.tint.withValues(alpha: 0),
                      story.tint.withValues(alpha: 0.75),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 22,
                right: 22,
                bottom: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      story.eyebrow,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      story.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      story.subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _AppRow(colors: story.apps, title: story.title),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppRow extends StatelessWidget {
  const _AppRow({required this.colors, required this.title});
  final List<Color> colors;
  final String title;

  Widget _icon(Color color) => Container(
    width: 48,
    height: 48,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [color, Color.lerp(color, Colors.black, 0.35)!],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(12),
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (colors.length > 1) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [for (final c in colors) _icon(c)],
      );
    }
    return Row(
      children: [
        _icon(colors.first),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Text(
                'Racing game',
                style: TextStyle(color: Colors.white60, fontSize: 13),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Get',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _FloatingTabBar extends StatelessWidget {
  const _FloatingTabBar({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.today_rounded, 'Today'),
      (Icons.rocket_launch_rounded, 'Games'),
      (Icons.layers_rounded, 'Apps'),
      (Icons.search_rounded, 'Search'),
    ];
    return Container(
      height: 64,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2E).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: i == 0 ? onBack : null,
                child: Container(
                  decoration:
                      i == 0
                          ? BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(28),
                          )
                          : null,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        items[i].$1,
                        color: i == 0 ? Colors.lightBlueAccent : Colors.white,
                      ),
                      Text(
                        items[i].$2,
                        style: TextStyle(
                          fontSize: 11,
                          color: i == 0 ? Colors.lightBlueAccent : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
