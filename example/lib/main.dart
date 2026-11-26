import 'package:example/screens/blur_benchmark.dart';
import 'package:example/screens/home.dart';
import 'package:example/screens/native_compare.dart';
import 'package:example/screens/showcase/frosted_feed.dart';
import 'package:example/screens/showcase/lock_screen.dart';
import 'package:example/screens/showcase/map_explorer.dart';
import 'package:example/screens/showcase/miniature.dart';
import 'package:example/screens/showcase/music_player.dart';
import 'package:example/screens/showcase/story_cards.dart';
import 'package:example/screens/showcase/travel_cards.dart';
import 'package:example/screens/showcase/video_story.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Variable Blur',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.white,
        scaffoldBackgroundColor: Colors.black,
      ),
      home:
          _showcases[const String.fromEnvironment('SHOWCASE')] ??
          (const bool.fromEnvironment('NATIVE_COMPARE')
              ? const NativeCompare()
              : const bool.fromEnvironment('BENCH')
              ? const BlurBenchmark()
              : const HomeScreen()),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Showcase screens, also reachable at launch with
/// `--dart-define=SHOWCASE=key` (used to capture the README media).
const _showcases = <String, Widget>{
  'home': HomeScreen(),
  'music': MusicPlayerShowcase(),
  'feed': FrostedFeedShowcase(),
  'travel': TravelCardsShowcase(),
  'lock': LockScreenShowcase(),
  'miniature': MiniatureShowcase(),
  'map': MapExplorerShowcase(),
  'stories': StoryCardsShowcase(),
  'video': VideoStoryShowcase(),
};
