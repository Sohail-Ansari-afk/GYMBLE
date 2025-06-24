import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';

enum AuthStatus { initial, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? error;

  AuthState({
    required this.status,
    this.user,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}

// Provider for the AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// Provider to listen to changes in the AuthRepository
final authRepositoryChangeProvider = ChangeNotifierProvider<AuthRepository>((ref) {
  return ref.watch(authRepositoryProvider);
});

// Provider for the current authentication state
final authStateProvider = Provider<AuthState>((ref) {
  final authRepo = ref.watch(authRepositoryChangeProvider);
  
  if (authRepo.isLoading) {
    return AuthState(status: AuthStatus.initial);
  }
  
  if (authRepo.isAuthenticated) {
    return AuthState(
      status: AuthStatus.authenticated,
      user: authRepo.currentUser,
    );
  } else {
    return AuthState(
      status: AuthStatus.unauthenticated,
      error: authRepo.error,
    );
  }
});

// Provider for the current user
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.user;
});

// Provider for the authentication status
final authStatusProvider = Provider<AuthStatus>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.status;
});

// Provider for authentication actions
final authNotifierProvider = Provider<AuthNotifier>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepo);
});

// Class to handle authentication actions
class AuthNotifier {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository);

  Future<void> initialize() async {
    await _authRepository.initialize();
  }

  Future<bool> login(String email, String password) async {
    return await _authRepository.login(email, password);
  }

  Future<bool> register(String email, String password, String gymId) async {
    return await _authRepository.register(email, password, gymId);
  }

  Future<void> logout() async {
    await _authRepository.logout();
  }
  
  Future<bool> forgotPassword(String email) async {
    return await _authRepository.forgotPassword(email);
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});