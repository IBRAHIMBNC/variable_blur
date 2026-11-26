import 'package:material_ui/material_ui.dart';
import 'package:variable_blur/variable_blur.dart';

import 'demo_scroll.dart';

/// A photo feed that scrolls under a header and a tab bar which fade from
/// sharp to blurred, like the newest iOS apps.
class FrostedFeedShowcase extends StatefulWidget {
  const FrostedFeedShowcase({super.key});

  @override
  State<FrostedFeedShowcase> createState() => _FrostedFeedShowcaseState();
}

class _FrostedFeedShowcaseState extends State<FrostedFeedShowcase> {
  final _controller = ScrollController();

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

  static const _posts = [
    ('1514565131-fce0801e5785', 'New York at dusk', 'Mia Chen'),
    ('1500530855697-b586d89ba3ee', 'The long road west', 'Leo Park'),
    ('1499856871958-5b9627545d1a', 'Evening on the Seine', 'Ana Silva'),
    ('1470225620780-dba8ba36b745', 'Friday night set', 'DJ Kato'),
    ('1501785888041-af3ef285b470', 'Glass-green lake', 'Sam Rivera'),
    ('1511671782779-c97d3d27a1d4', 'Open mic', 'Noor Ali'),
    ('1507525428034-b723cf961d3e', 'First light', 'Jon Weiss'),
  ];

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    const header = 64.0, tabBar = 64.0;
    final top = padding.top + header;
    final bottom = padding.bottom + tabBar;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // The feed is blurred under the header and the tab bar only, with
          // the blur fading out as content moves toward the middle.
          VariableBlur(
            sigma: 16,
            edgeIntensity: 0.06,
            blurSides: ResponsiveBlurSides.vertical(
              top: top + 24,
              bottom: bottom + 24,
            ),
            child: ColoredBox(
              color: Colors.white,
              child: ListView.builder(
                controller: _controller,
                padding: EdgeInsets.fromLTRB(16, top + 8, 16, bottom + 16),
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
            child: _Header(topInset: padding.top),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: bottom,
            child: _TabBar(bottomInset: padding.bottom),
          ),
        ],
      ),
    );
  }
}

class _Post extends StatelessWidget {
  const _Post({required this.post});
  final (String, String, String) post;

  @override
  Widget build(BuildContext context) {
    final (id, title, author) = post;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor:
                    Colors.primaries[author.length % Colors.primaries.length],
                child: Text(
                  author[0],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              Text(author, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Image.network(
                'https://images.unsplash.com/photo-$id?w=900',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.topInset});
  final double topInset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8, topInset, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          ),
          const Text(
            'Discover',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
          ),
          const Spacer(),
          const Icon(Icons.search_rounded, size: 28),
        ],
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.bottomInset});
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    const icons = [
      Icons.home_rounded,
      Icons.explore_rounded,
      Icons.add_circle_rounded,
      Icons.favorite_border_rounded,
      Icons.person_outline_rounded,
    ];
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var i = 0; i < icons.length; i++)
            Icon(
              icons[i],
              size: i == 2 ? 36 : 28,
              color: i == 1 ? Colors.black : Colors.black54,
            ),
        ],
      ),
    );
  }
}
