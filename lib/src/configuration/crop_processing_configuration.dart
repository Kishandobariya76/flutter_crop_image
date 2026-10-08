import 'package:flutter/widgets.dart';

/// Memory and raster processing performance safeguards.
@immutable
class CropProcessingConfiguration {
  /// Creates a [CropProcessingConfiguration].
  const CropProcessingConfiguration({
    this.maxProcessingDimension = 4096,
    this.enableAntialiasing = true,
  }) : assert(maxProcessingDimension > 0,
            'maxProcessingDimension must be positive');

  /// Maximum allowed pixel dimension (width or height) during export processing.
  ///
  /// Prevents GPU texture memory overflow or OOM errors on extreme resolution images (e.g., 8K or 12K).
  final int maxProcessingDimension;

  /// Whether high-quality anti-aliasing is applied when drawing transformed textures.
  final bool enableAntialiasing;

  /// Creates a copy with modified properties.
  CropProcessingConfiguration copyWith({
    int? maxProcessingDimension,
    bool? enableAntialiasing,
  }) {
    return CropProcessingConfiguration(
      maxProcessingDimension:
          maxProcessingDimension ?? this.maxProcessingDimension,
      enableAntialiasing: enableAntialiasing ?? this.enableAntialiasing,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CropProcessingConfiguration &&
        other.maxProcessingDimension == maxProcessingDimension &&
        other.enableAntialiasing == enableAntialiasing;
  }

  @override
  int get hashCode => Object.hash(maxProcessingDimension, enableAntialiasing);
}
