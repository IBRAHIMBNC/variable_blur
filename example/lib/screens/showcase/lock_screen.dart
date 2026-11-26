import 'package:material_ui/material_ui.dart';
import 'package:variable_blur/variable_blur.dart';

/// A lock screen: the clock sits over the sharp sky, and the wallpaper
/// softens into blur behind the notifications.
class LockScreenShowcase extends StatelessWidget {
  const LockScreenShowcase({super.key});

  static const _wallpaper =
      'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=1200';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          VariableBlur(
            sigma: 24,
            edgeIntensity: 0.25,
            blurSides: const BlurSides.vertical(bottom: 0.5),
            child: Image.network(_wallpaper, fit: BoxFit.cover),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  const Icon(Icons.lock_rounded, color: Colors.white),
                  const SizedBox(height: 8),
                  const Text(
                    'Friday, 14 November',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  const Text(
                    '9:41',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 96,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                    ),
                  ),
                  const Spacer(),
                  const _Notification(
                    icon: Icons.chat_bubble_rounded,
                    color: Colors.green,
                    app: 'Messages',
                    title: 'Sara',
                    body: 'Look at the sky tonight, the stars are unreal ✨',
                    time: 'now',
                  ),
                  const SizedBox(height: 8),
                  const _Notification(
                    icon: Icons.wb_twilight_rounded,
                    color: Colors.indigo,
                    app: 'Weather',
                    title: 'Clear skies',
                    body: 'Perfect night for stargazing. Low 12°.',
                    time: '5m ago',
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _RoundButton(
                        icon: Icons.flashlight_on_rounded,
                        onTap: () => Navigator.maybePop(context),
                      ),
                      _RoundButton(
                        icon: Icons.camera_alt_rounded,
                        onTap: () {},
                      ),
                    ],
                  ),
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

class _Notification extends StatelessWidget {
  const _Notification({
    required this.icon,
    required this.color,
    required this.app,
    required this.title,
    required this.body,
    required this.time,
  });

  final IconData icon;
  final Color color;
  final String app;
  final String title;
  final String body;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(9),
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
                          fontWeight: FontWeight.w600,
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
                Text(body, style: const TextStyle(color: Colors.white)),
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
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
