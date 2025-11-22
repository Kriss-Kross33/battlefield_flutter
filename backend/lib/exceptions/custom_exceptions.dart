/// {@template invalid_email_or_password_exception}
/// Exception thrown when the email or password is invalid.
/// {@endtemplate}
class InvalidEmailOrPasswordException implements Exception {
  /// {@macro invalid_email_or_password_exception}
  const InvalidEmailOrPasswordException({required this.message});

  /// The message of the exception
  final String message;

  @override
  String toString() => message;
}

/// {@template player_already_exists_exception}
/// Exception thrown when the player already exists.
/// {@endtemplate}
class PlayerAlreadyExistsException implements Exception {
  /// {@macro player_already_exists_exception}
  const PlayerAlreadyExistsException({required this.message});

  /// The message of the exception
  final String message;

  @override
  String toString() => message;
}

/// {@template player_not_found_exception}
/// Exception thrown when the player is not found.
/// {@endtemplate}
class PlayerNotFoundException implements Exception {
  /// {@macro player_not_found_exception}
  const PlayerNotFoundException({required this.message});

  /// The message of the exception
  final String message;

  @override
  String toString() => message;
}

/// {@template session_not_found_exception}
/// Exception thrown when the session is not found.
/// {@endtemplate}
class SessionNotFoundException implements Exception {
  /// {@macro session_not_found_exception}
  const SessionNotFoundException({required this.message});

  /// The message of the exception
  final String message;

  @override
  String toString() => message;
}

/// {@template session_expired_exception}
/// Exception thrown when the session is expired.
/// {@endtemplate}
class SessionExpiredException implements Exception {
  /// {@macro session_expired_exception}
  const SessionExpiredException({required this.message});

  /// The message of the exception
  final String message;

  @override
  String toString() => message;
}

/// {@template session_expired_exception}
/// Exception thrown when the error is not known.
/// {@endtemplate}
class UnkownException implements Exception {
  /// {@macro session_expired_exception}
  const UnkownException({required this.message});

  /// The message of the exception
  final String message;

  @override
  String toString() => message;
}
