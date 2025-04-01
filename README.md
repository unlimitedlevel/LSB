# LSB OCR - Aplikasi Laporan Sumber Bahaya

Aplikasi untuk melakukan OCR (Optical Character Recognition) dan analisis otomatis terhadap form Laporan Sumber Bahaya (LSB) pada proyek konstruksi menggunakan Flutter dan AI dari Google Gemini.

## Fitur Utama

- 📷 **OCR Form LSB**: Scan dan ekstrak data otomatis dari form LSB fisik melalui foto
- 🤖 **AI Analysis**: Koreksi tata bahasa dan typo pada teks hasil OCR menggunakan Gemini 2.0
- 📊 **Dashboard Laporan**: Visualisasi status dan tren laporan bahaya
- 🗄️ **Database Terintegrasi**: Penyimpanan dan pengelolaan data menggunakan Supabase
- 📱 **Multi-platform**: Tersedia untuk Android, iOS, dan Web

## Persiapan Lingkungan Pengembangan

### Prasyarat

- Flutter SDK 3.7.0 atau lebih baru
- Dart 3.0.0 atau lebih baru
- Google API Key (untuk Gemini API)
- Supabase Account dan Project (untuk backend)

### Mendapatkan Kunci API

Hapus baris ini

### Konfigurasi Lingkungan

Hapus baris ini

### Instalasi

Hapus baris ini

## Struktur Basis Data

Aplikasi menggunakan Supabase dengan struktur database berikut:

```sql
-- Tabel utama
CREATE TABLE hazard_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE,
  
  -- Informasi Pelapor
  reporter_name TEXT NOT NULL,
  reporter_position TEXT NOT NULL,
  reporter_signature TEXT,
  
  -- Informasi LSB
  lsb_number TEXT,
  report_datetime TIMESTAMP WITH TIME ZONE NOT NULL,
  location TEXT NOT NULL,
  observation_type TEXT NOT NULL,
  hazard_description TEXT NOT NULL,
  suggested_action TEXT NOT NULL,
  
  -- Status dan Image
  status TEXT NOT NULL DEFAULT 'submitted',
  image_path TEXT,
  
  -- Field Validasi
  validated_by TEXT,
  validation_notes TEXT,
  validated_at TIMESTAMP WITH TIME ZONE,
  
  -- Field Tindak Lanjut
  follow_up TEXT,
  followed_up_by TEXT,
  followed_up_at TIMESTAMP WITH TIME ZONE,
  
  -- Field Penutupan Laporan
  closed_by TEXT,
  closing_notes TEXT,
  closed_at TIMESTAMP WITH TIME ZONE,
  
  -- Field Koreksi AI
  correction_detected BOOLEAN,
  correction_report TEXT,
  
  -- Metadata tambahan (JSON)
  metadata JSONB
);
```

## Penggunaan Gemini 2.0 API

Aplikasi ini menggunakan Google Gemini 2.0 Flash API untuk melakukan OCR dan analisis teks dari gambar form LSB. Model ini dapat mengekstrak informasi terstruktur dari gambar dan melakukan koreksi teks.

```dart
// Contoh penggunaan API Gemini 2.0
final targetUrl = 'https://generativelanguage.googleapis.com/v1/models/gemini-2.0-flash:generateContent?key=$apiKey';

// Request body
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
  // Configuration
  'generationConfig': {
    'temperature': 0.2,
    'topK': 32,
    'topP': 0.95,
    'maxOutputTokens': 2048,
  },
};
```

## Kontribusi

Kami sangat menghargai kontribusi! Silakan buat pull request atau laporkan issue untuk perbaikan atau penambahan fitur.

## Keamanan

- **JANGAN** commit file `.env` atau file yang berisi API keys ke repository
- File `.gitignore` sudah dikonfigurasi untuk mengabaikan file-file sensitif
- Gunakan environment variables untuk informasi rahasia pada deployment

## Lisensi

MIT License

## Kontak

Untuk pertanyaan atau bantuan, hubungi tim pengembang di: developer@example.com
