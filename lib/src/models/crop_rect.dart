import 'package:flutter/widgets.dart';

/// Represents a normalized crop rectangle within a bounding viewport.
///
/// Normalized values [left], [top], [right], [bottom] range from `0.0` to `1.0`.
@immutable
class CropRect {
  /// Creates a normalized [CropRect].
  const CropRect({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  })  : assert(left >= 0.0 && left <= 1.0, 'left must be between 0.0 and 1.0'),
        assert(top >= 0.0 && top <= 1.0, 'top must be between 0.0 and 1.0'),
        assert(
            right >= 0.0 && right <= 1.0, 'right must be between 0.0 and 1.0'),
        assert(bottom >= 0.0 && bottom <= 1.0,
            'bottom must be between 0.0 and 1.0'),
        assert(left < right, 'left must be strictly less than right'),
        assert(top < bottom, 'top must be strictly less than bottom');

  /// Creates a [CropRect] from standard [Rect] and container [size].
  factory CropRect.fromRect(Rect rect, Size size) {
    assert(
        size.width > 0 && size.height > 0, 'Container size must be positive');
    final left = (rect.left / size.width).clamp(0.0, 1.0);
    final top = (rect.top / size.height).clamp(0.0, 1.0);
    final right = (rect.right / size.width).clamp(0.0, 1.0);
    final bottom = (rect.bottom / size.height).clamp(0.0, 1.0);

    return CropRect(
      left: left < right ? left : 0.0,
      top: top < bottom ? top : 0.0,
      right: right > left ? right : 1.0,
      bottom: bottom > top ? bottom : 1.0,
    );
  }

  /// Full crop window covering the entire container.
  static const CropRect full = CropRect(
    left: 0.0,
    top: 0.0,
    right: 1.0,
    bottom: 1.0,
  );

  /// Normalized left coordinate [0.0, 1.0].
  final double left;

  /// Normalized top coordinate [0.0, 1.0].
  final double top;

  /// Normalized right coordinate [0.0, 1.0].
  final double right;

  /// Normalized bottom coordinate [0.0, 1.0].
  final double bottom;

  /// Normalized width of the crop rect.
  double get width => right - left;

  /// Normalized height of the crop rect.
  double get height => bottom - top;

  /// Normalized aspect ratio (width / height).
  double get aspectRatio => width / height;

  /// Denormalizes this [CropRect] into absolute logical pixels given [size].
  Rect toRect(Size size) {
    return Rect.fromLTRB(
      left * size.width,
      top * size.height,
      right * size.width,
      bottom * size.height,
    );
  }

  /// Creates a copy with optionally modified bounds.
  CropRect copyWith({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return CropRect(
      left: left ?? this.left,
      top: top ?? this.top,
      right: right ?? this.right,
      bottom: bottom ?? this.bottom,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CropRect &&
        other.left == left &&
        other.top == top &&
        other.right == right &&
        other.bottom == bottom;
  }

  @override
  int get hashCode => Object.hash(left, top, right, bottom);

  @override
  String toString() =>
      'CropRect(l: ${left.toStringAsFixed(3)}, t: ${top.toStringAsFixed(3)}, '
      'r: ${right.toStringAsFixed(3)}, b: ${bottom.toStringAsFixed(3)})';
}
