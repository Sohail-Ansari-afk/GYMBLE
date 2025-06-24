import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthRepository extends ChangeNotifier {
  final ApiService _apiService;
  final FlutterSecureStorage _secureStorage;
  
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  
  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null && _currentUser!.token != null;
  
  AuthRepository({
    ApiService? apiService,
    FlutterSecureStorage? secureStorage,
  }) : 
    _apiService = apiService ?? ApiService(),
    _secureStorage = secureStorage ?? const FlutterSecureStorage();
  
  // Initialize repository - check for stored credentials
  Future<void> initialize() async {
    _setLoading(true);
    try {
      final storedToken = await _secureStorage.read(key: 'auth_token');
      final storedUserId = await _secureStorage.read(key: 'user_id');
      final storedEmail = await _secureStorage.read(key: 'user_email');
      final storedGymId = await _secureStorage.read(key: 'user_gym_id');
      
      if (storedToken != null && storedEmail != null) {
        // Create a basic user with stored data
        _currentUser = User(
          id: storedUserId ?? '',
          email: storedEmail,
          token: storedToken,
          gymId: storedGymId ?? '',
        );
        
        // TODO: Fetch full user profile from API
        
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to restore session');
      debugPrint('Error initializing auth: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Login user
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      final user = await _apiService.login(email, password);
      
      // Save user data
      _currentUser = user;
      
      // Store credentials securely
      if (user.token != null) {
        await _secureStorage.write(key: 'auth_token', value: user.token);
        await _secureStorage.write(key: 'user_id', value: user.id);
        await _secureStorage.write(key: 'user_email', value: user.email);
        await _secureStorage.write(key: 'user_gym_id', value: user.gymId);
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      final errorMessage = e is ApiException 
          ? e.message 
          : 'Failed to login. Please check your credentials.';
      _setError(errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Register user
  Future<bool> register(String email, String password, String gymId) async {
    _setLoading(true);
    _clearError();
    
    try {
      final user = await _apiService.register(email, password, gymId);
      
      // Save user data
      _currentUser = user;
      
      // Store credentials securely
      if (user.token != null) {
        await _secureStorage.write(key: 'auth_token', value: user.token);
        await _secureStorage.write(key: 'user_id', value: user.id);
        await _secureStorage.write(key: 'user_email', value: user.email);
        await _secureStorage.write(key: 'user_gym_id', value: user.gymId);
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      final errorMessage = e is ApiException 
          ? e.message 
          : 'Registration failed. Please try again.';
      _setError(errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Forgot password
  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _apiService.forgotPassword(email);
      return true;
    } catch (e) {
      final errorMessage = e is ApiException 
          ? e.message 
          : 'Failed to send password reset email. Please try again.';
      _setError(errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Logout user
  Future<void> logout() async {
    _setLoading(true);
    
    try {
      // Clear secure storage
      await _secureStorage.delete(key: 'auth_token');
      await _secureStorage.delete(key: 'user_id');
      await _secureStorage.delete(key: 'user_email');
      await _secureStorage.delete(key: 'user_gym_id');
      
      // Clear current user
      _currentUser = null;
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to logout properly');
      debugPrint('Error during logout: $e');
    } finally {
      _setLoading(false);
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