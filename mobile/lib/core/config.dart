/// The release pipeline supplies the verified HTTPS API through `API_URL`.
/// Keeping the emulator default makes local development work without ever
/// guessing a production domain.
class AppConfig {
  static const String developmentUrl = 'http://10.0.2.2:8000/api';
  static const String _definedApiUrl = String.fromEnvironment('API_URL');
  static String get apiUrl => _definedApiUrl.isNotEmpty ? _definedApiUrl : developmentUrl;
  static bool get isProduction => _definedApiUrl.startsWith('https://');
}
