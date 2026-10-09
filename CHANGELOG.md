## 0.2.0

* Added **Automatic Document & ID Card Detection** (`CropAutoDetector`, `NativeDocumentDetector`).
* Pure-Dart hardware luminance gradient edge detector with zero external C++/ML dependencies.
* Added `CropperConfiguration.idCard` and `CropperConfiguration.documentScanner` presets.
* Added standard document aspect ratios: `CropAspectRatio.idCard` (ISO/IEC 7810 ID-1 standard ~1.586 for Aadhar/PAN cards), `CropAspectRatio.a4` (~1.414), and `CropAspectRatio.passport` (~0.778).
* Added `CropController.autoDetectDocument()` and `CropController.autoDetectAndSnap()` with smooth easing animations.
* Added Auto-Detect document button to `DefaultCropperControls` toolbar with scrollable overflow prevention.
* Added simulated Aadhar card test and demo tile to the example application.

## 0.1.0

* Initial release of `flutter_crop_image`.
* Pure Dart/Flutter crop engine decoupled from UI frameworks and state-management libraries.
* Core headless `FlutterCropImage` (`AdvancedCropper`) widget and turnkey `FlutterCropImageView` (`AdvancedCropperView`) screen.
* Hardware-accelerated GPU image cropping via `NativeUiCropProcessor` and `dart:ui`.
* Geometric crop shapes: `rectangle`, `circle`, `oval`, and `roundedRectangle`.
* Standard and custom aspect ratios (`free`, `1:1`, `4:3`, `16:9`, `9:16`, `3:2`, `custom`).
* Interactive corner resize handles with smooth aspect constraints.
* Composition grid system with Rule of Thirds, Golden Ratio, Crosshair, and custom $M \times N$ divisions.
* Full touch gesture handling: 1-finger pan, 2-finger pinch zoom, double-tap zoom, and rotation.
* Full programmatic control through `CropController` (zoom, rotation, flip H/V, move, reset, fit, crop).
* `CropperTheme` system with `dark`, `light`, `cupertinoDark`, and `nord` presets.
* Memory management and dimensions clamping for high-resolution 4K/8K images.
* Complete example application and automated test suite.
