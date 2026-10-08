import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';
import '../configuration/crop_aspect_ratio.dart';
import '../configuration/cropper_configuration.dart';
import '../configuration/cropper_theme.dart';
import '../controller/crop_controller.dart';
import '../exceptions/crop_exception.dart';
import '../models/crop_rect.dart';
import '../models/crop_state.dart';
import '../models/crop_transform.dart';
import '../processing/crop_processor.dart';
import '../processing/native_ui_crop_processor.dart';
import 'crop_grid.dart';
import 'crop_handles.dart';
import 'crop_overlay.dart';

/// The core, reusable, headless image cropping widget.
///
/// Can be embedded in any layout, dialog, or custom screen without dependency
/// on Material, Cupertino, or any external state-management framework.
class AdvancedCropper extends StatefulWidget {
  /// Creates an [AdvancedCropper] from any standard [ImageProvider].
  const AdvancedCropper({
    super.key,
    required this.image,
    this.controller,
    this.configuration = const CropperConfiguration(),
    this.theme = const CropperTheme(),
    this.processor = const NativeUiCropProcessor(),
    this.showOverlay = true,
    this.onCropChanged,
    this.onZoomChanged,
    this.onRotationChanged,
    this.onError,
    this.loadingBuilder,
    this.errorBuilder,
    this.overlayBuilder,
  });

  /// Convenience constructor creating an [AdvancedCropper] from in-memory byte data.
  factory AdvancedCropper.memory(
    Uint8List bytes, {
    Key? key,
    CropController? controller,
    CropperConfiguration configuration = const CropperConfiguration(),
    CropperTheme theme = const CropperTheme(),
    CropProcessor processor = const NativeUiCropProcessor(),
    bool showOverlay = true,
    ValueChanged<CropState>? onCropChanged,
    ValueChanged<double>? onZoomChanged,
    ValueChanged<double>? onRotationChanged,
    ValueChanged<CropException>? onError,
    Widget Function(BuildContext context)? loadingBuilder,
    Widget Function(BuildContext context, Object error)? errorBuilder,
    Widget Function(BuildContext context, Rect cropRect)? overlayBuilder,
  }) {
    return AdvancedCropper(
      key: key,
      image: MemoryImage(bytes),
      controller: controller,
      configuration: configuration,
      theme: theme,
      processor: processor,
      showOverlay: showOverlay,
      onCropChanged: onCropChanged,
      onZoomChanged: onZoomChanged,
      onRotationChanged: onRotationChanged,
      onError: onError,
      loadingBuilder: loadingBuilder,
      errorBuilder: errorBuilder,
      overlayBuilder: overlayBuilder,
    );
  }

  /// Convenience constructor creating an [AdvancedCropper] from a network URL.
  factory AdvancedCropper.network(
    String url, {
    Key? key,
    CropController? controller,
    CropperConfiguration configuration = const CropperConfiguration(),
    CropperTheme theme = const CropperTheme(),
    CropProcessor processor = const NativeUiCropProcessor(),
    bool showOverlay = true,
    ValueChanged<CropState>? onCropChanged,
    ValueChanged<double>? onZoomChanged,
    ValueChanged<double>? onRotationChanged,
    ValueChanged<CropException>? onError,
    Widget Function(BuildContext context)? loadingBuilder,
    Widget Function(BuildContext context, Object error)? errorBuilder,
    Widget Function(BuildContext context, Rect cropRect)? overlayBuilder,
  }) {
    return AdvancedCropper(
      key: key,
      image: NetworkImage(url),
      controller: controller,
      configuration: configuration,
      theme: theme,
      processor: processor,
      showOverlay: showOverlay,
      onCropChanged: onCropChanged,
      onZoomChanged: onZoomChanged,
      onRotationChanged: onRotationChanged,
      onError: onError,
      loadingBuilder: loadingBuilder,
      errorBuilder: errorBuilder,
      overlayBuilder: overlayBuilder,
    );
  }

  /// Convenience constructor creating an [AdvancedCropper] from an asset bundle.
  factory AdvancedCropper.asset(
    String assetName, {
    Key? key,
    CropController? controller,
    CropperConfiguration configuration = const CropperConfiguration(),
    CropperTheme theme = const CropperTheme(),
    CropProcessor processor = const NativeUiCropProcessor(),
    bool showOverlay = true,
    ValueChanged<CropState>? onCropChanged,
    ValueChanged<double>? onZoomChanged,
    ValueChanged<double>? onRotationChanged,
    ValueChanged<CropException>? onError,
    Widget Function(BuildContext context)? loadingBuilder,
    Widget Function(BuildContext context, Object error)? errorBuilder,
    Widget Function(BuildContext context, Rect cropRect)? overlayBuilder,
  }) {
    return AdvancedCropper(
      key: key,
      image: AssetImage(assetName),
      controller: controller,
      configuration: configuration,
      theme: theme,
      processor: processor,
      showOverlay: showOverlay,
      onCropChanged: onCropChanged,
      onZoomChanged: onZoomChanged,
      onRotationChanged: onRotationChanged,
      onError: onError,
      loadingBuilder: loadingBuilder,
      errorBuilder: errorBuilder,
      overlayBuilder: overlayBuilder,
    );
  }

  /// The source image provider.
  final ImageProvider image;

  /// Optional controller to programmatically manipulate zoom, rotation, and crop execution.
  final CropController? controller;

  /// Configuration specifying aspect ratio, overlay style, gestures, and memory constraints.
  final CropperConfiguration configuration;

  /// Visual styling palette for the cropper.
  final CropperTheme theme;

  /// The image processing pipeline used when cropping.
  final CropProcessor processor;

  /// Whether the dimmed overlay mask and guides are rendered.
  final bool showOverlay;

  /// Callback fired whenever the crop region or transformation state changes.
  final ValueChanged<CropState>? onCropChanged;

  /// Callback fired when zoom scale changes.
  final ValueChanged<double>? onZoomChanged;

  /// Callback fired when rotation angle changes.
  final ValueChanged<double>? onRotationChanged;

  /// Callback fired when image decoding or export fails.
  final ValueChanged<CropException>? onError;

  /// Builder for displaying a custom widget while decoding the image.
  final Widget Function(BuildContext context)? loadingBuilder;

  /// Builder for displaying an error view if image resolution fails.
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  /// Builder allowing complete replacement of the default overlay layer.
  final Widget Function(BuildContext context, Rect cropRect)? overlayBuilder;

  @override
  State<AdvancedCropper> createState() => _AdvancedCropperState();
}

class _AdvancedCropperState extends State<AdvancedCropper>
    with SingleTickerProviderStateMixin
    implements CropEngineDelegate {
  late CropController _controller;
  bool _isInternalController = false;

  ImageStream? _imageStream;
  ImageStreamListener? _imageStreamListener;
  ui.Image? _decodedImage;
  Object? _imageError;
  bool _isLoading = true;

  Size _viewportSize = Size.zero;
  Rect _fittedImageRect = Rect.zero;
  Rect _cropRect = Rect.zero;

  // Gesture state tracking
  Offset _initialFocalPoint = Offset.zero;
  CropTransform _initialTransform = CropTransform.identity;
  Rect _initialCropRect = Rect.zero;
  _CropDragMode _dragMode = _CropDragMode.none;
  bool _isInteracting = false;

  // Animation controller for animated zooms
  late AnimationController _animController;
  Animation<CropTransform>? _transformAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _animController.addListener(_onAnimationTick);

    _initController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveImage();
  }

  void _initController() {
    if (widget.controller != null) {
      _controller = widget.controller!;
      _isInternalController = false;
    } else {
      _controller = CropController(initialConfiguration: widget.configuration);
      _isInternalController = true;
    }
    _controller.attach(this);
    _controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant AdvancedCropper oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerChanged);
      oldWidget.controller?.detach();
      if (_isInternalController) {
        _controller.dispose();
      }
      _initController();
    }

    if (oldWidget.image != widget.image) {
      _resolveImage();
    } else if (oldWidget.configuration.aspectRatio !=
            widget.configuration.aspectRatio ||
        oldWidget.configuration.shape != widget.configuration.shape) {
      _calculateBounds();
    }
  }

  @override
  void dispose() {
    _animController.removeListener(_onAnimationTick);
    _animController.dispose();

    _imageStreamListener?.let((listener) {
      _imageStream?.removeListener(listener);
    });

    _controller.removeListener(_onControllerChanged);
    _controller.detach();
    if (_isInternalController) {
      _controller.dispose();
    }

    _decodedImage?.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {});
    widget.onCropChanged?.call(_controller.state);
  }

  void _onAnimationTick() {
    if (_transformAnimation != null) {
      _controller.updateTransform(_transformAnimation!.value);
    }
  }

  // ===========================================================================
  // IMAGE RESOLUTION
  // ===========================================================================

  void _resolveImage() {
    setState(() {
      _isLoading = true;
      _imageError = null;
    });

    final ImageConfiguration config = createLocalImageConfiguration(context);
    final ImageStream newStream = widget.image.resolve(config);

    if (_imageStream?.key == newStream.key) return;

    if (_imageStreamListener != null && _imageStream != null) {
      _imageStream!.removeListener(_imageStreamListener!);
    }

    _imageStream = newStream;
    _imageStreamListener = ImageStreamListener(
      _onImageLoaded,
      onError: _onImageError,
    );
    _imageStream!.addListener(_imageStreamListener!);
  }

  void _onImageLoaded(ImageInfo imageInfo, bool synchronousCall) {
    if (!mounted) return;
    final ui.Image image = imageInfo.image;

    setState(() {
      _decodedImage?.dispose();
      _decodedImage = image;
      _isLoading = false;
      _imageError = null;
    });

    _calculateBounds();
  }

  void _onImageError(Object exception, StackTrace? stackTrace) {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _imageError = exception;
    });
    final cropEx = CropException('Failed to load image', exception);
    widget.onError?.call(cropEx);
  }

  // ===========================================================================
  // BOUNDS & LAYOUT CALCULATION
  // ===========================================================================

  void _calculateBounds() {
    if (_decodedImage == null || _viewportSize.isEmpty) return;

    final double imgWidth = _decodedImage!.width.toDouble();
    final double imgHeight = _decodedImage!.height.toDouble();
    final Size naturalImageSize = Size(imgWidth, imgHeight);

    // Compute containment fit inside viewport
    final FittedSizes sizes = applyBoxFit(
      BoxFit.contain,
      naturalImageSize,
      _viewportSize,
    );

    final double fittedW = sizes.destination.width;
    final double fittedH = sizes.destination.height;
    final double left = (_viewportSize.width - fittedW) / 2.0;
    final double top = (_viewportSize.height - fittedH) / 2.0;

    _fittedImageRect = Rect.fromLTWH(left, top, fittedW, fittedH);

    // Compute crop window based on active aspect ratio
    final CropAspectRatio aspect = _controller.aspectRatio;
    const double padding = 20.0;
    final Rect paddedViewport = Rect.fromLTWH(
      padding,
      padding,
      math.max(1.0, _viewportSize.width - padding * 2),
      math.max(1.0, _viewportSize.height - padding * 2),
    );

    if (aspect.isFree) {
      // Freeform: default to fitted image bounds or padded viewport
      _cropRect = _fittedImageRect;
    } else {
      final double targetRatio = aspect.ratio!;
      double cropW = paddedViewport.width;
      double cropH = cropW / targetRatio;

      if (cropH > paddedViewport.height) {
        cropH = paddedViewport.height;
        cropW = cropH * targetRatio;
      }

      final double cLeft =
          paddedViewport.left + (paddedViewport.width - cropW) / 2.0;
      final double cTop =
          paddedViewport.top + (paddedViewport.height - cropH) / 2.0;
      _cropRect = Rect.fromLTWH(cLeft, cTop, cropW, cropH);
    }

    _updateEngineState();
  }

  void _updateEngineState() {
    final cropRectModel = CropRect.fromRect(_cropRect, _viewportSize);
    _controller.updateEngineState(
      cropRect: _cropRect,
      viewRect: Offset.zero & _viewportSize,
      normalizedCropRect: cropRectModel,
      transform: _controller.state.transform,
      aspectRatio: _controller.aspectRatio,
      shape: _controller.shape,
      imageSize: _decodedImage != null
          ? Size(
              _decodedImage!.width.toDouble(), _decodedImage!.height.toDouble())
          : Size.zero,
      isReady: _decodedImage != null,
    );
  }

  // ===========================================================================
  // GESTURE HANDLING
  // ===========================================================================

  void _onScaleStart(ScaleStartDetails details) {
    if (_decodedImage == null) return;
    _initialFocalPoint = details.localFocalPoint;
    _initialTransform = _controller.state.transform;
    _initialCropRect = _cropRect;

    final double hitRadius =
        math.max(32.0, widget.configuration.overlay.handleSize);
    if (widget.configuration.overlay.showHandles && _cropRect.width > 0) {
      if ((details.localFocalPoint - _cropRect.topLeft).distance <= hitRadius) {
        _dragMode = _CropDragMode.resizeTopLeft;
      } else if ((details.localFocalPoint - _cropRect.topRight).distance <=
          hitRadius) {
        _dragMode = _CropDragMode.resizeTopRight;
      } else if ((details.localFocalPoint - _cropRect.bottomLeft).distance <=
          hitRadius) {
        _dragMode = _CropDragMode.resizeBottomLeft;
      } else if ((details.localFocalPoint - _cropRect.bottomRight).distance <=
          hitRadius) {
        _dragMode = _CropDragMode.resizeBottomRight;
      } else {
        _dragMode = _CropDragMode.panImage;
      }
    } else {
      _dragMode = _CropDragMode.panImage;
    }

    setState(() {
      _isInteracting = true;
    });
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_decodedImage == null) return;
    final gestures = widget.configuration.gestures;

    if (details.pointerCount > 1) {
      _dragMode = _CropDragMode.panImage;
    }

    if (_dragMode != _CropDragMode.panImage &&
        _dragMode != _CropDragMode.none) {
      final Offset delta = details.localFocalPoint - _initialFocalPoint;
      final aspect = _controller.aspectRatio;
      const double minDim = 48.0;

      double left = _initialCropRect.left;
      double top = _initialCropRect.top;
      double right = _initialCropRect.right;
      double bottom = _initialCropRect.bottom;

      switch (_dragMode) {
        case _CropDragMode.resizeTopLeft:
          left = math.min(_initialCropRect.left + delta.dx, right - minDim);
          top = math.min(_initialCropRect.top + delta.dy, bottom - minDim);
          break;
        case _CropDragMode.resizeTopRight:
          right = math.max(_initialCropRect.right + delta.dx, left + minDim);
          top = math.min(_initialCropRect.top + delta.dy, bottom - minDim);
          break;
        case _CropDragMode.resizeBottomLeft:
          left = math.min(_initialCropRect.left + delta.dx, right - minDim);
          bottom = math.max(_initialCropRect.bottom + delta.dy, top + minDim);
          break;
        case _CropDragMode.resizeBottomRight:
          right = math.max(_initialCropRect.right + delta.dx, left + minDim);
          bottom = math.max(_initialCropRect.bottom + delta.dy, top + minDim);
          break;
        default:
          break;
      }

      if (!aspect.isFree && aspect.ratio != null) {
        final double ratio = aspect.ratio!;
        final double currentW = right - left;
        final double currentH = bottom - top;
        if (currentW / currentH > ratio) {
          final double targetW = currentH * ratio;
          if (_dragMode == _CropDragMode.resizeTopLeft ||
              _dragMode == _CropDragMode.resizeBottomLeft) {
            left = right - targetW;
          } else {
            right = left + targetW;
          }
        } else {
          final double targetH = currentW / ratio;
          if (_dragMode == _CropDragMode.resizeTopLeft ||
              _dragMode == _CropDragMode.resizeTopRight) {
            top = bottom - targetH;
          } else {
            bottom = top + targetH;
          }
        }
      }

      left = left.clamp(0.0, _viewportSize.width - minDim);
      top = top.clamp(0.0, _viewportSize.height - minDim);
      right = right.clamp(left + minDim, _viewportSize.width);
      bottom = bottom.clamp(top + minDim, _viewportSize.height);

      setState(() {
        _cropRect = Rect.fromLTRB(left, top, right, bottom);
      });
      _updateEngineState();
      return;
    }

    Offset newOffset = _initialTransform.offset;
    if (gestures.enablePan) {
      final Offset focalDelta = details.localFocalPoint - _initialFocalPoint;
      newOffset = _initialTransform.offset + focalDelta;
    }

    double newScale = _initialTransform.scale;
    if (gestures.enableZoom) {
      newScale = (_initialTransform.scale * details.scale).clamp(
        gestures.minZoom,
        gestures.maxZoom,
      );
    }

    double newRotation = _initialTransform.rotationDegrees;
    if (gestures.enableRotationGesture && details.rotation != 0.0) {
      final double deltaDeg = details.rotation * (180.0 / math.pi);
      newRotation = (_initialTransform.rotationDegrees + deltaDeg) % 360.0;
    }

    final updatedTransform = _initialTransform.copyWith(
      offset: newOffset,
      scale: newScale,
      rotationDegrees: newRotation,
    );

    _controller.updateTransform(updatedTransform);

    if (newScale != _initialTransform.scale) {
      widget.onZoomChanged?.call(newScale);
    }
    if (newRotation != _initialTransform.rotationDegrees) {
      widget.onRotationChanged?.call(newRotation);
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    _dragMode = _CropDragMode.none;
    setState(() {
      _isInteracting = false;
    });
  }

  void _onDoubleTap() {
    final gestures = widget.configuration.gestures;
    if (!gestures.enableDoubleTapZoom) return;

    final double currentZoom = _controller.zoom;
    final double targetZoom = (currentZoom > gestures.minZoom + 0.1)
        ? gestures.minZoom
        : gestures.doubleTapZoomFactor
            .clamp(gestures.minZoom, gestures.maxZoom);

    unawaited(_controller.animateToZoom(targetZoom));
  }

  // ===========================================================================
  // CROP ENGINE DELEGATE IMPLEMENTATION
  // ===========================================================================

  @override
  ui.Image? get activeImage => _decodedImage;

  @override
  Rect get viewportRect => Offset.zero & _viewportSize;

  @override
  Rect get fittedImageRect => _fittedImageRect;

  @override
  CropperConfiguration get activeConfiguration => widget.configuration;

  @override
  CropProcessor get processor => widget.processor;

  @override
  Future<void> animateTransform(
    CropTransform target, {
    Duration duration = const Duration(milliseconds: 250),
    Curve curve = Curves.easeOutCubic,
  }) {
    final completer = Completer<void>();
    _animController.duration = duration;
    _transformAnimation = _TransformTween(
      begin: _controller.state.transform,
      end: target,
    ).animate(CurvedAnimation(parent: _animController, curve: curve));

    _animController.forward(from: 0.0).whenComplete(() {
      completer.complete();
    });
    return completer.future;
  }

  @override
  void updateCropWindow(Rect newRect) {
    setState(() {
      _cropRect = newRect;
    });
    _updateEngineState();
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Image cropper viewport',
      container: true,
      child: Container(
        color: widget.theme.backgroundColor,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final Size size = constraints.biggest;
            if (size != _viewportSize) {
              _viewportSize = size;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _calculateBounds();
              });
            }

            if (_imageError != null) {
              return widget.errorBuilder != null
                  ? widget.errorBuilder!(context, _imageError!)
                  : Center(
                      child: Text(
                        'Failed to load image: $_imageError',
                        style: TextStyle(color: widget.theme.textColor),
                      ),
                    );
            }

            if (_isLoading || _decodedImage == null) {
              return widget.loadingBuilder != null
                  ? widget.loadingBuilder!(context)
                  : Center(
                      child: Text(
                        'Loading image...',
                        style: TextStyle(
                          color: widget.theme.secondaryTextColor,
                          fontSize: 14.0,
                        ),
                      ),
                    );
            }

            final transform = _controller.state.transform;
            final overlayConfig = widget.configuration.overlay.copyWith(
              overlayColor: widget.theme.overlayColor,
              borderColor: widget.theme.cropBorderColor,
              handleColor: widget.theme.cropHandleColor,
              shape: _controller.shape,
            );

            final gridConfig = widget.configuration.grid.copyWith(
              gridColor: widget.theme.cropGridColor,
            );

            return Stack(
              fit: StackFit.expand,
              children: [
                // 1. Gesture detector & image rendering
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onScaleStart: _onScaleStart,
                  onScaleUpdate: _onScaleUpdate,
                  onScaleEnd: _onScaleEnd,
                  onDoubleTap: _onDoubleTap,
                  child: ClipRect(
                    child: RepaintBoundary(
                      child: CustomPaint(
                        painter: _CropperImagePainter(
                          image: _decodedImage!,
                          fittedRect: _fittedImageRect,
                          transform: transform,
                          antialiasing: widget
                              .configuration.processing.enableAntialiasing,
                        ),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                ),

                // 2. Overlay cutout and border
                if (widget.showOverlay) ...[
                  if (widget.overlayBuilder != null)
                    widget.overlayBuilder!(context, _cropRect)
                  else ...[
                    IgnorePointer(
                      child: RepaintBoundary(
                        child: CropOverlay(
                          cropRect: _cropRect,
                          configuration: overlayConfig,
                        ),
                      ),
                    ),

                    // 3. Composition grid lines
                    if (gridConfig.showGrid &&
                        (!gridConfig.showOnlyOnInteraction || _isInteracting))
                      IgnorePointer(
                        child: RepaintBoundary(
                          child: CropGrid(
                            cropRect: _cropRect,
                            configuration: gridConfig,
                            shape: _controller.shape,
                            cornerRadius: overlayConfig.cornerRadius,
                          ),
                        ),
                      ),

                    // 4. Corner handles
                    if (overlayConfig.showHandles)
                      IgnorePointer(
                        child: RepaintBoundary(
                          child: CropHandles(
                            cropRect: _cropRect,
                            configuration: overlayConfig,
                          ),
                        ),
                      ),
                  ],
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Custom painter for drawing the transformed source image efficiently on the GPU.
class _CropperImagePainter extends CustomPainter {
  const _CropperImagePainter({
    required this.image,
    required this.fittedRect,
    required this.transform,
    required this.antialiasing,
  });

  final ui.Image image;
  final Rect fittedRect;
  final CropTransform transform;
  final bool antialiasing;

  @override
  void paint(Canvas canvas, Size size) {
    if (fittedRect.isEmpty) return;

    canvas.save();

    final Offset center = fittedRect.center;
    canvas.translate(
      center.dx + transform.offset.dx,
      center.dy + transform.offset.dy,
    );

    if (transform.rotationDegrees != 0.0) {
      canvas.rotate(transform.rotationRadians);
    }

    final double sx =
        (transform.isFlippedHorizontal ? -1.0 : 1.0) * transform.scale;
    final double sy =
        (transform.isFlippedVertical ? -1.0 : 1.0) * transform.scale;
    canvas.scale(sx, sy);

    canvas.translate(-center.dx, -center.dy);

    final paint = Paint()
      ..isAntiAlias = antialiasing
      ..filterQuality = FilterQuality.high;

    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      fittedRect,
      paint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CropperImagePainter oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.fittedRect != fittedRect ||
        oldDelegate.transform != transform ||
        oldDelegate.antialiasing != antialiasing;
  }
}

/// Tween interpolation for smooth [CropTransform] animations.
class _TransformTween extends Tween<CropTransform> {
  _TransformTween({required super.begin, required super.end});

  @override
  CropTransform lerp(double t) {
    final b = begin ?? CropTransform.identity;
    final e = end ?? CropTransform.identity;

    return CropTransform(
      offset: Offset.lerp(b.offset, e.offset, t) ?? Offset.zero,
      scale: ui.lerpDouble(b.scale, e.scale, t) ?? 1.0,
      rotationDegrees:
          ui.lerpDouble(b.rotationDegrees, e.rotationDegrees, t) ?? 0.0,
      isFlippedHorizontal:
          t < 0.5 ? b.isFlippedHorizontal : e.isFlippedHorizontal,
      isFlippedVertical: t < 0.5 ? b.isFlippedVertical : e.isFlippedVertical,
    );
  }
}

enum _CropDragMode {
  none,
  panImage,
  resizeTopLeft,
  resizeTopRight,
  resizeBottomLeft,
  resizeBottomRight,
}

extension _ScopeExtension<T> on T {
  R let<R>(R Function(T it) block) => block(this);
}

/// Convenient alias for [AdvancedCropper] matching package name.
typedef FlutterCropImage = AdvancedCropper;

/// Convenient alias for [AdvancedCropper].
typedef CropImage = AdvancedCropper;
