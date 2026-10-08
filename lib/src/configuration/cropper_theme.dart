import 'package:flutter/widgets.dart';

/// Complete visual styling configuration for the cropper and its UI controls.
///
/// Designed to be completely independent of Flutter Material's [ThemeData],
/// enabling seamless use inside any custom design system, Cupertino app,
/// or brand guideline.
@immutable
class CropperTheme {
  /// Creates a [CropperTheme].
  const CropperTheme({
    this.backgroundColor = const Color(0xFF0F0F12),
    this.toolbarColor = const Color(0xFF18181F),
    this.primaryColor = const Color(0xFF3B82F6),
    this.accentColor = const Color(0xFF60A5FA),
    this.iconColor = const Color(0xFFE2E8F0),
    this.activeIconColor = const Color(0xFF3B82F6),
    this.textColor = const Color(0xFFF8FAFC),
    this.secondaryTextColor = const Color(0xFF94A3B8),
    this.textStyle,
    this.overlayColor = const Color(0xB3000000),
    this.cropBorderColor = const Color(0xFFFFFFFF),
    this.cropHandleColor = const Color(0xFFFFFFFF),
    this.cropGridColor = const Color(0x66FFFFFF),
    this.borderRadius = 8.0,
  });

  /// Default dark theme with modern slate and blue accents.
  static const CropperTheme dark = CropperTheme();

  /// Clean light theme with soft gray and blue accents.
  static const CropperTheme light = CropperTheme(
    backgroundColor: Color(0xFFF1F5F9),
    toolbarColor: Color(0xFFFFFFFF),
    primaryColor: Color(0xFF2563EB),
    accentColor: Color(0xFF3B82F6),
    iconColor: Color(0xFF334155),
    activeIconColor: Color(0xFF2563EB),
    textColor: Color(0xFF0F172A),
    secondaryTextColor: Color(0xFF64748B),
    overlayColor: Color(0x99000000),
    cropBorderColor: Color(0xFF2563EB),
    cropHandleColor: Color(0xFF2563EB),
    cropGridColor: Color(0x662563EB),
  );

  /// Sleek iOS Cupertino-styled dark theme.
  static const CropperTheme cupertinoDark = CropperTheme(
    backgroundColor: Color(0xFF000000),
    toolbarColor: Color(0xCC1C1C1E),
    primaryColor: Color(0xFF0A84FF),
    accentColor: Color(0xFF64D2FF),
    iconColor: Color(0xFFFFFFFF),
    activeIconColor: Color(0xFF0A84FF),
    textColor: Color(0xFFFFFFFF),
    secondaryTextColor: Color(0xFF8E8E93),
    overlayColor: Color(0xB3000000),
    cropBorderColor: Color(0xFFFFFFFF),
    cropHandleColor: Color(0xFFFFFFFF),
    cropGridColor: Color(0x55FFFFFF),
  );

  /// Nord palette aesthetic.
  static const CropperTheme nord = CropperTheme(
    backgroundColor: Color(0xFF2E3440),
    toolbarColor: Color(0xFF3B4252),
    primaryColor: Color(0xFF88C0D0),
    accentColor: Color(0xFF81A1C1),
    iconColor: Color(0xFFECEFF4),
    activeIconColor: Color(0xFF88C0D0),
    textColor: Color(0xFFECEFF4),
    secondaryTextColor: Color(0xFFD8DEE9),
    overlayColor: Color(0xB32E3440),
    cropBorderColor: Color(0xFF88C0D0),
    cropHandleColor: Color(0xFF88C0D0),
    cropGridColor: Color(0x6688C0D0),
  );

  /// Main background color behind the cropper canvas.
  final Color backgroundColor;

  /// Background color of the top and bottom toolbars.
  final Color toolbarColor;

  /// Primary action / highlight color.
  final Color primaryColor;

  /// Accent / hover color.
  final Color accentColor;

  /// Default icon color for toolbar buttons.
  final Color iconColor;

  /// Icon color for currently active tools or toggles.
  final Color activeIconColor;

  /// Primary label text color.
  final Color textColor;

  /// Secondary description / subtle label text color.
  final Color secondaryTextColor;

  /// Base text style applied to labels and captions.
  final TextStyle? textStyle;

  /// Shading color that dims the image outside the active crop frame.
  final Color overlayColor;

  /// Color of the bounding crop border.
  final Color cropBorderColor;

  /// Color of the resize handles at the corners.
  final Color cropHandleColor;

  /// Color of the composition grid lines.
  final Color cropGridColor;

  /// Border radius for toolbar buttons and chips.
  final double borderRadius;

  /// Creates a copy with modified properties.
  CropperTheme copyWith({
    Color? backgroundColor,
    Color? toolbarColor,
    Color? primaryColor,
    Color? accentColor,
    Color? iconColor,
    Color? activeIconColor,
    Color? textColor,
    Color? secondaryTextColor,
    TextStyle? textStyle,
    Color? overlayColor,
    Color? cropBorderColor,
    Color? cropHandleColor,
    Color? cropGridColor,
    double? borderRadius,
  }) {
    return CropperTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      toolbarColor: toolbarColor ?? this.toolbarColor,
      primaryColor: primaryColor ?? this.primaryColor,
      accentColor: accentColor ?? this.accentColor,
      iconColor: iconColor ?? this.iconColor,
      activeIconColor: activeIconColor ?? this.activeIconColor,
      textColor: textColor ?? this.textColor,
      secondaryTextColor: secondaryTextColor ?? this.secondaryTextColor,
      textStyle: textStyle ?? this.textStyle,
      overlayColor: overlayColor ?? this.overlayColor,
      cropBorderColor: cropBorderColor ?? this.cropBorderColor,
      cropHandleColor: cropHandleColor ?? this.cropHandleColor,
      cropGridColor: cropGridColor ?? this.cropGridColor,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CropperTheme &&
        other.backgroundColor == backgroundColor &&
        other.toolbarColor == toolbarColor &&
        other.primaryColor == primaryColor &&
        other.accentColor == accentColor &&
        other.iconColor == iconColor &&
        other.activeIconColor == activeIconColor &&
        other.textColor == textColor &&
        other.secondaryTextColor == secondaryTextColor &&
        other.textStyle == textStyle &&
        other.overlayColor == overlayColor &&
        other.cropBorderColor == cropBorderColor &&
        other.cropHandleColor == cropHandleColor &&
        other.cropGridColor == cropGridColor &&
        other.borderRadius == borderRadius;
  }

  @override
  int get hashCode => Object.hash(
        backgroundColor,
        toolbarColor,
        primaryColor,
        accentColor,
        iconColor,
        activeIconColor,
        textColor,
        secondaryTextColor,
        textStyle,
        overlayColor,
        cropBorderColor,
        cropHandleColor,
        cropGridColor,
        borderRadius,
      );
}
