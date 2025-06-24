import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/gym.dart';
import '../repositories/gym_repository.dart';
import '../services/api_service.dart';
import 'api_provider.dart';
import 'auth_provider.dart';

enum GymStatus { initial, loading, loaded, error }

// Provider for the GymRepository
final gymRepositoryProvider = Provider<GymRepository>((ref) {
  return GymRepository(
    apiService: ref.watch(apiServiceProvider),
  );
});

// Provider to listen to changes in the GymRepository
final gymRepositoryChangeProvider = ChangeNotifierProvider<GymRepository>((ref) {
  return ref.watch(gymRepositoryProvider);
});

// Provider for the list of gyms
final gymsProvider = Provider<List<Gym>>((ref) {
  final gymRepo = ref.watch(gymRepositoryChangeProvider);
  return gymRepo.gyms ?? [];
});

// Provider for the loading state
final gymLoadingProvider = Provider<bool>((ref) {
  final gymRepo = ref.watch(gymRepositoryChangeProvider);
  return gymRepo.isLoading;
});

// Provider for the error state
final gymErrorProvider = Provider<String?>((ref) {
  final gymRepo = ref.watch(gymRepositoryChangeProvider);
  return gymRepo.error;
});

// Provider for gym actions
final gymNotifierProvider = Provider<GymNotifier>((ref) {
  final gymRepo = ref.watch(gymRepositoryProvider);
  final authState = ref.watch(authStateProvider);
  return GymNotifier(gymRepo, authState.user?.token);
});

// Class to handle gym actions
class GymNotifier {
  final GymRepository _gymRepository;
  final String? _token;

  GymNotifier(this._gymRepository, this._token);

  Future<List<Gym>> fetchGyms({bool forceRefresh = false}) async {
    return await _gymRepository.getGyms(
      forceRefresh: forceRefresh,
      token: _token,
    );
  }

  Future<Gym?> getGymById(String id) async {
    return await _gymRepository.getGymById(id);
  }
  
  // Alias for fetchGyms with forceRefresh=true
  Future<List<Gym>> refreshGyms() async {
    return fetchGyms(forceRefresh: true);
  }
}

final gymNotifierProvider = StateNotifierProvider<GymNotifier, GymState>((ref) {
  final gymRepository = ref.watch(gymRepositoryProvider);
  final authNotifier = ref.watch(authNotifierProvider.notifier);
  return GymNotifier(gymRepository, authNotifier);
});