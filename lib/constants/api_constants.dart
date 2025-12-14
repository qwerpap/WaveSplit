class ApiConstants {
  ApiConstants._();

  // Backend base URL. Override with: --dart-define=API_BASE_URL=http://10.0.2.2:8000
  // For iOS Simulator we need to use the host machine's IP
  // For Android Emulator use 10.0.2.2
  // Using host IP for iOS Simulator
  static const String baseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'http://192.168.31.124:8000');
}
