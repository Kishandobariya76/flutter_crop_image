import 'package:flutter/widgets.dart';
import '../configuration/crop_grid_configuration.dart';
import '../configuration/crop_shape.dart';

/// Custom painter for composition guide lines within the crop window.
class CropGridPainter extends CustomPainter {
  /// Creates a [CropGridPainter].
  const CropGridPainter({
    required this.cropRect,
    required this.configuration,
    this.shape = CropShape.rectangle,
    this.cornerRadius = 0.0,
  });

  /// The active crop window rectangle.
  final Rect cropRect;

  /// The grid configuration.
  final CropGridConfiguration configuration;

  /// Shape of the crop window for clipping.
  final CropShape shape;

  /// Corner radius when [shape] is [CropShape.roundedRectangle].
  final double cornerRadius;

  @override
  void paint(Canvas canvas, Size size) {
    if (!configuration.showGrid ||
        configuration.style == CropGridStyle.none ||
        cropRect.isEmpty) {
      return;
    }

    canvas.save();

    // Clip to crop frame shape.
    switch (shape) {
      case CropShape.circle:
      case CropShape.oval:
        canvas.clipPath(Path()..addOval(cropRect));
        break;
      case CropShape.roundedRectangle:
        canvas.clipRRect(
          RRect.fromRectAndRadius(cropRect, Radius.circular(cornerRadius)),
        );
        break;
      case CropShape.rectangle:
        canvas.clipRect(cropRect);
        break;
    }

    final paint = Paint()
      ..color = configuration.gridColor
      ..strokeWidth = configuration.gridWidth
      ..style = PaintingStyle.stroke;

    int cols = 3;
    int rws = 3;

    switch (configuration.style) {
      case CropGridStyle.ruleOfThirds:
        cols = 3;
        rws = 3;
        break;
      case CropGridStyle.goldenRatio:
        final double x1 = cropRect.left + cropRect.width * 0.381966;
        final double x2 = cropRect.left + cropRect.width * 0.618034;
        canvas.drawLine(
            Offset(x1, cropRect.top), Offset(x1, cropRect.bottom), paint);
        canvas.drawLine(
            Offset(x2, cropRect.top), Offset(x2, cropRect.bottom), paint);

        final double y1 = cropRect.top + cropRect.height * 0.381966;
        final double y2 = cropRect.top + cropRect.height * 0.618034;
        canvas.drawLine(
            Offset(cropRect.left, y1), Offset(cropRect.right, y1), paint);
        canvas.drawLine(
            Offset(cropRect.left, y2), Offset(cropRect.right, y2), paint);
        canvas.restore();
        return;
      case CropGridStyle.crosshair:
        cols = 2;
        rws = 2;
        break;
      case CropGridStyle.custom:
        cols = configuration.columns;
        rws = configuration.rows;
        break;
      case CropGridStyle.none:
        canvas.restore();
        return;
    }

    // Vertical grid lines
    if (cols > 1) {
      final double colStep = cropRect.width / cols;
      for (int i = 1; i < cols; i++) {
        final double x = cropRect.left + i * colStep;
        canvas.drawLine(
          Offset(x, cropRect.top),
          Offset(x, cropRect.bottom),
          paint,
        );
      }
    }

    // Horizontal grid lines
    if (rws > 1) {
      final double rowStep = cropRect.height / rws;
      for (int i = 1; i < rws; i++) {
        final double y = cropRect.top + i * rowStep;
        canvas.drawLine(
          Offset(cropRect.left, y),
          Offset(cropRect.right, y),
          paint,
        );
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CropGridPainter oldDelegate) {
    return oldDelegate.cropRect != cropRect ||
        oldDelegate.configuration != configuration ||
        oldDelegate.shape != shape ||
        oldDelegate.cornerRadius != cornerRadius;
  }
}

/// Widget rendering grid guide lines inside the crop boundary.
class CropGrid extends StatelessWidget {
  /// Creates a [CropGrid].
  const CropGrid({
    super.key,
    required this.cropRect,
    required this.configuration,
    this.shape = CropShape.rectangle,
    this.cornerRadius = 0.0,
  });

  /// The active crop rectangle.
  final Rect cropRect;

  /// Grid settings.
  final CropGridConfiguration configuration;

  /// Shape of the crop frame.
  final CropShape shape;

  /// Corner radius for rounded rectangles.
  final double cornerRadius;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CropGridPainter(
        cropRect: cropRect,
        configuration: configuration,
        shape: shape,
        cornerRadius: cornerRadius,
      ),
      size: Size.infinite,
    );
  }
}
