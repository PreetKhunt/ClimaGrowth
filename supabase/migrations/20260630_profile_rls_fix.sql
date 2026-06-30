-- Allow public to read profiles (needed for community post authors)
CREATE POLICY "Public profiles are viewable by everyone." ON profiles
FOR SELECT USING (true);

-- Make sure we don't duplicate policies if this script is re-run.
-- A safer approach in Postgres is to drop if exists and then create:
DO $$
BEGIN
    DROP POLICY IF EXISTS "Public profiles are viewable by everyone." ON profiles;
    CREATE POLICY "Public profiles are viewable by everyone." ON profiles FOR SELECT USING (true);
END $$;

NOTIFY pgrst, 'reload schema';
