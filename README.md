# flutter_crop_image

[![pub package](https://img.shields.io/pub/v/flutter_crop_image.svg)](https://pub.dev/packages/flutter_crop_image)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![platform](https://img.shields.io/badge/platform-flutter%20%7C%20android%20%7C%20ios%20%7C%20web%20%7C%20macos%20%7C%20windows%20%7C%20linux-blue.svg)](https://pub.dev/packages/flutter_crop_image)

A production-ready, highly extensible Flutter image cropping package. Built with a decoupled headless engine, 60/120 FPS GPU-accelerated rendering, interactive corner handles, customizable composition grids, comprehensive gesture handling, modular theming, and **zero external dependencies**.

---

## 📸 Showcase & Preview

<table>
  <tr>
    <td align="center" width="25%">
      <img src="https://raw.githubusercontent.com/Kishandobariya76/flutter_crop_image/main/screenshots/02_basic_cropper.png" width="220" alt="Turnkey Cropper" />
      <br />
      <b>Turnkey Cropper</b>
      <br />
      <sub>Toolbar & Composition Grid</sub>
    </td>
    <td align="center" width="25%">
      <img src="https://raw.githubusercontent.com/Kishandobariya76/flutter_crop_image/main/screenshots/04_circular_avatar.png" width="220" alt="Avatar Crop" />
      <br />
      <b>Circular Avatar</b>
      <br />
      <sub>Profile Cutout Mask</sub>
    </td>
    <td align="center" width="25%">
      <img src="https://raw.githubusercontent.com/Kishandobariya76/flutter_crop_image/main/screenshots/06_landscape_16_9.png" width="220" alt="16:9 Landscape" />
      <br />
      <b>16:9 Landscape</b>
      <br />
      <sub>Widescreen Preset</sub>
    </td>
    <td align="center" width="25%">
      <img src="https://raw.githubusercontent.com/Kishandobariya76/flutter_crop_image/main/screenshots/07_nord_theme.png" width="220" alt="Nord Theme" />
      <br />
      <b>Nord Theme</b>
      <br />
      <sub>Custom Palette Styling</sub>
    </td>
  </tr>
</table>

---

## 🌟 Key Features

* **Decoupled Architecture**: The core crop engine is pure Dart/Flutter, completely independent of `Material`, `Cupertino`, `Scaffold`, or any third-party state manager.
* **Turnkey Screen & Headless Modes**: Use the ready-to-go `FlutterCropImageView` screen or embed the bare `FlutterCropImage` widget directly inside your own layouts.
* **Hardware-Accelerated (60/120 FPS)**: Rendered via `RepaintBoundary` and GPU `dart:ui.Canvas` matrix transformations. Gesture pans and pinches never cause parent widget re-renders.
* **Interactive Corner Resizing**: Touch-and-drag corner handles (TL, TR, BL, BR) with smooth aspect-ratio constraints and boundary clamping.
* **Geometric Cutout Shapes**: Standard Rectangular, Circular (avatar/profile photo), Oval, and Rounded Rectangle with customizable corner radius.
* **Full Gesture Suite**: 1-finger panning, 2-finger pinch zoom, double-tap zoom, continuous rotation gestures, and boundary clamping.
* **Programmatic Controller**: Complete control over zoom, rotation, horizontal/vertical flipping, positioning, aspect ratio, shapes, and export via `CropController`.
* **Composition Guide System**: Rule of Thirds, Golden Ratio ($0.382 / 0.618$), Crosshair, and custom $M \times N$ grid divisions.
* **Design-System Agnostic Theming**: Style every color, handle, line width, and typography through `CropperTheme` (includes Dark, Light, Cupertino, and Nord presets).
* **Memory & OOM Defense**: Configurable raster dimension clamping (`maxProcessingDimension`) prevents GPU crashes on 4K, 8K, or multi-megapixel camera photos.
* **Zero External Dependencies**: Runs entirely on the Flutter SDK without native bridges, NDK, or heavy C++ binaries.
* **Auto Document & ID Card Detection**: Real-time edge boundary detection for ID cards (Aadhar, PAN, Driver's License), receipts, and documents with instant auto-snapping and ratio recognition. Includes `CropperConfiguration.idCard` and `CropperConfiguration.documentScanner` presets.

---

## 📦 Installation

Add `flutter_crop_image` to your project using the command line:

```bash
flutter pub add flutter_crop_image
```

Or add it directly to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_crop_image: ^0.1.0
```

Then import the package in your Dart code:

```dart
import 'package:flutter_crop_image/flutter_crop_image.dart';
```

---

## 🚀 Getting Started

### 1. Instant Turnkey Cropping Screen (`FlutterCropImageView`)

For an instant, full-featured cropping screen with top navigation, cancel/done actions, zoom slider, rotation, and aspect ratio selector:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_crop_image/flutter_crop_image.dart';

void openImageCropper(BuildContext context, ImageProvider imageProvider) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => FlutterCropImageView(
        image: imageProvider,
        title: 'Crop Image',
        onCropped: (CropResult result) {
          Navigator.of(context).pop();
          
          // Access exported bytes and image metadata
          final Uint8List bytes = result.bytes;
          final int width = result.width;
          final int height = result.height;
          
          debugPrint('Cropped successfully: ${width}x$height (${result.byteLength} bytes)');
        },
        onCancelled: () => Navigator.of(context).pop(),
      ),
    ),
  );
}
```

<table>
  <tr>
    <td align="center" width="50%">
      <img src="https://raw.githubusercontent.com/Kishandobariya76/flutter_crop_image/main/screenshots/02_basic_cropper.png" width="280" alt="Turnkey Cropper View" />
      <br />
      <b>Interactive Crop Viewport</b>
    </td>
    <td align="center" width="50%">
      <img src="https://raw.githubusercontent.com/Kishandobariya76/flutter_crop_image/main/screenshots/05_cropped_result.png" width="280" alt="Cropped Result Dialog" />
      <br />
      <b>Exported Result & Metadata</b>
    </td>
  </tr>
</table>

---

### 2. Headless In-App Widget (`FlutterCropImage`)

Embed the cropping viewport directly into your custom page, dialog, or bottom sheet without any package toolbars:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_crop_image/flutter_crop_image.dart';

class MyCustomEditorScreen extends StatefulWidget {
  const MyCustomEditorScreen({super.key, required this.imageProvider});
  final ImageProvider imageProvider;

  @override
  State<MyCustomEditorScreen> createState() => _MyCustomEditorScreenState();
}

class _MyCustomEditorScreenState extends State<MyCustomEditorScreen> {
  final CropController _controller = CropController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _exportCroppedImage() async {
    final CropResult result = await _controller.crop();
    // Do something with result.bytes (e.g. upload, save to disk)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Editor')),
      body: FlutterCropImage(
        image: widget.imageProvider,
        controller: _controller,
        configuration: const CropperConfiguration(
          aspectRatio: CropAspectRatio.square,
          shape: CropShape.circle,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _exportCroppedImage,
        child: const Icon(Icons.check),
      ),
    );
  }
}
```

<table>
  <tr>
    <td align="center" width="50%">
      <img src="https://raw.githubusercontent.com/Kishandobariya76/flutter_crop_image/main/screenshots/09_headless_engine.png" width="280" alt="Headless Cropper" />
      <br />
      <b>Headless Engine Viewport</b>
    </td>
    <td align="center" width="50%">
      <img src="https://raw.githubusercontent.com/Kishandobariya76/flutter_crop_image/main/screenshots/08_custom_controls.png" width="280" alt="Custom Controls" />
      <br />
      <b>Custom Developer Controls</b>
    </td>
  </tr>
</table>

---

## 🖼️ Image Source Support

`flutter_crop_image` supports all standard Flutter `ImageProvider` implementations:

```dart
// Memory byte buffer
FlutterCropImage(image: MemoryImage(uint8listBytes));

// Network URL
FlutterCropImage(image: NetworkImage('https://example.com/photo.jpg'));

// Local File (iOS, Android, Desktop)
FlutterCropImage(image: FileImage(file));

// Flutter Asset Bundle
FlutterCropImage(image: AssetImage('assets/images/sample.png'));
```

Convenience factory constructors are also available:

```dart
FlutterCropImage.memory(bytes);
FlutterCropImage.network('https://example.com/photo.jpg');
FlutterCropImage.asset('assets/images/sample.png');
```

---

## 🎮 Programmatic Control (`CropController`)

Create a `CropController` to manipulate transforms programmatically or observe state changes:

```dart
final controller = CropController();

// --- Zoom Controls ---
controller.zoomIn();
controller.zoomOut();
controller.setZoom(2.5);
await controller.animateToZoom(3.0, duration: const Duration(milliseconds: 300));

// --- Rotation & Mirroring ---
controller.rotateLeft();   // -90 degrees
controller.rotateRight();  // +90 degrees
controller.setRotation(45.0); // Arbitrary angle
controller.flipHorizontal();
controller.flipVertical();

// --- Viewport Positioning ---
controller.center();
controller.fit();
controller.move(const Offset(10.0, -5.0)); // Delta offset
controller.reset();

// --- Dynamic Constraints ---
controller.setAspectRatio(CropAspectRatio.ratio16x9);
controller.setCropShape(CropShape.circle);

// --- Export Result ---
final CropResult result = await controller.crop(
  format: CropImageFormat.png,
  quality: 90,
  targetSize: const Size(1080, 1080), // Optional downscaling
);
```

### Observing Reactive State
`CropController` extends `ChangeNotifier`, making it compatible with `ListenableBuilder`, `AnimatedBuilder`, or state-management packages (Bloc, Riverpod, Provider, GetX):

```dart
ListenableBuilder(
  listenable: controller,
  builder: (context, _) {
    return Column(
      children: [
        Text('Zoom: ${controller.zoom.toStringAsFixed(1)}x'),
        Text('Rotation: ${controller.rotation.toInt()}°'),
        Text('Aspect: ${controller.aspectRatio}'),
      ],
    );
  },
);
```

<p align="center">
  <img src="https://raw.githubusercontent.com/Kishandobariya76/flutter_crop_image/main/screenshots/10_rotate_and_zoom.png" width="280" alt="Programmatic Rotation and Fine Zoom" />
  <br />
  <b>90° Hardware Matrix Rotation & Continuous Zoom Slider (up to 5.0x)</b>
</p>

---

## 📐 Aspect Ratios

Support predefined proportions, custom dimensions, or unconstrained freeform resizing:

```dart
// Predefined Presets
CropAspectRatio.free;       // Unconstrained freeform resizing
CropAspectRatio.square;     // 1:1
CropAspectRatio.ratio16x9;  // 16:9 Landscape
CropAspectRatio.ratio9x16;  // 9:16 Story / Shorts / Reels
CropAspectRatio.ratio4x3;   // 4:3 Standard Photo
CropAspectRatio.ratio3x4;   // 3:4 Portrait
CropAspectRatio.ratio3x2;   // 3:2 Classic Photo
CropAspectRatio.ratio2x3;   // 2:3 Classic Portrait

// Document & ID Presets
CropAspectRatio.idCard;     // ISO/IEC 7810 ID-1 standard (~1.586) for Aadhar, PAN, Voter ID
CropAspectRatio.a4;         // ISO 216 standard (~1.414) for printed documents
CropAspectRatio.passport;   // 35x45mm standard (~0.778) for passport photos

// Custom Ratios
final cinema = CropAspectRatio.custom(21, 9, label: '21:9 Cinema');
final floatRatio = CropAspectRatio.ratio(2.35, label: 'Anamorphic');
```

<table>
  <tr>
    <td align="center" width="50%">
      <img src="https://raw.githubusercontent.com/Kishandobariya76/flutter_crop_image/main/screenshots/03_aspect_ratios.png" width="280" alt="Aspect Ratio Selection" />
      <br />
      <b>Dynamic Aspect Ratio Selector</b>
    </td>
    <td align="center" width="50%">
      <img src="https://raw.githubusercontent.com/Kishandobariya76/flutter_crop_image/main/screenshots/06_landscape_16_9.png" width="280" alt="16:9 Landscape Preset" />
      <br />
      <b>Locked 16:9 Landscape Mode</b>
    </td>
  </tr>
</table>

---

## 🪪 Document & ID Card Auto-Cropping (Aadhar / PAN / Passports)

Automatically analyze document boundaries and snap the crop rectangle to the edges with zero external C++/ML dependencies:

```dart
// Turnkey ID Card Scanner (Aadhar, PAN, Driving License, Student ID)
AdvancedCropperView(
  image: FileImage(capturedFile),
  title: 'Scan ID Card',
  configuration: CropperConfiguration.idCard,
  onCropped: (result) => handleCroppedDocument(result),
)

// Or generic document scanner with auto-detection
AdvancedCropperView(
  image: FileImage(capturedFile),
  title: 'Scan Document',
  configuration: CropperConfiguration.documentScanner,
  onCropped: (result) => handleCroppedDocument(result),
)

// Programmatic invocation via controller:
await controller.autoDetectAndSnap(
  duration: const Duration(milliseconds: 350),
  curve: Curves.easeOutCubic,
);
```

<table>
  <tr>
    <td align="center" width="50%">
      <img src="https://raw.githubusercontent.com/Kishandobariya76/flutter_crop_image/main/screenshots/11_auto_document_crop.png" width="280" alt="Auto Document Detection & Snapping" />
      <br />
      <b>Real-Time Auto-Detection & Snapping</b>
      <br />
      <sub>Automatic edge alignment around Aadhar / ID card</sub>
    </td>
    <td align="center" width="50%">
      <img src="https://raw.githubusercontent.com/Kishandobariya76/flutter_crop_image/main/screenshots/12_document_crop_result.png" width="280" alt="Cropped Document Result" />
      <br />
      <b>High-Precision Cropped Result</b>
      <br />
      <sub>Pixel-perfect, crisp document export (PNG/JPEG)</sub>
    </td>
  </tr>
</table>

---

## ⭕ Geometric Crop Shapes

Configure geometric cutouts via `CropShape`:

| Shape | Description | Alpha Transparency |
| :--- | :--- | :---: |
| `CropShape.rectangle` | Standard rectangular box | N/A |
| `CropShape.circle` | Circular mask for avatars and profile pictures | ✅ Full alpha cutout |
| `CropShape.oval` | Elliptical cutout fitting the crop window | ✅ Full alpha cutout |
| `CropShape.roundedRectangle` | Rectangle with customizable `cornerRadius` | ✅ Anti-aliased corners |

```dart
CropperConfiguration(
  shape: CropShape.roundedRectangle,
  overlay: CropOverlayConfiguration(
    cornerRadius: 16.0,
  ),
)
```

<table>
  <tr>
    <td align="center" width="50%">
      <img src="https://raw.githubusercontent.com/Kishandobariya76/flutter_crop_image/main/screenshots/04_circular_avatar.png" width="280" alt="Circular Avatar Mask" />
      <br />
      <b>Circular Avatar Mask Preview</b>
    </td>
    <td align="center" width="50%">
      <img src="https://raw.githubusercontent.com/Kishandobariya76/flutter_crop_image/main/screenshots/04b_avatar_result.png" width="280" alt="Circular Alpha Output" />
      <br />
      <b>Transparent Alpha PNG Output</b>
    </td>
  </tr>
</table>

---

## 📐 Composition Guides & Grids

Help users compose their crop with alignment grids:

```dart
// Rule of Thirds (Classic 3x3)
CropperConfiguration(
  grid: CropGridConfiguration(
    style: CropGridStyle.ruleOfThirds,
    gridColor: Colors.white70,
  ),
)

// Golden Ratio (0.382 / 0.618 divisions)
CropperConfiguration(
  grid: CropGridConfiguration(
    style: CropGridStyle.goldenRatio,
  ),
)

// Center Crosshair (2x2)
CropperConfiguration(
  grid: CropGridConfiguration(
    style: CropGridStyle.crosshair,
  ),
)

// Custom NxM Grid
CropperConfiguration(
  grid: CropGridConfiguration(
    style: CropGridStyle.custom,
    rows: 4,
    columns: 4,
  ),
)
```

---

## 🎨 Theme Customization

The cropper does not impose any visual identity. Use `CropperTheme` to match your application's design system:

```dart
FlutterCropImageView(
  image: imageProvider,
  theme: const CropperTheme(
    backgroundColor: Color(0xFF0F172A),
    toolbarColor: Color(0xFF1E293B),
    primaryColor: Color(0xFF6366F1),
    accentColor: Color(0xFF818CF8),
    textColor: Color(0xFFF8FAFC),
    secondaryTextColor: Color(0xFF94A3B8),
    cropBorderColor: Color(0xFF6366F1),
    cropHandleColor: Color(0xFF6366F1),
    cropGridColor: Color(0x666366F1),
  ),
);
```

### Built-in Theme Presets
* `CropperTheme.dark` (Default dark slate palette)
* `CropperTheme.light` (Clean light mode)
* `CropperTheme.cupertinoDark` (iOS Photos app style)
* `CropperTheme.nord` (Arctic Nord palette)

<p align="center">
  <img src="https://raw.githubusercontent.com/Kishandobariya76/flutter_crop_image/main/screenshots/07_nord_theme.png" width="280" alt="Nord Theme Styling" />
  <br />
  <b>Custom Nord Theme Preset (Frost Polar Palette & Themed Grid)</b>
</p>

---

## ⚙️ Configuration Presets

Quickly configure the cropper for common workflows:

```dart
// Circular Profile Picture (1:1, circle mask, no grid)
CropperConfiguration.profilePhoto

// Instagram Square Post (1:1, rectangle)
CropperConfiguration.instagramSquare

// Instagram / TikTok Story (9:16, rectangle)
CropperConfiguration.story

// YouTube / Video Thumbnail (16:9, rectangle)
CropperConfiguration.landscape16x9
```

---

## 🛠️ Complete Copy-Paste Runnable Example

Below is a complete, self-contained `main.dart` demonstrating in-memory offline image creation, turnkey cropping, and displaying the cropped result:

```dart
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_crop_image/flutter_crop_image.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CropperDemoScreen(),
  ));
}

class CropperDemoScreen extends StatefulWidget {
  const CropperDemoScreen({super.key});

  @override
  State<CropperDemoScreen> createState() => _CropperDemoScreenState();
}

class _CropperDemoScreenState extends State<CropperDemoScreen> {
  Uint8List? _imageBytes;
  Uint8List? _croppedBytes;

  @override
  void initState() {
    super.initState();
    _createSampleImage();
  }

  // Generates a simple 600x600 in-memory image for testing without network/files
  Future<void> _createSampleImage() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        const Offset(600, 600),
        [Colors.blue, Colors.purple, Colors.orange],
      );
    canvas.drawRect(const Rect.fromLTWH(0, 0, 600, 600), paint);

    final picture = recorder.endRecording();
    final img = await picture.toImage(600, 600);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    setState(() {
      _imageBytes = byteData!.buffer.asUint8List();
    });
  }

  void _openCropper() {
    if (_imageBytes == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FlutterCropImageView(
          image: MemoryImage(_imageBytes!),
          title: 'Crop Sample',
          configuration: CropperConfiguration.profilePhoto,
          onCropped: (result) {
            Navigator.of(context).pop();
            setState(() {
              _croppedBytes = result.bytes;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('flutter_crop_image Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_croppedBytes != null) ...[
              const Text('Cropped Result:'),
              const SizedBox(height: 8),
              Image.memory(_croppedBytes!, width: 200, height: 200),
              const SizedBox(height: 24),
            ],
            ElevatedButton.icon(
              onPressed: _openCropper,
              icon: const Icon(Icons.crop),
              label: const Text('Open Cropper'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 📱 Interactive Example App

The included [`example/`](example/) project showcases all 6 cropper modes and workflows. It generates a high-resolution 1600×1200 vector canvas in memory for testing offline without external assets or network dependencies:

<p align="center">
  <img src="https://raw.githubusercontent.com/Kishandobariya76/flutter_crop_image/main/screenshots/01_example_home.png" width="300" alt="Example Showcase App" />
  <br />
  <b>Interactive Example Suite on Physical Device</b>
</p>

| Mode | Highlight |
| :--- | :--- |
| **1. Basic Turnkey Cropper** | Full navigation bar, aspect ratios, zoom slider, rotate, and flip. |
| **2. Circular Profile Crop** | 1:1 circular mask for avatars with transparent alpha channel cutout. |
| **3. 16:9 Landscape Thumbnail** | Fixed widescreen ratio with Rule of Thirds alignment guides. |
| **4. Custom Nord Theme** | Polar theme palette override for toolbar, borders, handles, and grid. |
| **5. Custom Developer Controls** | Completely bespoke floating buttons and custom action rows. |
| **6. Headless Crop Engine** | Bare `FlutterCropImage` embedded directly inside custom screens. |

---

## ⚡ Performance & Memory Architecture

Processing multi-megapixel (4K/8K) camera images can cause high GPU memory pressure if unmanaged. `flutter_crop_image` safeguards your app:

1. **Repaint Boundary Isolation**: Pan and pinch gestures only repaint the canvas texture layer, avoiding parent widget rebuilding.
2. **Dimension Clamping (`maxProcessingDimension`)**: Prevents GPU buffer allocation crashes by automatically clamping output dimensions to safe limits (default 4096 px).
3. **Deterministic Memory Cleanup**: Native `ui.Image` and `ui.Picture` memory buffers are explicitly disposed.

```dart
CropperConfiguration(
  processing: CropProcessingConfiguration(
    maxProcessingDimension: 4096, // Maximum dimension during export
    enableAntialiasing: true,
  ),
)
```

---

## 🌐 Platform Support

| Platform | Support | Engine | Output Pipeline |
| :--- | :---: | :--- | :--- |
| **Android** | ✅ | Impeller / Skia | GPU Canvas (`dart:ui`) |
| **iOS** | ✅ | Metal Impeller | GPU Canvas (`dart:ui`) |
| **Web** | ✅ | CanvasKit / Skia WASM | HTML5 Canvas / `dart:ui` |
| **macOS** | ✅ | Metal Impeller | GPU Canvas (`dart:ui`) |
| **Windows** | ✅ | Direct3D / Impeller | GPU Canvas (`dart:ui`) |
| **Linux** | ✅ | OpenGL / Impeller | GPU Canvas (`dart:ui`) |

---

## 📑 API Reference Summary

| Class | Description |
| :--- | :--- |
| [`FlutterCropImage`](#) | Core headless cropper widget (also aliased as `AdvancedCropper`). |
| [`FlutterCropImageView`](#) | Turnkey crop screen with navigation bar and toolbar controls (also aliased as `AdvancedCropperView`). |
| [`CropController`](#) | State controller for zoom, rotation, flip, pan, aspect ratio, and export. |
| [`CropperConfiguration`](#) | Top-level configuration model (aspect ratios, shapes, overlays, grids, gestures). |
| [`CropperTheme`](#) | Visual palette configuration for toolbars, overlays, borders, and handles. |
| [`CropAspectRatio`](#) | Aspect ratio model with presets (`square`, `ratio16x9`, `ratio4x3`, `free`, `custom`). |
| [`CropShape`](#) | Enum defining cutout geometry (`rectangle`, `circle`, `oval`, `roundedRectangle`). |
| [`CropResult`](#) | Export result model containing encoded bytes, dimensions, format, and crop rect. |
| [`DefaultCropperControls`](#) | Accessible toolbar with aspect selector, zoom slider, rotate, and flip buttons. |

---

## 🤝 Contributing & Feedback

Contributions, feature requests, and bug reports are welcome! Feel free to open an issue or submit a pull request on [GitHub](https://github.com/Kishandobariya76/flutter_crop_image).

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

## Support

If Flutter Crop Image saved you time, you can buy me a chai.

[![Buy Me a Chai](https://img.shields.io/badge/Buy%20Me%20a%20Chai-ffdd00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://kishan-dobariya-pay.netlify.app/)
[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-ffdd00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://kishan-dobariya-pay.netlify.app/)

Phones open a UPI app. Desktops show a QR to scan.

---

## Developer

**Kishan Dobariya**

- Phone: +91 90232 56218
- Email: [flutterdeveloper2206@gmail.com](mailto:flutterdeveloper2206@gmail.com)
- LinkedIn: [kishan-dobariya-99b005217](https://www.linkedin.com/in/kishan-dobariya-99b005217)
- GitHub: [Kishandobariya76](https://github.com/Kishandobariya76)
