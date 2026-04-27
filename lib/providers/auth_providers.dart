import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../models/auth_token.dart';
import '../services/auth_service.dart';
import '../services/user_profile_services.dart';

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

  AuthNotifier(this._authService, this._userService) : super(const AuthState());

  // register now requires username
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

  // identifier can be email or username — matches API's LoginRequest
  Future<void> login(String identifier, String password) async {
    state = const AuthState(isLoading: true);
    try {
      final tokens = await _authService.login(identifier, password);
      final user = await _userService.getMe(tokens.accessToken);
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
      state = AuthState(tokens: tokens, user: user);
    } catch (e) {
      state = AuthState(error: e.toString());
    }
  }

  Future<void> refreshTokens() async {
    final current = state.tokens;
    if (current == null) return;
    try {
      final newTokens = await _authService.refreshTokens(current.refreshToken);
      state = AuthState(tokens: newTokens, user: state.user);
    } catch (e) {
      state = const AuthState();
    }
  }

  // logout now passes both accessToken and refreshToken
  Future<void> logout() async {
    final tokens = state.tokens;
    if (tokens != null) {
      try {
        await _authService.logout(
          accessToken: tokens.accessToken,
          refreshToken: tokens.refreshToken,
        );
      } catch (_) {
        // ignore backend logout failure and clear local state
      }
    }
    state = const AuthState();
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
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final dio = Dio();
  final authService = AuthService(dio: dio);
  final userService = UserService(dio: dio);
  return AuthNotifier(authService, userService);
});
