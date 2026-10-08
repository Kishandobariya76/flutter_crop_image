import 'package:flutter/widgets.dart';
import '../models/crop_image_format.dart';

/// Configuration options for exporting the cropped image result.
@immutable
class CropExportConfiguration {
  /// Creates a [CropExportConfiguration].
  const CropExportConfiguration({
    this.format = CropImageFormat.png,
    this.quality = 90,
    this.targetSize,
    this.maintainTransparency = true,
    this.backgroundColor = const Color(0xFFFFFFFF),
  }) : assert(quality >= 1 && quality <= 100,
            'Quality must be between 1 and 100');

  /// Target encoding format for the exported image.
  final CropImageFormat format;

  /// Compression quality from 1 to 100 (where applicable).
  final int quality;

  /// Optional target size to resize the cropped image to upon export.
  final Size? targetSize;

  /// Whether to maintain alpha channel transparency for circular/oval shapes.
  final bool maintainTransparency;

  /// Fallback background fill color if the format does not support transparency (e.g. JPEG).
  final Color backgroundColor;

  /// Creates a copy with modified properties.
  CropExportConfiguration copyWith({
    CropImageFormat? format,
    int? quality,
    Size? targetSize,
    bool? maintainTransparency,
    Color? backgroundColor,
  }) {
    return CropExportConfiguration(
      format: format ?? this.format,
      quality: quality ?? this.quality,
      targetSize: targetSize ?? this.targetSize,
      maintainTransparency: maintainTransparency ?? this.maintainTransparency,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CropExportConfiguration &&
        other.format == format &&
        other.quality == quality &&
        other.targetSize == targetSize &&
        other.maintainTransparency == maintainTransparency &&
        other.backgroundColor == backgroundColor;
  }

  @override
  int get hashCode => Object.hash(
        format,
        quality,
        targetSize,
        maintainTransparency,
        backgroundColor,
      );
}
