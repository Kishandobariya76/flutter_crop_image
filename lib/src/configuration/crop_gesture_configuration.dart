import 'package:flutter/widgets.dart';

/// Configuration options for touch gestures, pinch-zoom, and boundary constraints.
@immutable
class CropGestureConfiguration {
  /// Creates a [CropGestureConfiguration].
  const CropGestureConfiguration({
    this.enablePan = true,
    this.enableZoom = true,
    this.enableRotationGesture = false,
    this.enableDoubleTapZoom = true,
    this.doubleTapZoomFactor = 2.0,
    this.minZoom = 1.0,
    this.maxZoom = 8.0,
    this.initialZoom = 1.0,
    this.zoomStep = 0.5,
  })  : assert(minZoom > 0, 'minZoom must be greater than zero'),
        assert(maxZoom >= minZoom,
            'maxZoom must be greater than or equal to minZoom'),
        assert(initialZoom >= minZoom && initialZoom <= maxZoom,
            'initialZoom must be within [minZoom, maxZoom]');

  /// Whether 1-finger panning / dragging is enabled.
  final bool enablePan;

  /// Whether 2-finger pinch zooming is enabled.
  final bool enableZoom;

  /// Whether 2-finger continuous rotation gestures are enabled.
  final bool enableRotationGesture;

  /// Whether double-tapping quickly zooms in/out between minZoom and doubleTapZoomFactor.
  final bool enableDoubleTapZoom;

  /// The zoom multiplier applied on double-tap when at minZoom.
  final double doubleTapZoomFactor;

  /// Minimum allowable zoom multiplier (default 1.0).
  final double minZoom;

  /// Maximum allowable zoom multiplier (default 8.0).
  final double maxZoom;

  /// Initial zoom scale when the image is first loaded.
  final double initialZoom;

  /// Incremental step for programmatic [zoomIn] and [zoomOut] calls.
  final double zoomStep;

  /// Creates a copy with modified properties.
  CropGestureConfiguration copyWith({
    bool? enablePan,
    bool? enableZoom,
    bool? enableRotationGesture,
    bool? enableDoubleTapZoom,
    double? doubleTapZoomFactor,
    double? minZoom,
    double? maxZoom,
    double? initialZoom,
    double? zoomStep,
  }) {
    return CropGestureConfiguration(
      enablePan: enablePan ?? this.enablePan,
      enableZoom: enableZoom ?? this.enableZoom,
      enableRotationGesture:
          enableRotationGesture ?? this.enableRotationGesture,
      enableDoubleTapZoom: enableDoubleTapZoom ?? this.enableDoubleTapZoom,
      doubleTapZoomFactor: doubleTapZoomFactor ?? this.doubleTapZoomFactor,
      minZoom: minZoom ?? this.minZoom,
      maxZoom: maxZoom ?? this.maxZoom,
      initialZoom: initialZoom ?? this.initialZoom,
      zoomStep: zoomStep ?? this.zoomStep,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CropGestureConfiguration &&
        other.enablePan == enablePan &&
        other.enableZoom == enableZoom &&
        other.enableRotationGesture == enableRotationGesture &&
        other.enableDoubleTapZoom == enableDoubleTapZoom &&
        other.doubleTapZoomFactor == doubleTapZoomFactor &&
        other.minZoom == minZoom &&
        other.maxZoom == maxZoom &&
        other.initialZoom == initialZoom &&
        other.zoomStep == zoomStep;
  }

  @override
  int get hashCode => Object.hash(
        enablePan,
        enableZoom,
        enableRotationGesture,
        enableDoubleTapZoom,
        doubleTapZoomFactor,
        minZoom,
        maxZoom,
        initialZoom,
        zoomStep,
      );
}
