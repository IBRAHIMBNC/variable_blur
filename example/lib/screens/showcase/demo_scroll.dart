import 'package:material_ui/material_ui.dart';

/// Scrolls [controller] down and back up by itself when the app is launched
/// with `--dart-define=DEMO_SCROLL=true`. Used only to record the README
/// GIFs; it does nothing otherwise.
void startDemoScroll(State state, ScrollController controller) {
  if (!const bool.fromEnvironment('DEMO_SCROLL')) return;
  Future<void> loop() async {
    await Future<void>.delayed(const Duration(seconds: 3));
    var down = true;
    while (state.mounted && controller.hasClients) {
      final position = controller.position;
      await controller.animateTo(
        down ? position.maxScrollExtent * 0.6 : 0,
        duration: const Duration(seconds: 4),
        curve: Curves.easeInOutCubic,
      );
      await Future<void>.delayed(const Duration(milliseconds: 600));
      down = !down;
    }
  }

  WidgetsBinding.instance.addPostFrameCallback((_) => loop());
}
