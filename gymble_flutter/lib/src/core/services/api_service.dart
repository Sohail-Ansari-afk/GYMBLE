import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/gym.dart';
import '../config/env_config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? details;

  ApiException(this.message, {this.statusCode, this.details});

  @override
  String toString() => 'ApiException: $message${statusCode != null ? ' (Status code: $statusCode)' : ''}${details != null ? '\nDetails: $details' : ''}';
}

class ApiService {
  // Use centralized environment configuration
  static String get baseUrl => EnvConfig.apiBaseUrl;
  
  // Authentication endpoints
  static String get loginEndpoint => '$baseUrl/auth/login';
  static String get registerEndpoint => '$baseUrl/auth/register';
  static String get forgotPasswordEndpoint => '$baseUrl/auth/forgot-password';
  
  // Gym endpoints
  static String get gymsEndpoint => '$baseUrl/gyms';
  
  // Check-in endpoints
  static String get checkinsEndpoint => '$baseUrl/api/checkins';
  
  final http.Client _client;
  
  ApiService({http.Client? client}) : _client = client ?? http.Client();
  
  // Helper method to handle HTTP errors
  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        throw ApiException('Failed to parse response: $e');
      }
    } else {
      Map<String, dynamic> errorData = {};
      try {
        errorData = jsonDecode(response.body);
      } catch (_) {
        // If we can't parse the error response, use a generic message
      }
      
      final errorMessage = errorData['message'] ?? 
                          errorData['detail'] ?? 
                          errorData['error'] ?? 
                          'Request failed with status: ${response.statusCode}';
      
      throw ApiException(
        errorMessage,
        statusCode: response.statusCode,
        details: errorData.toString(),
      );
    }
  }
  
  // Authentication methods
  Future<User> login(String email, String password) async {
    try {
      final response = await _client.post(
        Uri.parse(loginEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      
      final data = await _handleResponse(response);
      
      // Extract token from response
      final String? token = data['access_token'] ?? data['token'];
      
      // If we have user data directly
      if (data.containsKey('user')) {
        final user = User.fromJson(data['user']);
        // Add token to user if available
        return token != null ? user.copyWith(token: token) : user;
      } 
      // If we have user data in the root
      else if (data.containsKey('email')) {
        // Create user with token
        return User.fromJson({...data, 'token': token});
      }
      // If we only have a token, we need to fetch user data
      else if (token != null) {
        // Return minimal user with token, we'll fetch full profile later
        return User(
          id: data['id'] ?? '',
          email: email,
          gymId: data['gym_id'] ?? '',
          token: token,
        );
      } else {
        throw ApiException('Invalid response format');
      }
    } on SocketException {
      throw ApiException('Network error: Unable to connect to server');
    } on TimeoutException {
      throw ApiException('Connection timeout: Server took too long to respond');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to login: $e');
    }
  }
  
  Future<User> register(String email, String password, String gymId) async {
    try {
      final response = await _client.post(
        Uri.parse(registerEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'gym_id': gymId,
        }),
      );
      
      final data = await _handleResponse(response);
      
      // Store the token if it's in the response
      final user = User.fromJson(data['user'] ?? data);
      return user;
    } on SocketException {
      throw ApiException('Network error: Unable to connect to server');
    } on TimeoutException {
      throw ApiException('Connection timeout: Server took too long to respond');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to register: $e');
    }
  }
  
  Future<void> forgotPassword(String email) async {
    try {
      final response = await _client.post(
        Uri.parse(forgotPasswordEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
        }),
      );
      
      await _handleResponse(response);
    } on SocketException {
      throw ApiException('Network error: Unable to connect to server');
    } on TimeoutException {
      throw ApiException('Connection timeout: Server took too long to respond');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to send password reset email: $e');
    }
  }
  
  // Gym methods
  Future<List<Gym>> getGyms({String? token}) async {
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      
      // Add authorization header if token is provided
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await _client.get(
        Uri.parse(gymsEndpoint),
        headers: headers,
      );
      
      final data = await _handleResponse(response);
      final List gymList;
      
      // Handle different response formats
      if (data is List) {
        gymList = data;
      } else if (data is Map && data.containsKey('gyms')) {
        gymList = data['gyms'] as List;
      } else if (data is Map && data.containsKey('data')) {
        gymList = data['data'] as List;
      } else {
        throw ApiException('Unexpected response format');
      }
      
      return gymList.map((gym) => Gym.fromJson(gym)).toList();
    } on SocketException {
      throw ApiException('Network error: Unable to connect to server');
    } on TimeoutException {
      throw ApiException('Connection timeout: Server took too long to respond');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch gyms: $e');
    }
  }
  
  // Check-in methods
  Future<Map<String, dynamic>> checkIn({
    required String method,
    required String code,
    required double latitude,
    required double longitude,
    required String token,
  }) async {
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      
      final response = await _client.post(
        Uri.parse(checkinsEndpoint),
        headers: headers,
        body: jsonEncode({
          'method': method, // 'qr' or 'manual'
          'code': code,
          'coordinates': [latitude, longitude],
        }),
      );
      
      return await _handleResponse(response);
    } on SocketException {
      throw ApiException('Network error: Unable to connect to server');
    } on TimeoutException {
      throw ApiException('Connection timeout: Server took too long to respond');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to check in: $e');
    }
  }
}