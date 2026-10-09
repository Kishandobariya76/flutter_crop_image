import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import '../configuration/crop_aspect_ratio.dart';
import '../configuration/crop_export_configuration.dart';
import '../configuration/crop_shape.dart';
import '../configuration/cropper_configuration.dart';
import '../detection/crop_auto_detector.dart';
import '../exceptions/crop_exception.dart';
import '../models/crop_image_format.dart';
import '../models/crop_rect.dart';
import '../models/crop_result.dart';
import '../models/crop_state.dart';
import '../models/crop_transform.dart';
import '../processing/crop_processor.dart';

/// Delegate interface implemented by [AdvancedCropper] to bind engine operations to [CropController].
abstract class CropEngineDelegate {
  /// Resolves the current raw decoded image.
  ui.Image? get activeImage;

  /// The viewport container bounds.
  Rect get viewportRect;

  /// The base un-transformed fitted image bounds.
  Rect get fittedImageRect;

  /// Active configuration.
  CropperConfiguration get activeConfiguration;

  /// Active crop processor.
  CropProcessor get processor;

  /// Animates transform smoothly.
  Future<void> animateTransform(
    CropTransform target, {
    Duration duration = const Duration(milliseconds: 250),
    Curve curve = Curves.easeOutCubic,
  });

  /// Recalculates and clamps crop frame to active aspect ratio.
  void updateCropWindow(Rect newRect);

  /// Animates crop window bounds smoothly.
  Future<void> animateCropWindow(
    Rect targetRect, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOutCubic,
  });
}

/// Primary controller for manipulating image cropping transformations and exporting results.
///
/// Extends [ChangeNotifier] so it can be observed via [ListenableBuilder],
/// [AnimatedBuilder], or integrated with any state management library
/// (Bloc, Riverpod, Provider, MobX, GetX) without tight coupling.
class CropController extends ChangeNotifier {
  /// Creates a [CropController] with optional initial settings.
  CropController({
    CropperConfiguration? initialConfiguration,
  })  : _configuration = initialConfiguration ?? const CropperConfiguration(),
        _state = CropState(
          cropRect: Rect.zero,
          viewRect: Rect.zero,
          normalizedCropRect: CropRect.full,
          transform: CropTransform.identity,
          aspectRatio:
              initialConfiguration?.aspectRatio ?? CropAspectRatio.free,
          shape: initialConfiguration?.shape ?? CropShape.rectangle,
          imageSize: Size.zero,
          isReady: false,
        );

  CropperConfiguration _configuration;
  CropState _state;
  CropEngineDelegate? _delegate;

  /// The active configuration.
  CropperConfiguration get configuration => _configuration;

  /// Current immutable snapshot of the cropper state.
  CropState get state => _state;

  /// Whether the cropper has decoded the source image and is ready for operations.
  bool get isReady => _state.isReady;

  /// Current zoom scale multiplier.
  double get zoom => _state.transform.scale;

  /// Current rotation angle in degrees.
  double get rotation => _state.transform.rotationDegrees;

  /// Whether the image is currently flipped horizontally.
  bool get isFlippedHorizontal => _state.transform.isFlippedHorizontal;

  /// Whether the image is currently flipped vertically.
  bool get isFlippedVertical => _state.transform.isFlippedVertical;

  /// Current aspect ratio constraint.
  CropAspectRatio get aspectRatio => _state.aspectRatio;

  /// Current geometric shape of the crop frame.
  CropShape get shape => _state.shape;

  /// Current pixel coordinates of the crop frame in viewport coordinates.
  Rect get cropRect => _state.cropRect;

  /// Normalized crop window coordinates in range `[0.0, 1.0]`.
  CropRect get normalizedCropRect => _state.normalizedCropRect;

  /// The base un-transformed image bounding rectangle in viewport coordinates.
  Rect get imageRect => _delegate?.fittedImageRect ?? Rect.zero;

  /// The container viewport bounding rectangle.
  Rect get viewRect => _state.viewRect;

  /// Intrinsic dimensions of the source image in pixels.
  Size get imageSize => _state.imageSize;

  /// Binds an engine delegate. Internal use by [AdvancedCropper].
  void attach(CropEngineDelegate delegate) {
    _delegate = delegate;
  }

  /// Detaches the active engine delegate. Internal use by [AdvancedCropper].
  void detach() {
    _delegate = null;
    _state = _state.copyWith(isReady: false);
    notifyListeners();
  }

  /// Internal update called by the engine widget when viewport or image dimensions change.
  void updateEngineState({
    required Rect cropRect,
    required Rect viewRect,
    required CropRect normalizedCropRect,
    required CropTransform transform,
    required CropAspectRatio aspectRatio,
    required CropShape shape,
    required Size imageSize,
    required bool isReady,
  }) {
    final newState = CropState(
      cropRect: cropRect,
      viewRect: viewRect,
      normalizedCropRect: normalizedCropRect,
      transform: transform,
      aspectRatio: aspectRatio,
      shape: shape,
      imageSize: imageSize,
      isReady: isReady,
    );

    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  /// Directly updates the transformation state.
  void updateTransform(CropTransform transform) {
    if (_state.transform == transform) return;
    _state = _state.copyWith(transform: transform);
    notifyListeners();
  }

  // ===========================================================================
  // ZOOM CONTROLS
  // ===========================================================================

  /// Increments the zoom scale by [step] (defaulting to gesture config step).
  void zoomIn([double? step]) {
    final s = step ?? _configuration.gestures.zoomStep;
    setZoom(zoom + s);
  }

  /// Decrements the zoom scale by [step] (defaulting to gesture config step).
  void zoomOut([double? step]) {
    final s = step ?? _configuration.gestures.zoomStep;
    setZoom(zoom - s);
  }

  /// Sets the zoom scale multiplier clamped between minZoom and maxZoom.
  void setZoom(double newZoom) {
    final clamped = newZoom.clamp(
      _configuration.gestures.minZoom,
      _configuration.gestures.maxZoom,
    );
    if (_state.transform.scale == clamped) return;
    updateTransform(_state.transform.copyWith(scale: clamped));
  }

  /// Smoothly animates the zoom scale to [targetZoom].
  Future<void> animateToZoom(
    double targetZoom, {
    Duration duration = const Duration(milliseconds: 250),
    Curve curve = Curves.easeOutCubic,
  }) async {
    final clamped = targetZoom.clamp(
      _configuration.gestures.minZoom,
      _configuration.gestures.maxZoom,
    );
    final targetTransform = _state.transform.copyWith(scale: clamped);

    if (_delegate != null) {
      await _delegate!.animateTransform(
        targetTransform,
        duration: duration,
        curve: curve,
      );
    } else {
      updateTransform(targetTransform);
    }
  }

  // ===========================================================================
  // ROTATION & FLIP CONTROLS
  // ===========================================================================

  /// Rotates the image counter-clockwise by 90 degrees.
  void rotateLeft() {
    setRotation((rotation - 90.0) % 360.0);
  }

  /// Rotates the image clockwise by 90 degrees.
  void rotateRight() {
    setRotation((rotation + 90.0) % 360.0);
  }

  /// Sets arbitrary rotation angle in degrees.
  void setRotation(double degrees) {
    final normalized = (degrees % 360.0 + 360.0) % 360.0;
    if (_state.transform.rotationDegrees == normalized) return;
    updateTransform(_state.transform.copyWith(rotationDegrees: normalized));
  }

  /// Toggles horizontal mirroring.
  void flipHorizontal() {
    updateTransform(
      _state.transform.copyWith(
        isFlippedHorizontal: !_state.transform.isFlippedHorizontal,
      ),
    );
  }

  /// Toggles vertical mirroring.
  void flipVertical() {
    updateTransform(
      _state.transform.copyWith(
        isFlippedVertical: !_state.transform.isFlippedVertical,
      ),
    );
  }

  // ===========================================================================
  // PAN & POSITION CONTROLS
  // ===========================================================================

  /// Shifts the image translation offset by [delta] logical pixels.
  void move(Offset delta) {
    if (delta == Offset.zero) return;
    updateTransform(
      _state.transform.copyWith(
        offset: _state.transform.offset + delta,
      ),
    );
  }

  /// Centers the image in the current viewport and clears pan offsets.
  void center() {
    updateTransform(_state.transform.copyWith(offset: Offset.zero));
  }

  /// Fits the image to the current crop window bounds.
  void fit() {
    center();
    setZoom(_configuration.gestures.initialZoom);
  }

  /// Resets all transformations (zoom, pan, rotation, flip) to initial defaults.
  void reset() {
    updateTransform(CropTransform(
      scale: _configuration.gestures.initialZoom,
      offset: Offset.zero,
      rotationDegrees: 0.0,
      isFlippedHorizontal: false,
      isFlippedVertical: false,
    ));
  }

  // ===========================================================================
  // ASPECT RATIO & SHAPE CONTROLS
  // ===========================================================================

  /// Updates the active crop aspect ratio constraint.
  void setAspectRatio(CropAspectRatio newAspectRatio) {
    if (_state.aspectRatio == newAspectRatio) return;
    _configuration = _configuration.copyWith(aspectRatio: newAspectRatio);
    _state = _state.copyWith(aspectRatio: newAspectRatio);
    notifyListeners();
  }

  /// Updates the active crop shape geometry.
  void setCropShape(CropShape newShape) {
    if (_state.shape == newShape) return;
    _configuration = _configuration.copyWith(shape: newShape);
    _state = _state.copyWith(shape: newShape);
    notifyListeners();
  }

  /// Updates the pixel crop window rectangle.
  void setCropRect(Rect newCropRect) {
    if (_delegate != null) {
      _delegate!.updateCropWindow(newCropRect);
    }
  }

  // ===========================================================================
  // DOCUMENT AUTO-DETECTION & SNAPPING
  // ===========================================================================

  /// Most recently detected document, if auto-detection has been executed.
  DetectedDocument? get detectedDocument => _state.detectedDocument;

  /// Runs document boundary detection on the active image using [detector] or [CropperConfiguration.detector].
  ///
  /// Updates [CropState.detectedDocument] and returns the result, or `null` if no document was detected.
  Future<DetectedDocument?> autoDetectDocument({
    CropAutoDetector? detector,
  }) async {
    final delegate = _delegate;
    if (delegate == null || !isReady || delegate.activeImage == null) {
      return null;
    }

    final activeDetector = detector ?? _configuration.detector;
    final DetectedDocument? result =
        await activeDetector.detect(delegate.activeImage!);

    if (result != null) {
      _state = _state.copyWith(detectedDocument: result);
      notifyListeners();
    }
    return result;
  }

  /// Detects document boundaries and smoothly snaps the crop frame to encircle the document.
  ///
  /// If [updateAspectRatio] is true and the document matches a known ratio (e.g. ID Card / Aadhar),
  /// the active aspect ratio constraint is updated automatically.
  ///
  /// Returns `true` if a document was recognized and snapped, or `false` otherwise.
  Future<bool> autoDetectAndSnap({
    Duration duration = const Duration(milliseconds: 350),
    Curve curve = Curves.easeOutCubic,
    CropAutoDetector? detector,
    bool updateAspectRatio = true,
  }) async {
    final delegate = _delegate;
    if (delegate == null || !isReady || delegate.activeImage == null) {
      return false;
    }

    final DetectedDocument? doc =
        await autoDetectDocument(detector: detector);
    if (doc == null) return false;

    final Rect fitted = delegate.fittedImageRect;
    final double left = fitted.left + doc.normalizedRect.left * fitted.width;
    final double top = fitted.top + doc.normalizedRect.top * fitted.height;
    final double width = doc.normalizedRect.width * fitted.width;
    final double height = doc.normalizedRect.height * fitted.height;

    final Rect targetRect = Rect.fromLTWH(left, top, width, height);

    if (updateAspectRatio && doc.matchedRatio != null) {
      setAspectRatio(doc.matchedRatio!);
    }

    if (duration > Duration.zero) {
      await delegate.animateCropWindow(
        targetRect,
        duration: duration,
        curve: curve,
      );
    } else {
      delegate.updateCropWindow(targetRect);
    }

    return true;
  }

  // ===========================================================================
  // EXPORT / CROP
  // ===========================================================================

  /// Crops the image using current transformations and returns [CropResult].
  ///
  /// Optional parameters [format], [quality], and [targetSize] override
  /// the active [CropExportConfiguration].
  Future<CropResult> crop({
    CropImageFormat? format,
    int? quality,
    Size? targetSize,
  }) async {
    final delegate = _delegate;
    if (delegate == null || !isReady || delegate.activeImage == null) {
      throw const CropException(
          'Cannot crop: Cropper is not ready or image is not loaded');
    }

    final image = delegate.activeImage!;
    final exportConfig = _configuration.export.copyWith(
      format: format,
      quality: quality,
      targetSize: targetSize,
    );

    return delegate.processor.process(
      image: image,
      cropRect: _state.cropRect,
      viewRect: _state.viewRect,
      fittedImageRect: delegate.fittedImageRect,
      transform: _state.transform,
      shape: _state.shape,
      cornerRadius: _configuration.overlay.cornerRadius,
      exportConfig: exportConfig,
      processingConfig: _configuration.processing,
    );
  }

  /// Alias for [crop].
  Future<CropResult> export({
    CropImageFormat? format,
    int? quality,
    Size? targetSize,
  }) =>
      crop(format: format, quality: quality, targetSize: targetSize);
}
