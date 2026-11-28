import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:variable_blur/variable_blur.dart';

import 'demo_scroll.dart';

/// Full-screen stays you swipe between: each photo melts into blur behind
/// the details, so the text reads on any photo without a dark gradient.
class TravelCardsShowcase extends StatefulWidget {
  const TravelCardsShowcase({super.key});

  @override
  State<TravelCardsShowcase> createState() => _TravelCardsShowcaseState();
}

class _TravelCardsShowcaseState extends State<TravelCardsShowcase> {
  final _pages = PageController();
  int _page = 0;

  static const _stays = [
    _Stay(
      photo: '1501785888041-af3ef285b470',
      name: 'Lakeside Cabin',
      place: 'Dolomites, Italy',
      rating: '4.97',
      reviews: '312',
      price: '\$240',
      amenities: [
        (Icons.kayaking_rounded, 'Kayaks'),
        (Icons.fireplace_rounded, 'Fireplace'),
        (Icons.wifi_rounded, 'Wi-Fi'),
      ],
    ),
    _Stay(
      photo: '1520250497591-112f2f40a3f4',
      name: 'Jungle Pool Villa',
      place: 'Krabi, Thailand',
      rating: '4.91',
      reviews: '528',
      price: '\$180',
      amenities: [
        (Icons.pool_rounded, 'Private pool'),
        (Icons.spa_rounded, 'Spa'),
        (Icons.free_breakfast_rounded, 'Breakfast'),
      ],
    ),
    _Stay(
      photo: '1507525428034-b723cf961d3e',
      name: 'Beach House',
      place: 'Tulum, Mexico',
      rating: '4.88',
      reviews: '204',
      price: '\$310',
      amenities: [
        (Icons.beach_access_rounded, 'Beachfront'),
        (Icons.surfing_rounded, 'Surf'),
        (Icons.ac_unit_rounded, 'AC'),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    startDemoPages(this, _pages, _stays.length);
  }

  @override
  void dispose() {
    _pages.dispose();
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
            PageView.builder(
              controller: _pages,
              itemCount: _stays.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, i) => _StayPage(stay: _stays[i]),
            ),
            Positioned(
              top: padding.top + 8,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  _GlassButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.maybePop(context),
                  ),
                  const Spacer(),
                  _GlassButton(icon: Icons.ios_share_rounded, onTap: () {}),
                  const SizedBox(width: 10),
                  _GlassButton(
                    icon: Icons.favorite_border_rounded,
                    onTap: () {},
                  ),
                ],
              ),
            ),
            Positioned(
              top: padding.top + 70,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < _stays.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == _page ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: i == _page ? Colors.white : Colors.white54,
                        borderRadius: BorderRadius.circular(3),
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

class _Stay {
  const _Stay({
    required this.photo,
    required this.name,
    required this.place,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.amenities,
  });

  final String photo;
  final String name;
  final String place;
  final String rating;
  final String reviews;
  final String price;
  final List<(IconData, String)> amenities;
}

class _StayPage extends StatelessWidget {
  const _StayPage({required this.stay});
  final _Stay stay;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        // The photo blurs over its lower half, behind the details.
        VariableBlur(
          sigma: 26,
          edgeIntensity: 0.35,
          blurSides: const BlurSides.vertical(bottom: 0.4),
          child: Image.network(
            'https://images.unsplash.com/photo-${stay.photo}?w=1200',
            fit: BoxFit.cover,
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.2, 0.55, 1.0],
              colors: [
                Colors.black38,
                Colors.transparent,
                Colors.transparent,
                Colors.black45,
              ],
            ),
          ),
        ),
        Positioned(
          left: 22,
          right: 22,
          bottom: padding.bottom + 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.place_rounded,
                    color: Colors.white70,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    stay.place.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                stay.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '${stay.rating}  ·  ${stay.reviews} reviews',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final (icon, label) in stay.amenities)
                    _Chip(icon: icon, label: label),
                ],
              ),
              const SizedBox(height: 22),
              Container(height: 1, color: Colors.white24),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: stay.price,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                        children: const [
                          TextSpan(
                            text: '  / night',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      'Reserve',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.25),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
