import 'package:flutter/material.dart';
import '../configuration/cropper_configuration.dart';
import '../configuration/cropper_theme.dart';
import '../controller/crop_controller.dart';
import '../models/crop_result.dart';
import 'advanced_cropper.dart';
import 'default_cropper_controls.dart';

/// Complete, ready-to-use turnkey crop screen widget.
///
/// Combines the headless [AdvancedCropper] with a header (Cancel / Done buttons),
/// and the interactive [DefaultCropperControls] toolbar.
class AdvancedCropperView extends StatefulWidget {
  /// Creates an [AdvancedCropperView].
  const AdvancedCropperView({
    super.key,
    required this.image,
    this.controller,
    this.configuration = const CropperConfiguration(),
    this.theme = const CropperTheme(),
    this.title = 'Crop Image',
    this.onCropped,
    this.onCancelled,
    this.showControls = true,
    this.topBarBuilder,
    this.bottomBarBuilder,
  });

  /// The source image provider to crop.
  final ImageProvider image;

  /// Optional external [CropController]. If omitted, one is managed internally.
  final CropController? controller;

  /// Crop configuration (aspect ratios, shapes, overlay styles, gestures).
  final CropperConfiguration configuration;

  /// Visual theme styling.
  final CropperTheme theme;

  /// Header title text displayed in the top bar.
  final String title;

  /// Callback executed when the user taps "Done" and cropping succeeds.
  final ValueChanged<CropResult>? onCropped;

  /// Callback executed when the user taps "Cancel".
  final VoidCallback? onCancelled;

  /// Whether the top and bottom toolbars are shown.
  final bool showControls;

  /// Optional custom top bar builder.
  final Widget Function(BuildContext context, CropController controller)?
      topBarBuilder;

  /// Optional custom bottom bar builder.
  final Widget Function(BuildContext context, CropController controller)?
      bottomBarBuilder;

  @override
  State<AdvancedCropperView> createState() => _AdvancedCropperViewState();
}

class _AdvancedCropperViewState extends State<AdvancedCropperView> {
  late CropController _controller;
  bool _isInternalController = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
      _isInternalController = false;
    } else {
      _controller = CropController(initialConfiguration: widget.configuration);
      _isInternalController = true;
    }
  }

  @override
  void didUpdateWidget(covariant AdvancedCropperView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (_isInternalController) {
        _controller.dispose();
      }
      if (widget.controller != null) {
        _controller = widget.controller!;
        _isInternalController = false;
      } else {
        _controller =
            CropController(initialConfiguration: widget.configuration);
        _isInternalController = true;
      }
    }
  }

  @override
  void dispose() {
    if (_isInternalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _handleDone() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final result = await _controller.crop();
      if (mounted) {
        widget.onCropped?.call(result);
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            if (widget.showControls)
              widget.topBarBuilder != null
                  ? widget.topBarBuilder!(context, _controller)
                  : Container(
                      color: theme.toolbarColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: widget.onCancelled ??
                                () => Navigator.of(context).maybePop(),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: theme.secondaryTextColor,
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                          Text(
                            widget.title,
                            style: TextStyle(
                              color: theme.textColor,
                              fontSize: 17.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          _isProcessing
                              ? const SizedBox(
                                  width: 20.0,
                                  height: 20.0,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.0),
                                )
                              : TextButton(
                                  onPressed: _handleDone,
                                  child: Text(
                                    'Done',
                                    style: TextStyle(
                                      color: theme.primaryColor,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),

            // Main Cropper Viewport
            Expanded(
              child: AdvancedCropper(
                image: widget.image,
                controller: _controller,
                configuration: widget.configuration,
                theme: theme,
              ),
            ),

            // Bottom Bar / Toolbar Controls
            if (widget.showControls)
              widget.bottomBarBuilder != null
                  ? widget.bottomBarBuilder!(context, _controller)
                  : DefaultCropperControls(
                      controller: _controller,
                      theme: theme,
                    ),
          ],
        ),
      ),
    );
  }
}

/// Convenient alias for [AdvancedCropperView] matching package name.
typedef FlutterCropImageView = AdvancedCropperView;

/// Convenient alias for [AdvancedCropperView].
typedef CropImageView = AdvancedCropperView;
