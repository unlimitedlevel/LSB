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

Aplikasi ini menggunakan arsitektur modular dengan komponen-komponen yang telah direfaktor untuk modularitas yang lebih baik:

- **screens/**: Berisi halaman utama aplikasi
  - `home_screen.dart`: Halaman beranda yang menampilkan daftar laporan
  - `report_form_screen.dart`: Form untuk membuat laporan baru
  - `report_detail_screen.dart`: Halaman detail laporan
  - `success_screen.dart`: Halaman konfirmasi setelah laporan berhasil dikirim

- **widgets/**: Komponen UI yang dapat digunakan kembali
  - `image_picker_widget.dart`: Widget untuk memilih dan menampilkan gambar
  - `report_form_widget.dart`: Widget form untuk laporan
  - `report_detail_widgets.dart`: Widget-widget untuk halaman detail
  - `system_info_section.dart`: Widget untuk menampilkan informasi sistem
  - `gradient_card.dart`: Card dengan latar gradient
  - `user_header.dart`: Header dengan informasi pengguna

- **models/**: Model data aplikasi
  - `hazard_report.dart`: Model untuk laporan bahaya

- **services/**: Layanan dan logika bisnis
  - `supabase_service.dart`: Menangani komunikasi dengan Supabase
  - `report_service.dart`: Menangani pemrosesan laporan
  - `image_processing_service.dart`: Khusus menangani pemrosesan gambar dan OCR
  - `secure_api_bridge.dart`: Mengelola kunci API secara aman

- **utils/**: Fungsi-fungsi utilitas
  - `form_correction_utils.dart`: Utilitas untuk menangani koreksi form

- **config/**: Konfigurasi aplikasi
  - `app_theme.dart`: Tema dan gaya aplikasi
  - `supabase_config.dart`: Konfigurasi Supabase
  - `secure_keys.dart`: Menyimpan kunci API dengan aman

## Pengembangan Terbaru

- Refactoring kode untuk modularitas yang lebih baik dan pemeliharaan yang lebih mudah
- Pemisahan komponen UI menjadi widget yang dapat digunakan kembali
- Optimalisasi layanan dengan pemisahan tanggung jawab yang lebih jelas
- Penambahan dukungan nomor LSB pada formulir dan laporan
- Perbaikan tampilan kartu laporan di halaman beranda
- Penambahan halaman detail laporan yang komprehensif
- Implementasi refresh otomatis untuk memastikan data selalu terbaru
- Integrasi yang lebih baik dengan Supabase
- Peningkatan prompt Gemini API untuk ekstraksi data yang lebih akurat
- Perbaikan UI/UX secara keseluruhan

## Cara Menggunakan

1. Pastikan Anda telah mengatur file `.env` dengan kunci API yang benar:
   ```
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_anon_key
   SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
   GOOGLE_VISION_API_KEY=your_google_vision_api_key
   GEMINI_API_KEY=your_gemini_api_key
   ```

2. Jalankan `flutter pub get` untuk mengunduh semua dependensi
3. Jalankan aplikasi dengan `flutter run`

## Dependensi Utama

- Flutter SDK
- Supabase Flutter
- Image Picker
- Intl
- HTTP
- Flutter Dotenv
- UUID

## Pemeliharaan

Aplikasi ini dirancang dengan arsitektur yang modular sehingga:
- Penambahan fitur baru dapat dilakukan dengan mudah
- Komponen dapat diuji secara terpisah
- Perbaikan bug dapat dilakukan tanpa mempengaruhi bagian lain
- Refactoring dapat dilakukan secara bertahap
