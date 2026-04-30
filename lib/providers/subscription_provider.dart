import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/subscription_service.dart';
import '../../providers/auth_providers.dart';

// ── State ────────────────────────────────────────────────────────────────────

class SubscriptionState {
  final SubscriptionStatus? status;
  final bool isLoading;
  final bool isUpgrading;
  final String? error;
  final String? successMessage;

  const SubscriptionState({
    this.status,
    this.isLoading = false,
    this.isUpgrading = false,
    this.error,
    this.successMessage,
  });

  bool get isPremium => status?.isPremium ?? false;

  bool isCurrentPlanFor(String billingType) {
    if (!isPremium) return false;
    if (billingType.toLowerCase() == 'monthly')
      return status?.isMonthly ?? false;
    if (billingType.toLowerCase() == 'yearly') return status?.isYearly ?? false;
    return false;
  }

  SubscriptionState copyWith({
    SubscriptionStatus? status,
    bool? isLoading,
    bool? isUpgrading,
    String? error,
    String? successMessage,
  }) {
    return SubscriptionState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      isUpgrading: isUpgrading ?? this.isUpgrading,
      error: error,
      successMessage: successMessage,
    );
  }
}

// ── Notifier ─────────────────────────────────────────────────────────────────

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  SubscriptionNotifier(this._ref) : super(const SubscriptionState()) {
    // Reset and re-fetch whenever the auth token changes (login/logout)
    _ref.listen(authProvider, (previous, next) {
      final prevToken = previous?.tokens?.accessToken;
      final nextToken = next.tokens?.accessToken;
      if (prevToken != nextToken) {
        state = const SubscriptionState(); // clear old state immediately
        if (nextToken != null) fetchStatus(); // fetch for new account
      }
    });
  }

  final Ref _ref;
  final _service = SubscriptionService();

  String? get _token => _ref.read(authProvider).tokens?.accessToken;

  /// Fetch current subscription status from backend.
  Future<void> fetchStatus() async {
    final token = _token;
    if (token == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final status = await _service.getMySubscription(accessToken: token);
      state = state.copyWith(isLoading: false, status: status);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Upgrade to Premium.
  /// [isYearly] determines which endpoint to hit.
  Future<bool> upgrade({
    required String paymentToken,
    required bool isYearly,
  }) async {
    final token = _token;
    if (token == null) {
      state = state.copyWith(error: 'Not logged in.');
      return false;
    }
    state = state.copyWith(isUpgrading: true);
    try {
      final message = await _service.upgrade(
        accessToken: token,
        paymentToken: paymentToken,
        isYearly: isYearly,
      );
      await fetchStatus();
      state = state.copyWith(isUpgrading: false, successMessage: message);
      return true;
    } catch (e) {
      state = state.copyWith(
        isUpgrading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  void clearError() => state = state.copyWith(error: null);
  void clearSuccess() => state = state.copyWith(successMessage: null);
}

// ── Provider ─────────────────────────────────────────────────────────────────

final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>(
      (ref) => SubscriptionNotifier(ref),
    );
