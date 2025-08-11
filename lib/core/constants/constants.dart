import 'dart:io';

class Constants {
  // Smart backend URI that adapts to the platform
  static String get backendUri {
    if (Platform.isAndroid) {
      // Android emulator uses 10.0.2.2 to access host machine
      return "http://10.0.2.2:8000";
    } else if (Platform.isIOS) {
      // iOS simulator can use localhost
      return "http://localhost:8000";
    } else {
      // For web, desktop, or other platforms
      return "http://localhost:8000";
    }
  }

  // Alternative: manually override for physical devices
  // static String backendUri = "http://192.168.1.100:8000"; // Replace with your machine's IP
}
