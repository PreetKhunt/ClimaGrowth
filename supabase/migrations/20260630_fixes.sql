-- 20260630_fixes.sql
-- Missing Buckets
INSERT INTO storage.buckets (id, name, public) 
VALUES 
  ('farm-images', 'farm-images', true),
  ('avatars', 'avatars', true),
  ('product-images', 'product-images', true),
  ('community-media', 'community-media', true)
ON CONFLICT (id) DO NOTHING;

-- Missing columns from profiles
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id);

-- Ensure farms has area_acres
ALTER TABLE farms ADD COLUMN IF NOT EXISTS area_acres NUMERIC;

-- Missing RLS Policies for Storage
CREATE POLICY "Public Access" ON storage.objects FOR SELECT USING (bucket_id IN ('disease-images', 'farm-images', 'avatars', 'product-images', 'community-media', 'community-images'));
CREATE POLICY "Authenticated users can upload" ON storage.objects FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Users can update own files" ON storage.objects FOR UPDATE USING (auth.uid() = owner);
CREATE POLICY "Users can delete own files" ON storage.objects FOR DELETE USING (auth.uid() = owner);
ALTER TABLE farms ADD COLUMN IF NOT EXISTS coordinates JSONB;
