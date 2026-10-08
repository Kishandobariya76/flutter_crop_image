/// Exception thrown when an image crop or transformation operation fails.
class CropException implements Exception {
  /// Creates a [CropException] with a descriptive [message] and optional [cause].
  const CropException(this.message, [this.cause]);

  /// Human-readable explanation of why the crop failed.
  final String message;

  /// The underlying cause or exception, if any.
  final Object? cause;

  @override
  String toString() {
    if (cause != null) {
      return 'CropException: $message (Caused by: $cause)';
    }
    return 'CropException: $message';
  }
}
