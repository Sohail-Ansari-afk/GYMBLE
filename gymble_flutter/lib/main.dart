import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymble_flutter/src/app.dart';
import 'package:gymble_flutter/src/core/services/notification_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gymble_flutter/src/core/models/subscription.dart';

// Provider for the notification service
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(SubscriptionAdapter());
  Hive.registerAdapter(SubscriptionStatusAdapter());
  
  // Load environment variables
  await dotenv.load();
  
  // Create ProviderContainer to initialize services before the app starts
  final container = ProviderContainer();
  
  // Initialize notification service
  final notificationService = container.read(notificationServiceProvider);
  await notificationService.initialize();
  await notificationService.requestPermissions();
  
  // Run the app with ProviderScope
  runApp(
    ProviderScope(
      parent: container,
      child: const MyApp(),
    ),
  );
}
