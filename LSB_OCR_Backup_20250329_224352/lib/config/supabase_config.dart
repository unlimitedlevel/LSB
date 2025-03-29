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

  // Hard-coded values jika .env tidak tersedia
  static const String _fallbackUrl = 'https://zuqrzeuavfpawxpvcuhg.supabase.co';
  static const String _fallbackAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp1cXJ6ZXVhdmZwYXd4cHZjdWhnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI4ODQ3NTQsImV4cCI6MjA1ODQ2MDc1NH0.E4Y1ZCljEAEyZsMMBmPvhyb6beX2aS0PsXrU5lzoasE';
  static const String _fallbackGeminiApiKey =
      'AIzaSyBRaV8W5egEHdpEzrbKUxBmkLXmYxQPx8w';

  // Initialize dan cache keys
  static Future<void> initialize() async {
    try {
      // Coba baca dari .env file untuk development
      _cachedUrl = dotenv.env['SUPABASE_URL'] ?? '';
      _cachedAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
      _cachedVisionApiKey = dotenv.env['GOOGLE_VISION_API_KEY'] ?? '';
      _cachedGeminiApiKey = dotenv.env['GOOGLE_GEMINI_API_KEY'] ?? '';

      // Jika nilai masih kosong, gunakan fallback
      if (_cachedUrl?.isEmpty == true) {
        _cachedUrl = _fallbackUrl;
      }
      if (_cachedAnonKey?.isEmpty == true) {
        _cachedAnonKey = _fallbackAnonKey;
      }
      if (_cachedGeminiApiKey?.isEmpty == true) {
        _cachedGeminiApiKey = _fallbackGeminiApiKey;
      }

      debugPrint('Supabase URL: $_cachedUrl');
      debugPrint('Supabase configuration initialized');
    } catch (e) {
      // Gunakan fallback jika ada error
      _cachedUrl = _fallbackUrl;
      _cachedAnonKey = _fallbackAnonKey;
      _cachedGeminiApiKey = _fallbackGeminiApiKey;

      debugPrint('Error initializing Supabase configuration: $e');
      debugPrint('Using fallback configuration values');
    }
  }

  // Supabase URL
  static String get url {
    return _cachedUrl ?? _fallbackUrl;
  }

  // Supabase Anon Key
  static String get anonKey {
    return _cachedAnonKey ?? _fallbackAnonKey;
  }

  // Ini tetap dari .env karena hanya digunakan di server-side
  static String get serviceRoleKey =>
      dotenv.env['SUPABASE_SERVICE_ROLE_KEY'] ??
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp1cXJ6ZXVhdmZwYXd4cHZjdWhnIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0Mjg4NDc1NCwiZXhwIjoyMDU4NDYwNzU0fQ.o2piD-18R_ts9HYOHTCYSXOt-AWw-PdYWa9RqE9mRx8';
  static String get functionName =>
      dotenv.env['SUPABASE_FUNCTION_NAME'] ?? 'process-hazard-report';

  // Google Cloud Vision API key untuk OCR
  static String get visionApiKey {
    return _cachedVisionApiKey ?? 'AIzaSyCgjEuXtbEtxnDUKu7P-VVtXNmtfoS0_Gc';
  }

  // Google Gemini API key untuk proses AI
  static String get geminiApiKey {
    return _cachedGeminiApiKey ?? _fallbackGeminiApiKey;
  }

  // Google Cloud Project ID (opsional, untuk kebutuhan tertentu)
  static String get googleCloudProjectId =>
      dotenv.env['GOOGLE_CLOUD_PROJECT_ID'] ?? '';

  // Storage bucket name
  static const String storageBucket = 'hazard-images';

  // S3 Access Keys - digunakan untuk akses bucket langsung jika getBucket gagal
  static const String s3AccessKeyId = 'd32e0ad8b843a1f1b4bb44ff4b6d4f55';
  static const String s3SecretAccessKey =
      'c0d9b27e08c55d024d5d53dad43ce81cf4a15b71864861af6cf97d54423f6c57';

  // Database table names
  static const String hazardReportsTable = 'hazard_reports';

  // RLS helper
  static const bool applyRLS = true;

  // PostgreSQL Connection Info
  static String postgresHost = 'aws-0-ap-southeast-1.pooler.supabase.com';
  static int postgresPort = 5432;
  static String postgresDatabase = 'postgres';
  static String postgresUser = 'postgres.zuqrzeuavfpawxpvcuhg';
  static String postgresPassword = '';

  // JWT Secret (untuk kebutuhan auth)
  static String get jwtSecret =>
      dotenv.env['JWT_SECRET'] ??
      'W+oDN2lqDCXPZ2VGXDc/6R6Dh6SKax7cgDFJ//OZBL/ztJnxm7vGZxNNPwfngTegbjBl3i8lWfovej4xAAmTwQ==';
}
