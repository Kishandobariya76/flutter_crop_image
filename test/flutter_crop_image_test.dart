import 'package:flutter/widgets.dart';
import 'package:flutter_crop_image/flutter_crop_image.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CropTransform Tests', () {
    test('Identity transform has default values', () {
      const transform = CropTransform.identity;
      expect(transform.offset, Offset.zero);
      expect(transform.scale, 1.0);
      expect(transform.rotationDegrees, 0.0);
      expect(transform.isFlippedHorizontal, false);
      expect(transform.isFlippedVertical, false);
    });

    test('toMatrix4 produces expected transform matrix', () {
      const transform = CropTransform(
        offset: Offset(10, 20),
        scale: 2.0,
        rotationDegrees: 90.0,
        isFlippedHorizontal: true,
      );

      final matrix = transform.toMatrix4();
      expect(matrix, isNotNull);
    });

    test('copyWith updates properties correctly', () {
      const original = CropTransform();
      final updated = original.copyWith(
        scale: 3.0,
        rotationDegrees: 180.0,
        isFlippedHorizontal: true,
      );

      expect(updated.scale, 3.0);
      expect(updated.rotationDegrees, 180.0);
      expect(updated.isFlippedHorizontal, true);
      expect(updated.isFlippedVertical, false);
    });
  });

  group('CropAspectRatio Tests', () {
    test('Standard ratio presets', () {
      expect(CropAspectRatio.free.isFree, isTrue);
      expect(CropAspectRatio.free.ratio, isNull);

      expect(CropAspectRatio.square.ratio, 1.0);
      expect(CropAspectRatio.ratio16x9.ratio, closeTo(16.0 / 9.0, 0.001));
      expect(CropAspectRatio.ratio4x3.ratio, closeTo(4.0 / 3.0, 0.001));
      expect(CropAspectRatio.ratio9x16.ratio, closeTo(9.0 / 16.0, 0.001));
    });

    test('Custom aspect ratios', () {
      final custom = CropAspectRatio.custom(21, 9);
      expect(custom.ratio, closeTo(21.0 / 9.0, 0.001));
      expect(custom.isFree, isFalse);

      final ratioFloat = CropAspectRatio.ratio(2.5, label: 'Custom 2.5');
      expect(ratioFloat.ratio, 2.5);
      expect(ratioFloat.label, 'Custom 2.5');
    });
  });

  group('CropRect Tests', () {
    test('Full bounds normalized values', () {
      const full = CropRect.full;
      expect(full.left, 0.0);
      expect(full.top, 0.0);
      expect(full.right, 1.0);
      expect(full.bottom, 1.0);
      expect(full.width, 1.0);
      expect(full.height, 1.0);
      expect(full.aspectRatio, 1.0);
    });

    test('toRect and fromRect denormalization', () {
      const containerSize = Size(400, 300);
      const pixelRect = Rect.fromLTWH(40, 30, 200, 150);

      final cropRect = CropRect.fromRect(pixelRect, containerSize);
      expect(cropRect.left, closeTo(0.1, 0.001));
      expect(cropRect.top, closeTo(0.1, 0.001));
      expect(cropRect.right, closeTo(0.6, 0.001));
      expect(cropRect.bottom, closeTo(0.6, 0.001));

      final convertedBack = cropRect.toRect(containerSize);
      expect(convertedBack.left, closeTo(40, 0.001));
      expect(convertedBack.top, closeTo(30, 0.001));
      expect(convertedBack.width, closeTo(200, 0.001));
      expect(convertedBack.height, closeTo(150, 0.001));
    });
  });

  group('CropController Tests', () {
    test('Initial controller state', () {
      final controller = CropController();
      expect(controller.zoom, 1.0);
      expect(controller.rotation, 0.0);
      expect(controller.isFlippedHorizontal, isFalse);
      expect(controller.isFlippedVertical, isFalse);
      expect(controller.aspectRatio, CropAspectRatio.free);
      expect(controller.shape, CropShape.rectangle);
      expect(controller.isReady, isFalse);
    });

    test('Zoom operations and clamping', () {
      final controller = CropController();
      controller.zoomIn(1.0);
      expect(controller.zoom, 2.0);

      controller.zoomOut(0.5);
      expect(controller.zoom, 1.5);

      // Max clamp (default max 8.0)
      controller.setZoom(20.0);
      expect(controller.zoom, 8.0);

      // Min clamp (default min 1.0)
      controller.setZoom(0.2);
      expect(controller.zoom, 1.0);
    });

    test('Rotation and flip operations', () {
      final controller = CropController();

      controller.rotateRight();
      expect(controller.rotation, 90.0);

      controller.rotateRight();
      expect(controller.rotation, 180.0);

      controller.rotateLeft();
      expect(controller.rotation, 90.0);

      controller.setRotation(350.0);
      expect(controller.rotation, 350.0);

      controller.flipHorizontal();
      expect(controller.isFlippedHorizontal, isTrue);
      controller.flipHorizontal();
      expect(controller.isFlippedHorizontal, isFalse);

      controller.flipVertical();
      expect(controller.isFlippedVertical, isTrue);
    });

    test('Reset restores transform defaults', () {
      final controller = CropController();
      controller.setZoom(3.5);
      controller.setRotation(180.0);
      controller.flipHorizontal();

      expect(controller.zoom, 3.5);
      expect(controller.rotation, 180.0);
      expect(controller.isFlippedHorizontal, isTrue);

      controller.reset();

      expect(controller.zoom, 1.0);
      expect(controller.rotation, 0.0);
      expect(controller.isFlippedHorizontal, isFalse);
      expect(controller.isFlippedVertical, isFalse);
    });

    test('Aspect ratio and shape changes notify listeners', () {
      final controller = CropController();
      int listenerCalls = 0;
      controller.addListener(() {
        listenerCalls++;
      });

      controller.setAspectRatio(CropAspectRatio.square);
      expect(controller.aspectRatio, CropAspectRatio.square);
      expect(listenerCalls, 1);

      controller.setCropShape(CropShape.circle);
      expect(controller.shape, CropShape.circle);
      expect(listenerCalls, 2);
    });
  });

  group('Configuration Presets Tests', () {
    test('Profile photo preset', () {
      const config = CropperConfiguration.profilePhoto;
      expect(config.shape, CropShape.circle);
      expect(config.aspectRatio, CropAspectRatio.square);
      expect(config.grid.showGrid, isFalse);
    });

    test('Instagram and Story presets', () {
      const ig = CropperConfiguration.instagramSquare;
      expect(ig.aspectRatio, CropAspectRatio.square);

      const story = CropperConfiguration.story;
      expect(story.aspectRatio, CropAspectRatio.ratio9x16);
    });
  });

  group('CropperTheme Tests', () {
    test('Preset theme colors are properly defined', () {
      expect(CropperTheme.dark.backgroundColor, isNotNull);
      expect(CropperTheme.light.backgroundColor, isNotNull);
      expect(CropperTheme.cupertinoDark.backgroundColor, isNotNull);
      expect(CropperTheme.nord.backgroundColor, isNotNull);
    });
  });

  group('CropException Tests', () {
    test('Formats message and cause cleanly', () {
      const ex1 = CropException('Invalid dimensions');
      expect(ex1.toString(), 'CropException: Invalid dimensions');

      final ex2 = CropException('Failed decode', ArgumentError('bad data'));
      expect(ex2.toString(), contains('Caused by:'));
    });
  });
}
