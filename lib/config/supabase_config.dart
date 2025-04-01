import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class SupabaseConfig {
  // Supabase URL
  static String get url => dotenv.env['SUPABASE_URL'] ?? '';

  // Supabase Anon Key
  static String get anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // Ini tetap dari .env karena hanya digunakan di server-side
  static String get serviceRoleKey =>
      dotenv.env['SUPABASE_SERVICE_ROLE_KEY'] ?? '';
  static String get functionName =>
      dotenv.env['SUPABASE_FUNCTION_NAME'] ?? 'process-hazard-report';

  // Google Cloud Vision API key untuk OCR
  static String get visionApiKey => dotenv.env['GOOGLE_VISION_API_KEY'] ?? '';

  // Google Gemini API key untuk proses AI
  static String get geminiApiKey {
    final key =
        dotenv.env['GEMINI_API_KEY'] ??
        dotenv.env['GOOGLE_GEMINI_API_KEY'] ??
        '';
    if (key.isEmpty) {
      debugPrint('Warning: No Gemini API key found in environment variables');
    }
    return key;
  }

  // Google Cloud Project ID (opsional, untuk kebutuhan tertentu)
  static String get googleCloudProjectId =>
      dotenv.env['GOOGLE_CLOUD_PROJECT_ID'] ?? '';
}
