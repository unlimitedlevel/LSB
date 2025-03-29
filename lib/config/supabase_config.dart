import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'secure_keys.dart';

class SupabaseConfig {
  // Instance SecureKeys
  static final _secureKeys = SecureKeys();

  // Cached values
  static String? _cachedUrl;
  static String? _cachedAnonKey;
  static String? _cachedVisionApiKey;
  static String? _cachedGeminiApiKey;

  // Initialize dan cache keys
  static Future<void> initialize() async {
    if (kReleaseMode) {
      _cachedUrl = await _secureKeys.getSupabaseUrl();
      _cachedAnonKey = await _secureKeys.getSupabaseAnonKey();
      _cachedVisionApiKey = await _secureKeys.getVisionApiKey();
      _cachedGeminiApiKey = await _secureKeys.getGeminiApiKey();
    }
  }

  // Supabase URL
  static String get url {
    if (kReleaseMode) {
      return _cachedUrl ?? '';
    }
    return dotenv.env['SUPABASE_URL'] ?? '';
  }

  // Supabase Anon Key
  static String get anonKey {
    if (kReleaseMode) {
      return _cachedAnonKey ?? '';
    }
    return dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  }

  // Ini tetap dari .env karena hanya digunakan di server-side
  static String get serviceRoleKey =>
      dotenv.env['SUPABASE_SERVICE_ROLE_KEY'] ?? '';
  static String get functionName =>
      dotenv.env['SUPABASE_FUNCTION_NAME'] ?? 'process-hazard-report';

  // Google Cloud Vision API key untuk OCR
  static String get visionApiKey {
    if (kReleaseMode) {
      return _cachedVisionApiKey ?? '';
    }
    return dotenv.env['GOOGLE_VISION_API_KEY'] ?? '';
  }

  // Google Gemini API key untuk proses AI
  static String get geminiApiKey {
    if (kReleaseMode) {
      return _cachedGeminiApiKey ?? '';
    }
    return dotenv.env['GOOGLE_GEMINI_API_KEY'] ?? '';
  }

  // Google Cloud Project ID (opsional, untuk kebutuhan tertentu)
  static String get googleCloudProjectId =>
      dotenv.env['GOOGLE_CLOUD_PROJECT_ID'] ?? '';
}
