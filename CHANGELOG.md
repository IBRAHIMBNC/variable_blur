## 0.2.0 - 2026-11-28

### Changed
- **True variable blur**: Each pixel gets its own blur strength that rises smoothly into the blur regions, instead of fading a sharp image into one fixed blur.
- **Small-copy blur, like Flutter's own blur**: The child is rendered into a small copy (down to 1/4 or 1/8 size for strong blur), blurred there, and laid back over the sharp child. The sharp area keeps every original pixel.
- **Only the blur regions are copied**: Instead of copying and blurring the whole child, only the blur regions (plus how far their blur reaches) are processed. Opposite regions that do not touch, such as top and bottom, get one small copy each.
- **Less work while scrolling**: The blur is only worked out again when the child's content or the blur settings change. Moving the widget reuses the last result.
- **Much lighter**: Uses far less memory and about half the CPU of the previous version. Tested on an iPhone 7 Plus, where it scrolls smoothly at 60 fps.
- **Quality**: `BlurQuality` now sets how small the blurred copy may get and how many samples each pixel reads. It no longer weakens `sigma`.
- **Shapes**: The blur stays inside the child's own shape, so rounded or see-through parts do not leak sharp pixels or spread a halo.
- **Transforms**: Works under `Transform.scale` and `Transform.rotate`.
- **Upside-down blur fixed**: No flip is applied on any backend any more. With Impeller on OpenGL ES (for example the Android emulator) the old automatic flip drew the blur upside down.
- Requires Flutter 3.32 or newer. Tested on Flutter 3.32.0 and 3.50.1, on iOS (iPhone 7 Plus, iPhone 17 Pro Max, simulator) and Android (emulator).

### Added
- **`updateEveryFrame`**: Redoes the blur every frame, for content Flutter does not repaint itself: video (`VideoPlayer`), camera previews and other `Texture` widgets. Without it the blurred part shows a frozen frame while the sharp part plays.
- **New pub.dev page**: A banner, GIFs, a gallery and nine showcase screens (scroll story, music player, video, story cards, map, travel stays, frosted header and tab bar, lock screen, tilt-shift editor), each with its code, plus a "what it can blur" table.
- `topics` and `screenshots` in the pubspec.

### Deprecated
- `isYFlipNeed`: no longer needed, and will be removed in a future release.

### Kept
- The public API is unchanged. `BlurSidesBase` is now exported, since `blurSides` uses it.

### Removed
- The `flutter_shaders` dependency, the old two-pass shaders and the unused `shader_builder.dart` helper.
- The old `screen_shots` folder, which made the package much bigger to download.

---

## 0.1.0 - 2025-07-18

### Improved
- **Performance**: 40-75% performance boost with 4-tier optimization system
- **Blur Range**: Extended maximum kernel size to 100 pixels
- **ResponsiveBlurSides**: Added screen size breakpoint configuration

### Fixed
- **Impeller Issue**: Fixed SkSL shader compilation errors when Impeller is disabled on Android
- **Cross-Platform**: Ensured compatibility with both Impeller and Skia rendering backends

---

## 0.0.8 - 2025-06-29

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

## 0.0.7 - 2025-06-11

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

## 0.0.6 - 2025-06-02

- **VISUAL**: Added comprehensive screenshot gallery to README.md for better pub.dev presentation
- **IMPROVED**: Enhanced README.md with visual examples showcasing different blur effects
- **OPTIMIZED**: Refined package description to meet pub.dev character limits (60-180 chars)
- **ENHANCED**: Added organized image gallery displaying tilt-shift, horizontal, vertical, and dynamic blur effects
- **PRESENTATION**: Improved package discoverability with prominent visual examples in documentation
- **POLISH**: Better structured README layout for professional pub.dev package listing

## 0.0.5 - 2025-06-01
- **DOCUMENTATION**: Comprehensive API documentation added to meet pub.dev standards (20%+ coverage achieved)
- **NEW**: Added detailed dartdoc comments for all public API elements
- **IMPROVED**: Enhanced library-level documentation with features overview and usage examples
- **ADDED**: Important compatibility notes - blur effects only work on images or colored containers
- **ENHANCED**: Detailed class and method documentation with performance considerations
- **QUALITY**: Added comprehensive examples and best practices in documentation
- **REFERENCES**: Clear references to example app for implementation guidance

## 0.0.4 - 2025-05-29

- **BREAKING FIX**: Fixed coordinate system compatibility between iOS and Android platforms
- **NEW**: Added platform-aware rendering to prevent upside-down blur effects on Android
- **IMPROVED**: Enhanced cross-platform shader compatibility with automatic coordinate system detection
- **TECHNICAL**: Added platform detection logic to handle different coordinate origins (iOS: bottom-left, Android: top-left)
- **PERFORMANCE**: Optimized shader branching for platform-specific coordinate transformations

## 0.0.3 - 2025-05-28

- Documentation updates and package maintenance

## 0.0.2 - 2025-05-27

- Internal improvements and bug fixes

## 0.0.1 - 2025-05-27

- Initial release with variable blur effects
- Tilt-shift blur implementation with GPU shaders
- Customizable blur sides (top, bottom, left, right)
- Performance-optimized blur rendering
- Quality control settings (low, medium, high)
- Cross-platform support for Flutter applications
