const { Client } = require('pg');
async function run() {
  const client = new Client({
    connectionString: 'postgresql://postgres.lwhvtrmcevzayljxxanx:P1r2e3e4t5!@aws-1-ap-northeast-1.pooler.supabase.com:5432/postgres',
    ssl: { rejectUnauthorized: false }
  });
  await client.connect();
  
  const sql = `
    -- Enable RLS
    ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

    -- Drop existing policies if any
    DROP POLICY IF EXISTS "Users can view their own profile" ON profiles;
    DROP POLICY IF EXISTS "Users can update their own profile" ON profiles;
    DROP POLICY IF EXISTS "Users can insert their own profile" ON profiles;
    DROP POLICY IF EXISTS "Admins can do everything" ON profiles;

    -- Policy: Users can view their own profile
    CREATE POLICY "Users can view their own profile" 
    ON profiles FOR SELECT 
    USING (auth.uid() = user_id OR auth.uid() = id);

    -- Policy: Users can update their own profile
    CREATE POLICY "Users can update their own profile" 
    ON profiles FOR UPDATE 
    USING (auth.uid() = user_id OR auth.uid() = id);

    -- Policy: Users can insert their own profile
    CREATE POLICY "Users can insert their own profile" 
    ON profiles FOR INSERT 
    WITH CHECK (auth.uid() = user_id OR auth.uid() = id);

    -- Policy: Admin bypass
    CREATE POLICY "Admins can do everything"
    ON profiles FOR ALL
    USING (
      EXISTS (
        SELECT 1 FROM profiles 
        WHERE (user_id = auth.uid() OR id = auth.uid()) 
        AND role = 'Admin'
      )
    );
  `;
  
  await client.query(sql);
  console.log("RLS policies applied to profiles");
  
  await client.end();
}
run().catch(console.error);
