import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

/// Bridge untuk mendapatkan API key dari platform native
/// dengan cara yang lebih aman (menggunakan platform channels)
class SecureApiBridge {
  static const _channel = MethodChannel('com.lsb.ocr/secure_keys');
  static final _logger = Logger('SecureApiBridge');

  /// Mendapatkan API key dari platform native
  /// Untuk Android akan mengambil dari BuildConfig
  /// Untuk iOS akan mengambil dari Info.plist atau keychain
  static Future<String> getApiKey(String keyName) async {
    try {
      final String result = await _channel.invokeMethod('getApiKey', {
        'keyName': keyName,
      });
      return result;
    } on PlatformException catch (e) {
      _logger.warning('Error getting API key: ${e.message}');
      return '';
    } catch (e) {
      _logger.severe('Unexpected error: $e');
      return '';
    }
  }
}
