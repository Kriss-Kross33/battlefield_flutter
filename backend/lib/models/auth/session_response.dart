/// {@template session_response}
/// Response object containing both access and refresh tokens.
/// {@endtemplate}
class SessionResponse {
  /// {@macro session_response}
  const SessionResponse({
    required this.userId,
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiry,
    required this.refreshTokenExpiry,
  });

  /// The id of the user who has created the session
  final String userId;

  /// The JWT access token (short-lived, ~15 minutes)
  final String accessToken;

  /// The refresh token (long-lived, ~7 days)
  final String refreshToken;

  /// When the access token expires
  final DateTime accessTokenExpiry;

  /// When the refresh token expires
  final DateTime refreshTokenExpiry;

  /// Convert to JSON for API responses
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'access_token_expiry': accessTokenExpiry.toIso8601String(),
      'refresh_token_expiry': refreshTokenExpiry.toIso8601String(),
      'access_token_expires_in':
          accessTokenExpiry.difference(DateTime.now()).inSeconds,
      'refresh_token_expires_in':
          refreshTokenExpiry.difference(DateTime.now()).inSeconds,
    };
  }
}
