import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  // Stream untuk memantau perubahan status otentikasi
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Mendapatkan pengguna saat ini
  User? get currentUser => _client.auth.currentUser;

  // Mendapatkan ID pengguna saat ini
  String? get currentUserId => currentUser?.id;

  // Mendapatkan nama/email pengguna (contoh, mungkin perlu disesuaikan)
  String get currentUserDisplayName {
     // Coba ambil dari user_metadata jika ada 'full_name' atau sejenisnya
     final nameFromMetadata = currentUser?.userMetadata?['full_name'] as String?;
     if (nameFromMetadata != null && nameFromMetadata.isNotEmpty) {
       return nameFromMetadata;
     }
     // Jika tidak ada, gunakan email sebagai fallback
     return currentUser?.email ?? 'Pengguna Tidak Dikenal';
  }


  // Fungsi Login
  Future<AuthResponse> signInWithPassword(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      debugPrint('Login successful for user: ${response.user?.email}');
      return response;
    } on AuthException catch (e) {
      debugPrint('AuthException during login: ${e.message}');
      throw Exception('Login Gagal: ${e.message}');
    } catch (e) {
      debugPrint('Unexpected error during login: $e');
      throw Exception('Terjadi kesalahan saat login.');
    }
  }

  // Fungsi Signup (jika diperlukan)
  Future<AuthResponse> signUp(String email, String password, {String? fullName}) async {
     try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : null, // Simpan nama di metadata
      );
       debugPrint('Signup successful for user: ${response.user?.email}');
       // Mungkin perlu konfirmasi email tergantung pengaturan Supabase
       return response;
    } on AuthException catch (e) {
      debugPrint('AuthException during signup: ${e.message}');
      throw Exception('Signup Gagal: ${e.message}');
    } catch (e) {
      debugPrint('Unexpected error during signup: $e');
      throw Exception('Terjadi kesalahan saat signup.');
    }
  }


  // Fungsi Logout
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      debugPrint('User signed out successfully.');
    } catch (e) {
      debugPrint('Error during sign out: $e');
      throw Exception('Gagal logout.');
    }
  }
}
