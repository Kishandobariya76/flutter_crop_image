import 'package:flutter/material.dart';
import '../configuration/crop_aspect_ratio.dart';
import '../configuration/crop_shape.dart';
import '../configuration/cropper_theme.dart';
import '../controller/crop_controller.dart';

/// Ready-to-use, accessible toolbar controls for image cropping.
///
/// Provides rotation, flipping, aspect ratio picking, zoom slider,
/// and reset actions, visually styled according to [CropperTheme].
class DefaultCropperControls extends StatelessWidget {
  /// Creates a [DefaultCropperControls] toolbar.
  const DefaultCropperControls({
    super.key,
    required this.controller,
    this.theme = const CropperTheme(),
    this.showAspectRatioSelector = true,
    this.showShapeSelector = true,
    this.showZoomSlider = true,
    this.showRotateButtons = true,
    this.showFlipButtons = true,
    this.showResetButton = true,
  });

  /// The active crop controller.
  final CropController controller;

  /// Active theme styling.
  final CropperTheme theme;

  /// Whether to display the aspect ratio selection bar.
  final bool showAspectRatioSelector;

  /// Whether to display shape toggles (e.g. circle, rectangle).
  final bool showShapeSelector;

  /// Whether to display the interactive zoom slider.
  final bool showZoomSlider;

  /// Whether to display left and right rotation buttons.
  final bool showRotateButtons;

  /// Whether to display horizontal and vertical flip buttons.
  final bool showFlipButtons;

  /// Whether to display the reset button.
  final bool showResetButton;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (BuildContext context, _) {
        final state = controller.state;
        final config = controller.configuration;

        return Container(
          color: theme.toolbarColor,
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Aspect Ratio Selector
              if (showAspectRatioSelector && config.aspectRatios.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: config.aspectRatios.map((ratio) {
                      final isSelected = state.aspectRatio == ratio;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: _AspectChip(
                          ratio: ratio,
                          isSelected: isSelected,
                          theme: theme,
                          onTap: () => controller.setAspectRatio(ratio),
                        ),
                      );
                    }).toList(),
                  ),
                ),

              // 2. Zoom Slider
              if (showZoomSlider)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 2.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.zoom_out,
                        color: theme.secondaryTextColor,
                        size: 20.0,
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: theme.primaryColor,
                            inactiveTrackColor:
                                theme.secondaryTextColor.withValues(alpha: 0.3),
                            thumbColor: theme.primaryColor,
                            overlayColor:
                                theme.primaryColor.withValues(alpha: 0.2),
                            trackHeight: 3.0,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 7.0),
                          ),
                          child: Slider(
                            value: state.zoom.clamp(
                              config.gestures.minZoom,
                              config.gestures.maxZoom,
                            ),
                            min: config.gestures.minZoom,
                            max: config.gestures.maxZoom,
                            onChanged: (val) => controller.setZoom(val),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.zoom_in,
                        color: theme.secondaryTextColor,
                        size: 20.0,
                      ),
                      SizedBox(
                        width: 42.0,
                        child: Text(
                          '${state.zoom.toStringAsFixed(1)}x',
                          style: TextStyle(
                            color: theme.textColor,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),

              // 3. Action Buttons (Rotate, Flip, Shapes, Reset)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (showRotateButtons) ...[
                      _ToolbarIconButton(
                        icon: Icons.rotate_90_degrees_ccw,
                        tooltip: 'Rotate Left',
                        theme: theme,
                        onPressed: controller.rotateLeft,
                      ),
                      _ToolbarIconButton(
                        icon: Icons.rotate_90_degrees_cw,
                        tooltip: 'Rotate Right',
                        theme: theme,
                        onPressed: controller.rotateRight,
                      ),
                    ],
                    if (showFlipButtons) ...[
                      _ToolbarIconButton(
                        icon: Icons.flip,
                        tooltip: 'Flip Horizontal',
                        theme: theme,
                        isActive: state.isFlippedHorizontal,
                        onPressed: controller.flipHorizontal,
                      ),
                      _ToolbarIconButton(
                        icon: Icons.flip,
                        tooltip: 'Flip Vertical',
                        transform: Matrix4.rotationZ(
                            1.5708), // 90 deg visual indicator
                        theme: theme,
                        isActive: state.isFlippedVertical,
                        onPressed: controller.flipVertical,
                      ),
                    ],
                    if (showShapeSelector) ...[
                      _ToolbarIconButton(
                        icon: Icons.crop_square,
                        tooltip: 'Rectangle Shape',
                        theme: theme,
                        isActive: state.shape == CropShape.rectangle,
                        onPressed: () =>
                            controller.setCropShape(CropShape.rectangle),
                      ),
                      _ToolbarIconButton(
                        icon: Icons.circle_outlined,
                        tooltip: 'Circle Shape',
                        theme: theme,
                        isActive: state.shape == CropShape.circle,
                        onPressed: () =>
                            controller.setCropShape(CropShape.circle),
                      ),
                    ],
                    if (showResetButton)
                      _ToolbarIconButton(
                        icon: Icons.restart_alt,
                        tooltip: 'Reset Transformations',
                        theme: theme,
                        onPressed: controller.reset,
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AspectChip extends StatelessWidget {
  const _AspectChip({
    required this.ratio,
    required this.isSelected,
    required this.theme,
    required this.onTap,
  });

  final CropAspectRatio ratio;
  final bool isSelected;
  final CropperTheme theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? theme.primaryColor : theme.backgroundColor,
      borderRadius: BorderRadius.circular(theme.borderRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(theme.borderRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          child: Text(
            ratio.label ?? ratio.toString(),
            style: TextStyle(
              color: isSelected ? Colors.white : theme.textColor,
              fontSize: 12.0,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolbarIconButton extends StatelessWidget {
  const _ToolbarIconButton({
    required this.icon,
    required this.tooltip,
    required this.theme,
    required this.onPressed,
    this.isActive = false,
    this.transform,
  });

  final IconData icon;
  final String tooltip;
  final CropperTheme theme;
  final VoidCallback onPressed;
  final bool isActive;
  final Matrix4? transform;

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = Icon(
      icon,
      color: isActive ? theme.activeIconColor : theme.iconColor,
      size: 22.0,
    );

    if (transform != null) {
      iconWidget = Transform(
        alignment: Alignment.center,
        transform: transform!,
        child: iconWidget,
      );
    }

    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: iconWidget,
      splashRadius: 20.0,
    );
  }
}
