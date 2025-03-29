# LSB OCR - Aplikasi Laporan Sumber Bahaya dengan OCR

Aplikasi ini dirancang untuk memudahkan pengguna dalam membuat laporan sumber bahaya menggunakan teknologi Optical Character Recognition (OCR) dan analisis AI dengan Gemini Vision API.

## Fitur Utama

- **OCR dan Analisis AI**: Otomatis mengekstrak data dari formulir laporan dan melakukan analisis tata bahasa
- **Koreksi Typo Otomatis**: Memperbaiki kesalahan ketik pada teks yang diekstrak dari gambar
- **Integrasi Supabase**: Penyimpanan data yang aman dan realtime
- **Nomor LSB**: Mendukung penggunaan nomor LSB untuk pelacakan laporan
- **Jenis Pengamatan**: Mendukung kategori "Unsafe Condition", "Unsafe Action", dan "Intervensi"
- **Status Laporan**: Melacak status laporan (Submitted, Validated, In Progress, Completed)
- **Upload Gambar**: Mendukung upload gambar dari galeri atau kamera

## Struktur Aplikasi

Aplikasi ini menggunakan struktur modular dengan komponen-komponen berikut:

- **screens/**: Berisi halaman utama aplikasi
  - `home_screen.dart`: Halaman beranda yang menampilkan daftar laporan
  - `report_form_screen.dart`: Form untuk membuat laporan baru
  - `report_detail_screen.dart`: Halaman detail laporan
  - `success_screen.dart`: Halaman konfirmasi setelah laporan berhasil dikirim

- **models/**: Model data aplikasi
  - `hazard_report.dart`: Model untuk laporan bahaya

- **services/**: Layanan dan logika bisnis
  - `supabase_service.dart`: Menangani komunikasi dengan Supabase
  - `report_service.dart`: Menangani pemrosesan laporan dan OCR
  - `secure_api_bridge.dart`: Mengelola kunci API secara aman

- **config/**: Konfigurasi aplikasi
  - `app_theme.dart`: Tema dan gaya aplikasi
  - `supabase_config.dart`: Konfigurasi Supabase
  - `secure_keys.dart`: Menyimpan kunci API dengan aman

## Pengembangan Terbaru

- Penambahan dukungan nomor LSB pada formulir dan laporan
- Perbaikan tampilan kartu laporan di halaman beranda
- Penambahan halaman detail laporan yang komprehensif
- Implementasi refresh otomatis untuk memastikan data selalu terbaru
- Integrasi yang lebih baik dengan Supabase
- Peningkatan prompt Gemini API untuk ekstraksi data yang lebih akurat
- Perbaikan UI/UX secara keseluruhan

## Cara Menggunakan

1. Pastikan Anda telah mengatur file `.env` dengan kunci API yang benar
2. Jalankan `flutter pub get` untuk mengunduh semua dependensi
3. Jalankan aplikasi dengan `flutter run`

## Dependensi Utama

- Flutter SDK
- Supabase Flutter
- Image Picker
- Intl
- HTTP
- Flutter Dotenv
