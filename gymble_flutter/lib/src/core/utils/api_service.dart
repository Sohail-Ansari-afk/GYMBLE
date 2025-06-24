import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env_config.dart';

class ApiService {
  static String get baseUrl => EnvConfig.apiBaseUrl;
  static const int timeoutDuration = 15; // seconds

  // Headers that will be sent with every request
  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Add auth token to headers if available
  static Map<String, String> _getAuthHeaders(String? token) {
    final headers = Map<String, String>.from(_headers);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // GET request
  static Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint').replace(
        queryParameters: queryParams,
      );

      final response = await http
          .get(
            uri,
            headers: _getAuthHeaders(token),
          )
          .timeout(const Duration(seconds: timeoutDuration));

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // POST request
  static Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      final response = await http
          .post(
            uri,
            headers: _getAuthHeaders(token),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: timeoutDuration));

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // PUT request
  static Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      final response = await http
          .put(
            uri,
            headers: _getAuthHeaders(token),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: timeoutDuration));

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // DELETE request
  static Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      final response = await http
          .delete(
            uri,
            headers: _getAuthHeaders(token),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: timeoutDuration));

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Handle API response
  static Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final responseBody = response.body.isNotEmpty
        ? jsonDecode(response.body) as Map<String, dynamic>
        : <String, dynamic>{};

    if (statusCode >= 200 && statusCode < 300) {
      return responseBody;
    } else {
      final error = responseBody['error'] ?? 'Unknown error occurred';
      throw Exception('API Error: $error (Status Code: $statusCode)');
    }
  }

  // Handle errors
  static Map<String, dynamic> _handleError(dynamic error) {
    print('API Service Error: $error');
    throw Exception('Failed to complete request: $error');
  }
}