import 'package:flutter/foundation.dart';

/// Defines an aspect ratio constraint for the cropping window.
@immutable
class CropAspectRatio {
  /// Creates a [CropAspectRatio] with optional [width] and [height] proportions.
  ///
  /// If [width] or [height] is null, the aspect ratio is considered unconstrained ("Free").
  const CropAspectRatio({
    this.width,
    this.height,
    this.label,
  });

  /// Creates a custom aspect ratio with explicit numeric width and height.
  factory CropAspectRatio.custom(double width, double height, {String? label}) {
    assert(width > 0, 'Width must be greater than zero');
    assert(height > 0, 'Height must be greater than zero');
    return CropAspectRatio(
      width: width,
      height: height,
      label: label ??
          '${width.toStringAsFixed(width.truncateToDouble() == width ? 0 : 1)}:${height.toStringAsFixed(height.truncateToDouble() == height ? 0 : 1)}',
    );
  }

  /// Creates a [CropAspectRatio] from a floating point ratio value (width / height).
  factory CropAspectRatio.ratio(double ratio, {String? label}) {
    assert(ratio > 0, 'Ratio must be greater than zero');
    return CropAspectRatio(
      width: ratio,
      height: 1.0,
      label: label ?? ratio.toStringAsFixed(2),
    );
  }

  /// Freeform aspect ratio where the user can resize bounds freely.
  static const CropAspectRatio free = CropAspectRatio(
    width: null,
    height: null,
    label: 'Free',
  );

  /// 1:1 square aspect ratio.
  static const CropAspectRatio square = CropAspectRatio(
    width: 1.0,
    height: 1.0,
    label: '1:1',
  );

  /// 4:3 standard landscape ratio.
  static const CropAspectRatio ratio4x3 = CropAspectRatio(
    width: 4.0,
    height: 3.0,
    label: '4:3',
  );

  /// 3:4 portrait ratio.
  static const CropAspectRatio ratio3x4 = CropAspectRatio(
    width: 3.0,
    height: 4.0,
    label: '3:4',
  );

  /// 16:9 widescreen landscape ratio.
  static const CropAspectRatio ratio16x9 = CropAspectRatio(
    width: 16.0,
    height: 9.0,
    label: '16:9',
  );

  /// 9:16 vertical video / story ratio.
  static const CropAspectRatio ratio9x16 = CropAspectRatio(
    width: 9.0,
    height: 16.0,
    label: '9:16',
  );

  /// 3:2 classic photo landscape ratio.
  static const CropAspectRatio ratio3x2 = CropAspectRatio(
    width: 3.0,
    height: 2.0,
    label: '3:2',
  );

  /// 2:3 classic photo portrait ratio.
  static const CropAspectRatio ratio2x3 = CropAspectRatio(
    width: 2.0,
    height: 3.0,
    label: '2:3',
  );

  /// Standard ISO/IEC 7810 ID-1 card ratio (85.60 mm x 53.98 mm ≈ 1.586).
  /// Used for Aadhar card, PAN card, Driver's License, Credit/Debit cards.
  static const CropAspectRatio idCard = CropAspectRatio(
    width: 85.60,
    height: 53.98,
    label: 'ID Card (Aadhar)',
  );

  /// Standard ISO 216 A4 document ratio (297 mm x 210 mm ≈ 1.414).
  static const CropAspectRatio a4 = CropAspectRatio(
    width: 297.0,
    height: 210.0,
    label: 'A4 Document',
  );

  /// Standard passport photo ratio (35 mm x 45 mm ≈ 0.778 portrait).
  static const CropAspectRatio passport = CropAspectRatio(
    width: 35.0,
    height: 45.0,
    label: 'Passport',
  );

  /// Default list of aspect ratio presets.
  static const List<CropAspectRatio> presets = [
    free,
    square,
    ratio4x3,
    ratio3x4,
    ratio16x9,
    ratio9x16,
    ratio3x2,
    ratio2x3,
    idCard,
    a4,
  ];

  /// Relative width component.
  final double? width;

  /// Relative height component.
  final double? height;

  /// Optional display label for UI buttons (e.g., "16:9", "Square").
  final String? label;

  /// Floating point ratio (width / height), or null if [isFree].
  double? get ratio {
    if (width != null && height != null && height! > 0) {
      return width! / height!;
    }
    return null;
  }

  /// Whether this aspect ratio is unconstrained (freeform).
  bool get isFree => ratio == null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CropAspectRatio &&
        other.width == width &&
        other.height == height &&
        other.label == label;
  }

  @override
  int get hashCode => Object.hash(width, height, label);

  @override
  String toString() => label ?? (isFree ? 'Free' : '$width:$height');
}
