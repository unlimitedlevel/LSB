-- Buat tabel hazard_reports sesuai format FM-RLSB (Register LSB) R-0.1
CREATE TABLE IF NOT EXISTS hazard_reports (
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
  closed_at TIMESTAMP WITH TIME ZONE
);

-- Tambahkan index untuk mempercepat pencarian
CREATE INDEX IF NOT EXISTS idx_hazard_reports_status ON hazard_reports(status);
CREATE INDEX IF NOT EXISTS idx_hazard_reports_report_datetime ON hazard_reports(report_datetime);
CREATE INDEX IF NOT EXISTS idx_hazard_reports_lsb_number ON hazard_reports(lsb_number);

-- Enable Row Level Security (RLS)
ALTER TABLE hazard_reports ENABLE ROW LEVEL SECURITY;

-- Buat policy untuk akses
CREATE POLICY "Enable read access for all users" ON hazard_reports
  FOR SELECT USING (true);

CREATE POLICY "Enable insert for authenticated users" ON hazard_reports
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Enable update for authenticated users" ON hazard_reports
  FOR UPDATE USING (auth.role() = 'authenticated');

-- Setup untuk bucket storage
-- Catatan: Ini perlu dilakukan melalui interface Supabase atau API

-- Buat views untuk report dashboard sesuai format FM-RLSB
CREATE OR REPLACE VIEW lsb_register AS
SELECT 
  lsb_number,
  reporter_name,
  report_datetime,
  location,
  observation_type,
  hazard_description,
  suggested_action,
  status,
  follow_up,
  closed_at,
  created_at
FROM hazard_reports
ORDER BY report_datetime DESC; 