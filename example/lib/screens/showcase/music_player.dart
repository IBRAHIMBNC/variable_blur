import 'package:material_ui/material_ui.dart';
import 'package:variable_blur/variable_blur.dart';

/// A "now playing" screen: the album art melts into soft blur behind the
/// player controls, like modern music apps.
class MusicPlayerShowcase extends StatelessWidget {
  const MusicPlayerShowcase({super.key});

  static const _cover =
      'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=1200';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // The whole effect: the bottom 55% of the art blurs smoothly.
          VariableBlur(
            sigma: 30,
            edgeIntensity: 0.5,
            blurSides: const BlurSides.vertical(bottom: 0.45),
            child: Image.network(_cover, fit: BoxFit.cover),
          ),
          // A light shade so the white controls stay readable.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.45, 1.0],
                colors: [Colors.black26, Colors.transparent, Colors.black54],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _TopBar(onClose: () => Navigator.maybePop(context)),
                  const Spacer(),
                  const _TrackInfo(),
                  const SizedBox(height: 20),
                  const _Progress(),
                  const SizedBox(height: 16),
                  const _Controls(),
                  const SizedBox(height: 24),
                  const _Volume(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onClose,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
          color: Colors.white,
        ),
        const Expanded(
          child: Column(
            children: [
              Text(
                'PLAYING FROM ALBUM',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Neon Nights',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_horiz_rounded),
          color: Colors.white,
        ),
      ],
    );
  }
}

class _TrackInfo extends StatelessWidget {
  const _TrackInfo();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Into the Light',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'The Midnight Echo',
                style: TextStyle(color: Colors.white70, fontSize: 17),
              ),
            ],
          ),
        ),
        Icon(Icons.favorite_rounded, color: Colors.white, size: 28),
      ],
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress();

  @override
  Widget build(BuildContext context) {
    const time = TextStyle(color: Colors.white60, fontSize: 12);
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: const LinearProgressIndicator(
            value: 0.38,
            minHeight: 5,
            color: Colors.white,
            backgroundColor: Colors.white24,
          ),
        ),
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text('1:24', style: time), Text('-2:16', style: time)],
        ),
      ],
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Icon(Icons.shuffle_rounded, color: Colors.white70),
        const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 44),
        Container(
          width: 76,
          height: 76,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.pause_rounded, color: Colors.black, size: 44),
        ),
        const Icon(Icons.skip_next_rounded, color: Colors.white, size: 44),
        const Icon(Icons.repeat_rounded, color: Colors.white70),
      ],
    );
  }
}

class _Volume extends StatelessWidget {
  const _Volume();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.volume_mute_rounded, color: Colors.white60, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 0.7,
              minHeight: 4,
              color: Colors.white70,
              backgroundColor: Colors.white24,
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Icon(Icons.volume_up_rounded, color: Colors.white60, size: 20),
      ],
    );
  }
}
