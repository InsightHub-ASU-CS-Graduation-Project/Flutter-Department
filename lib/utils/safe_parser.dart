class SafeParser {
  /// Extracts a String safely from a Map.
  static String getString(Map<String, dynamic>? data, String key, {String defaultValue = ''}) {
    try {
      if (data == null || !data.containsKey(key) || data[key] == null) {
        return defaultValue;
      }
      return data[key].toString();
    } catch (e) {
      return defaultValue;
    }
  }

  /// Extracts a double safely from a Map.
  static double getDouble(Map<String, dynamic>? data, String key, {double defaultValue = 0.0}) {
    try {
      if (data == null || !data.containsKey(key) || data[key] == null) {
        return defaultValue;
      }
      final value = data[key];
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? defaultValue;
      return defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  /// Extracts a List safely from a Map.
  static List<dynamic> getList(Map<String, dynamic>? data, String key, {List<dynamic> defaultValue = const []}) {
    try {
      if (data == null || !data.containsKey(key) || data[key] == null) {
        return defaultValue;
      }
      final value = data[key];
      if (value is List) return value;
      return defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  /// Extracts a Map safely from a Map.
  static Map<String, dynamic> getMap(Map<String, dynamic>? data, String key, {Map<String, dynamic> defaultValue = const {}}) {
    try {
      if (data == null || !data.containsKey(key) || data[key] == null) {
        return defaultValue;
      }
      final value = data[key];
      if (value is Map<String, dynamic>) return value;
      if (value is Map) return Map<String, dynamic>.from(value);
      return defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  /// Extracts a bool safely from a Map.
  static bool getBool(Map<String, dynamic>? data, String key, {bool defaultValue = false}) {
    try {
      if (data == null || !data.containsKey(key) || data[key] == null) {
        return defaultValue;
      }
      final value = data[key];
      if (value is bool) return value;
      if (value is String) {
        final lower = value.toLowerCase().trim();
        return lower == 'true' || lower == '1' || lower == 'yes';
      }
      if (value is int) return value == 1;
      return defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }
}
