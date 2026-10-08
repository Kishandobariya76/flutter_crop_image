import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';
import '../configuration/crop_export_configuration.dart';
import '../configuration/crop_processing_configuration.dart';
import '../configuration/crop_shape.dart';
import '../models/crop_result.dart';
import '../models/crop_transform.dart';

/// Abstract contract for processing and rendering cropped image data.
///
/// Implementations may use Flutter's built-in GPU [ui.Canvas], CPU-based
/// image processing isolates, or native platform C++/Metal/NDK pipelines.
abstract class CropProcessor {
  /// Processes the [image] according to [cropRect], [transform], and [exportConfig].
  Future<CropResult> process({
    required ui.Image image,
    required Rect cropRect,
    required Rect viewRect,
    required Rect fittedImageRect,
    required CropTransform transform,
    required CropShape shape,
    required double cornerRadius,
    required CropExportConfiguration exportConfig,
    required CropProcessingConfiguration processingConfig,
  });
}
