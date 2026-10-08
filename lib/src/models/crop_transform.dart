import 'dart:math' as math;
import 'package:flutter/widgets.dart';

/// Immutable representation of the 2D transform applied to an image during cropping.
///
/// Encapsulates translation [offset], [scale] factor, [rotationDegrees],
/// and horizontal/vertical flipping.
@immutable
class CropTransform {
  /// Creates a [CropTransform] with the given transform parameters.
  const CropTransform({
    this.offset = Offset.zero,
    this.scale = 1.0,
    this.rotationDegrees = 0.0,
    this.isFlippedHorizontal = false,
    this.isFlippedVertical = false,
  });

  /// Identity transform with no offset, scale of 1.0, and 0 rotation.
  static const CropTransform identity = CropTransform();

  /// The pan translation offset in logical pixels.
  final Offset offset;

  /// The zoom scale multiplier. A value of 1.0 indicates default scale.
  final double scale;

  /// The rotation in degrees, normalized to [0, 360).
  final double rotationDegrees;

  /// Whether the image is mirrored horizontally.
  final bool isFlippedHorizontal;

  /// Whether the image is mirrored vertically.
  final bool isFlippedVertical;

  /// The rotation in radians.
  double get rotationRadians => rotationDegrees * (math.pi / 180.0);

  /// Creates a copy of this transform with modified values.
  CropTransform copyWith({
    Offset? offset,
    double? scale,
    double? rotationDegrees,
    bool? isFlippedHorizontal,
    bool? isFlippedVertical,
  }) {
    return CropTransform(
      offset: offset ?? this.offset,
      scale: scale ?? this.scale,
      rotationDegrees: rotationDegrees ?? this.rotationDegrees,
      isFlippedHorizontal: isFlippedHorizontal ?? this.isFlippedHorizontal,
      isFlippedVertical: isFlippedVertical ?? this.isFlippedVertical,
    );
  }

  /// Converts this transform into a Flutter [Matrix4] matrix around a specified [origin].
  Matrix4 toMatrix4([Offset origin = Offset.zero]) {
    final matrix = Matrix4.identity();
    if (origin != Offset.zero) {
      matrix.multiply(Matrix4.translationValues(origin.dx, origin.dy, 0.0));
    }

    matrix.multiply(Matrix4.translationValues(offset.dx, offset.dy, 0.0));

    if (rotationDegrees != 0.0) {
      matrix.multiply(Matrix4.rotationZ(rotationRadians));
    }

    final sx = (isFlippedHorizontal ? -1.0 : 1.0) * scale;
    final sy = (isFlippedVertical ? -1.0 : 1.0) * scale;
    matrix.multiply(Matrix4.diagonal3Values(sx, sy, 1.0));

    if (origin != Offset.zero) {
      matrix.multiply(Matrix4.translationValues(-origin.dx, -origin.dy, 0.0));
    }

    return matrix;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CropTransform &&
        other.offset == offset &&
        other.scale == scale &&
        other.rotationDegrees == rotationDegrees &&
        other.isFlippedHorizontal == isFlippedHorizontal &&
        other.isFlippedVertical == isFlippedVertical;
  }

  @override
  int get hashCode => Object.hash(
        offset,
        scale,
        rotationDegrees,
        isFlippedHorizontal,
        isFlippedVertical,
      );

  @override
  String toString() =>
      'CropTransform(offset: $offset, scale: $scale, rotation: $rotationDegrees°, '
      'flipH: $isFlippedHorizontal, flipV: $isFlippedVertical)';
}
