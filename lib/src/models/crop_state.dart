import 'package:flutter/widgets.dart';
import '../configuration/crop_aspect_ratio.dart';
import '../configuration/crop_shape.dart';
import '../detection/crop_auto_detector.dart';
import 'crop_rect.dart';
import 'crop_transform.dart';

/// Immutable snapshot representing the active state of an image cropper.
@immutable
class CropState {
  /// Creates a [CropState].
  const CropState({
    required this.cropRect,
    required this.viewRect,
    required this.normalizedCropRect,
    required this.transform,
    required this.aspectRatio,
    required this.shape,
    required this.imageSize,
    required this.isReady,
    this.detectedDocument,
  });

  /// An uninitialized initial state.
  static const CropState initial = CropState(
    cropRect: Rect.zero,
    viewRect: Rect.zero,
    normalizedCropRect: CropRect.full,
    transform: CropTransform.identity,
    aspectRatio: CropAspectRatio.free,
    shape: CropShape.rectangle,
    imageSize: Size.zero,
    isReady: false,
    detectedDocument: null,
  );

  /// Pixel coordinates of the crop frame within the container viewport.
  final Rect cropRect;

  /// Pixel coordinates and dimensions of the container viewport.
  final Rect viewRect;

  /// Normalized crop rectangle [0.0, 1.0].
  final CropRect normalizedCropRect;

  /// Current 2D transformation (pan, zoom, rotation, flip).
  final CropTransform transform;

  /// Active aspect ratio constraint.
  final CropAspectRatio aspectRatio;

  /// Active crop shape geometry.
  final CropShape shape;

  /// Original intrinsic dimensions of the source image in pixels.
  final Size imageSize;

  /// Whether the image has been decoded and the cropper is ready for operations.
  final bool isReady;

  /// Optional detected document bounding information when auto-detection is performed.
  final DetectedDocument? detectedDocument;

  /// Current zoom scale multiplier.
  double get zoom => transform.scale;

  /// Current rotation in degrees.
  double get rotation => transform.rotationDegrees;

  /// Whether image is mirrored horizontally.
  bool get isFlippedHorizontal => transform.isFlippedHorizontal;

  /// Whether image is mirrored vertically.
  bool get isFlippedVertical => transform.isFlippedVertical;

  /// Creates a copy with modified properties.
  CropState copyWith({
    Rect? cropRect,
    Rect? viewRect,
    CropRect? normalizedCropRect,
    CropTransform? transform,
    CropAspectRatio? aspectRatio,
    CropShape? shape,
    Size? imageSize,
    bool? isReady,
    DetectedDocument? detectedDocument,
  }) {
    return CropState(
      cropRect: cropRect ?? this.cropRect,
      viewRect: viewRect ?? this.viewRect,
      normalizedCropRect: normalizedCropRect ?? this.normalizedCropRect,
      transform: transform ?? this.transform,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      shape: shape ?? this.shape,
      imageSize: imageSize ?? this.imageSize,
      isReady: isReady ?? this.isReady,
      detectedDocument: detectedDocument ?? this.detectedDocument,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CropState &&
        other.cropRect == cropRect &&
        other.viewRect == viewRect &&
        other.normalizedCropRect == normalizedCropRect &&
        other.transform == transform &&
        other.aspectRatio == aspectRatio &&
        other.shape == shape &&
        other.imageSize == imageSize &&
        other.isReady == isReady &&
        other.detectedDocument == detectedDocument;
  }

  @override
  int get hashCode => Object.hash(
        cropRect,
        viewRect,
        normalizedCropRect,
        transform,
        aspectRatio,
        shape,
        imageSize,
        isReady,
        detectedDocument,
      );

  @override
  String toString() =>
      'CropState(ready: $isReady, zoom: ${zoom.toStringAsFixed(2)}, '
      'rotation: $rotation°, shape: $shape, aspect: $aspectRatio)';
}
