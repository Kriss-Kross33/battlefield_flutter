import 'package:equatable/equatable.dart';

/// {@template session}
/// Represents a user session.
/// {@endtemplate}
class PlayerSession extends Equatable {
  /// {@macro session}
  const PlayerSession({
    required this.token,
    required this.userId,
    required this.expiryDate,
    required this.createdAt,
  });

  /// The session token.
  final String token;

  /// The user id.
  final String userId;

  /// The session expiry date.
  final DateTime expiryDate;

  /// The session creation date.
  final DateTime createdAt;

  @override
  List<Object?> get props => [token, userId, expiryDate, createdAt];
}
