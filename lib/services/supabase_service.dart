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
      return null;
    }
  }

  // Fungsi untuk memeriksa dan membuat tabel jika belum ada
  Future<bool> createTableIfNotExists() async {
    if (_client == null) return false;

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
      return getDummyReports();
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
      return [];
    }
  }

  // Fungsi untuk menyimpan laporan bahaya baru
  Future<HazardReport?> saveHazardReport(HazardReport report) async {
    if (_client == null) {
      return report.copyWith(
        id: 'dummy-${DateTime.now().millisecondsSinceEpoch}',
      );
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
      return null;
    }
  }

  // Fungsi untuk mengupdate laporan bahaya
  Future<HazardReport?> updateHazardReport(HazardReport report) async {
    if (_client == null || report.id == null) return null;

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
      return null;
    }
  }

  // Fungsi untuk menghapus laporan bahaya
  Future<bool> deleteHazardReport(String id) async {
    if (_client == null) return false;

    try {
      await _client!.from('hazard_reports').delete().eq('id', id);
      return true;
    } catch (e) {
      debugPrint('Error deleting hazard report: $e');
      return false;
    }
  }

  // Membuat URL untuk upload gambar
  String getImageUploadUrl(String path) {
    if (_client == null) {
      return 'https://via.placeholder.com/150';
    }

    // Membuat URL storage Supabase yang benar
    final url = _client!.storage.from('hazard-images').getPublicUrl(path);
    return url;
  }

  // Fungsi untuk mendapatkan laporan dummy untuk mode demo
  List<HazardReport> getDummyReports() {
    return [
      HazardReport(
        id: 'dummy-1',
        reporterName: 'John Doe',
        reporterPosition: 'Safety Officer',
        location: 'Area Workshop',
        reportDate: DateTime.now().subtract(const Duration(days: 2)),
        hazardDescription:
            'Terdapat genangan oli di lantai workshop yang dapat menyebabkan tergelincir.',
        suggestedAction: 'Bersihkan genangan dan pasang tanda peringatan.',
        status: 'open',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      HazardReport(
        id: 'dummy-2',
        reporterName: 'Jane Smith',
        reporterPosition: 'Operator',
        location: 'Gudang B',
        reportDate: DateTime.now().subtract(const Duration(days: 5)),
        hazardDescription:
            'Instalasi kabel listrik terbuka dan dapat menyebabkan hubungan pendek.',
        suggestedAction:
            'Perbaiki instalasi kabel dan lakukan isolasi dengan benar.',
        status: 'in_progress',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      HazardReport(
        id: 'dummy-3',
        reporterName: 'Ahmad Riyadi',
        reporterPosition: 'Teknisi',
        location: 'Area Loading',
        reportDate: DateTime.now().subtract(const Duration(days: 10)),
        hazardDescription:
            'Tangga akses loading dock tidak memiliki pegangan yang menyebabkan risiko terjatuh.',
        suggestedAction:
            'Pasang railing di kedua sisi tangga sesuai standar K3.',
        status: 'completed',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];
  }
}
