import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:variable_blur/variable_blur.dart';

/// A lock screen: the clock sits over the sharp sky, and the wallpaper
/// softens into blur behind the notifications.
class LockScreenShowcase extends StatelessWidget {
  const LockScreenShowcase({super.key});

  static const _wallpaper =
      'https://images.unsplash.com/photo-1444927714506-8492d94b4e3d?w=1400';

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            VariableBlur(
              sigma: 26,
              edgeIntensity: 0.25,
              blurSides: const BlurSides.vertical(bottom: 0.55),
              child: Image.network(_wallpaper, fit: BoxFit.cover),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.5, 1.0],
                  colors: [Colors.transparent, Colors.black38],
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 18),
                    const Icon(Icons.lock_rounded, color: Colors.white),
                    const SizedBox(height: 6),
                    const Text(
                      'Friday 14 November',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Text(
                      '9:41',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 108,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -3,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _Widget(icon: Icons.cloud_rounded, label: '12°'),
                        SizedBox(width: 14),
                        _Widget(
                          icon: Icons.battery_5_bar_rounded,
                          label: '82%',
                        ),
                        SizedBox(width: 14),
                        _Widget(icon: Icons.event_rounded, label: '3 PM'),
                        SizedBox(width: 14),
                        _Widget(
                          icon: Icons.directions_walk_rounded,
                          label: '6.4k',
                        ),
                      ],
                    ),
                    const Spacer(),
                    const _Notification(
                      icon: Icons.chat_bubble_rounded,
                      color: Color(0xFF34C759),
                      title: 'Sara',
                      body:
                          'Made it to the top. The fog is unreal this morning.',
                      time: 'now',
                    ),
                    const SizedBox(height: 8),
                    const _Notification(
                      icon: Icons.photo_library_rounded,
                      color: Color(0xFFFF9500),
                      title: 'Memories',
                      body: 'Mountain mornings, a new memory is ready.',
                      time: '12m ago',
                    ),
                    const SizedBox(height: 8),
                    const _Notification(
                      icon: Icons.wb_twilight_rounded,
                      color: Color(0xFF5856D6),
                      title: 'Weather',
                      body: 'Fog clears by 11. Sunny afternoon, high 18°.',
                      time: '1h ago',
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _RoundButton(
                          icon: Icons.flashlight_on_rounded,
                          onTap: () => Navigator.maybePop(context),
                        ),
                        Container(
                          width: 130,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        _RoundButton(
                          icon: Icons.camera_alt_rounded,
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Widget extends StatelessWidget {
  const _Widget({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.18),
        border: Border.all(color: Colors.white30),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Notification extends StatelessWidget {
  const _Notification({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.time,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
