import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/secure_api_bridge.dart';

/// Kelas untuk mengelola akses ke API key dengan lebih aman.
/// Pada mode rilis akan mengambil key dari BuildConfig (Android)
/// atau secure storage, bukan dari .env
class SecureKeys {
  // Instance Singleton
  static final SecureKeys _instance = SecureKeys._internal();
  factory SecureKeys() => _instance;
  SecureKeys._internal();

  // Flag jika app berjalan dalam mode rilis
  bool get isReleaseMode => kReleaseMode;

  // Method untuk mendapatkan Vision API Key dengan cara yang lebih aman
  Future<String> getVisionApiKey() async {
    if (isReleaseMode) {
      if (Platform.isAndroid || Platform.isIOS) {
        return await SecureApiBridge.getApiKey('VISION_API_KEY');
      } else {
        // Untuk web atau platform lain, gunakan metode khusus
        return '';
      }
    } else {
      // Dalam mode debug tetap gunakan dotenv
      return dotenv.env['GOOGLE_VISION_API_KEY'] ?? '';
    }
  }

  // Method untuk mendapatkan Gemini API Key
  Future<String> getGeminiApiKey() async {
    if (isReleaseMode) {
      if (Platform.isAndroid || Platform.isIOS) {
        return await SecureApiBridge.getApiKey('GEMINI_API_KEY');
      } else {
        return '';
      }
    } else {
      // Periksa kedua kunci yang mungkin
      final key =
          dotenv.env['GEMINI_API_KEY'] ??
          dotenv.env['GOOGLE_GEMINI_API_KEY'] ??
          '';
      return key;
    }
  }

  // Method untuk mendapatkan Supabase URL
  Future<String> getSupabaseUrl() async {
    if (isReleaseMode) {
      if (Platform.isAndroid || Platform.isIOS) {
        return await SecureApiBridge.getApiKey('SUPABASE_URL');
      } else {
        return '';
      }
    } else {
      return dotenv.env['SUPABASE_URL'] ?? '';
    }
  }

  // Method untuk mendapatkan Supabase Anon Key
  Future<String> getSupabaseAnonKey() async {
    if (isReleaseMode) {
      if (Platform.isAndroid || Platform.isIOS) {
        return await SecureApiBridge.getApiKey('SUPABASE_ANON_KEY');
      } else {
        return '';
      }
    } else {
      return dotenv.env['SUPABASE_ANON_KEY'] ?? '';
    }
  }
}
