/// This file contains exception classes used in the projection_cs package.
class ProjectionException implements Exception {
  /// Creates a new instance of [ProjectionException] with the provided message.
  ProjectionException(this.message);

  /// The error message associated with the exception.
  final String message;

  @override
  String toString() => 'ProjectionException: $message';
}
