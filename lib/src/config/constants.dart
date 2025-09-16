class SDKConstants {
  // Production endpoints
  static const String sdkApiUrlProd = 'https://backend-sdk.larkfinserv.in';
  static const String sdkUrlProd = 'https://sdk-fe.larkfinserv.in';

  // Sandbox/local endpoints (adjust as needed)
  static const String sdkApiUrlSandbox = 'http://localhost:8080';
  static const String sdkUrlSandbox = 'https://localhost:3000';

  static String get sdkApiUrl =>
      _currentEnvironment == 'production' ? sdkApiUrlProd : sdkApiUrlSandbox;
  static String get sdkUrl =>
      _currentEnvironment == 'production' ? sdkUrlProd : sdkUrlSandbox;

  static String _currentEnvironment = 'production';

  static void setEnvironment(String environment) {
    if (environment != 'production' && environment != 'sandbox') {
      _currentEnvironment = 'production';
      return;
    }
    _currentEnvironment = environment;
  }

  static const String sdkVersion = '1.0.1';
  static const String sdkPlatform = 'flutter';

  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
