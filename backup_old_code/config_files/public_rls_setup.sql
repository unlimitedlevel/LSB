-- Mengaktifkan Row Level Security untuk tabel hazard_reports
ALTER TABLE hazard_reports ENABLE ROW LEVEL SECURITY;

-- Hapus policy yang mungkin sudah ada untuk menghindari konflik
DROP POLICY IF EXISTS "Allow anonymous select" ON hazard_reports;
DROP POLICY IF EXISTS "Allow anonymous insert" ON hazard_reports;
DROP POLICY IF EXISTS "Allow anonymous update" ON hazard_reports;
DROP POLICY IF EXISTS "Enable access for all users" ON hazard_reports;

-- Policy untuk mengizinkan operasi SELECT tanpa autentikasi
CREATE POLICY "Allow anonymous select" ON hazard_reports
    FOR SELECT USING (true);

-- Policy untuk mengizinkan operasi INSERT tanpa autentikasi
CREATE POLICY "Allow anonymous insert" ON hazard_reports
    FOR INSERT WITH CHECK (true);

-- Policy untuk mengizinkan operasi UPDATE tanpa autentikasi
CREATE POLICY "Allow anonymous update" ON hazard_reports
    FOR UPDATE USING (true);

-- Storage Bucket policies
-- Catatan: Jalankan ini melalui SQL Editor jika mengalami masalah membuat policies melalui UI

-- Pastikan bucket hazard-images sudah dibuat terlebih dahulu melalui UI
-- Kemudian jalankan query ini untuk storage policies

-- Policy untuk mengizinkan akses publik untuk melihat file
CREATE POLICY "Allow public access" ON storage.objects
    FOR SELECT USING (bucket_id = 'hazard-images');

-- Policy untuk mengizinkan upload file tanpa autentikasi
CREATE POLICY "Allow anonymous uploads" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'hazard-images');

-- Policy untuk mengizinkan update file tanpa autentikasi
CREATE POLICY "Allow anonymous updates" ON storage.objects
    FOR UPDATE USING (bucket_id = 'hazard-images');

-- GRANT untuk akses publik ke REST API
GRANT USAGE ON SCHEMA public TO anon;
GRANT SELECT, INSERT, UPDATE ON public.hazard_reports TO anon;
GRANT SELECT, INSERT, UPDATE ON storage.objects TO anon; 