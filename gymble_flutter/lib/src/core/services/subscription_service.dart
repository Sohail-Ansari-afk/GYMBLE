import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/subscription.dart';
import '../config/env_config.dart';
import 'api_service.dart';

class SubscriptionService {
  static String get baseUrl => EnvConfig.apiBaseUrl;
  static String get subscriptionsEndpoint => '$baseUrl/subscriptions';
  static String get paymentsEndpoint => '$baseUrl/payments';
  
  final http.Client _client;
  final ApiService _apiService;
  
  SubscriptionService({
    http.Client? client,
    ApiService? apiService,
  }) : 
    _client = client ?? http.Client(),
    _apiService = apiService ?? ApiService();
  
  // Get current subscription for the user
  Future<Subscription?> getCurrentSubscription(String token) async {
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      
      final response = await _client.get(
        Uri.parse('$subscriptionsEndpoint/current'),
        headers: headers,
      );
      
      final data = await _apiService._handleResponse(response);
      
      if (data == null || (data is Map && data.isEmpty)) {
        return null; // No active subscription
      }
      
      return Subscription.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch subscription: $e');
    }
  }
  
  // Renew subscription
  Future<Subscription> renewSubscription({
    required String token,
    required String planId,
    required String paymentMethod,
    required String transactionId,
  }) async {
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      
      final response = await _client.post(
        Uri.parse('$subscriptionsEndpoint/renew'),
        headers: headers,
        body: jsonEncode({
          'plan_id': planId,
          'payment_method': paymentMethod,
          'transaction_id': transactionId,
        }),
      );
      
      final data = await _apiService._handleResponse(response);
      return Subscription.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to renew subscription: $e');
    }
  }
  
  // Cancel subscription
  Future<void> cancelSubscription(String token) async {
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      
      final response = await _client.post(
        Uri.parse('$subscriptionsEndpoint/cancel'),
        headers: headers,
      );
      
      await _apiService._handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to cancel subscription: $e');
    }
  }
  
  // Generate UPI payment link
  String generateUpiLink({
    required String payeeName,
    required String payeeVpa,
    required double amount,
    required String transactionNote,
    String? referenceId,
  }) {
    final upiParams = {
      'pa': payeeVpa, // Payee VPA (UPI ID)
      'pn': payeeName, // Payee name
      'am': amount.toString(), // Amount
      'tn': transactionNote, // Transaction note
      'cu': 'INR', // Currency (Indian Rupee)
    };
    
    // Add reference ID if provided
    if (referenceId != null) {
      upiParams['tr'] = referenceId; // Transaction reference ID
    }
    
    // Build the UPI URL
    final queryString = upiParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    
    return 'upi://pay?$queryString';
  }
  
  // Mock method to simulate payment verification
  // In a real app, this would verify the payment with the payment gateway
  Future<bool> verifyPayment(String transactionId) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    // For demo purposes, consider all payments successful
    return true;
  }
}