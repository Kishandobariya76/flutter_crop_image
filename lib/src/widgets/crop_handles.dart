import 'package:flutter/widgets.dart';
import '../configuration/crop_overlay_configuration.dart';

/// Custom painter rendering classic L-bracket corner handles.
class CropHandlesPainter extends CustomPainter {
  /// Creates a [CropHandlesPainter].
  const CropHandlesPainter({
    required this.cropRect,
    required this.configuration,
  });

  /// The active crop window rectangle.
  final Rect cropRect;

  /// Overlay configuration providing handle dimensions and colors.
  final CropOverlayConfiguration configuration;

  @override
  void paint(Canvas canvas, Size size) {
    if (!configuration.showHandles || cropRect.isEmpty) return;

    final paint = Paint()
      ..color = configuration.handleColor
      ..strokeWidth = configuration.handleWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final double length = configuration.handleSize;
    final double halfWidth = configuration.handleWidth / 2.0;

    final double l = cropRect.left - halfWidth;
    final double t = cropRect.top - halfWidth;
    final double r = cropRect.right + halfWidth;
    final double b = cropRect.bottom + halfWidth;

    // Top-Left Handle
    final tlPath = Path()
      ..moveTo(l, t + length)
      ..lineTo(l, t)
      ..lineTo(l + length, t);
    canvas.drawPath(tlPath, paint);

    // Top-Right Handle
    final trPath = Path()
      ..moveTo(r - length, t)
      ..lineTo(r, t)
      ..lineTo(r, t + length);
    canvas.drawPath(trPath, paint);

    // Bottom-Left Handle
    final blPath = Path()
      ..moveTo(l, b - length)
      ..lineTo(l, b)
      ..lineTo(l + length, b);
    canvas.drawPath(blPath, paint);

    // Bottom-Right Handle
    final brPath = Path()
      ..moveTo(r - length, b)
      ..lineTo(r, b)
      ..lineTo(r, b - length);
    canvas.drawPath(brPath, paint);
  }

  @override
  bool shouldRepaint(covariant CropHandlesPainter oldDelegate) {
    return oldDelegate.cropRect != cropRect ||
        oldDelegate.configuration != configuration;
  }
}

/// Widget rendering the corner resize handles.
class CropHandles extends StatelessWidget {
  /// Creates a [CropHandles].
  const CropHandles({
    super.key,
    required this.cropRect,
    required this.configuration,
  });

  /// The active crop rectangle.
  final Rect cropRect;

  /// Overlay settings.
  final CropOverlayConfiguration configuration;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CropHandlesPainter(
        cropRect: cropRect,
        configuration: configuration,
      ),
      size: Size.infinite,
    );
  }
}
