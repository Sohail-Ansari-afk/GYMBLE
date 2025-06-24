import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/gym.dart';
import '../services/api_service.dart';

final gymRepositoryProvider = Provider<GymRepository>((ref) {
  return GymRepository(
    apiService: ApiService(),
  );
});

class GymRepository extends ChangeNotifier {
  final ApiService _apiService;
  static const String gymBoxName = 'gymBox';
  static const String gymsKey = 'allGyms';
  
  List<Gym>? _gyms;
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<Gym>? get gyms => _gyms;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  GymRepository({
    required ApiService apiService,
  }) : _apiService = apiService;
  
  // Initialize Hive
  static Future<void> init() async {
    Hive.registerAdapter(GymAdapter());
    await Hive.openBox<List<dynamic>>(gymBoxName);
  }
  
  // Get gyms from local storage
  List<Gym>? getCachedGyms() {
    final box = Hive.box<List<dynamic>>(gymBoxName);
    final gyms = box.get(gymsKey);
    if (gyms != null) {
      return gyms.cast<Gym>();
    }
    return null;
  }
  
  // Save gyms to local storage
  Future<void> cacheGyms(List<Gym> gyms) async {
    final box = Hive.box<List<dynamic>>(gymBoxName);
    await box.put(gymsKey, gyms);
  }
  
  // Fetch gyms from API
  Future<List<Gym>> getGyms({bool forceRefresh = false, String? token}) async {
    if (_isLoading) return _gyms ?? [];
    
    _setLoading(true);
    _clearError();
    
    if (!forceRefresh && _gyms != null && _gyms!.isNotEmpty) {
      _setLoading(false);
      return _gyms!;
    }
    
    if (!forceRefresh) {
      final cachedGyms = getCachedGyms();
      if (cachedGyms != null && cachedGyms.isNotEmpty) {
        _gyms = cachedGyms;
        _setLoading(false);
        notifyListeners();
        return cachedGyms;
      }
    }
    
    try {
      final gyms = await _apiService.getGyms(token: token);
      await cacheGyms(gyms);
      _gyms = gyms;
      notifyListeners();
      return gyms;
    } catch (e) {
      final errorMessage = e is ApiException 
          ? e.message 
          : 'Failed to fetch gyms: ${e.toString()}';
      _setError(errorMessage);
      
      // Return cached gyms if available, otherwise return empty list
      final cachedGyms = getCachedGyms();
      if (cachedGyms != null && cachedGyms.isNotEmpty) {
        _gyms = cachedGyms;
        notifyListeners();
        return cachedGyms;
      }
      return [];
    } finally {
      _setLoading(false);
    }
  }
  
  // Get gym by ID
  Future<Gym?> getGymById(String id) async {
    try {
      final gyms = await getGyms();
      return gyms.firstWhere((gym) => gym.id == id, 
          orElse: () => throw ApiException('Gym not found'));
    } catch (e) {
      final errorMessage = e is ApiException 
          ? e.message 
          : 'Failed to find gym: ${e.toString()}';
      _setError(errorMessage);
      return null;
    }
  }
  
  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String? errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
    notifyListeners();
  }
}