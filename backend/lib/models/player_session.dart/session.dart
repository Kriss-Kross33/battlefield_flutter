import 'package:stormberry/stormberry.dart';

part 'session.schema.dart';

/// {@template session}
/// Represents a user session.
/// {@endtemplate}
@Model()
abstract class PlayerSession {
  /// {@macro session}
  const PlayerSession({
    required this.id,
    required this.token,
    required this.userId,
    required this.expiryDate,
    required this.createdAt,
    this.refreshExpiry,
    this.lastRefreshedAt,
    this.refreshToken,
  });

  /// The player session id.
  @PrimaryKey()
  final String id;

  /// The session token.
  final String token;

  /// The refresh token
  final String? refreshToken;

  /// The user id.
  final String userId;

  /// The session expiry date.
  final DateTime expiryDate;

  /// The refresh token expiry
  final DateTime? refreshExpiry;

  /// The session creation date.
  final DateTime createdAt;

  /// The last refresh time
  final DateTime? lastRefreshedAt;
}
