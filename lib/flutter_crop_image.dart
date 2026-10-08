/// A production-ready, highly extensible Flutter image cropper package.
///
/// Features:
/// - Pure Dart crop engine decoupled from UI.
/// - Headless cropping mode and turnkey [AdvancedCropperView].
/// - 60/120 FPS GPU-accelerated rendering using Flutter's native canvas.
/// - Interactive corner handle resizing and boundary constraints.
/// - Circular, oval, rounded-rectangle, and rectangular crop shapes.
/// - Rule of Thirds, Golden Ratio, Crosshair, and customizable composition grids.
/// - Pan, pinch-zoom, double-tap zoom, rotation, and flip gestures.
/// - Programmatic control via [CropController].
/// - Zero external dependencies.
library;

export 'src/configuration/crop_aspect_ratio.dart';
export 'src/configuration/crop_export_configuration.dart';
export 'src/configuration/crop_gesture_configuration.dart';
export 'src/configuration/crop_grid_configuration.dart';
export 'src/configuration/crop_overlay_configuration.dart';
export 'src/configuration/crop_processing_configuration.dart';
export 'src/configuration/crop_shape.dart';
export 'src/configuration/cropper_configuration.dart';
export 'src/configuration/cropper_theme.dart';
export 'src/controller/crop_controller.dart';
export 'src/exceptions/crop_exception.dart';
export 'src/models/crop_image_format.dart';
export 'src/models/crop_rect.dart';
export 'src/models/crop_result.dart';
export 'src/models/crop_state.dart';
export 'src/models/crop_transform.dart';
export 'src/processing/crop_processor.dart';
export 'src/processing/native_ui_crop_processor.dart';
export 'src/widgets/advanced_cropper.dart';
export 'src/widgets/advanced_cropper_view.dart';
export 'src/widgets/crop_grid.dart';
export 'src/widgets/crop_handles.dart';
export 'src/widgets/crop_overlay.dart';
export 'src/widgets/default_cropper_controls.dart';
