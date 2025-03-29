import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/hazard_report.dart';
import 'package:flutter/material.dart';

class SupabaseService {
  final SupabaseClient? _client;

  SupabaseService() : _client = _getSupabaseClient();

  static SupabaseClient? _getSupabaseClient() {
    try {
      return Supabase.instance.client;
    } catch (e) {
      debugPrint('Supabase client not initialized: $e');
      throw Exception('Supabase client tidak tersedia');
    }
  }

  // Fungsi untuk memeriksa dan membuat tabel jika belum ada
  Future<bool> createTableIfNotExists() async {
    if (_client == null) {
      throw Exception('Supabase client tidak tersedia');
    }

    try {
      // Cek apakah tabel hazard_reports sudah ada
      final response =
          await _client!
              .from('hazard_reports')
              .select('id')
              .limit(1)
              .maybeSingle();

      // Jika berhasil query, berarti tabel sudah ada
      return true;
    } catch (e) {
      debugPrint('Error checking table: $e');
      return false; // Tabel tidak ditemukan atau error lainnya
    }
  }

  // Fungsi untuk mendapatkan semua laporan bahaya
  Future<List<HazardReport>> getHazardReports() async {
    if (_client == null) {
      throw Exception('Supabase client tidak tersedia');
    }

    try {
      final response = await _client!
          .from('hazard_reports')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => HazardReport.fromJson(item))
          .toList();
    } catch (e) {
      debugPrint('Error getting hazard reports: $e');
      throw Exception('Gagal mendapatkan data laporan dari Supabase: $e');
    }
  }

  // Fungsi untuk menyimpan laporan bahaya baru
  Future<HazardReport?> saveHazardReport(HazardReport report) async {
    if (_client == null) {
      throw Exception('Supabase client tidak tersedia');
    }

    try {
      final data = report.toJson();
      // Hapus id jika null
      if (data['id'] == null) {
        data.remove('id');
      }

      final response =
          await _client!.from('hazard_reports').insert(data).select().single();

      return HazardReport.fromJson(response);
    } catch (e) {
      debugPrint('Error saving hazard report: $e');
      throw Exception('Gagal menyimpan laporan ke Supabase: $e');
    }
  }

  // Fungsi untuk mengupdate laporan bahaya
  Future<HazardReport?> updateHazardReport(HazardReport report) async {
    if (_client == null || report.id == null) {
      throw Exception('Supabase client tidak tersedia atau ID laporan kosong');
    }

    try {
      final data = report.toJson();
      // Hapus id dari data yang akan diupdate
      data.remove('id');

      final response =
          await _client!
              .from('hazard_reports')
              .update(data)
              .eq('id', report.id!)
              .select()
              .single();

      return HazardReport.fromJson(response);
    } catch (e) {
      debugPrint('Error updating hazard report: $e');
      throw Exception('Gagal mengupdate laporan di Supabase: $e');
    }
  }

  // Fungsi untuk menghapus laporan bahaya
  Future<bool> deleteHazardReport(String id) async {
    if (_client == null) {
      throw Exception('Supabase client tidak tersedia');
    }

    try {
      await _client!.from('hazard_reports').delete().eq('id', id);
      return true;
    } catch (e) {
      debugPrint('Error deleting hazard report: $e');
      throw Exception('Gagal menghapus laporan dari Supabase: $e');
    }
  }

  // Membuat URL untuk upload gambar
  String getImageUploadUrl(String path) {
    if (_client == null) {
      throw Exception('Supabase client tidak tersedia');
    }

    // Membuat URL storage Supabase yang benar
    final url = _client!.storage.from('hazard-images').getPublicUrl(path);
    return url;
  }
}
