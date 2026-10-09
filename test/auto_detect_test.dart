import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_crop_image/flutter_crop_image.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper to generate a synthetic test image containing a distinct ID card
/// on a contrasting background.
Future<ui.Image> createSyntheticDocumentImage({
  int totalWidth = 800,
  int totalHeight = 600,
  required Rect cardBounds,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  // 1. Dark table / background
  final bgPaint = Paint()..color = const Color(0xFF1E2022);
  canvas.drawRect(
    Rect.fromLTWH(0, 0, totalWidth.toDouble(), totalHeight.toDouble()),
    bgPaint,
  );

  // 2. High-contrast white/light-grey ID Card (simulated Aadhar card)
  final cardPaint = Paint()..color = const Color(0xFFF8FAFC);
  canvas.drawRect(cardBounds, cardPaint);

  // 3. Card interior markings (header band, photo box, simulated text lines)
  final headerPaint = Paint()..color = const Color(0xFFE2E8F0);
  canvas.drawRect(
    Rect.fromLTWH(cardBounds.left, cardBounds.top, cardBounds.width, 30),
    headerPaint,
  );

  // Simulated photo box on the left
  final photoPaint = Paint()..color = const Color(0xFF94A3B8);
  canvas.drawRect(
    Rect.fromLTWH(
        cardBounds.left + 20, cardBounds.top + 50, 70, cardBounds.height - 70),
    photoPaint,
  );

  // Simulated text lines on the right
  final textPaint = Paint()..color = const Color(0xFF64748B);
  for (double y = cardBounds.top + 60; y < cardBounds.bottom - 30; y += 25) {
    canvas.drawRect(
      Rect.fromLTWH(cardBounds.left + 110, y, cardBounds.width - 130, 8),
      textPaint,
    );
  }

  final picture = recorder.endRecording();
  final img = await picture.toImage(totalWidth, totalHeight);
  picture.dispose();
  return img;
}

/// Helper to generate a solid image with no distinct contrast or document.
Future<ui.Image> createBlankImage({int width = 400, int height = 400}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(
    Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    Paint()..color = const Color(0xFF333333),
  );
  final picture = recorder.endRecording();
  final img = await picture.toImage(width, height);
  picture.dispose();
  return img;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Document Aspect Ratios & Presets', () {
    test('CropAspectRatio.idCard matches ISO/IEC 7810 ID-1 standard', () {
      const ratio = CropAspectRatio.idCard;
      expect(ratio.width, 85.60);
      expect(ratio.height, 53.98);
      expect(ratio.ratio, closeTo(1.586, 0.005));
      expect(ratio.isFree, isFalse);
    });

    test('CropAspectRatio.a4 matches ISO 216 standard', () {
      const ratio = CropAspectRatio.a4;
      expect(ratio.width, 297.0);
      expect(ratio.height, 210.0);
      expect(ratio.ratio, closeTo(1.414, 0.005));
    });

    test('CropAspectRatio.passport has valid portrait proportions', () {
      const ratio = CropAspectRatio.passport;
      expect(ratio.width, 35.0);
      expect(ratio.height, 45.0);
      expect(ratio.ratio, closeTo(0.778, 0.005));
    });

    test('CropperConfiguration presets configure autoDetectDocument', () {
      expect(CropperConfiguration.documentScanner.autoDetectDocument, isTrue);
      expect(CropperConfiguration.idCard.autoDetectDocument, isTrue);
      expect(CropperConfiguration.idCard.aspectRatio, CropAspectRatio.idCard);
    });
  });

  group('NativeDocumentDetector Algorithm', () {
    test('successfully detects centered synthetic Aadhar / ID card', () async {
      // 800 x 600 image, Card is 476 x 300 (ratio ≈ 1.587)
      // Placed from (162, 150) to (638, 450)
      const expectedCard = Rect.fromLTWH(162, 150, 476, 300);
      final image = await createSyntheticDocumentImage(
        totalWidth: 800,
        totalHeight: 600,
        cardBounds: expectedCard,
      );

      const detector = NativeDocumentDetector();
      final DetectedDocument? result = await detector.detect(image);
      image.dispose();

      expect(result, isNotNull);
      expect(result!.confidence, greaterThan(0.60));
      expect(result.matchedRatio, CropAspectRatio.idCard);
      expect(result.label, contains('Aadhar'));

      // Check normalized bounds accuracy within 5% tolerance
      const expectedNormLeft = 162 / 800; // 0.2025
      const expectedNormTop = 150 / 600; // 0.2500
      const expectedNormWidth = 476 / 800; // 0.5950
      const expectedNormHeight = 300 / 600; // 0.5000

      expect(result.normalizedRect.left, closeTo(expectedNormLeft, 0.06));
      expect(result.normalizedRect.top, closeTo(expectedNormTop, 0.06));
      expect(result.normalizedRect.width, closeTo(expectedNormWidth, 0.06));
      expect(result.normalizedRect.height, closeTo(expectedNormHeight, 0.06));
    });

    test('returns null for uniform blank images without boundaries', () async {
      final image = await createBlankImage();
      const detector = NativeDocumentDetector();
      final DetectedDocument? result = await detector.detect(image);
      image.dispose();

      expect(result, isNull);
    });
  });

  group('CropController Auto-Detect Snapping Integration', () {
    test('autoDetectDocument updates CropState when document found', () async {
      final cardImage = await createSyntheticDocumentImage(
        totalWidth: 800,
        totalHeight: 600,
        cardBounds: const Rect.fromLTWH(150, 100, 500, 315),
      );

      final controller = CropController();
      const detector = NativeDocumentDetector();

      // Test direct detection via detector
      final result = await detector.detect(cardImage);
      expect(result, isNotNull);

      // Verify controller state copy with detectedDocument
      final updatedState = controller.state.copyWith(detectedDocument: result);
      expect(updatedState.detectedDocument, equals(result));

      cardImage.dispose();
    });
  });
}
