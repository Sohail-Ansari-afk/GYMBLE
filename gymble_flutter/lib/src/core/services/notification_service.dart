import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import '../models/subscription.dart';

class NotificationService {
  // This would normally be initialized with Firebase Cloud Messaging
  // For this implementation, we'll use Flutter Local Notifications
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  // Initialize the notification service
  Future<void> initialize() async {
    // Initialize settings for Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // Initialize settings for iOS
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    // Initialize settings for all platforms
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }
  
  // Request notification permissions
  Future<void> requestPermissions() async {
    // Request permissions for iOS
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    
    // Request permissions for Android
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();
  }
  
  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap based on payload
    if (response.payload != null) {
      final Map<String, dynamic> data = json.decode(response.payload!);
      
      // Handle different notification types
      switch (data['type']) {
        case 'subscription_expiring':
          // Navigate to subscription screen
          break;
        case 'subscription_expired':
          // Navigate to renewal screen
          break;
        default:
          // Default action
          break;
      }
    }
  }
  
  // Show a local notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'subscription_channel',
      'Subscription Notifications',
      channelDescription: 'Notifications related to your gym subscription',
      importance: Importance.high,
      priority: Priority.high,
      color: Color(0xFFF8BBD0), // Frost pink color
    );
    
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    
    await _flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }
  
  // Send subscription expiring soon notification
  Future<void> sendSubscriptionExpiringSoonNotification(Subscription subscription) async {
    final daysRemaining = subscription.daysRemaining;
    
    final title = 'Subscription Expiring Soon';
    final body = 'Your ${subscription.planName} subscription will expire in $daysRemaining days. Renew now to avoid interruption.';
    
    final payload = json.encode({
      'type': 'subscription_expiring',
      'subscription_id': subscription.id,
      'days_remaining': daysRemaining,
    });
    
    await showNotification(
      title: title,
      body: body,
      payload: payload,
    );
  }
  
  // Send subscription expired notification
  Future<void> sendSubscriptionExpiredNotification(Subscription subscription) async {
    final title = 'Subscription Expired';
    final body = 'Your ${subscription.planName} subscription has expired. Renew now to continue enjoying your membership benefits.';
    
    final payload = json.encode({
      'type': 'subscription_expired',
      'subscription_id': subscription.id,
    });
    
    await showNotification(
      title: title,
      body: body,
      payload: payload,
    );
  }
  
  // Schedule a notification for subscription expiry warning (7 days before)
  Future<void> scheduleExpiryWarningNotification(Subscription subscription) async {
    // Calculate when to send the notification (7 days before expiry)
    final scheduledDate = subscription.endDate.subtract(const Duration(days: 7));
    
    // Only schedule if the date is in the future
    if (scheduledDate.isAfter(DateTime.now())) {
      final title = 'Subscription Expiring Soon';
      final body = 'Your ${subscription.planName} subscription will expire in 7 days. Renew now to avoid interruption.';
      
      final payload = json.encode({
        'type': 'subscription_expiring',
        'subscription_id': subscription.id,
        'days_remaining': 7,
      });
      
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        1, // Notification ID
        title,
        body,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'subscription_channel',
            'Subscription Notifications',
            channelDescription: 'Notifications related to your gym subscription',
            importance: Importance.high,
            priority: Priority.high,
            color: Color(0xFFF8BBD0), // Frost pink color
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    }
  }
  
  // Schedule daily notifications after subscription expiry
  Future<void> scheduleDailyExpiryNotifications(Subscription subscription) async {
    // Only schedule if the subscription is expired
    if (subscription.isExpired) {
      final title = 'Renew Your Membership';
      final body = 'Your ${subscription.planName} subscription has expired. Renew now to regain access to all features.';
      
      final payload = json.encode({
        'type': 'subscription_expired',
        'subscription_id': subscription.id,
      });
      
      // Schedule a daily notification at 10:00 AM
      final now = DateTime.now();
      final scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        10, // 10:00 AM
        0,
      );
      
      // If it's already past 10:00 AM, schedule for tomorrow
      final finalScheduledDate = now.hour >= 10
          ? scheduledDate.add(const Duration(days: 1))
          : scheduledDate;
      
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        2, // Notification ID
        title,
        body,
        finalScheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'subscription_channel',
            'Subscription Notifications',
            channelDescription: 'Notifications related to your gym subscription',
            importance: Importance.high,
            priority: Priority.high,
            color: Color(0xFFF8BBD0), // Frost pink color
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
        matchDateTimeComponents: DateTimeComponents.time, // Repeat daily at the same time
      );
    }
  }
  
  // Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}