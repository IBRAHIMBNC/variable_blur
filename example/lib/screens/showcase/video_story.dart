import 'package:material_ui/material_ui.dart';
import 'package:variable_blur/variable_blur.dart';
import 'package:video_player/video_player.dart';

/// A story-style video whose bottom blurs behind the caption while it plays.
///
/// Video frames reach the screen without Flutter repainting anything, so the
/// blur is told to redo itself every frame with `updateEveryFrame: true`.
/// Turn the switch off to see the difference: the blurred part freezes.
class VideoStoryShowcase extends StatefulWidget {
  const VideoStoryShowcase({super.key});

  @override
  State<VideoStoryShowcase> createState() => _VideoStoryShowcaseState();
}

class _VideoStoryShowcaseState extends State<VideoStoryShowcase> {
  late final VideoPlayerController _video = VideoPlayerController.networkUrl(
    Uri.parse(
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    ),
  );
  bool _live = true;

  @override
  void initState() {
    super.initState();
    _video
      ..setLooping(true)
      ..setVolume(0)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _video.play();
      });
  }

  @override
  void dispose() {
    _video.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ready = _video.value.isInitialized;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (ready)
            VariableBlur(
              sigma: 24,
              edgeIntensity: 0.25,
              blurSides: const BlurSides.vertical(top: 0.12, bottom: 0.4),
              updateEveryFrame: _live,
              child: FittedBox(
                fit: BoxFit.cover,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: _video.value.size.width,
                  height: _video.value.size.height,
                  child: VideoPlayer(_video),
                ),
              ),
            )
          else
            const Center(child: CircularProgressIndicator()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.maybePop(context),
                        icon: const Icon(Icons.close_rounded),
                        color: Colors.white,
                      ),
                      const Spacer(),
                      const Text(
                        'Update every frame',
                        style: TextStyle(color: Colors.white),
                      ),
                      Switch(
                        value: _live,
                        onChanged: (v) => setState(() => _live = v),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Text(
                    'Garden visitors',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'A butterfly stops by the flowers. The blur behind this '
                    'caption follows the video as it plays.',
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
