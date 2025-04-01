import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:io';
import 'config/app_theme.dart';
import 'config/supabase_config.dart';
import 'screens/main_screen.dart';
import 'screens/login_screen.dart'; // Import LoginScreen
import 'services/auth_service.dart'; // Import AuthService
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase for AuthState

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize locale data for date formatting
  await initializeDateFormatting('id_ID', null);

  // Load .env file dengan robust error handling
  await dotenv
      .load(fileName: '.env')
      .then((value) {
        debugPrint('Successfully loaded .env file');
        // Tambahan debug untuk mengetahui isi environment variablesnys
        debugPrint('Environment variables loaded:');
        debugPrint(
          'GEMINI_API_KEY: ${dotenv.env['GEMINI_API_KEY']?.isNotEmpty}',
        );
        debugPrint(
          'GOOGLE_GEMINI_API_KEY: ${dotenv.env['GOOGLE_GEMINI_API_KEY']?.isNotEmpty}',
        );
        debugPrint('SUPABASE_URL: ${dotenv.env['SUPABASE_URL']?.isNotEmpty}');
      })
      .catchError((e) {
        debugPrint('Warning: .env file not found or invalid: $e');
        debugPrint('Working directory: ${Directory.current.path}');
      });

  // Initialize secure keys for release mode
  await SupabaseConfig.initialize();

  // Verify env values after initialization
  debugPrint(
    'Supabase URL after init: ${SupabaseConfig.url.isNotEmpty ? "Set" : "Empty"}',
  );
  debugPrint(
    'Supabase Anon Key after init: ${SupabaseConfig.anonKey.isNotEmpty ? "Set" : "Empty"}',
  );

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

  // Instance AuthService
  final AuthService authService = AuthService();

  runApp(
    MyApp(authService: authService),
  ); // Kirim instance AuthService ke MyApp
}

class MyApp extends StatelessWidget {
  final AuthService authService; // Terima instance AuthService

  const MyApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LSB OCR',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Atau ThemeMode.light / ThemeMode.dark
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('id', 'ID'), Locale('en', 'US')],
      locale: const Locale('id', 'ID'),
      // --- NONAKTIFKAN PEMERIKSAAN LOGIN SEMENTARA ---
      // Langsung tampilkan MainScreen
      home: MainScreen(authService: authService),
      // home: StreamBuilder<AuthState>(
      //   stream: authService.authStateChanges,
      //   builder: (context, snapshot) {
      //     // Tampilkan loading indicator saat menunggu status auth
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return const Scaffold(body: Center(child: CircularProgressIndicator()));
      //     }

      //     final AuthState? authState = snapshot.data;
      //     // Jika ada sesi aktif (user login)
      //     if (authState != null && authState.session != null) {
      //       // Teruskan instance authService ke MainScreen
      //       return MainScreen(authService: authService); // Tampilkan layar utama
      //     } else {
      //       // Jika tidak ada sesi (user logout atau belum login)
      //       return const LoginScreen(); // Tampilkan layar login
      //     }
      //   },
      // ),
      // --- AKHIR NONAKTIFKAN LOGIN ---
      // initialRoute: '/',
      // routes: {
      //   '/': (context) => const MainScreen(),
      //   '/home': (context) => const HomeScreen(),
      // },
    );
  }
}
