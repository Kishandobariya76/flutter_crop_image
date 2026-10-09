import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import '../configuration/crop_aspect_ratio.dart';
import '../models/crop_rect.dart';
import 'crop_auto_detector.dart';

/// Pure-Dart hardware-friendly document and ID card boundary detector.
///
/// Analyzes image contrast, edge gradients, and contour distributions
/// using fast downsampled pixel matrices without requiring native C++ or ML libraries.
class NativeDocumentDetector extends CropAutoDetector {
  /// Creates a [NativeDocumentDetector].
  const NativeDocumentDetector({
    this.maxAnalysisDimension = 240,
    this.edgeSensitivity = 28.0,
    this.minDocumentAreaFraction = 0.05,
    this.maxDocumentAreaFraction = 0.98,
  });

  /// The maximum pixel width/height to downsample to for analysis.
  /// Keeping this at ~240 ensures sub-30ms performance on all mobile devices.
  final int maxAnalysisDimension;

  /// Luminance gradient threshold to recognize a distinct edge boundary.
  final double edgeSensitivity;

  /// Minimum fraction of the image area the document must occupy to be recognized.
  final double minDocumentAreaFraction;

  /// Maximum fraction of the image area the document must occupy to be recognized.
  final double maxDocumentAreaFraction;

  @override
  Future<DetectedDocument?> detect(ui.Image image) async {
    final int origW = image.width;
    final int origH = image.height;
    if (origW <= 0 || origH <= 0) return null;

    // 1. Calculate downscaled dimensions preserving aspect ratio
    final double scale =
        math.min(maxAnalysisDimension / origW, maxAnalysisDimension / origH);
    final int targetW = math.max(16, (origW * scale).round());
    final int targetH = math.max(16, (origH * scale).round());

    // 2. Render downsampled image via PictureRecorder
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    canvas.drawImageRect(
      image,
      ui.Rect.fromLTWH(0, 0, origW.toDouble(), origH.toDouble()),
      ui.Rect.fromLTWH(0, 0, targetW.toDouble(), targetH.toDouble()),
      ui.Paint()..filterQuality = ui.FilterQuality.low,
    );
    final picture = recorder.endRecording();
    final downscaled = await picture.toImage(targetW, targetH);
    picture.dispose();

    // 3. Extract raw RGBA bytes
    final ByteData? byteData = await downscaled.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    );
    downscaled.dispose();

    if (byteData == null) return null;
    final Uint8List pixels = byteData.buffer.asUint8List();

    // 4. Compute Luminance Matrix (Y = 0.299R + 0.587G + 0.114B)
    final Float32List lum = Float32List(targetW * targetH);
    for (int y = 0; y < targetH; y++) {
      final int rowOffset = y * targetW;
      for (int x = 0; x < targetW; x++) {
        final int pxIndex = (rowOffset + x) * 4;
        final int r = pixels[pxIndex];
        final int g = pixels[pxIndex + 1];
        final int b = pixels[pxIndex + 2];
        lum[rowOffset + x] = 0.299 * r + 0.587 * g + 0.114 * b;
      }
    }

    // 5. Compute Sobel Gradient Magnitudes
    final Float32List grad = Float32List(targetW * targetH);
    double totalGrad = 0.0;
    int edgeCount = 0;

    for (int y = 1; y < targetH - 1; y++) {
      for (int x = 1; x < targetW - 1; x++) {
        // Horizontal Sobel kernel
        final double gx = (lum[(y - 1) * targetW + (x + 1)] +
                2.0 * lum[y * targetW + (x + 1)] +
                lum[(y + 1) * targetW + (x + 1)]) -
            (lum[(y - 1) * targetW + (x - 1)] +
                2.0 * lum[y * targetW + (x - 1)] +
                lum[(y + 1) * targetW + (x - 1)]);

        // Vertical Sobel kernel
        final double gy = (lum[(y + 1) * targetW + (x - 1)] +
                2.0 * lum[(y + 1) * targetW + x] +
                lum[(y + 1) * targetW + (x + 1)]) -
            (lum[(y - 1) * targetW + (x - 1)] +
                2.0 * lum[(y - 1) * targetW + x] +
                lum[(y - 1) * targetW + (x + 1)]);

        final double mag = math.sqrt(gx * gx + gy * gy);
        grad[y * targetW + x] = mag;
        totalGrad += mag;
        if (mag > edgeSensitivity) edgeCount++;
      }
    }

    final double avgGrad = totalGrad / (targetW * targetH);
    // If image has virtually no contrast or edges, no document is found
    if (avgGrad < 3.0 || edgeCount < 10) {
      return null;
    }

    // 6. Project gradients along X and Y axes
    final Float32List colEnergy = Float32List(targetW);
    final Float32List rowEnergy = Float32List(targetH);

    for (int y = 0; y < targetH; y++) {
      for (int x = 0; x < targetW; x++) {
        final double g = grad[y * targetW + x];
        if (g > edgeSensitivity) {
          colEnergy[x] += g;
          rowEnergy[y] += g;
        }
      }
    }

    // 7. Find document bounds using cumulative energy thresholds
    // Ignore outer 2% margin to eliminate lens/vignette or border noise
    final int marginX = math.max(1, (targetW * 0.02).round());
    final int marginY = math.max(1, (targetH * 0.02).round());

    double maxCol = 0.0;
    for (int x = marginX; x < targetW - marginX; x++) {
      if (colEnergy[x] > maxCol) maxCol = colEnergy[x];
    }

    double maxRow = 0.0;
    for (int y = marginY; y < targetH - marginY; y++) {
      if (rowEnergy[y] > maxRow) maxRow = rowEnergy[y];
    }

    if (maxCol < 1.0 || maxRow < 1.0) return null;

    final double colThreshold = maxCol * 0.20;
    final double rowThreshold = maxRow * 0.20;

    int left = marginX;
    while (left < targetW - marginX && colEnergy[left] < colThreshold) {
      left++;
    }

    int right = targetW - marginX - 1;
    while (right > left && colEnergy[right] < colThreshold) {
      right--;
    }

    int top = marginY;
    while (top < targetH - marginY && rowEnergy[top] < rowThreshold) {
      top++;
    }

    int bottom = targetH - marginY - 1;
    while (bottom > top && rowEnergy[bottom] < rowThreshold) {
      bottom--;
    }

    final int docW = right - left;
    final int docH = bottom - top;
    final double areaFraction = (docW * docH) / (targetW * targetH);

    if (docW < targetW * 0.15 ||
        docH < targetH * 0.15 ||
        areaFraction < minDocumentAreaFraction ||
        areaFraction > maxDocumentAreaFraction) {
      return null;
    }

    // 8. Aspect Ratio Matching & Classification
    final double docRatio = docW / docH;
    CropAspectRatio? matchedRatio;
    String label = 'Document';

    // Aadhar / ID-1 Card ratio ~ 1.586 landscape or ~ 0.630 portrait
    if ((docRatio - 1.586).abs() <= 0.20 || (docRatio - 0.630).abs() <= 0.10) {
      matchedRatio = CropAspectRatio.idCard;
      label = 'ID Card (Aadhar)';
    }
    // A4 Document ratio ~ 1.414 landscape or ~ 0.707 portrait
    else if ((docRatio - 1.414).abs() <= 0.15 ||
        (docRatio - 0.707).abs() <= 0.09) {
      matchedRatio = CropAspectRatio.a4;
      label = 'A4 Document';
    }
    // Square document ~ 1.0
    else if ((docRatio - 1.0).abs() <= 0.10) {
      matchedRatio = CropAspectRatio.square;
      label = 'Square Document';
    }

    // 9. Compute Confidence Score based on edge concentration
    double internalEnergy = 0.0;
    for (int y = top; y <= bottom; y++) {
      for (int x = left; x <= right; x++) {
        internalEnergy += grad[y * targetW + x];
      }
    }
    final double confidence =
        math.min(0.99, math.max(0.65, internalEnergy / (totalGrad + 1e-5)));

    // 10. Normalize coordinates (0.0 to 1.0)
    final double normLeft = (left / targetW).clamp(0.0, 0.95);
    final double normTop = (top / targetH).clamp(0.0, 0.95);
    final double normRight = (right / targetW).clamp(normLeft + 0.05, 1.0);
    final double normBottom = (bottom / targetH).clamp(normTop + 0.05, 1.0);

    final cropRect = CropRect(
      left: normLeft,
      top: normTop,
      right: normRight,
      bottom: normBottom,
    );

    return DetectedDocument(
      normalizedRect: cropRect,
      confidence: confidence,
      matchedRatio: matchedRatio,
      label: label,
    );
  }
}
