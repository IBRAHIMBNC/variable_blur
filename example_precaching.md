# Shader Precaching Example

## Usage Options

### Option 1: Manual Precaching (Recommended)
Call `VariableBlur.precacheShaders()` early in your app lifecycle:

```dart
import 'package:flutter/material.dart';
import 'package:variable_blur/variable_blur.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Precache shaders during app startup
  await VariableBlur.precacheShaders();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: VariableBlur(
          sigma: 15.0,
          blurSides: BlurSides.vertical(top: 1.0, bottom: 0.3),
          child: Image.asset('assets/photo.jpg'),
        ),
      ),
    );
  }
}
```

### Option 2: Automatic Precaching
The widget now automatically precaches shaders on first use, so no manual setup is required.

## Performance Benefits

- **Eliminates first-render stutter**: Shaders are compiled ahead of time
- **Smoother animations**: No compilation delay when blur effects start
- **Better user experience**: Consistent performance from the first frame
- **Fire-and-forget**: Once precached, all subsequent VariableBlur widgets benefit

## When to Use

- **Always recommended** for production apps
- **Essential** for apps with blur animations or transitions
- **Critical** for apps targeting lower-end devices where shader compilation is slower
