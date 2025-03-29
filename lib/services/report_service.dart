import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/supabase_config.dart';
import '../models/hazard_report.dart';

/// Service untuk memproses laporan bahaya
/// Termasuk OCR dan analisis dengan AI
class ReportService {
  // Instance Singleton
  static final ReportService _instance = ReportService._internal();
  factory ReportService() => _instance;
  ReportService._internal();

  /// Memproses gambar dan mengekstrak data dengan OCR dan AI
  Future<Map<String, dynamic>?> processImage(dynamic imageSource) async {
    try {
      // Convert image to base64
      String base64Image;

      if (imageSource is File) {
        final bytes = await imageSource.readAsBytes();
        base64Image = base64Encode(bytes);
      } else if (imageSource is Uint8List) {
        base64Image = base64Encode(imageSource);
      } else {
        throw Exception('Format gambar tidak didukung');
      }

      // Proses dengan Gemini Vision API
      final result = await _processWithGeminiVision(base64Image);

      if (result == null) {
        debugPrint('Gagal memproses gambar dengan Gemini API');
        throw Exception('Gagal memproses gambar');
      }

      return result;
    } catch (e) {
      debugPrint('Error processing image: $e');
      rethrow;
    }
  }

  /// Memproses gambar dengan Gemini Vision API
  Future<Map<String, dynamic>?> _processWithGeminiVision(
    String base64Image,
  ) async {
    final apiKey = SupabaseConfig.geminiApiKey;
    if (apiKey.isEmpty) {
      throw Exception('Gemini API key tidak tersedia');
    }

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey',
    );

    // Prompt instruksi untuk Gemini
    const prompt = '''
    Analisis gambar ini dan ekstrak informasi dari formulir laporan LSB (Laporan Sumber Bahaya).
    Berikan jawaban dalam format JSON dengan fields berikut:
    - lsb_number: Nomor LSB (biasanya tertulis di bagian atas formulir dengan format seperti "001-lsb-xxx")
    - reporter_name: Nama pelapor
    - reporter_position: Jabatan pelapor
    - location: Lokasi bahaya
    - report_date: Tanggal laporan (format YYYY-MM-DD)
    - observation_type: Jenis pengamatan (pilih salah satu dari: "Unsafe Condition", "Unsafe Action", atau "Intervensi")
    - hazard_description: Deskripsi bahaya
    - suggested_action: Saran tindakan

    Jika Anda menemukan kesalahan ketik atau tata bahasa dalam teks, perbaiki sesuai konteks.
    Lakukan analisis tata bahasa dan perbaikan typo pada semua field.
    Jika ada kata yang salah tulis tapi masih bisa dikenali, perbaiki.
    
    Perhatikan apakah ada nomor LSB di formulir. Biasanya tertulis "No. LSB:" diikuti nomor seperti "001-lsb-los04".
    Jika tidak ada, biarkan field lsb_number kosong.
    
    Untuk field observation_type, perhatikan apakah ada kotak yang dicentang (√ atau v) pada form.
    Biasanya di form tertulis "JENIS PENGAMATAN" dengan pilihan "Unsafe Condition", "Unsafe Action", atau "Intervensi".
    Pilih salah satu yang dicentang atau "Unsafe Condition" jika tidak ada yang tercentang atau tidak bisa menentukan.
    
    Pastikan tanggal dalam format yang benar (YYYY-MM-DD). Jika formatnya tidak sesuai, konversi ke format yang benar.
    
    Kembalikan juga informasi tentang koreksi typo yang signifikan dalam field "correction_report" sebagai string.
    ''';

    final payload = {
      "contents": [
        {
          "parts": [
            {"text": prompt},
            {
              "inline_data": {"mime_type": "image/jpeg", "data": base64Image},
            },
          ],
        },
      ],
      "generationConfig": {
        "temperature": 0.1,
        "topP": 0.9,
        "maxOutputTokens": 2048,
      },
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final text = result['candidates'][0]['content']['parts'][0]['text'];

        // Ekstrak JSON dari respons teks
        final jsonStart = text.indexOf('{');
        final jsonEnd = text.lastIndexOf('}') + 1;

        if (jsonStart >= 0 && jsonEnd > jsonStart) {
          final jsonStr = text.substring(jsonStart, jsonEnd);
          final data = jsonDecode(jsonStr);

          // Log koreksi typo jika ada
          if (data.containsKey('correction_report')) {
            // Konversi correction_report menjadi string jika bukan string
            if (data['correction_report'] is! String) {
              data['correction_report'] = data['correction_report'].toString();
            }

            debugPrint('Koreksi typo terdeteksi: ${data['correction_report']}');

            // Tambahkan flag ke metadata jika ada koreksi signifikan
            data['metadata'] = {
              'correction_detected': true,
              'correction_report': data['correction_report'],
            };
          }

          return data;
        } else {
          throw Exception('Format JSON tidak ditemukan dalam respons');
        }
      } else {
        debugPrint(
          'Error dari Gemini API: ${response.statusCode}, ${response.body}',
        );
        throw Exception('Error dari Gemini API: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error memproses gambar dengan Gemini: $e');
      rethrow;
    }
  }

  /// Membangun metadata laporan berdasarkan hasil ekstraksi dan koreksi
  Map<String, dynamic> buildReportMetadata({
    required Map<String, dynamic> extractedData,
    String? originalText,
  }) {
    final metadata = <String, dynamic>{
      'extracted_timestamp': DateTime.now().toIso8601String(),
      'extraction_source': 'gemini_vision',
    };

    // Tambahkan informasi koreksi jika ada
    if (extractedData.containsKey('correction_report')) {
      // Pastikan correction_report adalah string
      final corrReport = extractedData['correction_report'];
      metadata['correction_report'] =
          corrReport is String ? corrReport : corrReport.toString();
      metadata['correction_detected'] = true;
    } else if (extractedData['metadata'] != null &&
        extractedData['metadata']['correction_report'] != null) {
      final corrReport = extractedData['metadata']['correction_report'];
      metadata['correction_report'] =
          corrReport is String ? corrReport : corrReport.toString();
      metadata['correction_detected'] =
          extractedData['metadata']['correction_detected'] ?? false;
    }

    // Tambahkan teks asli jika tersedia
    if (originalText != null) {
      metadata['original_text'] = originalText;
    }

    return metadata;
  }
}
