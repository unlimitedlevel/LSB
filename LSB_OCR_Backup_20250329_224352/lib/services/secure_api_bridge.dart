import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Bridge untuk mengakses API keys dari native code (Android/iOS)
/// yang disimpan dengan cara yang lebih aman.
class SecureApiBridge {
  static const MethodChannel _channel = MethodChannel(
    'com.example.lsb_ocr/secure_api',
  );

  static Future<String> getApiKey(String keyName) async {
    try {
      final String result = await _channel.invokeMethod('getApiKey', {
        'keyName': keyName,
      });
      return result;
    } on PlatformException catch (e) {
      debugPrint('Error saat mengakses API key: $e');
      return '';
    }
  }
}
