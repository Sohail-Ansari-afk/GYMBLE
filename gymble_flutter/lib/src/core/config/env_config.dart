import 'dart:io' show File, Platform;
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;

/// Environment configuration for the app
class EnvConfig {
  static Map<String, String> _envVars = {};
  
  // API configuration
  static String get apiBaseUrl => 
      _envVars['API_BASE_URL'] ?? 
      _getPlatformEnv('API_BASE_URL') ?? 
      'http://localhost:8000/api';
  
  // MongoDB configuration
  static String get mongoDbUrl => 
      _envVars['MONGO_URL'] ?? 
      _getPlatformEnv('MONGO_URL') ?? 
      'mongodb://localhost:27017/gymble';
  
  static String get mongoDbName => 
      _envVars['DB_NAME'] ?? 
      _getPlatformEnv('DB_NAME') ?? 
      'gymble';
  
  // JWT configuration
  static String get jwtSecretKey => 
      _envVars['JWT_SECRET_KEY'] ?? 
      _getPlatformEnv('JWT_SECRET_KEY') ?? 
      'fallback-secret-key-for-development-only';
  
  // App configuration
  static bool get isDebugMode => 
      _envVars['DEBUG_MODE']?.toLowerCase() == 'true' || 
      _getPlatformEnv('DEBUG_MODE')?.toLowerCase() == 'true' || 
      kDebugMode; // Default to Flutter's debug mode
      
  // Helper method to safely access platform environment variables
  static String? _getPlatformEnv(String key) {
    try {
      if (kIsWeb) return null;
      return Platform.environment[key];
    } catch (e) {
      return null;
    }
  }
  
  // Initialize environment variables from .env file or other sources
  static Future<void> init() async {
    try {
      // Try to load from .env file
      await dotenv.dotenv.load(fileName: 'assets/.env');
      _envVars = dotenv.dotenv.env;
      print('Loaded environment variables from .env file');
    } catch (e) {
      print('Failed to load .env file: $e');
      print('Using default environment variables');
      
      // Try to create a basic .env file if it doesn't exist and not on web
      if (!kIsWeb) {
        try {
          const envPath = '.env';
          final envFile = File(envPath);
          if (!await envFile.exists()) {
            await envFile.writeAsString('''
# API Configuration
API_BASE_URL=http://localhost:8000/api

# MongoDB Configuration
MONGO_URL=mongodb://localhost:27017/gymble
DB_NAME=gymble

# JWT Configuration
JWT_SECRET_KEY=your-secret-key-for-development-only

# App Configuration
DEBUG_MODE=true
''');
            print('Created default .env file');
          }
        } catch (e) {
          print('Failed to create .env file: $e');
        }
      }
    }
    
    print('Environment configuration initialized');
    print('API Base URL: $apiBaseUrl');
    print('Debug Mode: $isDebugMode');
  }
}