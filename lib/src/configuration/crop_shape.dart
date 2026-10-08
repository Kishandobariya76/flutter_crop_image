/// Geometric shapes supported for image crop windows.
enum CropShape {
  /// Standard rectangular crop window.
  rectangle,

  /// Circular crop window (outputs with transparent background or mask).
  circle,

  /// Oval / elliptical crop window fitting the bounding rectangle.
  oval,

  /// Rectangle with rounded corners defined by cornerRadius.
  roundedRectangle,
}
