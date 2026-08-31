enum AppEnvironment { development, production }
class AppConfig { static const environment=AppEnvironment.development; static const developmentUrl='http://10.0.2.2:8000/api'; static const productionUrl='https://example.com/api'; static String get apiUrl=>environment==AppEnvironment.production?productionUrl:developmentUrl; }
