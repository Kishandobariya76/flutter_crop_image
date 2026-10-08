import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';
import 'crop_image_format.dart';

/// The result of an image crop and export operation.
@immutable
class CropResult {
  /// Creates a [CropResult].
  const CropResult({
    required this.bytes,
    required this.width,
    required this.height,
    required this.format,
    required this.cropRect,
    required this.rotation,
    required this.isFlippedHorizontal,
    required this.isFlippedVertical,
    this.rawImage,
  });

  /// The encoded image bytes (PNG, JPEG, WebP, or raw RGBA).
  final Uint8List bytes;

  /// The output image width in pixels.
  final int width;

  /// The output image height in pixels.
  final int height;

  /// The encoding format of [bytes].
  final CropImageFormat format;

  /// The cropped rectangular region in source coordinates.
  final Rect cropRect;

  /// The applied rotation angle in degrees.
  final double rotation;

  /// Whether the image was flipped horizontally during export.
  final bool isFlippedHorizontal;

  /// Whether the image was flipped vertically during export.
  final bool isFlippedVertical;

  /// Optional underlying [ui.Image], if retained by the processor.
  final ui.Image? rawImage;

  /// Size of the resulting image.
  Size get size => Size(width.toDouble(), height.toDouble());

  /// Aspect ratio (width / height) of the resulting image.
  double get aspectRatio => width / (height == 0 ? 1 : height);

  /// Size in bytes of the exported data.
  int get byteLength => bytes.lengthInBytes;

  @override
  String toString() =>
      'CropResult(${width}x$height, format: $format, bytes: ${bytes.length} B, '
      'rotation: $rotation°, flipH: $isFlippedHorizontal, flipV: $isFlippedVertical)';
}
