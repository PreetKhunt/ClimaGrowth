-- 20260630_final_schema_fixes.sql

-- 1. Create missing Storage Buckets
INSERT INTO storage.buckets (id, name, public) 
VALUES 
  ('disease-images', 'disease-images', true),
  ('farm-images', 'farm-images', true),
  ('community-images', 'community-images', true),
  ('avatars', 'avatars', true),
  ('product-images', 'product-images', true),
  ('tax-reports', 'tax-reports', false),
  ('learning-files', 'learning-files', false)
ON CONFLICT (id) DO UPDATE SET public = EXCLUDED.public;

-- 2. Storage RLS Policies
-- Public read access for images
CREATE POLICY "Public Read Image Buckets" 
ON storage.objects FOR SELECT 
USING (bucket_id IN ('disease-images', 'farm-images', 'community-images', 'avatars', 'product-images'));

-- Private read access for tax reports
CREATE POLICY "Private Read Tax Reports" 
ON storage.objects FOR SELECT 
USING (bucket_id = 'tax-reports' AND auth.uid() = owner);

-- Authenticated upload access
CREATE POLICY "Auth Upload" 
ON storage.objects FOR INSERT 
WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Auth Update" 
ON storage.objects FOR UPDATE 
USING (auth.uid() = owner);

CREATE POLICY "Auth Delete" 
ON storage.objects FOR DELETE 
USING (auth.uid() = owner);

-- 3. Ensure Columns Exist (Backward Compatible)
DO $$
BEGIN
    -- farms
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='farms' AND column_name='user_id') THEN
        ALTER TABLE farms ADD COLUMN user_id UUID REFERENCES auth.users(id);
    END IF;

    -- posts
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='posts' AND column_name='comments_count') THEN
        ALTER TABLE posts ADD COLUMN comments_count INTEGER DEFAULT 0;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='posts' AND column_name='likes_count') THEN
        ALTER TABLE posts ADD COLUMN likes_count INTEGER DEFAULT 0;
    END IF;

    -- profiles
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='profiles' AND column_name='user_id') THEN
        ALTER TABLE profiles ADD COLUMN user_id UUID REFERENCES auth.users(id);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='profiles' AND column_name='avatar_url') THEN
        ALTER TABLE profiles ADD COLUMN avatar_url TEXT;
    END IF;
END $$;

-- 4. Reload PostgREST Schema Cache
-- This is critical so the API recognizes the columns
NOTIFY pgrst, 'reload schema';
