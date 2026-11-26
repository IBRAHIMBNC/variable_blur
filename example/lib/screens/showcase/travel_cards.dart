import 'package:material_ui/material_ui.dart';
import 'package:variable_blur/variable_blur.dart';

import 'demo_scroll.dart';

/// Booking-style photo cards: the bottom of each photo fades into blur
/// behind the title and price, so the text reads on any photo.
class TravelCardsShowcase extends StatefulWidget {
  const TravelCardsShowcase({super.key});

  @override
  State<TravelCardsShowcase> createState() => _TravelCardsShowcaseState();
}

class _TravelCardsShowcaseState extends State<TravelCardsShowcase> {
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

  static const _stays = [
    (
      '1501785888041-af3ef285b470',
      'Lakeside Cabin',
      'Dolomites, Italy',
      '\$240',
      4.97,
    ),
    (
      '1520250497591-112f2f40a3f4',
      'Jungle Pool Villa',
      'Krabi, Thailand',
      '\$180',
      4.91,
    ),
    (
      '1507525428034-b723cf961d3e',
      'Beach House',
      'Tulum, Mexico',
      '\$310',
      4.88,
    ),
    (
      '1499856871958-5b9627545d1a',
      'Loft by the Seine',
      'Paris, France',
      '\$275',
      4.95,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F6),
      appBar: AppBar(
        title: const Text('Stays'),
        backgroundColor: const Color(0xFFF4F4F6),
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView.separated(
        controller: _controller,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        itemCount: _stays.length,
        separatorBuilder: (_, _) => const SizedBox(height: 16),
        itemBuilder: (context, i) => _StayCard(stay: _stays[i]),
      ),
    );
  }
}

class _StayCard extends StatelessWidget {
  const _StayCard({required this.stay});
  final (String, String, String, String, double) stay;

  @override
  Widget build(BuildContext context) {
    final (id, name, place, price, rating) = stay;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 300,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // The bottom 40% of the photo blurs behind the text.
            VariableBlur(
              sigma: 22,
              edgeIntensity: 0.2,
              blurSides: const BlurSides.vertical(bottom: 0.4),
              child: Image.network(
                'https://images.unsplash.com/photo-$id?w=900',
                fit: BoxFit.cover,
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.5, 1.0],
                  colors: [Colors.transparent, Colors.black45],
                ),
              ),
            ),
            Positioned(
              top: 14,
              right: 14,
              child: CircleAvatar(
                backgroundColor: Colors.white.withValues(alpha: 0.9),
                child: const Icon(
                  Icons.favorite_border_rounded,
                  color: Colors.black87,
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 18,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.place_rounded,
                              color: Colors.white70,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              place,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '$rating',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      text: price,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                      children: const [
                        TextSpan(
                          text: ' /night',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.white70,
                          ),
                        ),
                      ],
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
