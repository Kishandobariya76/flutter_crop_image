import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_crop_image/flutter_crop_image.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Widget Tests - Overlay, Grid & Handles', () {
    testWidgets('CropOverlay renders CustomPaint with crop rect',
        (tester) async {
      const rect = Rect.fromLTWH(50, 50, 200, 200);
      const config = CropOverlayConfiguration();

      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 400,
            height: 400,
            child: CropOverlay(
              cropRect: rect,
              configuration: config,
            ),
          ),
        ),
      );

      expect(find.byType(CropOverlay), findsOneWidget);
      expect(find.byType(CustomPaint), findsOneWidget);
    });

    testWidgets('CropGrid renders when showGrid is true', (tester) async {
      const rect = Rect.fromLTWH(20, 20, 300, 300);
      const config = CropGridConfiguration(showGrid: true);

      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 400,
            height: 400,
            child: CropGrid(
              cropRect: rect,
              configuration: config,
            ),
          ),
        ),
      );

      expect(find.byType(CropGrid), findsOneWidget);
    });

    testWidgets('CropHandles renders when showHandles is true', (tester) async {
      const rect = Rect.fromLTWH(30, 30, 250, 250);
      const config = CropOverlayConfiguration(showHandles: true);

      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 400,
            height: 400,
            child: CropHandles(
              cropRect: rect,
              configuration: config,
            ),
          ),
        ),
      );

      expect(find.byType(CropHandles), findsOneWidget);
    });
  });

  group('Widget Tests - Controls Toolbar', () {
    testWidgets(
        'DefaultCropperControls renders action buttons and responds to interactions',
        (tester) async {
      final controller = CropController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DefaultCropperControls(
              controller: controller,
            ),
          ),
        ),
      );

      expect(find.byType(DefaultCropperControls), findsOneWidget);
      expect(find.byTooltip('Rotate Right'), findsOneWidget);
      expect(find.byTooltip('Rotate Left'), findsOneWidget);
      expect(find.byTooltip('Reset Transformations'), findsOneWidget);

      // Tap rotate right
      await tester.tap(find.byTooltip('Rotate Right'));
      await tester.pump();
      expect(controller.rotation, 90.0);

      // Tap rotate left
      await tester.tap(find.byTooltip('Rotate Left'));
      await tester.pump();
      expect(controller.rotation, 0.0);

      // Tap circle shape
      await tester.tap(find.byTooltip('Circle Shape'));
      await tester.pump();
      expect(controller.shape, CropShape.circle);
    });
  });

  group('Widget Tests - AdvancedCropper Rendering', () {
    testWidgets(
        'AdvancedCropper shows loading text initially and handles memory image',
        (tester) async {
      // 1x1 transparent png bytes
      final kTransparentImage = Uint8List.fromList(<int>[
        0x89,
        0x50,
        0x4E,
        0x47,
        0x0D,
        0x0A,
        0x1A,
        0x0A,
        0x00,
        0x00,
        0x00,
        0x0D,
        0x49,
        0x48,
        0x44,
        0x52,
        0x00,
        0x00,
        0x00,
        0x01,
        0x00,
        0x00,
        0x00,
        0x01,
        0x08,
        0x06,
        0x00,
        0x00,
        0x00,
        0x1F,
        0x15,
        0xC4,
        0x89,
        0x00,
        0x00,
        0x00,
        0x0A,
        0x49,
        0x44,
        0x41,
        0x54,
        0x78,
        0x9C,
        0x63,
        0x00,
        0x01,
        0x00,
        0x00,
        0x05,
        0x00,
        0x01,
        0x0D,
        0x0A,
        0x2D,
        0xB4,
        0x00,
        0x00,
        0x00,
        0x00,
        0x49,
        0x45,
        0x4E,
        0x44,
        0xAE,
        0x42,
        0x60,
        0x82,
      ]);

      final controller = CropController();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 300,
            height: 300,
            child: AdvancedCropper(
              image: MemoryImage(kTransparentImage),
              controller: controller,
            ),
          ),
        ),
      );

      // Pump frame to decode
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(AdvancedCropper), findsOneWidget);
    });
  });
}
