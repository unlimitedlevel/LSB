import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // Private constructor to prevent instantiation
  ApiConfig._();

  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
}
