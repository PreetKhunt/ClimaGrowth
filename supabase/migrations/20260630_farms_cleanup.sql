-- 1. Migrate existing 'area' values to 'area_acres' if valid numbers
UPDATE farms 
SET area_acres = CAST(NULLIF(regexp_replace(area, '[^0-9\.]', '', 'g'), '') AS NUMERIC)
WHERE area IS NOT NULL AND area_acres IS NULL;

-- 2. Migrate existing 'crop' to 'crop_type'
UPDATE farms
SET crop_type = crop
WHERE crop IS NOT NULL AND crop_type IS NULL;

-- 3. Migrate existing 'water' to 'water_source'
UPDATE farms
SET water_source = water
WHERE water IS NOT NULL AND water_source IS NULL;

-- 4. Migrate 'lat' and 'lng' to 'coordinates' jsonb
UPDATE farms
SET coordinates = jsonb_build_object(
    'lat', CAST(NULLIF(regexp_replace(lat, '[^0-9\.\-]', '', 'g'), '') AS FLOAT), 
    'lng', CAST(NULLIF(regexp_replace(lng, '[^0-9\.\-]', '', 'g'), '') AS FLOAT)
)
WHERE lat IS NOT NULL AND lng IS NOT NULL AND coordinates IS NULL;

-- 5. Drop legacy columns to enforce single source of truth and remove NOT NULL constraints
ALTER TABLE farms
DROP COLUMN IF EXISTS area,
DROP COLUMN IF EXISTS crop,
DROP COLUMN IF EXISTS water,
DROP COLUMN IF EXISTS lat,
DROP COLUMN IF EXISTS lng;

-- Reload schema
NOTIFY pgrst, 'reload schema';
