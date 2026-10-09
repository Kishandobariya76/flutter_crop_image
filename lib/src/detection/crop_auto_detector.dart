import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import '../configuration/crop_aspect_ratio.dart';
import '../models/crop_rect.dart';

/// Represents a document detected in an image.
@immutable
class DetectedDocument {
  /// Creates a [DetectedDocument].
  const DetectedDocument({
    required this.normalizedRect,
    required this.confidence,
    this.matchedRatio,
    this.label = 'Document',
  }) : assert(
          confidence >= 0.0 && confidence <= 1.0,
          'Confidence must be between 0.0 and 1.0',
        );

  /// The normalized bounding rectangle of the detected document (values between 0.0 and 1.0).
  final CropRect normalizedRect;

  /// Detection confidence score between 0.0 and 1.0.
  final double confidence;

  /// Optional matched standard aspect ratio (e.g., [CropAspectRatio.idCard]).
  final CropAspectRatio? matchedRatio;

  /// Human-readable label for the detected document type (e.g. "ID Card (Aadhar)").
  final String label;

  /// Converts the normalized rectangle into absolute pixel bounds for a given image size.
  ui.Rect toPixelRect(ui.Size imageSize) {
    return ui.Rect.fromLTRB(
      normalizedRect.left * imageSize.width,
      normalizedRect.top * imageSize.height,
      normalizedRect.right * imageSize.width,
      normalizedRect.bottom * imageSize.height,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DetectedDocument &&
        other.normalizedRect == normalizedRect &&
        (other.confidence - confidence).abs() < 0.001 &&
        other.matchedRatio == matchedRatio &&
        other.label == label;
  }

  @override
  int get hashCode =>
      Object.hash(normalizedRect, confidence, matchedRatio, label);

  @override
  String toString() =>
      'DetectedDocument($label, confidence: ${(confidence * 100).toStringAsFixed(1)}%, rect: $normalizedRect)';
}

/// Abstract contract for automatic document and edge detection engines.
///
/// Implement this interface to plug in custom computer vision, OpenCV,
/// or platform ML engines (e.g. Google ML Kit, Apple Vision).
abstract class CropAutoDetector {
  /// Const constructor for subclasses.
  const CropAutoDetector();

  /// Analyzes the [image] and returns the detected document bounds,
  /// or `null` if no document or distinct boundary could be recognized.
  Future<DetectedDocument?> detect(ui.Image image);
}
