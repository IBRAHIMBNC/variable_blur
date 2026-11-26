## [0.2.0]

### Changed
- **Small-copy blur, like Flutter's own blur**: The child is rendered into a small copy (down to 1/4 or 1/8 size for strong blur), blurred there, and laid back over the sharp child. The sharp area keeps every original pixel.
- **Less work while scrolling**: The blur is only worked out again when the child's content or the blur settings change. Moving the widget reuses the last result.
- **`updateEveryFrame`**: New option that redoes the blur every frame, for content Flutter does not repaint itself: video (`VideoPlayer`), camera previews and other `Texture` widgets. Without it the blurred part shows a frozen frame while the sharp part plays. Tested with `video_player` on the iOS simulator.
- **New pub.dev page**: Rewritten README with GIFs and eight showcases (story cards, frosted header and tab bar, music player, travel cards, lock screen, tilt-shift miniature, `flutter_map`, video), a "what it can blur" table and measured performance. Added `topics` and `screenshots` to the pubspec and removed the old 9.6 MB `screen_shots` folder.
- **Only the blur regions are copied**: Instead of copying and blurring the whole child, only the blur regions (plus how far their blur reaches) are processed. Non-touching opposite regions, such as top and bottom, get one small copy each. On an iPhone 7 Plus (release mode, a 200 pt top fade over a full-screen scrolling list), the blur's extra memory fell from about 14 MB to about 11 MB and frame drawing time from 4.4 ms to 3.7 ms.
- **Measured on an iPhone 17 Pro Max** (profile mode, 30 blurred cards scrolling): CPU about 50% instead of 113%, memory about 195 MB instead of 230 MB. With the blur strength changing every frame: CPU 66–94% instead of 128–142%, memory about 218 MB instead of 280 MB.
- **True variable blur**: Each pixel gets its own blur strength that rises smoothly into the blur regions, instead of fading a sharp image into one fixed blur.
- **Quality**: `BlurQuality` now sets how small the blurred copy may get and how many samples each pixel reads. It no longer weakens `sigma`.
- **Shapes**: The blur stays inside the child's own shape, so rounded or see-through parts do not leak sharp pixels or spread a halo.
- **Transforms**: Works under `Transform.scale` and `Transform.rotate`.
- **Y-flip**: No flip is applied on any backend. On Flutter 3.50.1 with Impeller on OpenGL ES (Android emulator) the blurred copy is already the right way up; the old automatic OpenGL ES flip drew it upside down. `isYFlipNeed` is now deprecated and will be removed in a future release.
- Requires Flutter 3.32 or newer. Tested on Flutter 3.32.0 (iOS simulator) and 3.50.1 (iOS simulator and iPhone). Not yet tested on Android or with Impeller turned off.

### Kept
- Public API is unchanged. `BlurSidesBase` is now exported, since `blurSides` uses it.

### Removed
- The `flutter_shaders` dependency, the old two-pass shaders and the unused `shader_builder.dart` helper.

---

## [0.1.0] - 2024-01-XX

### ✨ Improvements
- **Performance**: 40-75% performance boost with 4-tier optimization system
- **Blur Range**: Extended maximum kernel size to 100 pixels
- **ResponsiveBlurSides**: Added screen size breakpoint configuration

### 🔧 Fixes
- **Impeller Issue**: Fixed SkSL shader compilation errors when Impeller is disabled on Android
- **Cross-Platform**: Ensured compatibility with both Impeller and Skia rendering backends

---

## [0.0.8] - 2024-01-XX

### Added
- Comprehensive documentation for `BlurSides` (ratio-based, 0–1) and `ResponsiveBlurSides` (pixel-based) for clarity and ease of use.
- Improved API docs and inline comments for all public classes and methods.

### Changed
- Major performance boost: rendering and blur computation are now significantly faster and more responsive, especially on large images and during dynamic updates.
- Responsiveness improvements: blur effects now adapt more smoothly to widget size and pixel-based configurations.
- Cleaned up and refactored code for maintainability and efficiency.
- Updated all examples and documentation to reflect new best practices and usage patterns.

### Fixed
- Improved handling of edge cases for both ratio-based and pixel-based blur regions.
- Enhanced compatibility and stability across iOS and Android devices.

## 0.0.7

### Added
- Automatic kernel size calculation based on sigma value and quality setting.
- Simplified API - no more manual kernel size configuration needed!

### Changed
- **REMOVED**: The `kernelSize` parameter has been removed to simplify the API.
- **IMPROVED**: Quality settings now automatically optimize kernel size for best performance vs quality trade-off.
- Cleaned up unused uniforms in shaders (removed `edgeIntensity` from horizontal pass).
- Updated all examples and documentation to reflect the simplified API.

### Fixed
- Previously, using sigma values greater than 15 was not recommended and could result in poor blur or performance issues.
- Now, kernel size is automatically calculated, making high sigma values safer to use with appropriate quality settings.

## 0.0.6

- **VISUAL**: Added comprehensive screenshot gallery to README.md for better pub.dev presentation
- **IMPROVED**: Enhanced README.md with visual examples showcasing different blur effects
- **OPTIMIZED**: Refined package description to meet pub.dev character limits (60-180 chars)
- **ENHANCED**: Added organized image gallery displaying tilt-shift, horizontal, vertical, and dynamic blur effects
- **PRESENTATION**: Improved package discoverability with prominent visual examples in documentation
- **POLISH**: Better structured README layout for professional pub.dev package listing

## 0.0.5
- **DOCUMENTATION**: Comprehensive API documentation added to meet pub.dev standards (20%+ coverage achieved)
- **NEW**: Added detailed dartdoc comments for all public API elements
- **IMPROVED**: Enhanced library-level documentation with features overview and usage examples
- **ADDED**: Important compatibility notes - blur effects only work on images or colored containers
- **ENHANCED**: Detailed class and method documentation with performance considerations
- **QUALITY**: Added comprehensive examples and best practices in documentation
- **REFERENCES**: Clear references to example app for implementation guidance

## 0.0.4

- **BREAKING FIX**: Fixed coordinate system compatibility between iOS and Android platforms
- **NEW**: Added platform-aware rendering to prevent upside-down blur effects on Android
- **IMPROVED**: Enhanced cross-platform shader compatibility with automatic coordinate system detection
- **TECHNICAL**: Added platform detection logic to handle different coordinate origins (iOS: bottom-left, Android: top-left)
- **PERFORMANCE**: Optimized shader branching for platform-specific coordinate transformations

## 0.0.3

- Documentation updates and package maintenance

## 0.0.2

- Internal improvements and bug fixes

## 0.0.1

- Initial release with variable blur effects
- Tilt-shift blur implementation with GPU shaders
- Customizable blur sides (top, bottom, left, right)
- Performance-optimized blur rendering
- Quality control settings (low, medium, high)
- Cross-platform support for Flutter applications
