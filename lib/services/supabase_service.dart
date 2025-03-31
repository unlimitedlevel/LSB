import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/hazard_report.dart';

class SupabaseService {
  final SupabaseClient? _client;

  SupabaseService() : _client = _getSupabaseClient();

  static SupabaseClient? _getSupabaseClient() {
    try {
      return Supabase.instance.client;
    } catch (e) {
      debugPrint('Error getting Supabase client: $e');
      return null;
    }
  }

  // Fungsi untuk memeriksa dan membuat tabel jika belum ada
  Future<bool> createTableIfNotExists() async {
    if (_client == null) {
      throw Exception('Supabase client tidak tersedia');
    }

    try {
      // Cek apakah tabel hazard_reports sudah ada
      await _client.from('hazard_reports').select('id').limit(1).maybeSingle();

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
      final response = await _client
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

  /// Menyimpan laporan hazard baru ke Supabase dan mengembalikan response
  Future<Map<String, dynamic>> saveHazardReport(HazardReport report) async {
    if (_client == null) {
      throw Exception('Supabase client tidak tersedia');
    }

    try {
      // Siapkan data untuk disimpan, konversi model ke JSON, tapi hapus field yang tidak ada di tabel
      final dataToSave = report.toJson();

      // Hapus field yang tidak ada di tabel hazard_reports
      dataToSave.remove('correction_detected');
      dataToSave.remove('correction_report');

      // Jika ada metadata, tambahkan informasi koreksi ke dalam metadata
      if (report.correctionDetected == true ||
          report.correctionReport != null) {
        if (dataToSave['metadata'] == null) {
          dataToSave['metadata'] = {};
        }

        dataToSave['metadata']['correction_detected'] =
            report.correctionDetected;
        if (report.correctionReport != null) {
          dataToSave['metadata']['correction_report'] = report.correctionReport;
        }
      }

      // Simpan ke Supabase
      final response =
          await _client
              .from('hazard_reports')
              .insert(dataToSave)
              .select()
              .single();

      debugPrint('Hazard report saved successfully: ${response['id']}');
      return response;
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
          await _client
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
      await _client.from('hazard_reports').delete().eq('id', id);
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
    final url = _client.storage.from('hazard-images').getPublicUrl(path);
    return url;
  }
}
