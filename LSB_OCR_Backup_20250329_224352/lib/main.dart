import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/home_screen.dart';
import 'config/supabase_config.dart';
import 'utils/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi data locale untuk format tanggal
  await initializeDateFormatting('id_ID');
  Intl.defaultLocale = 'id_ID';

  // Load .env file (hanya untuk development)
  await dotenv.load(fileName: '.env').catchError((e) {
    debugPrint('Warning: .env file not found or invalid: $e');
  });

  // Initialize secure keys for release mode
  await SupabaseConfig.initialize();

  // Initialize Supabase if URL and key are available
  try {
    final url = SupabaseConfig.url;
    final anonKey = SupabaseConfig.anonKey;

    if (url.isNotEmpty && anonKey.isNotEmpty) {
      await Supabase.initialize(url: url, anonKey: anonKey);
      debugPrint('Supabase initialized successfully');
    } else {
      debugPrint(
        'Warning: Supabase URL or Anon Key is empty, skipping initialization',
      );
    }
  } catch (e) {
    debugPrint('Error initializing Supabase: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LSB OCR',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme().copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      home: const HomeScreen(),
    );
  }
}
