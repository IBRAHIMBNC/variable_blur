import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:variable_blur/variable_blur.dart';

import 'demo_scroll.dart';

/// A dark photo feed that scrolls under a header and a floating tab bar:
/// the photos fade into blur as they slide under them, while the bars stay
/// crisp on top.
class FrostedFeedShowcase extends StatefulWidget {
  const FrostedFeedShowcase({super.key});

  @override
  State<FrostedFeedShowcase> createState() => _FrostedFeedShowcaseState();
}

class _FrostedFeedShowcaseState extends State<FrostedFeedShowcase> {
  final _controller = ScrollController();

  static const _posts = [
    ('1514565131-fce0801e5785', 'New York at dusk', 'Mia Chen', '2.4k'),
    ('1470225620780-dba8ba36b745', 'Friday night set', 'DJ Kato', '1.1k'),
    ('1501785888041-af3ef285b470', 'Glass-green lake', 'Sam Rivera', '3.8k'),
    ('1499856871958-5b9627545d1a', 'Evening on the Seine', 'Ana Silva', '956'),
    ('1500530855697-b586d89ba3ee', 'The long road west', 'Leo Park', '2.0k'),
    ('1511671782779-c97d3d27a1d4', 'Open mic', 'Noor Ali', '742'),
    ('1534447677768-be436bb09401', 'Under the stars', 'Jon Weiss', '5.1k'),
  ];

  static const _header = 108.0;
  static const _tabBar = 76.0;

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
    final top = padding.top + _header;
    final bottom = padding.bottom + _tabBar;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Only the feed blurs, under the header and the tab bar.
            VariableBlur(
              sigma: 18,
              edgeIntensity: 0.07,
              blurSides: ResponsiveBlurSides.vertical(
                top: top + 28,
                bottom: bottom + 28,
              ),
              child: ColoredBox(
                color: Colors.black,
                child: ListView.builder(
                  controller: _controller,
                  padding: EdgeInsets.fromLTRB(0, top + 4, 0, bottom + 24),
                  itemCount: _posts.length,
                  itemBuilder: (context, i) => _Post(post: _posts[i]),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: top,
              child: _Header(
                topInset: padding.top,
                onBack: () => Navigator.maybePop(context),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: padding.bottom + 10,
              child: const _TabBar(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Post extends StatelessWidget {
  const _Post({required this.post});
  final (String, String, String, String) post;

  @override
  Widget build(BuildContext context) {
    final (id, title, author, likes) = post;
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 4 / 5,
            child: Image.network(
              'https://images.unsplash.com/photo-$id?w=1000',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(
                    'https://images.unsplash.com/photo-$id?w=80&h=80&fit=crop',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        author,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.favorite_rounded,
                  color: Color(0xFFFF375F),
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(likes, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.topInset, required this.onBack});
  final double topInset;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    const chips = ['For you', 'Following', 'Cities', 'Nature', 'Night'];
    return Padding(
      padding: EdgeInsets.only(top: topInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
            child: Row(
              children: [
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                  color: Colors.white,
                ),
                const Text(
                  'Explore',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.search_rounded, color: Colors.white, size: 26),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: chips.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder:
                  (context, i) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color:
                          i == 0
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      chips[i],
                      style: TextStyle(
                        color: i == 0 ? Colors.black : Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar();

  @override
  Widget build(BuildContext context) {
    const icons = [
      Icons.home_rounded,
      Icons.explore_rounded,
      Icons.add_rounded,
      Icons.favorite_border_rounded,
      Icons.person_outline_rounded,
    ];
    return Container(
      height: 62,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(31),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var i = 0; i < icons.length; i++)
            i == 2
                ? Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icons[i], color: Colors.black),
                )
                : Icon(
                  icons[i],
                  size: 26,
                  color: i == 1 ? Colors.white : Colors.white54,
                ),
        ],
      ),
    );
  }
}
