import 'package:flutter/widgets.dart';
import '../configuration/crop_overlay_configuration.dart';
import '../configuration/crop_shape.dart';

/// Custom painter rendering the dimmed background mask and crop window border.
class CropOverlayPainter extends CustomPainter {
  /// Creates a [CropOverlayPainter].
  const CropOverlayPainter({
    required this.cropRect,
    required this.configuration,
  });

  /// The active crop window rectangle.
  final Rect cropRect;

  /// The overlay visual configuration.
  final CropOverlayConfiguration configuration;

  @override
  void paint(Canvas canvas, Size size) {
    if (cropRect.isEmpty) return;

    final fullPath = Path()..addRect(Offset.zero & size);
    final cutoutPath = Path();

    switch (configuration.shape) {
      case CropShape.circle:
        cutoutPath.addOval(cropRect);
        break;
      case CropShape.oval:
        cutoutPath.addOval(cropRect);
        break;
      case CropShape.roundedRectangle:
        cutoutPath.addRRect(
          RRect.fromRectAndRadius(
            cropRect,
            Radius.circular(configuration.cornerRadius),
          ),
        );
        break;
      case CropShape.rectangle:
        cutoutPath.addRect(cropRect);
        break;
    }

    // Draw shaded mask outside the crop window.
    final overlayPath = Path.combine(
      PathOperation.difference,
      fullPath,
      cutoutPath,
    );

    final overlayPaint = Paint()
      ..color = configuration.overlayColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(overlayPath, overlayPaint);

    // Draw crop boundary border.
    if (configuration.borderWidth > 0) {
      final borderPaint = Paint()
        ..color = configuration.borderColor
        ..strokeWidth = configuration.borderWidth
        ..style = PaintingStyle.stroke;
      canvas.drawPath(cutoutPath, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CropOverlayPainter oldDelegate) {
    return oldDelegate.cropRect != cropRect ||
        oldDelegate.configuration != configuration;
  }
}

/// Widget that paints the dimmed overlay mask and border around the crop frame.
class CropOverlay extends StatelessWidget {
  /// Creates a [CropOverlay].
  const CropOverlay({
    super.key,
    required this.cropRect,
    required this.configuration,
  });

  /// The active crop window rectangle.
  final Rect cropRect;

  /// Overlay configuration.
  final CropOverlayConfiguration configuration;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CropOverlayPainter(
        cropRect: cropRect,
        configuration: configuration,
      ),
      size: Size.infinite,
    );
  }
}
