class AuthTokens {
  final String accessToken;
  final String refreshToken;

  const AuthTokens({required this.accessToken, required this.refreshToken});

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;

    return AuthTokens(
      accessToken: data['access_token']?.toString() ?? '',
      refreshToken: data['refresh_token']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'access_token': accessToken, 'refresh_token': refreshToken};
  }

  bool get isValid {
    return accessToken.isNotEmpty && refreshToken.isNotEmpty;
  }
}
