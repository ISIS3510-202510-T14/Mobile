// lib/src/config.dart
class Config {
  static const String apiBaseUrl =
    String.fromEnvironment('API_BASE_URL',
      defaultValue: 'http://localhost:8080'
    );
}
