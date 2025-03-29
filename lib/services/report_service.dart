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
      return result;
    } catch (e) {
      debugPrint('Error processing image: $e');
      return null;
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
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro-vision:generateContent?key=$apiKey',
    );

    // Prompt instruksi untuk Gemini
    const prompt = '''
    Analisis gambar ini dan ekstrak informasi dari formulir laporan LSB (Laporan Sumber Bahaya).
    Berikan jawaban dalam format JSON dengan fields berikut:
    - reporter_name: Nama pelapor
    - reporter_position: Jabatan pelapor
    - location: Lokasi bahaya
    - report_date: Tanggal laporan (format YYYY-MM-DD)
    - hazard_description: Deskripsi bahaya
    - suggested_action: Saran tindakan

    Jika Anda menemukan kesalahan ketik atau tata bahasa dalam teks, perbaiki sesuai konteks.
    Lakukan analisis tata bahasa dan perbaikan typo pada semua field.
    Jika ada kata yang salah tulis tapi masih bisa dikenali, perbaiki.
    
    Pastikan tanggal dalam format yang benar (YYYY-MM-DD). Jika formatnya tidak sesuai, konversi ke format yang benar.
    
    Kembalikan juga informasi tentang koreksi typo yang signifikan dalam field "correction_report".
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
        throw Exception('Error dari Gemini API: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error memproses gambar dengan Gemini: $e');
      return null;
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
      metadata['correction_report'] = extractedData['correction_report'];
      metadata['correction_detected'] = true;
    }

    // Tambahkan teks asli jika tersedia
    if (originalText != null) {
      metadata['original_text'] = originalText;
    }

    return metadata;
  }
}
