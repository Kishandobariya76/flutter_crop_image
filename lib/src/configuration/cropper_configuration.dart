import 'package:flutter/foundation.dart';
import '../detection/crop_auto_detector.dart';
import '../detection/native_document_detector.dart';
import 'crop_aspect_ratio.dart';
import 'crop_export_configuration.dart';
import 'crop_gesture_configuration.dart';
import 'crop_grid_configuration.dart';
import 'crop_overlay_configuration.dart';
import 'crop_processing_configuration.dart';
import 'crop_shape.dart';

/// Top-level immutable configuration for [AdvancedCropper].
@immutable
class CropperConfiguration {
  /// Creates a [CropperConfiguration].
  const CropperConfiguration({
    this.aspectRatio = CropAspectRatio.free,
    this.shape = CropShape.rectangle,
    this.overlay = const CropOverlayConfiguration(),
    this.grid = const CropGridConfiguration(),
    this.gestures = const CropGestureConfiguration(),
    this.export = const CropExportConfiguration(),
    this.processing = const CropProcessingConfiguration(),
    this.aspectRatios = CropAspectRatio.presets,
    this.autoDetectDocument = false,
    this.detector = const NativeDocumentDetector(),
  });

  /// The active aspect ratio constraint.
  final CropAspectRatio aspectRatio;

  /// The geometric crop shape cutout.
  final CropShape shape;

  /// Overlay and frame border styling.
  final CropOverlayConfiguration overlay;

  /// Alignment grid settings.
  final CropGridConfiguration grid;

  /// Gesture and zoom bounds configuration.
  final CropGestureConfiguration gestures;

  /// Export format and quality options.
  final CropExportConfiguration export;

  /// Raster memory safeguards.
  final CropProcessingConfiguration processing;

  /// Supported aspect ratio presets offered to the user in toolbars.
  final List<CropAspectRatio> aspectRatios;

  /// Whether to automatically run document/card boundary detection and snap the crop frame on initial image load.
  final bool autoDetectDocument;

  /// Document detection engine to use when [autoDetectDocument] is active or when requested programmatically.
  final CropAutoDetector detector;

  /// Convenient preset for circular profile pictures (1:1 aspect ratio, circle shape).
  static const CropperConfiguration profilePhoto = CropperConfiguration(
    aspectRatio: CropAspectRatio.square,
    shape: CropShape.circle,
    grid: CropGridConfiguration(showGrid: false),
    aspectRatios: [CropAspectRatio.square],
  );

  /// Convenient preset for Instagram 1:1 square posts.
  static const CropperConfiguration instagramSquare = CropperConfiguration(
    aspectRatio: CropAspectRatio.square,
    shape: CropShape.rectangle,
    aspectRatios: [CropAspectRatio.square],
  );

  /// Convenient preset for Instagram / TikTok / Snapchat 9:16 stories.
  static const CropperConfiguration story = CropperConfiguration(
    aspectRatio: CropAspectRatio.ratio9x16,
    shape: CropShape.rectangle,
    aspectRatios: [CropAspectRatio.ratio9x16],
  );

  /// Convenient preset for YouTube / landscape 16:9 thumbnails.
  static const CropperConfiguration landscape16x9 = CropperConfiguration(
    aspectRatio: CropAspectRatio.ratio16x9,
    shape: CropShape.rectangle,
    aspectRatios: [CropAspectRatio.ratio16x9],
  );

  /// Convenient preset for scanning and auto-cropping general documents (A4, contracts, receipts).
  static const CropperConfiguration documentScanner = CropperConfiguration(
    autoDetectDocument: true,
    aspectRatio: CropAspectRatio.free,
    aspectRatios: [
      CropAspectRatio.free,
      CropAspectRatio.a4,
      CropAspectRatio.idCard,
      CropAspectRatio.square,
    ],
  );

  /// Convenient preset for scanning and auto-cropping ID cards (Aadhar, PAN, Driver's License).
  static const CropperConfiguration idCard = CropperConfiguration(
    autoDetectDocument: true,
    aspectRatio: CropAspectRatio.idCard,
    aspectRatios: [
      CropAspectRatio.idCard,
      CropAspectRatio.free,
    ],
  );

  /// Creates a copy with modified properties.
  CropperConfiguration copyWith({
    CropAspectRatio? aspectRatio,
    CropShape? shape,
    CropOverlayConfiguration? overlay,
    CropGridConfiguration? grid,
    CropGestureConfiguration? gestures,
    CropExportConfiguration? export,
    CropProcessingConfiguration? processing,
    List<CropAspectRatio>? aspectRatios,
    bool? autoDetectDocument,
    CropAutoDetector? detector,
  }) {
    return CropperConfiguration(
      aspectRatio: aspectRatio ?? this.aspectRatio,
      shape: shape ?? this.shape,
      overlay: overlay ?? this.overlay,
      grid: grid ?? this.grid,
      gestures: gestures ?? this.gestures,
      export: export ?? this.export,
      processing: processing ?? this.processing,
      aspectRatios: aspectRatios ?? this.aspectRatios,
      autoDetectDocument: autoDetectDocument ?? this.autoDetectDocument,
      detector: detector ?? this.detector,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CropperConfiguration &&
        other.aspectRatio == aspectRatio &&
        other.shape == shape &&
        other.overlay == overlay &&
        other.grid == grid &&
        other.gestures == gestures &&
        other.export == export &&
        other.processing == processing &&
        other.autoDetectDocument == autoDetectDocument &&
        other.detector == detector &&
        listEquals(other.aspectRatios, aspectRatios);
  }

  @override
  int get hashCode => Object.hash(
        aspectRatio,
        shape,
        overlay,
        grid,
        gestures,
        export,
        processing,
        autoDetectDocument,
        detector,
        Object.hashAll(aspectRatios),
      );
}
