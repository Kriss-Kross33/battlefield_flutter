/// {@template refresh_token_response}
/// Response object containing a newly issued access token.
/// {@endtemplate}
class RefreshTokenResponse {
  /// {@macro refresh_token_response}
  const RefreshTokenResponse({
    required this.accessToken,
    required this.expiresIn,
  });

  /// The new JWT access token
  final String accessToken;

  /// Seconds until the access token expires
  final int expiresIn;

  /// Convert to JSON for API responses
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'expires_in': expiresIn,
    };
  }
}
