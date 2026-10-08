import 'dart:typed_data';
import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ExampleHomeScreen loads and renders showcase examples',
      (tester) async {
    // 1x1 test png
    final kDummyPng = Uint8List.fromList(<int>[
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

    await tester.pumpWidget(CropperExampleApp(initialImageBytes: kDummyPng));
    await tester.pumpAndSettle();

    expect(find.text('Advanced Cropper'), findsOneWidget);
    expect(find.text('1. Basic Turnkey Cropper'), findsOneWidget);
    expect(find.text('2. Circular Profile Crop'), findsOneWidget);
    expect(find.text('3. 16:9 Landscape / Thumbnail'), findsOneWidget);
    expect(find.text('4. Custom Nord Theme'), findsOneWidget);
    expect(find.text('5. Custom Developer Controls'), findsOneWidget);
    expect(find.text('6. Headless Crop Engine'), findsOneWidget);
  });
}
