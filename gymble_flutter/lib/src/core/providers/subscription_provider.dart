import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/subscription.dart';
import '../services/subscription_service.dart';
import 'auth_provider.dart';

part 'subscription_provider.g.dart';

enum SubscriptionLoadingState {
  initial,
  loading,
  loaded,
  error,
}

class SubscriptionState {
  final Subscription? subscription;
  final SubscriptionLoadingState loadingState;
  final String? errorMessage;

  SubscriptionState({
    this.subscription,
    this.loadingState = SubscriptionLoadingState.initial,
    this.errorMessage,
  });

  SubscriptionState copyWith({
    Subscription? subscription,
    SubscriptionLoadingState? loadingState,
    String? errorMessage,
    bool clearError = false,
    bool clearSubscription = false,
  }) {
    return SubscriptionState(
      subscription: clearSubscription ? null : (subscription ?? this.subscription),
      loadingState: loadingState ?? this.loadingState,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// Provider for the subscription service
@riverpod
SubscriptionService subscriptionService(SubscriptionServiceRef ref) {
  return SubscriptionService();
}

// Provider for the subscription state
@riverpod
class SubscriptionNotifier extends _$SubscriptionNotifier {
  @override
  SubscriptionState build() {
    return SubscriptionState();
  }

  // Fetch the current subscription
  Future<void> fetchCurrentSubscription() async {
    final authState = ref.read(authStateProvider);
    final token = authState.user?.token;

    if (token == null) {
      state = state.copyWith(
        loadingState: SubscriptionLoadingState.error,
        errorMessage: 'Authentication required',
      );
      return;
    }

    state = state.copyWith(loadingState: SubscriptionLoadingState.loading, clearError: true);

    try {
      final subscriptionService = ref.read(subscriptionServiceProvider);
      final subscription = await subscriptionService.getCurrentSubscription(token);

      state = state.copyWith(
        subscription: subscription,
        loadingState: SubscriptionLoadingState.loaded,
      );
    } catch (e) {
      state = state.copyWith(
        loadingState: SubscriptionLoadingState.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Renew subscription
  Future<bool> renewSubscription({
    required String planId,
    required String paymentMethod,
    required String transactionId,
  }) async {
    final authState = ref.read(authStateProvider);
    final token = authState.user?.token;

    if (token == null) {
      state = state.copyWith(
        loadingState: SubscriptionLoadingState.error,
        errorMessage: 'Authentication required',
      );
      return false;
    }

    state = state.copyWith(loadingState: SubscriptionLoadingState.loading, clearError: true);

    try {
      final subscriptionService = ref.read(subscriptionServiceProvider);
      final subscription = await subscriptionService.renewSubscription(
        token: token,
        planId: planId,
        paymentMethod: paymentMethod,
        transactionId: transactionId,
      );

      state = state.copyWith(
        subscription: subscription,
        loadingState: SubscriptionLoadingState.loaded,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        loadingState: SubscriptionLoadingState.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  // Cancel subscription
  Future<bool> cancelSubscription() async {
    final authState = ref.read(authStateProvider);
    final token = authState.user?.token;

    if (token == null) {
      state = state.copyWith(
        loadingState: SubscriptionLoadingState.error,
        errorMessage: 'Authentication required',
      );
      return false;
    }

    state = state.copyWith(loadingState: SubscriptionLoadingState.loading, clearError: true);

    try {
      final subscriptionService = ref.read(subscriptionServiceProvider);
      await subscriptionService.cancelSubscription(token);

      // Update the subscription status to cancelled
      if (state.subscription != null) {
        state = state.copyWith(
          subscription: state.subscription!.copyWith(
            status: SubscriptionStatus.cancelled,
          ),
          loadingState: SubscriptionLoadingState.loaded,
        );
      } else {
        state = state.copyWith(loadingState: SubscriptionLoadingState.loaded);
      }
      return true;
    } catch (e) {
      state = state.copyWith(
        loadingState: SubscriptionLoadingState.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  // Verify payment
  Future<bool> verifyPayment(String transactionId) async {
    state = state.copyWith(loadingState: SubscriptionLoadingState.loading, clearError: true);

    try {
      final subscriptionService = ref.read(subscriptionServiceProvider);
      final isVerified = await subscriptionService.verifyPayment(transactionId);

      state = state.copyWith(loadingState: SubscriptionLoadingState.loaded);
      return isVerified;
    } catch (e) {
      state = state.copyWith(
        loadingState: SubscriptionLoadingState.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }
}

// Convenience providers
@riverpod
Subscription? currentSubscription(CurrentSubscriptionRef ref) {
  final subscriptionState = ref.watch(subscriptionNotifierProvider);
  return subscriptionState.subscription;
}

@riverpod
bool hasActiveSubscription(HasActiveSubscriptionRef ref) {
  final subscription = ref.watch(currentSubscriptionProvider);
  return subscription != null && subscription.status == SubscriptionStatus.active;
}

@riverpod
bool isSubscriptionExpiringSoon(IsSubscriptionExpiringSoonRef ref) {
  final subscription = ref.watch(currentSubscriptionProvider);
  return subscription != null && subscription.isExpiringSoon;
}

@riverpod
int daysRemainingInSubscription(DaysRemainingInSubscriptionRef ref) {
  final subscription = ref.watch(currentSubscriptionProvider);
  return subscription?.daysRemaining ?? 0;
}