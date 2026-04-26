class SafeParser {
  /// Extracts a String safely from a Map.
  static String getString(
    Map<String, dynamic>? data,
    String key, {
    String defaultValue = '',
  }) {
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
  static double getDouble(
    Map<String, dynamic>? data,
    String key, {
    double defaultValue = 0.0,
  }) {
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

  /// Extracts an int safely from a Map.
  static int getInt(
    Map<String, dynamic>? data,
    String key, {
    int defaultValue = 0,
  }) {
    try {
      if (data == null || !data.containsKey(key) || data[key] == null) {
        return defaultValue;
      }
      final value = data[key];
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? defaultValue;
      return defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  /// Extracts a List safely from a Map.
  static List<dynamic> getList(
    Map<String, dynamic>? data,
    String key, {
    List<dynamic> defaultValue = const [],
  }) {
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
  static Map<String, dynamic> getMap(
    Map<String, dynamic>? data,
    String key, {
    Map<String, dynamic> defaultValue = const {},
  }) {
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
  static bool getBool(
    Map<String, dynamic>? data,
    String key, {
    bool defaultValue = false,
  }) {
    try {
      if (data == null) return defaultValue;

      // Try exact key first
      dynamic value = data[key];

      // If null, try PascalCase version (e.g., isEmployed -> IsEmployed)
      if (value == null && key.isNotEmpty) {
        final pascalKey = key[0].toUpperCase() + key.substring(1);
        value = data[pascalKey];
      }

      if (value == null) return defaultValue;

      if (value is bool) return value;
      if (value is String) {
        final lower = value.toLowerCase().trim();
        return lower == 'true' ||
            lower == '1' ||
            lower == 'yes' ||
            lower == 'on';
      }
      if (value is int) return value == 1;
      return defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }
}
