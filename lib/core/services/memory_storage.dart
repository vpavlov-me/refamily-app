/// In-memory storage that mimics SharedPreferences API
/// Used when SharedPreferences is not available (no CocoaPods)
class MemoryStorage {
  static final MemoryStorage _instance = MemoryStorage._internal();
  factory MemoryStorage() => _instance;
  MemoryStorage._internal();

  final Map<String, dynamic> _storage = {};

  // String
  String? getString(String key) => _storage[key] as String?;
  Future<bool> setString(String key, String value) async {
    _storage[key] = value;
    return true;
  }

  // Bool
  bool? getBool(String key) => _storage[key] as bool?;
  Future<bool> setBool(String key, bool value) async {
    _storage[key] = value;
    return true;
  }

  // Int
  int? getInt(String key) => _storage[key] as int?;
  Future<bool> setInt(String key, int value) async {
    _storage[key] = value;
    return true;
  }

  // Double
  double? getDouble(String key) => _storage[key] as double?;
  Future<bool> setDouble(String key, double value) async {
    _storage[key] = value;
    return true;
  }

  // StringList
  List<String>? getStringList(String key) => _storage[key] as List<String>?;
  Future<bool> setStringList(String key, List<String> value) async {
    _storage[key] = value;
    return true;
  }

  // Remove
  Future<bool> remove(String key) async {
    _storage.remove(key);
    return true;
  }

  // Clear
  Future<bool> clear() async {
    _storage.clear();
    return true;
  }

  // Contains
  bool containsKey(String key) => _storage.containsKey(key);

  // Keys
  Set<String> getKeys() => _storage.keys.toSet();
}
