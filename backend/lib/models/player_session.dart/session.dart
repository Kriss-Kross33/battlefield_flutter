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

  @PrimaryKey()
  final String id;

  /// The session token.
  final String token;

  final String? refreshToken;

  /// The user id.
  final String userId;

  /// The session expiry date.
  final DateTime expiryDate;

  final DateTime? refreshExpiry;

  /// The session creation date.
  final DateTime createdAt;

  final DateTime? lastRefreshedAt;
}
