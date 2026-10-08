/// Supported image formats for exported cropped images.
enum CropImageFormat {
  /// Portable Network Graphics format (supports full alpha channel transparency).
  png,

  /// Joint Photographic Experts Group format (compressed, no alpha channel).
  jpeg,

  /// WebP format.
  webp,

  /// Raw uncompressed RGBA pixel bytes.
  rawRgba,
}
