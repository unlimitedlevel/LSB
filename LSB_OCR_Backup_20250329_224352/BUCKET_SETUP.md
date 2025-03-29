# Panduan Setup Storage Bucket dan Policy RLS di Supabase

## 1. Membuat Storage Bucket

1. Buka dashboard Supabase Anda di https://app.supabase.com
2. Pilih project "zuqrzeuavfpawxpvcuhg"
3. Pada sidebar, klik "Storage"
4. Klik "Create a new bucket"
5. Masukkan nama bucket: `hazard-images`
6. Aktifkan opsi "Public bucket" (untuk memudahkan akses publik ke gambar)
7. Klik "Create bucket"

## 2. Mengatur RLS Policy untuk Storage

Setelah bucket dibuat:

1. Klik bucket `hazard-images` yang baru dibuat
2. Pada tab "Policies", klik "New Policy"
3. Pilih template "Create a policy from scratch"
4. Isi formulir policy:
   - Policy name: `Allow public access`
   - Allowed operations: SELECT (untuk read access)
   - Policy definition: `true` (akses publik untuk membaca)
5. Klik "Save policy"

6. Buat policy baru lagi untuk INSERT:
   - Policy name: `Allow anonymous uploads`
   - Allowed operations: INSERT (untuk upload)
   - Policy definition: `true` (akses publik untuk upload)
7. Klik "Save policy"

## 3. Mengatur RLS Policy untuk Tabel hazard_reports

1. Pada sidebar, klik "Table Editor"
2. Klik tabel `hazard_reports`
3. Klik tab "Policies"
4. Klik "New Policy"
5. Pilih template "Create a policy from scratch"
6. Isi formulir policy:
   - Policy name: `Allow anonymous select`
   - Allowed operations: SELECT
   - Policy definition: `true`
7. Klik "Save policy"

8. Buat policy baru lagi untuk INSERT:
   - Policy name: `Allow anonymous insert`
   - Allowed operations: INSERT
   - Policy definition: `true`
9. Klik "Save policy"

10. Buat policy baru lagi untuk UPDATE:
    - Policy name: `Allow anonymous update`
    - Allowed operations: UPDATE
    - Policy definition: `true`
11. Klik "Save policy"

## 4. Mengaktifkan Akses Publik untuk Aplikasi

Karena aplikasi LSB OCR dirancang untuk digunakan tanpa otentikasi pengguna, kita perlu memastikan bahwa Row Level Security (RLS) yang dikonfigurasi memungkinkan akses publik.

1. Pada sidebar, klik "Authentication"
2. Klik tab "Policies"
3. Pastikan "Enable Row Level Security (RLS)" diaktifkan untuk tabel hazard_reports
4. Pastikan RLS policy yang Anda buat menggunakan kondisi `true` untuk mengizinkan akses publik
5. Jika diperlukan, Anda juga dapat menambahkan policy khusus:
   ```sql
   CREATE POLICY "Enable access for all users" ON hazard_reports
   USING (true)
   WITH CHECK (true);
   ```

## 5. Testing Setup

Setelah semua policy diatur, jalankan aplikasi dan lakukan testing:

1. Upload gambar: Pastikan bucket hazard-images ada dan policy INSERT diaktifkan
2. Simpan laporan: Pastikan tabel hazard_reports memiliki policy INSERT yang diaktifkan
3. Lihat laporan: Pastikan tabel hazard_reports memiliki policy SELECT yang diaktifkan

## Catatan Keamanan

Policy yang diatur di atas adalah untuk pengujian dan pengembangan. Untuk lingkungan produksi, sebaiknya terapkan kontrol akses yang lebih ketat. Jika memerlukan autentikasi di masa mendatang, Anda dapat menggunakan metode lain seperti:

1. Email/Password authentication
2. Magic Link
3. Social providers (Google, Facebook, dll.)
4. Phone authentication

Untuk mengaktifkan metode otentikasi ini, kunjungi bagian "Authentication" > "Providers" di dashboard Supabase. 