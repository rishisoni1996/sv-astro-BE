class TokenRefreshResponse {
  final String? token;
  final String? refreshToken;
  final int? tokenExpires;

  TokenRefreshResponse({this.token, this.refreshToken, this.tokenExpires});

  factory TokenRefreshResponse.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;
    return TokenRefreshResponse(
      token: data['token'] as String?,
      refreshToken: data['refreshToken'] as String?,
      tokenExpires: data['tokenExpires'] as int?,
    );
  }
}
