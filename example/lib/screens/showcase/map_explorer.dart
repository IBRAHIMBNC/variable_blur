import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';
import 'package:variable_blur/variable_blur.dart';

/// A map whose top and bottom melt into blur behind the search bar and the
/// place card. Works because `flutter_map` is drawn by Flutter; native map
/// views (Google Maps, Apple Maps) are drawn by the OS and cannot be blurred.
class MapExplorerShowcase extends StatelessWidget {
  const MapExplorerShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    return Scaffold(
      body: Stack(
        children: [
          VariableBlur(
            sigma: 14,
            edgeIntensity: 0.08,
            blurSides: ResponsiveBlurSides.vertical(
              top: padding.top + 90,
              bottom: padding.bottom + 190,
            ),
            child: FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(48.8584, 2.2945),
                initialZoom: 14.5,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'dev.variable_blur.example',
                ),
                const MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(48.8584, 2.2945),
                      width: 44,
                      height: 44,
                      child: Icon(
                        Icons.location_on_rounded,
                        color: Colors.redAccent,
                        size: 44,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: padding.top + 12,
            left: 16,
            right: 16,
            child: _SearchBar(onBack: () => Navigator.maybePop(context)),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: padding.bottom + 16,
            child: const _PlaceCard(),
          ),
          Positioned(
            right: 8,
            bottom: padding.bottom + 4,
            child: const Text(
              '© OpenStreetMap contributors',
              style: TextStyle(fontSize: 9, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const Expanded(
            child: Text(
              'Search places',
              style: TextStyle(color: Colors.black54, fontSize: 16),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.mic_none_rounded, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  const _PlaceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Eiffel Tower',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Landmark · Champ de Mars, Paris · Open until 23:45',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.directions_rounded),
                  label: const Text('Directions'),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filledTonal(
                onPressed: () {},
                icon: const Icon(Icons.bookmark_border_rounded),
              ),
              IconButton.filledTonal(
                onPressed: () {},
                icon: const Icon(Icons.share_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
