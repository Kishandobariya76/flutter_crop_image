import 'package:flutter/widgets.dart';
import 'crop_shape.dart';

/// Configuration options for the cropping window overlay, border, and resize handles.
@immutable
class CropOverlayConfiguration {
  /// Creates a [CropOverlayConfiguration].
  const CropOverlayConfiguration({
    this.overlayColor = const Color(0xB3000000), // ~70% black
    this.borderColor = const Color(0xFFFFFFFF),
    this.borderWidth = 1.5,
    this.cornerRadius = 0.0,
    this.showHandles = true,
    this.handleColor = const Color(0xFFFFFFFF),
    this.handleSize = 22.0,
    this.handleWidth = 3.5,
    this.shape = CropShape.rectangle,
    this.clipBehavior = Clip.antiAlias,
  });

  /// Background color that dims the image area outside the crop window.
  final Color overlayColor;

  /// Border color outlining the active crop window.
  final Color borderColor;

  /// Stroke width of the crop border.
  final double borderWidth;

  /// Corner radius for [CropShape.roundedRectangle].
  final double cornerRadius;

  /// Whether interactive corner handles are displayed.
  final bool showHandles;

  /// Color of the corner resize handles.
  final Color handleColor;

  /// Length of each handle line segment in logical pixels.
  final double handleSize;

  /// Stroke thickness of the corner handles.
  final double handleWidth;

  /// Geometric shape of the crop overlay window.
  final CropShape shape;

  /// Anti-aliasing clip behavior for custom shapes.
  final Clip clipBehavior;

  /// Creates a copy with modified properties.
  CropOverlayConfiguration copyWith({
    Color? overlayColor,
    Color? borderColor,
    double? borderWidth,
    double? cornerRadius,
    bool? showHandles,
    Color? handleColor,
    double? handleSize,
    double? handleWidth,
    CropShape? shape,
    Clip? clipBehavior,
  }) {
    return CropOverlayConfiguration(
      overlayColor: overlayColor ?? this.overlayColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      showHandles: showHandles ?? this.showHandles,
      handleColor: handleColor ?? this.handleColor,
      handleSize: handleSize ?? this.handleSize,
      handleWidth: handleWidth ?? this.handleWidth,
      shape: shape ?? this.shape,
      clipBehavior: clipBehavior ?? this.clipBehavior,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CropOverlayConfiguration &&
        other.overlayColor == overlayColor &&
        other.borderColor == borderColor &&
        other.borderWidth == borderWidth &&
        other.cornerRadius == cornerRadius &&
        other.showHandles == showHandles &&
        other.handleColor == handleColor &&
        other.handleSize == handleSize &&
        other.handleWidth == handleWidth &&
        other.shape == shape &&
        other.clipBehavior == clipBehavior;
  }

  @override
  int get hashCode => Object.hash(
        overlayColor,
        borderColor,
        borderWidth,
        cornerRadius,
        showHandles,
        handleColor,
        handleSize,
        handleWidth,
        shape,
        clipBehavior,
      );
}
