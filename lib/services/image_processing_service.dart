import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/secure_keys.dart';

/// Service untuk memproses gambar dengan OCR dan analisis AI
class ImageProcessingService {
  static final ImageProcessingService _instance =
      ImageProcessingService._internal();
  final SecureKeys _secureKeys = SecureKeys();

  factory ImageProcessingService() {
    return _instance;
  }

  ImageProcessingService._internal();

  /// Memproses gambar menggunakan Gemini Vision API untuk ekstraksi data dan analisis
  Future<Map<String, dynamic>?> processWithGeminiVision(
    dynamic imageSource,
  ) async {
    try {
      final apiKey = await _secureKeys.getGeminiApiKey();

      // Jika tidak ada API key atau menggunakan demo mode
      if (apiKey == null || apiKey.isEmpty || apiKey == 'DEMO_KEY') {
        debugPrint('Using dummy data for Gemini Vision API');
        return _getDummyExtractionResults();
      }

      // Ubah gambar ke base64
      String base64Image = await _getBase64Image(imageSource);

      // Buat prompt untuk Gemini Vision API
      final prompt = '''
Ekstrak informasi berikut dari laporan bahaya/hazard report ini dengan format JSON:
- reporter_name: Nama pelapor
- reporter_position: Jabatan/posisi pelapor
- location: Lokasi bahaya
- report_date: Tanggal laporan (format YYYY-MM-DD)
- observation_type: Jenis pengamatan (pilih satu: "Unsafe Condition", "Unsafe Action", atau "Intervensi")
- hazard_description: Deskripsi bahaya
- suggested_action: Saran tindakan
- lsb_number: Nomor LSB jika ada

Juga lakukan analisis tata bahasa dan perbaiki typo pada teks yang diekstrak. Jika ada koreksi, tambahkan:
- metadata: { 
  "correction_detected": true/false,
  "correction_report": "daftar koreksi yang dilakukan"
}
''';

      // Panggil Gemini Vision API
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro-vision:generateContent?key=$apiKey',
      );

      final requestBody = {
        'contents': [
          {
            'parts': [
              {'text': prompt},
              {
                'inline_data': {'mime_type': 'image/jpeg', 'data': base64Image},
              },
            ],
          },
        ],
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final generatedContent =
            jsonResponse['candidates'][0]['content']['parts'][0]['text'];

        // Parse JSON dari respons teks
        try {
          // Cari awal dan akhir JSON dalam teks
          final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(generatedContent);
          if (jsonMatch != null) {
            final jsonStr = jsonMatch.group(0);
            final extractedData = jsonDecode(jsonStr!) as Map<String, dynamic>;
            return extractedData;
          }
        } catch (e) {
          debugPrint('Error parsing JSON from response: $e');
        }
      }

      debugPrint(
        'Failed to process image with Gemini Vision API: ${response.statusCode}',
      );
      return null;
    } catch (e) {
      debugPrint('Error processing image with Gemini Vision API: $e');
      return null;
    }
  }

  /// Mengubah gambar ke format base64
  Future<String> _getBase64Image(dynamic imageSource) async {
    try {
      if (imageSource is File) {
        final bytes = await imageSource.readAsBytes();
        return base64Encode(bytes);
      } else if (imageSource is Uint8List) {
        return base64Encode(imageSource);
      } else {
        throw Exception('Unsupported image source type');
      }
    } catch (e) {
      debugPrint('Error converting image to base64: $e');
      throw Exception('Failed to process image');
    }
  }

  /// Menghasilkan data dummy untuk keperluan demo
  Map<String, dynamic> _getDummyExtractionResults() {
    return {
      'reporter_name': 'Ahmad Supriadi',
      'reporter_position': 'Safety Officer',
      'location': 'Area Produksi Lantai 2',
      'report_date': DateTime.now().toString().substring(0, 10),
      'observation_type': 'Unsafe Condition',
      'hazard_description':
          'Terdapat tumpahan oli di area kerja yang dapat menyebabkan pekerja terpeleset.',
      'suggested_action':
          'Segera bersihkan tumpahan dan pasang tanda peringatan area licin.',
      'lsb_number': 'LSB-2025-0042',
      'metadata': {
        'correction_detected': true,
        'correction_report':
            '- "tumpahan" dikoreksi dari "tumpehan"\n- "terpeleset" dikoreksi dari "terpelset"',
      },
    };
  }
}
