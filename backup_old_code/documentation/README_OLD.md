# Aplikasi Laporan Sumber Bahaya (LSB) Otomatis

Aplikasi mobile berbasis Flutter untuk mempermudah pelaporan sumber bahaya di lapangan menggunakan teknologi OCR dan AI.

## Fitur Utama

- Mengambil foto formulir Laporan Sumber Bahaya (LSB) yang ditulis tangan
- Mengekstrak teks dari gambar menggunakan Google Cloud Vision OCR
- Menggunakan AI (Google Gemini API) untuk menginterpretasi dan strukturisasi hasil OCR
- Menyimpan data terstruktur ke database Supabase
- Manajemen dan pelacakan laporan sumber bahaya
- Mode demo saat Supabase tidak dikonfigurasi

## Persyaratan

- Flutter 3.7.0 atau lebih tinggi
- Dart 3.0.0 atau lebih tinggi
- Akun Supabase
- Akun Google Cloud Platform dengan API Vision dan Gemini diaktifkan

## Persiapan

1. Clone repository:
```bash
git clone <repository-url>
cd lsb_ocr
```

2. Install dependencies:
```bash
flutter pub get
```

3. Setup konfigurasi:
   - Salin file `.env.example` menjadi `.env`
   - Isi dengan kredensial Anda:
   ```
   # Supabase Configuration
   SUPABASE_URL=YOUR_SUPABASE_URL
   SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
   SUPABASE_SERVICE_ROLE_KEY=YOUR_SUPABASE_SERVICE_ROLE_KEY

   # Supabase Function
   SUPABASE_FUNCTION_NAME=process-hazard-report

   # Google Cloud Configuration
   GOOGLE_CLOUD_PROJECT_ID=YOUR_GOOGLE_CLOUD_PROJECT_ID
   GOOGLE_VISION_API_KEY=YOUR_GOOGLE_VISION_API_KEY
   GOOGLE_GEMINI_API_KEY=YOUR_GOOGLE_GEMINI_API_KEY
   ```

4. Setup Supabase:
   - Buat project baru di Supabase
   - Tabel `hazard_reports` akan dibuat otomatis saat aplikasi dijalankan
   - Setup storage bucket `hazard-images` untuk menyimpan gambar
   - Deploy Edge Function `process-hazard-report` (kode tersedia di folder `supabase/functions/`)

## Keamanan API Key

> **PENTING**: File `.env` berisi API key dan kredensial sensitif. JANGAN PERNAH commit file ini ke repository!

Untuk mengamankan API key dan kredensial dalam deployment:

### Pengembangan Lokal
- File `.env` sudah ditambahkan ke `.gitignore` untuk mencegah commit secara tidak sengaja
- Gunakan `.env.example` sebagai template
- Jangan pernah membagikan kredensial pribadi di kode atau repository publik

### Deployment Mobile (Android/iOS)
- Untuk aplikasi rilis, gunakan environment variables yang dikonfigurasi dalam build:
  - Android: Konfigurasi di `build.gradle` dengan ProGuard
  - iOS: Konfigurasi di Xcode dengan Info.plist encryption

### Deployment Web
- Saat deploy ke hosting, gunakan environment variables dari platform:
  - Firebase Hosting: Konfigurasi di Firebase Console
  - Vercel/Netlify: Konfigurasi di dashboard platform
- Hindari menambahkan API key langsung ke bundled JavaScript

### Batasi API Key dengan Restriction
1. Google Cloud API:
   - Batasi API key hanya untuk layanan yang Anda gunakan (Vision API, Gemini API)
   - Tambahkan batasan aplikasi/domain/IP
   - Tetapkan quota limit untuk mencegah penggunaan berlebihan

2. Supabase:
   - Gunakan Row Level Security (RLS) untuk kontrol akses
   - Jangan gunakan service_role_key di aplikasi klien, hanya gunakan di server

## Mode Demo

Aplikasi ini memiliki mode demo yang akan aktif secara otomatis jika:
- File `.env` tidak ditemukan atau tidak berisi kredensial Supabase yang valid
- Koneksi ke Supabase gagal

Dalam mode demo, semua data akan disimpan secara lokal dan tidak akan dikirim ke server.

## Menjalankan Aplikasi

```bash
flutter run
```

## Struktur Aplikasi

- `lib/models/` - Model data seperti `HazardReport`
- `lib/screens/` - Widget untuk setiap layar/halaman (Home, Report Form, Success)
- `lib/services/` - Logika bisnis & interaksi API (SupabaseService, ReportService)
- `lib/widgets/` - Widget UI yang reusable seperti ImageInput
- `lib/config/` - Konfigurasi Supabase
- `assets/` - Asset seperti gambar

## Fitur OCR dan AI

Aplikasi ini dapat menggunakan OCR (Optical Character Recognition) dan AI untuk secara otomatis mengekstrak data dari formulir LSB yang difoto. Fitur ini memerlukan:

1. Supabase Edge Function yang aktif
2. Kredensial Google Cloud yang valid
3. API Gemini yang diaktifkan untuk analisis konten

## Troubleshooting

- **Tabel tidak terbuat**: Tabel akan dibuat otomatis saat aplikasi dijalankan jika Anda memiliki kredenesial Supabase yang valid
- **Error saat upload gambar**: Pastikan bucket `hazard-images` sudah dibuat di Supabase Storage
- **OCR tidak berfungsi**: Pastikan Edge Function sudah di-deploy dengan benar

## Kontribusi

Silakan berkontribusi dengan mengirimkan Pull Request atau membuka Issue.

## Lisensi

Copyright (c) 2025 - LSB OCR Team
