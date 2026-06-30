-- ==============================================================================
-- COMPLETE DATABASE RECONCILIATION MIGRATION
-- Synchronizes the Supabase database schema to strictly match the application
-- ==============================================================================

-- 1. `farms` Table Reconciliation
DO $$ 
BEGIN 
  -- Add area_acres
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='farms' AND column_name='area_acres') THEN
    ALTER TABLE farms ADD COLUMN area_acres NUMERIC;
    -- Optionally try to cast existing area data if it exists
    -- UPDATE farms SET area_acres = CAST(area AS NUMERIC) WHERE area IS NOT NULL AND area ~ '^[0-9\.]+$';
  END IF;

  -- Add soil_type
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='farms' AND column_name='soil_type') THEN
    ALTER TABLE farms ADD COLUMN soil_type TEXT;
  END IF;

  -- Add crop_type (and map from old crop column if needed, but application expects crop_type)
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='farms' AND column_name='crop_type') THEN
    ALTER TABLE farms ADD COLUMN crop_type TEXT;
    UPDATE farms SET crop_type = crop WHERE crop IS NOT NULL AND crop_type IS NULL;
  END IF;

  -- Add irrigation_type
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='farms' AND column_name='irrigation_type') THEN
    ALTER TABLE farms ADD COLUMN irrigation_type TEXT;
  END IF;

  -- Add water_source (map from old water column)
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='farms' AND column_name='water_source') THEN
    ALTER TABLE farms ADD COLUMN water_source TEXT;
    UPDATE farms SET water_source = water WHERE water IS NOT NULL AND water_source IS NULL;
  END IF;

  -- Add coordinates
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='farms' AND column_name='coordinates') THEN
    ALTER TABLE farms ADD COLUMN coordinates JSONB;
  END IF;

  -- Add images array
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='farms' AND column_name='images') THEN
    ALTER TABLE farms ADD COLUMN images TEXT[] DEFAULT '{}';
  END IF;
END $$;

-- 2. `posts` Table Reconciliation
DO $$ 
BEGIN 
  -- Ensure images array exists for posts
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='posts' AND column_name='images') THEN
    ALTER TABLE posts ADD COLUMN images TEXT[] DEFAULT '{}';
    -- Map old image_url to new array format if data exists
    UPDATE posts SET images = ARRAY[image_url] WHERE image_url IS NOT NULL;
  END IF;

  -- Ensure comments_count and likes_count exist (idempotent checks just in case)
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='posts' AND column_name='comments_count') THEN
    ALTER TABLE posts ADD COLUMN comments_count INTEGER DEFAULT 0;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='posts' AND column_name='likes_count') THEN
    ALTER TABLE posts ADD COLUMN likes_count INTEGER DEFAULT 0;
  END IF;
END $$;

-- 3. Storage Buckets Reconciliation
-- This creates any missing storage buckets used by the application
DO $$ 
DECLARE
    bucket_record record;
BEGIN
    -- List of required buckets and their public status
    -- format: (id, name, public)
    FOR bucket_record IN SELECT * FROM (VALUES
        ('avatars', 'avatars', true),
        ('disease-images', 'disease-images', true),
        ('farm-images', 'farm-images', true),
        ('community-images', 'community-images', true),
        ('product-images', 'product-images', true),
        ('tax-reports', 'tax-reports', false),
        ('learning-files', 'learning-files', false)
    ) AS b(id, name, is_public) 
    LOOP
        IF NOT EXISTS (SELECT 1 FROM storage.buckets WHERE id = bucket_record.id) THEN
            INSERT INTO storage.buckets (id, name, public) 
            VALUES (bucket_record.id, bucket_record.name, bucket_record.is_public);
        END IF;
    END LOOP;
END $$;

-- 4. Reload PostgREST schema cache
NOTIFY pgrst, 'reload schema';
