import '../../models/project_config.dart';
import 'extras_generator.dart';

class StorageGenerator extends ExtrasGenerator {
  StorageGenerator({
    required super.config,
    required super.fileWriter,
  });

  @override
  Future<void> generate() async {
    if (config.storageOptions.isEmpty) return;

    await fileWriter.createDirectory('lib/core/storage');

    for (final option in config.storageOptions) {
      switch (option) {
        case Storage.sharedPreferences:
          await fileWriter.writeFile(
            'lib/core/storage/preferences_service.dart',
            _preferencesServiceContent(),
          );
          break;
        case Storage.hive:
          await fileWriter.writeFile(
            'lib/core/storage/hive_service.dart',
            _hiveServiceContent(),
          );
          break;
        case Storage.isar:
          await fileWriter.writeFile(
            'lib/core/storage/isar_service.dart',
            _isarServiceContent(),
          );
          break;
        case Storage.sqflite:
          await fileWriter.writeFile(
            'lib/core/storage/database_service.dart',
            _sqfliteServiceContent(),
          );
          break;
        case Storage.secureStorage:
          await fileWriter.writeFile(
            'lib/core/storage/secure_storage_service.dart',
            _secureStorageServiceContent(),
          );
          break;
      }
    }
  }

  String _preferencesServiceContent() => '''
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  PreferencesService._(this._prefs);

  final SharedPreferences _prefs;

  static Future<PreferencesService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferencesService._(prefs);
  }

  Future<bool> setString(String key, String value) => _prefs.setString(key, value);
  String? getString(String key) => _prefs.getString(key);

  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);
  bool? getBool(String key) => _prefs.getBool(key);

  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);
  int? getInt(String key) => _prefs.getInt(key);

  Future<bool> remove(String key) => _prefs.remove(key);
  Future<bool> clear() => _prefs.clear();
}
''';

  String _hiveServiceContent() => '''
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  HiveService._();
  static final HiveService instance = HiveService._();

  Future<void> init() async {
    await Hive.initFlutter();
  }

  Future<Box<T>> openBox<T>(String name) => Hive.openBox<T>(name);

  Future<void> put<T>(String boxName, String key, T value) async {
    final box = await openBox<T>(boxName);
    await box.put(key, value);
  }

  Future<T?> get<T>(String boxName, String key) async {
    final box = await openBox<T>(boxName);
    return box.get(key);
  }

  Future<void> delete(String boxName, String key) async {
    final box = await openBox(boxName);
    await box.delete(key);
  }

  Future<void> closeAll() => Hive.close();
}
''';

  String _isarServiceContent() => '''
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class IsarService {
  IsarService._();
  static final IsarService instance = IsarService._();

  Isar? _isar;

  Isar get db {
    if (_isar == null) {
      throw StateError('IsarService not initialized. Call init() first.');
    }
    return _isar!;
  }

  Future<void> init({required List<CollectionSchema<dynamic>> schemas}) async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(schemas, directory: dir.path);
  }

  Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }
}
''';

  String _sqfliteServiceContent() => '''
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  Database? _db;

  Database get db {
    if (_db == null) {
      throw StateError('DatabaseService not initialized. Call init() first.');
    }
    return _db!;
  }

  Future<void> init({String dbName = 'app.db', int version = 1}) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, dbName);
    _db = await openDatabase(
      path,
      version: version,
      onCreate: (db, version) async {
        // TODO: create your tables here.
      },
    );
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
''';

  String _secureStorageServiceContent() => '''
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService._();
  static final SecureStorageService instance = SecureStorageService._();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> write(String key, String value) => _storage.write(key: key, value: value);
  Future<String?> read(String key) => _storage.read(key: key);
  Future<void> delete(String key) => _storage.delete(key: key);
  Future<void> deleteAll() => _storage.deleteAll();
}
''';
}