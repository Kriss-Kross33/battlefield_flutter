/// Exception is thrown when notification couldn't be get

class FCMServiceException implements Exception {
  /// {@macro trip_repository_exception}
  const FCMServiceException(this.error, this.stackTrace);

  /// The [Exception] which was thrown.
  final Exception? error;

  /// The full [StackTrace].
  final StackTrace? stackTrace;
}

class GetTokenException extends FCMServiceException {
  GetTokenException({
    Exception? error,
    StackTrace? stackTrace,
  }) : super(error, stackTrace);
}

class DeleteTokenException extends FCMServiceException {
  DeleteTokenException({
    Exception? error,
    StackTrace? stackTrace,
  }) : super(error, stackTrace);
}
