import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/auth_token.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/user_profile_services.dart';

// 🔐 Secure storage provider
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

class AuthState {
  final AuthTokens? tokens;
  final User? user;
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const AuthState({
    this.tokens,
    this.user,
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  bool get isLoggedIn => tokens != null;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final UserService _userService;
  final FlutterSecureStorage _storage;

  AuthNotifier(this._authService, this._userService, this._storage)
    : super(const AuthState()) {
    _bootstrap(); // 🔥 load saved session on app start
  }

  // ─────────────────────────────────────────────
  // 🔥 BOOTSTRAP (restore login)
  // ─────────────────────────────────────────────
  Future<void> _bootstrap() async {
    try {
      final access = await _storage.read(key: 'access_token');
      final refresh = await _storage.read(key: 'refresh_token');

      if (access == null || refresh == null) return;

      final tokens = AuthTokens(accessToken: access, refreshToken: refresh);

      final user = await _userService.getMe(tokens.accessToken);

      state = AuthState(tokens: tokens, user: user);
    } catch (e) {
      await _storage.deleteAll();
      state = const AuthState();
    }
  }

  // ─────────────────────────────────────────────
  // 💾 SAVE TOKENS
  // ─────────────────────────────────────────────
  Future<void> _saveTokens(AuthTokens tokens) async {
    await _storage.write(key: 'access_token', value: tokens.accessToken);
    await _storage.write(key: 'refresh_token', value: tokens.refreshToken);
  }

  Future<void> _clearTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  // ─────────────────────────────────────────────
  // AUTH METHODS
  // ─────────────────────────────────────────────

  Future<void> login(String identifier, String password) async {
    state = const AuthState(isLoading: true);

    try {
      final tokens = await _authService.login(identifier, password);
      final user = await _userService.getMe(tokens.accessToken);

      await _saveTokens(tokens); // 🔥 persist

      state = AuthState(tokens: tokens, user: user);
    } catch (e) {
      state = AuthState(error: e.toString());
    }
  }

  Future<void> googleLogin(String googleIdToken) async {
    state = const AuthState(isLoading: true);

    try {
      final tokens = await _authService.googleLogin(googleIdToken);
      final user = await _userService.getMe(tokens.accessToken);

      await _saveTokens(tokens);

      state = AuthState(tokens: tokens, user: user);
    } catch (e) {
      state = AuthState(error: e.toString());
    }
  }

  Future<void> facebookLogin(String facebookToken) async {
    state = const AuthState(isLoading: true);

    try {
      final tokens = await _authService.facebookLogin(facebookToken);
      final user = await _userService.getMe(tokens.accessToken);

      await _saveTokens(tokens);

      state = AuthState(tokens: tokens, user: user);
    } catch (e) {
      state = AuthState(error: e.toString());
    }
  }

  Future<void> refreshTokens() async {
    final currentTokens = state.tokens;
    if (currentTokens == null) return;

    try {
      final newTokens = await _authService.refreshTokens(
        currentTokens.refreshToken,
      );

      await _saveTokens(newTokens);

      state = AuthState(tokens: newTokens, user: state.user);
    } catch (_) {
      await _clearTokens();
      state = const AuthState();
    }
  }

  Future<void> logout() async {
    final currentTokens = state.tokens;

    state = AuthState(tokens: state.tokens, user: state.user, isLoading: true);

    if (currentTokens != null) {
      try {
        await _authService.logout(
          accessToken: currentTokens.accessToken,
          refreshToken: currentTokens.refreshToken,
        );
      } catch (_) {}
    }

    await _clearTokens(); // 🔥 clear storage
    state = const AuthState();
  }

  // ─────────────────────────────────────────────
  // OTHER (unchanged)
  // ─────────────────────────────────────────────

  Future<void> register({
    required String email,
    required String username,
    required String password,
    required String displayName,
    String accountType = 'listener',
  }) async {
    state = const AuthState(isLoading: true);

    try {
      await _authService.register(
        email: email,
        username: username,
        password: password,
        displayName: displayName,
        accountType: accountType,
      );

      state = const AuthState(
        successMessage: 'Account created! Check your email to verify.',
      );
    } catch (e) {
      state = AuthState(error: e.toString());
    }
  }

  Future<void> verifyEmail(String token) async {
    state = const AuthState(isLoading: true);

    try {
      await _authService.verifyEmail(token);

      state = const AuthState(
        successMessage: 'Email verified! You can now log in.',
      );
    } catch (e) {
      state = AuthState(error: e.toString());
    }
  }

  Future<void> resendVerification(String email) async {
    state = const AuthState(isLoading: true);

    try {
      await _authService.resendVerification(email);

      state = const AuthState(successMessage: 'Verification email resent.');
    } catch (e) {
      state = AuthState(error: e.toString());
    }
  }

  Future<void> forgotPassword(String email) async {
    state = const AuthState(isLoading: true);

    try {
      await _authService.forgotPassword(email);

      state = const AuthState(
        successMessage:
            'If an account with that email exists, a reset link has been sent.',
      );
    } catch (e) {
      state = AuthState(error: e.toString());
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
    state = const AuthState(isLoading: true);

    try {
      await _authService.resetPassword(token, newPassword);

      state = const AuthState(
        successMessage: 'Password updated successfully. You can now log in.',
      );
    } catch (e) {
      state = AuthState(error: e.toString());
    }
  }

  void clearMessages() {
    state = AuthState(
      tokens: state.tokens,
      user: state.user,
      isLoading: state.isLoading,
    );
  }
}

// ─────────────────────────────────────────────

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final dio = Dio();
  final authService = AuthService(dio: dio);
  final userService = UserService(dio: dio);
  final storage = ref.read(secureStorageProvider);

  return AuthNotifier(authService, userService, storage);
});
