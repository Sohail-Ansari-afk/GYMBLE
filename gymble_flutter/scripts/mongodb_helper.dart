import 'package:mongo_dart/mongo_dart.dart';
import '../lib/src/core/config/env_config.dart';

class MongoDBHelper {
  static Db? _db;
  // Use centralized environment configuration
  static String get connectionString => EnvConfig.mongoDbUrl;
  static String get dbName => EnvConfig.mongoDbName;

  /// Initialize the MongoDB connection
  static Future<bool> connect() async {
    if (_db == null || !_db!.isConnected) {
      try {
        print('Connecting to MongoDB at $connectionString');
        _db = await Db.create(connectionString);
        await _db!.open();
        print('Connected to MongoDB successfully');
        // Test the connection by listing collections
        final collections = await _db!.getCollectionNames();
        print('Available collections: $collections');
        return true;
      } catch (e) {
        print('Error connecting to MongoDB: $e');
        return false;
      }
    }
    return _db!.isConnected;
  }

  /// Close the MongoDB connection
  static Future<void> close() async {
    if (_db != null && _db!.isConnected) {
      await _db!.close();
      print('Disconnected from MongoDB');
    }
  }

  /// Get a collection from the database
  static DbCollection getCollection(String collectionName) {
    if (_db == null || !_db!.isConnected) {
      throw Exception('Database not connected. Call connect() first.');
    }
    return _db!.collection(collectionName);
  }

  /// Insert a document into a collection
  static Future<WriteResult> insertDocument(String collectionName, Map<String, dynamic> document) async {
    final collection = getCollection(collectionName);
    return await collection.insert(document);
  }

  /// Find documents in a collection
  static Future<List<Map<String, dynamic>>> findDocuments(String collectionName, {Map<String, dynamic>? query}) async {
    final collection = getCollection(collectionName);
    final cursor = await collection.find(query ?? {});
    return await cursor.toList();
  }

  /// Update documents in a collection
  static Future<WriteResult> updateDocuments(String collectionName, Map<String, dynamic> selector, Map<String, dynamic> update) async {
    final collection = getCollection(collectionName);
    return await collection.update(selector, update);
  }

  /// Delete documents from a collection
  static Future<WriteResult> deleteDocuments(String collectionName, Map<String, dynamic> selector) async {
    final collection = getCollection(collectionName);
    return await collection.remove(selector);
  }
}